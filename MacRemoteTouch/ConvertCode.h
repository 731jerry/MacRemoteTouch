//
//  ConvertCode.h
//  MacRemoteTouch
//
//  Created by Jerry Zhu on 8/17/12.
//  Copyright (c) 2012 Jerry Zhu. All rights reserved.
//

#ifndef MacRemoteTouch_ConvertCode_h
#define MacRemoteTouch_ConvertCode_h
#include <stdint.h>
#include <stdio.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>

CGKeyCode keyCodeForCharWithLayout(const char c,
                                   const UCKeyboardLayout *uchrHeader);


#endif
