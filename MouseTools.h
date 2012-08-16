//
//  MouseTools.h
//  MacRemoteTouch
//
//  Created by Jerry Zhu on 8/15/12.
//  Copyright (c) 2012 Jerry Zhu. All rights reserved.
//

#ifndef MacRemoteTouch_MouseTools_h
#define MacRemoteTouch_MouseTools_h
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


// mouse clicks
void performLeftClick(CGEventFlags modKeys);
void performLeftClickWithoutModKeys(); //
void performDoubleLeftClick();
void performRightClick();
CGEventFlags getModKeysValue(BOOL doShiftDown, BOOL doCommandDown, BOOL doOptionDown, BOOL doControlDown);
void allModifiersUp();

// move mouse
void moveMouseToPoint(float x, float y);
void stepMouseToPoint(float x, float y, int numSteps);
void mouseLocation(BOOL isTopCoordinates);

void moveMouseWithOffset(float x, float y); //
void moveMouse(float x, float y); //
NSPoint mouseLocationWithNSEvent(); //
// helpers
BOOL isPointOnAScreen(NSPoint point, NSScreen** theScreen);
void getXYStringCoordinatesFromArgs(NSString** x, NSString** y);
void myDelay(float value);
void printUsage();

// global variables
CGEventTapLocation tapLocation;
CGEventSourceRef sourceRef;


#endif
