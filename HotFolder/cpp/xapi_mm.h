//
//  xapi_mm.h
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

#ifndef xapi_mm_h
#define xapi_mm_h

#import "includes/XAPI.H"
#import <CoreFoundation/CoreFoundation.h>


@interface XAPI : NSObject
{
    _XSDK_Init xsdk_Init;
    _XSDK_Exit xsdk_Exit;
    _XSDK_Detect xsdk_Detect;
    _XSDK_OpenEx xsdk_OpenEx;
    _XSDK_Close xsdk_Close;
    
    _XSDK_GetDeviceInfo xsdk_GetDeviceInfo;

    _XSDK_GetErrorNumber xsdk_GetErrorNumber;
    
    _XSDK_ReadImageInfo xsdk_ReadImageInfo;
    _XSDK_ReadImage xsdk_ReadImage;

    CFBundleRef cfBundle;
}

- (XSDK_APIENTRY)xsdk_Init;
- (XSDK_APIENTRY)xsdk_Exit;
- (XSDK_APIENTRY)xsdk_Detect:(long)arg_lInterface
                   pInterface:(NSString*)arg_pInterface
                  pDeviceName:(NSString*)arg_pDeviceName
                      plCount:(long*)arg_plCount;
- (XSDK_APIENTRY)xsdk_OpenEx:(NSString*)arg_pDevice
                    phCamera:(XSDK_HANDLE*)arg_phCamera
                plCameraMode:(long*)arg_plCameraMode
                     pOption:(void*)arg_pOption;
- (XSDK_APIENTRY)xsdk_Close:(XSDK_HANDLE)arg_hCamera;


- (XSDK_APIENTRY)xsdk_GetErrorNumber:(XSDK_HANDLE)arg_hCamera
                           plAPICode:(long*)arg_plAPICode
                           plERRCode:(long*)arg_plERRCode;

- (XSDK_APIENTRY)xsdk_GetDeviceInfo:(XSDK_HANDLE)arg_hCamera
                           pDevInfo:(XSDK_DeviceInformation*)arg_pDevInfo;

- (XSDK_APIENTRY)xsdk_ReadImageInfo:(XSDK_HANDLE)arg_hCamera
                           pImgInfo:(XSDK_ImageInformation*)arg_pImgInfo;
- (XSDK_APIENTRY)xsdk_ReadImage:(XSDK_HANDLE)arg_hCamera
                          pData:(unsigned char*)arg_pData
                      lDataSize:(unsigned long)arg_lDataSize;

@end

#endif /* xapi_mm_h */
