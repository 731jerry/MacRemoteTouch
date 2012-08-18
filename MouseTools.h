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
void performRightClickWell();
void PostMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point);
CGEventFlags getModKeysValue(BOOL doShiftDown, BOOL doCommandDown, BOOL doOptionDown, BOOL doControlDown);
void allModifiersUp();

// move mouse
void moveMouseToPoint(float x, float y);
void stepMouseToPoint(float x, float y, int numSteps);
void mouseLocation(BOOL isTopCoordinates);

void moveMouseWithCoordinateOffset(float x, float y); //
void moveMouseWithCoordinateOffsetOnLandscapeLeftRotation(float x, float y); //
void moveMouseWithCoordinateOffsetOnPortraitRotation(float x, float y);//
void moveMouseWithOffsetDistance(float distance);
void moveMouse(float x, float y); //
NSPoint mouseLocationWithServerBottomLeft(); //
NSPoint mouseLocationWithServerTopLeft(); //
// helpers
BOOL isPointOnAScreen(NSPoint point, NSScreen** theScreen);
void getXYStringCoordinatesFromArgs(NSString** x, NSString** y);
void myDelay(float value);
void printUsage();

// global variables
CGEventTapLocation tapLocation;
CGEventSourceRef sourceRef;
float mouseFlexibility; // mouse flexibility


#endif
