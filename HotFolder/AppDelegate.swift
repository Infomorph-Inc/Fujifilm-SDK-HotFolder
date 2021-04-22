//
//  AppDelegate.swift
//  HotFolder
//
// Copyright 2021 Infomorph, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var cameraNameMenuItem: NSMenuItem!
    var timer = Timer()
    let xapi = XAPI()
    var savedDateTimeFolder:URL?=nil
    var cameraHandle:XSDK_HANDLE?=nil
    let DefaultFolder = "DefaultFolder"

    func checkXSDKError(nsError:NSError){
        if(nsError.code==XSDK_ERROR){
            var lAPICode:Int = 0
            var lERRCode:Int = 0
            xapi.xsdk_GetErrorNumber(nil,plAPICode: &lAPICode,plERRCode: &lERRCode)
            NSLog("xsdk Error, APICode: 0x"+String(format:"%02X", lAPICode)+", ERRCode: 0x"+String(format:"%02X", lERRCode) )
        }
    }
    
    func createDateTimeFolder(parentDir:URL) throws -> URL {
        let dt = Date()
        let dateFormatter = ISO8601DateFormatter()
        // 2021-03-01T12:00:00Z -> 20210301T120000+0900
        dateFormatter.formatOptions.insert(.withTimeZone)
        dateFormatter.formatOptions.remove(.withColonSeparatorInTimeZone)
        dateFormatter.formatOptions.remove(.withDashSeparatorInDate)
        dateFormatter.formatOptions.remove(.withColonSeparatorInTime)
        let saveDirectory = parentDir.appendingPathComponent(dateFormatter.string(from: dt), isDirectory: true)
        NSLog(saveDirectory.absoluteURL.absoluteString)

        let fileManager = FileManager.default
        try fileManager.createDirectory(at: saveDirectory, withIntermediateDirectories: false)

        return saveDirectory;
    }

    func periodicProc(){
        DispatchQueue.global().async {
            while true{
                let intervalSec = self.checkConnection()
                Thread.sleep(forTimeInterval: intervalSec)
            }
        }
    }
    
    func checkConnection() -> TimeInterval{
        var err:XSDK_APIENTRY=XSDK_COMPLETE
        do {
            var cameraMode:Int = 0
            var numCount: Int = -1
            var devInfo = XSDK_DeviceInformation()
            if(self.cameraHandle == nil){
                // Under S1 or S2 Session
                err = xapi.xsdk_Detect(
//                    Int(UInt32(XSDK_DSC_IF_USB)|UInt32(XSDK_DSC_IF_WIFI_LOCAL)), // for both USB and Network connections
                    Int(UInt32(XSDK_DSC_IF_USB)),
                    pInterface: nil, pDeviceName: nil, plCount: &numCount)
                if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_Detect", code: err)}
                NSLog("numCount="+String(numCount))

                if(numCount>0){
                    // S2 -> S3 Session
                    let camera = "ENUM:0"
                    err = xapi.xsdk_OpenEx(camera, phCamera: &self.cameraHandle, plCameraMode:&cameraMode, pOption: nil)
                    if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_OpenEx", code: err)}
                }
            }
            if(self.cameraHandle != nil){
                // Under S3 Session
                err = xapi.xsdk_GetDeviceInfo(self.cameraHandle,pDevInfo: &devInfo)
                if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_GetDeviceInfo", code: err)}
                
                let strDeviceName = withUnsafePointer(to: devInfo.strProduct) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                        String(cString: $0)
                    }
                }
                DispatchQueue.main.async {
                    if let button = self.statusBarItem.button {
                         button.image = NSImage(named: "CAM_ACT")
                    }
                    let deviceNameStr = strDeviceName+" is connected."
                    self.cameraNameMenuItem.title = deviceNameStr
                }
                
                // Under connection
                var imgInfo = XSDK_ImageInformation()
                err = xapi.xsdk_ReadImageInfo(self.cameraHandle,pImgInfo: &imgInfo)
                if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_ReadImageInfo", code: err)}
                
                if( imgInfo.lFormat&0xFF == XSDK_IMAGEFORMAT_RAW
                                || imgInfo.lFormat&0xFF == XSDK_IMAGEFORMAT_JPEG ){
   
                    if( self.savedDateTimeFolder == nil ){
                        // Create DateTime folder to save images
                        self.savedDateTimeFolder = try setSavedDateTimeFolder()
                    }

                    // Get image info
                    let fname = withUnsafePointer(to: imgInfo.strInternalName) {
                        $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                            String(cString: $0)
                        }
                    }
                    DispatchQueue.main.async {
                        let fileIOInfoStr = "Importing: "+fname
                        self.cameraNameMenuItem.title = fileIOInfoStr
                    }
                    // Get image
                    let data = UnsafeMutablePointer<UInt8>.allocate(capacity:imgInfo.lDataSize)
                    err = xapi.xsdk_ReadImage(self.cameraHandle,pData:data,lDataSize:UInt(imgInfo.lDataSize));
                    if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_ReadImage", code: err)}
                    
                    // Save image
                    let urlImageName = self.savedDateTimeFolder!.appendingPathComponent(fname)
                    NSLog("Start writing image: "+urlImageName.absoluteString)
                    let wData = Data(bytes: data, count:imgInfo.lDataSize)
                    try wData.write(to: urlImageName)
                    NSLog("Wrote image: "+urlImageName.absoluteString)
                }
            }else{
                // "No connection."
            }
            
        } catch let error {
            let nserr = error as NSError
            checkXSDKError(nsError: nserr)

            DispatchQueue.main.async {
                if let button = self.statusBarItem.button {
                     button.image = NSImage(named: "CAM_OFF")
                }
                self.cameraNameMenuItem.title = "Camera was disconnected."
            }
            
            if(self.cameraHandle != nil){
                // Disconnected
                err = xapi.xsdk_Close(self.cameraHandle)
                //if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_Close", code: err)}
            }
            self.cameraHandle = nil
            self.savedDateTimeFolder = nil
        }

        // Set timer
        var timeInterval = 1.0
        if(self.cameraHandle != nil){
            timeInterval = 0.5
        }
        return timeInterval;
    }
    
    // Launch app
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        var err:XSDK_APIENTRY=XSDK_COMPLETE

        do {
            NSApp.setActivationPolicy(.accessory)
            
            err = xapi.xsdk_Init()
            if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_Init", code: err)}
        
            let statusBar = NSStatusBar.system;
            self.statusBarItem = statusBar.statusItem(
                withLength: NSStatusItem.squareLength);
            if let button = self.statusBarItem.button {
                 button.image = NSImage(named: "CAM_ON")
                 button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            }

            let statusBarMenu = NSMenu(title: "Status Bar Menu");
            self.statusBarItem.menu = statusBarMenu

            statusBarMenu.addItem(NSMenuItem(
                                    title: "Select a folder to receive images",
                                    action: #selector(AppDelegate.selectFolder),
                                    keyEquivalent: ""));
            statusBarMenu.addItem(NSMenuItem(
                                    title: "Quit",
                                    action: #selector(AppDelegate.quitApp),
                                    keyEquivalent: ""));
            self.cameraNameMenuItem = NSMenuItem()
            cameraNameMenuItem.title = "No Connected Camera"
            statusBarMenu.insertItem(cameraNameMenuItem, at: 0);

            //Set timer
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
                self.periodicProc()
            })

        } catch let error {
            let nserr = error as NSError
            checkXSDKError(nsError: nserr)
        }
    }
    
    func setSavedDateTimeFolder() throws -> URL?{
        var saveFolderURL = UserDefaults.standard.url(forKey: DefaultFolder) ?? nil
        if(saveFolderURL == nil){
            let pictureDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
            
            UserDefaults.standard.set(pictureDirectory, forKey: DefaultFolder)
            saveFolderURL = pictureDirectory
        }
        var savedDateTimeFolder:URL?=nil
        if(saveFolderURL != nil){
            savedDateTimeFolder = try self.createDateTimeFolder(parentDir: saveFolderURL!)
        }
        NSLog("savedDateTimeFolder:"+(savedDateTimeFolder?.absoluteURL.absoluteString ?? "Not specified"))
        return savedDateTimeFolder
    }

    @objc func selectFolder() {
        var directoryUrl:URL? = UserDefaults.standard.url(forKey: DefaultFolder)
        if(directoryUrl == nil){
            directoryUrl = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        }
        let savePanel = NSOpenPanel()
        savePanel.directoryURL = directoryUrl
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.prompt = "Select"
        savePanel.canChooseDirectories = true
        savePanel.canChooseFiles = false
        
        if (savePanel.runModal() == NSApplication.ModalResponse.OK)
        {
            let url = savePanel.url
            if (url != nil)
            {
                NSLog("DefaultFolder: "+url!.absoluteString)
                UserDefaults.standard.set(url, forKey: DefaultFolder)
                // NSWorkspace.shared.open(url!) // open the folder in Finder
                self.savedDateTimeFolder = nil
            }
        }
    }
    
    @objc func quitApp() {
        var err:XSDK_APIENTRY=XSDK_COMPLETE

        if(self.cameraHandle != nil){
            err = xapi.xsdk_Close(self.cameraHandle)
            //if(err != XSDK_COMPLETE){throw NSError(domain:"xsdk_Close", code: err)}
            NSLog("quitApp xsdk_Close= "+String(err))
        }
        self.cameraHandle = nil
        self.savedDateTimeFolder = nil
        
        NSApp.terminate(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        let err = xapi.xsdk_Exit()
        NSLog("applicationWillTerminate xsdk_Exit= "+String(err))
    }
}

