//
//  xapi.mm
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

#import <Foundation/Foundation.h>
#import "xapi_mm.h"
 
@implementation XAPI

 
- (id)init
{
    NSLog(@"init");

    NSString *bundlePath;
    NSURL *bundleURL;
 
    self = [super init];
 
    bundlePath = [[[NSBundle mainBundle] resourcePath]
                    stringByAppendingPathComponent:@"XAPI.bundle"];
    bundleURL = [NSURL fileURLWithPath:bundlePath];
    cfBundle = CFBundleCreate(kCFAllocatorDefault, (CFURLRef)bundleURL);
 
    return self;
}
 
- (void)dealloc
{
    NSLog(@"dealloc");

    CFRelease(cfBundle);
}


- (XSDK_APIENTRY)xsdk_Init
{
    NSLog(@"xsdk_Init");

    if(!xsdk_Init)
    {
        xsdk_Init = (_XSDK_Init)CFBundleGetFunctionPointerForName(cfBundle,
                                           CFSTR("XSDK_Init"));
    }
    return xsdk_Init(cfBundle);
}

- (XSDK_APIENTRY)xsdk_Exit
{
    NSLog(@"xsdk_Exit");

    if(!xsdk_Exit)
    {
        xsdk_Exit = (_XSDK_Exit)CFBundleGetFunctionPointerForName(cfBundle,
                                           CFSTR("XSDK_Exit"));
    }
    return xsdk_Exit();
}

- (XSDK_APIENTRY)xsdk_Detect:(long)arg_lInterface
                  pInterface:(NSString*)arg_pInterface
                 pDeviceName:(NSString*)arg_pDeviceName
                      plCount:(long*)arg_plCount
{
    NSLog(@"xsdk_Detect");

    XSDK_APIENTRY err = 0;
    if(!xsdk_Detect)
    {
        xsdk_Detect = (_XSDK_Detect)CFBundleGetFunctionPointerForName(cfBundle,
                                           CFSTR("XSDK_Detect"));
    }
    if(xsdk_Detect!=NULL){
        const char* pIF = [arg_pInterface UTF8String];
        const char* pDN = [arg_pDeviceName UTF8String];
        err = xsdk_Detect(arg_lInterface,(char*)pIF,(char*)pDN,arg_plCount);
    }
    return err;
}

- (XSDK_APIENTRY)xsdk_OpenEx:(NSString*)arg_pDevice
                    phCamera:(XSDK_HANDLE*)arg_phCamera
                plCameraMode:(long*)arg_plCameraMode
                     pOption:(void*)arg_pOption
{
    NSLog(@"xsdk_OpenEx");

    if(!xsdk_OpenEx)
    {
        xsdk_OpenEx = (_XSDK_OpenEx)CFBundleGetFunctionPointerForName(cfBundle,
                                           CFSTR("XSDK_OpenEx"));
    }
    const char* pCharDevice = [arg_pDevice UTF8String];
    return xsdk_OpenEx((char*)pCharDevice,arg_phCamera,arg_plCameraMode,arg_pOption);
}

- (XSDK_APIENTRY)xsdk_Close:(XSDK_HANDLE)arg_hCamera
{
    NSLog(@"xsdk_Close");

    if(!xsdk_Close)
    {
        xsdk_Close = (_XSDK_Close)CFBundleGetFunctionPointerForName(cfBundle,
                                           CFSTR("XSDK_Close"));
    }
    return xsdk_Close(arg_hCamera);
}

- (XSDK_APIENTRY)xsdk_GetDeviceInfo:(XSDK_HANDLE)arg_hCamera
                           pDevInfo:(XSDK_DeviceInformation*)arg_pDevInfo
{
    NSLog(@"xsdk_GetDeviceInfo");

    if(!xsdk_GetDeviceInfo)
    {
        xsdk_GetDeviceInfo = (_XSDK_GetDeviceInfo)CFBundleGetFunctionPointerForName(cfBundle,
                                           CFSTR("XSDK_GetDeviceInfo"));
    }
    return xsdk_GetDeviceInfo(arg_hCamera,arg_pDevInfo);
}

- (XSDK_APIENTRY)xsdk_GetErrorNumber:(XSDK_HANDLE)arg_hCamera
                           plAPICode:(long*)arg_plAPICode
                           plERRCode:(long*)arg_plERRCode
{
    NSLog(@"xsdk_GetErrorNumber");

    if(!xsdk_GetErrorNumber)
    {
        xsdk_GetErrorNumber = (_XSDK_GetErrorNumber)CFBundleGetFunctionPointerForName(cfBundle,
                                           CFSTR("XSDK_GetErrorNumber"));
    }
    return xsdk_GetErrorNumber(arg_hCamera,arg_plAPICode,arg_plERRCode);
}

- (XSDK_APIENTRY)xsdk_ReadImageInfo:(XSDK_HANDLE)arg_hCamera
                           pImgInfo:(XSDK_ImageInformation*)arg_pImgInfo
{
    NSLog(@"xsdk_ReadImageInfo");
    if(!xsdk_ReadImageInfo)
    {
        xsdk_ReadImageInfo = (_XSDK_ReadImageInfo)CFBundleGetFunctionPointerForName(cfBundle,
                                                                                    CFSTR("XSDK_ReadImageInfo"));
    }
    return xsdk_ReadImageInfo(arg_hCamera,arg_pImgInfo);
}

- (XSDK_APIENTRY)xsdk_ReadImage:(XSDK_HANDLE)arg_hCamera
                          pData:(unsigned char*)arg_pData
                      lDataSize:(unsigned long)arg_lDataSize
{
    NSLog(@"xsdk_ReadImage");
    if(!xsdk_ReadImage)
    {
        xsdk_ReadImage = (_XSDK_ReadImage)CFBundleGetFunctionPointerForName(cfBundle,
                                                                            CFSTR("XSDK_ReadImage"));
    }
    return xsdk_ReadImage(arg_hCamera,arg_pData,arg_lDataSize);
}

@end
