# Fujifilm-SDK-HotFolder for macOS

# Important Notice
* YOU AGREE AND ACKNOWLEDGE THAT, ONCE A FUJIFILM X OR GFX DIGITAL CAMERA IS USED OR CONTROLLED BY OR THROUGH THE HotFolder SOFTWARE, THE CAMERA SHALL BE OUT OF MANUFACTURER-WARRANTY WITH RESPECT TO THE PRODUCT AS SEPARATELY SPECIFIED BY FUJIFILM, FUJIFILM’S AFFILIATES, OR THEIR BUSINESS PARTNERS.
* Fujifilm and Fujifilm’s affiliates do not provide any support for this HotFolder.

# What is this
* Here is an example of using the "FUJIFILM X Series/GFX System Digital Camera Control Software Development Kit" (SDK).
* This software is similar to ["FUJIFILM X Acquire"](https://fujifilm-x.com/en-us/support/download/software/x-acquire/), you can send and save images directly to your Mac via a USB cable when you take them with a camera connected to your Mac.

# How to use
1. Launch HotFolder.app  
   The camera icon will show on the menu bar of the desktop.
2. Select a folder to receive images  
   Select the folder by selecting the "Select a folder to receive images" menu item in the menu bar icon. The default folder is the "~/Pictures/" folder.
4. Connect your camera using a USB cable.
5. Take a picture with your camera.  
   The images are transferred from the camera to a subfolder in the folder specified in step 2. The subfolder is generated with Coordinated Universal Time (UTC) name such as "20210422T150102Z" when you capture the first picture after camera connection.

# How to build
1. Download the ["FUJIFILM X Series/GFX System Digital Camera Control Software Development Kit"](https://fujifilm-x.com/special/camera-control-sdk/).
2. Copy "XAPI.H" file from the SDK to "/HotFolder/cpp/includes" folder.
3. Copy "FTLPTP.dylib", "FTLPTPIP.dylib", "XSDK.DAT", and "XAPI.bundle" files/folders from the SDK to "/HotFolder/Resources" folder.
4. Open the project file (HitFolder.xcodeproj) in Xcode 12.
5. Update signing in the project settings.
6. Select "Run" or "Build" from the "Product" menu.

# Required system requirements
## for USE
* macOS: 10.14.6 (Mojave) - 11.2.2 (Big Sur)
* Supported Camera: refer the document in the Fujifilm's SDK
  * We checked the HotFolder app with FUJIFILM X-T3.
* The site ["FUJIFILM X Acquire - Features & Users Guide"](https://fujifilm-x.com/en-us/stories/fujifilm-x-acquire-features-users-guide/) describes the preparation of the camera.

## for BUILD
* macOS Catalina 10.15.7
* Xcode Version 12.3 (12C33)

# Notes
### Reset settings
* This program uses **UserDefaults** to record the default folder to save images. If you want to reset the setting, remove the folder `~/Library/Containers/jp.infomorph.HotFolder`.

# License

The "FUJIFILM X Series/GFX System Digital Camera Control Software Development Kit" (SDK) provided by Fujifilm comes under their license. The files in the "Resources" folder in the SDK are redistributable. The "XAPI.H", "FTLPTP.dylib", "FTLPTPIP.dylib", "XSDK.DAT", and "XAPI.bundle" files we use is not authorised for solo redistribution. Therefore, you have to download the SDK by yourself and copy these files to build.
And our codes are provided under the license as below.

```
   Copyright 2021 Infomorph, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
