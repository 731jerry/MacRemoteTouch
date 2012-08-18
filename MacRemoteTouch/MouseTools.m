//
//  MouseTools.m
//  MacRemoteTouch
//
//  Created by Jerry Zhu on 8/15/12.
//  Copyright (c) 2012 Jerry Zhu. All rights reserved.
//

/*
 MouseTools

 
 SWITCHES:
 [-h] return this help text
 [-b] coordinates are measured from bottom-left corner of the screen
 [-location] return the current mouse location
 [-x xValue -y yValue] move the mouse to the {xValue, yValue} location
 [-mouseSteps numSteps] move mouse in number-of-steps to the location
 [-leftClick] perform a mouse left-click at the current mouse location
 [-doubleLeftClick] perform a mouse double-click with the left mouse button
 [-rightClick] perform a mouse right-click at the current mouse location
 [-shiftKey] shift key down, useful when performing a left-click event
 [-commandKey] command key down, useful when performing a left-click event
 [-optionKey] option key down, useful when performing a left-click event
 [-controlKey] control key down, useful when performing a left-click event
 
 EXAMPLES:
 1. get mouse location (measured from top-left)
 MouseTools -location
 
 2. get mouse location (measured from bottom-left)
 MouseTools -b -location
 
 3. move the mouse to a screen location
 MouseTools -x xValue -y yValue
 
 4. move the mouse in 1000 steps to a screen location
 MouseTools -x xValue -y yValue -mouseSteps 1000
 
 5. right-click the mouse at the current mouse position
 MouseTools -rightClick
 
 6. move the mouse to the given coordinates and perform a left-click
 MouseTools -x xValue -y yValue -leftClick
 
 7. move the mouse to the given coordinates and perform a shift-click
 MouseTools -x xValue -y yValue -leftClick -shiftKey
*/

#import "MouseTools.h"


//----------------------------------------
//            MOUSE CLICKS
//----------------------------------------
#pragma mark -
#pragma mark MOUSE CLICKS

void performLeftClick(CGEventFlags modKeys) {
	// get the current mouse location
	CGEventRef mouseEvent = CGEventCreate(NULL);
	CGPoint mouseLoc = CGEventGetLocation(mouseEvent);
	CFRelease(mouseEvent);
	
	// click mouse
	CGEventRef clickMouse = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseDown, mouseLoc, 0);
	if (!modKeys == 0) CGEventSetFlags(clickMouse, modKeys);
	CGEventPost(tapLocation, clickMouse);
	CFRelease(clickMouse);
	
	// release mouse
	CGEventRef releaseMouse = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseUp, mouseLoc, 0);
	CGEventPost(tapLocation, releaseMouse);
	CFRelease(releaseMouse);
} // left-click at current mouse location, we pass the modifier keys mask in case we want to shift-click

void performLeftClickWithoutModKeys(){
    // get the current mouse location
	CGEventRef mouseEvent = CGEventCreate(NULL);
	CGPoint mouseLoc = CGEventGetLocation(mouseEvent);
	CFRelease(mouseEvent);
	
	// click mouse
	CGEventRef clickMouse = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseDown, mouseLoc, 0);
    CGEventPost(tapLocation, clickMouse);
    CFRelease(clickMouse);
        
    // release mouse
    CGEventRef releaseMouse = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseUp, mouseLoc, 0);
    CGEventPost(tapLocation, releaseMouse);
    CFRelease(releaseMouse);
}

void performDoubleLeftClick() {
	// get the current mouse location
	CGEventRef mouseEvent = CGEventCreate(NULL);
	CGPoint mouseLoc = CGEventGetLocation(mouseEvent);
	CFRelease(mouseEvent);
	
	// NOTE: the first mouse down and mouse up are not really needed to perform a double click
	// I only do that because sometimes you have to click once to bring whatever you want to double-click to the front
	
	// first click mouse
	CGEventRef clickMouse = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseDown, mouseLoc, 0);
	CGEventSetIntegerValueField(clickMouse, kCGMouseEventClickState, 1);
	CGEventPost(tapLocation, clickMouse);
	CFRelease(clickMouse);
	
	// first mouse up
	CGEventRef releaseMouse = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseUp, mouseLoc, 0);
	CGEventSetIntegerValueField(releaseMouse, kCGMouseEventClickState, 1);
	CGEventPost(tapLocation, releaseMouse);
	CFRelease(releaseMouse);
	
	// second click mouse
	CGEventRef clickMouse2 = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseDown, mouseLoc, 0);
	CGEventSetIntegerValueField(clickMouse2, kCGMouseEventClickState, 2);
	CGEventPost(tapLocation, clickMouse2);
	CFRelease(clickMouse2);
	
	// second mouse up
	CGEventRef releaseMouse2 = CGEventCreateMouseEvent(sourceRef, kCGEventLeftMouseUp, mouseLoc, 0);
	CGEventSetIntegerValueField(releaseMouse2, kCGMouseEventClickState, 2);
	CGEventPost(tapLocation, releaseMouse2);
	CFRelease(releaseMouse2);
} // double click the mouse NOTE:sometimes you have to perform a leftClick first to bring the target forward before the double cLick

void performRightClick() {
	//performLeftClick(0); // we make sure the proper thing is selected by performing a left-click first
	
	// get the current mouse location
	CGEventRef mouseEvent = CGEventCreate(NULL);
	CGPoint mouseLoc = CGEventGetLocation(mouseEvent);
	CFRelease(mouseEvent);
	
	// click right-mouse
	CGEventRef clickMouse = CGEventCreateMouseEvent(sourceRef, kCGEventRightMouseDown, mouseLoc, 0);
	CGEventPost(tapLocation, clickMouse);
	CFRelease(clickMouse);
	
	// release
	CGEventRef releaseMouse = CGEventCreateMouseEvent(sourceRef, kCGEventRightMouseUp, mouseLoc, 0);
	CGEventPost(tapLocation, releaseMouse);
	CFRelease(releaseMouse);
} // right-click at current mouse location

void performRightClickWell(){
//    CGPoint point = [self getMousePointWithDeltaX:0 deltaY:0];
    CGEventRef mouseEvent = CGEventCreate(NULL);
	CGPoint mouseLoc = CGEventGetLocation(mouseEvent);

    PostMouseEvent(kCGMouseButtonRight, kCGEventMouseMoved, mouseLoc);
	PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseDown, mouseLoc);
	PostMouseEvent(kCGMouseButtonRight, kCGEventRightMouseUp, mouseLoc);
    
}

void PostMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point)
{
	CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
	//CGEventSetType(theEvent, type);
	CGEventPost(kCGHIDEventTap, theEvent);
	CFRelease(theEvent);
}

CGEventFlags getModKeysValue(BOOL doShiftDown, BOOL doCommandDown, BOOL doOptionDown, BOOL doControlDown) {
	CGEventFlags modKeys = 0;
	
	if (doShiftDown) modKeys = kCGEventFlagMaskShift;
	if (doCommandDown) {
		if (modKeys == 0) {
			modKeys = kCGEventFlagMaskCommand;
		} else {
			modKeys = modKeys | kCGEventFlagMaskCommand;
		}
	}
	
	if (doOptionDown) {
		if (modKeys == 0) {
			modKeys = kCGEventFlagMaskAlternate;
		} else {
			modKeys = modKeys | kCGEventFlagMaskAlternate;
		}
	}
	
	if (doControlDown) {
		if (modKeys == 0) {
			modKeys = kCGEventFlagMaskControl;
		} else {
			modKeys = modKeys | kCGEventFlagMaskControl;
		}
	}
	
	return modKeys;
} // calculate the value of the modifier keys

void allModifiersUp() {
	NSString* modsUpString = [NSString stringWithFormat:@"tell application \"System Events\"\nkey up {shift, command, option, control}\nend tell"];
	NSAppleScript* modsUp = [[NSAppleScript alloc] initWithSource:modsUpString];
	[modsUp executeAndReturnError:nil];
	[modsUp release];
} // having major problems with stuck modifier keys, so we just use a reliable applescript to make sure they're all up

//----------------------------------------
//            MOVE MOUSE
//----------------------------------------
#pragma mark -
#pragma mark MOVE MOUSE

void moveMouseToPoint(float x, float y) {
	//CGWarpMouseCursorPosition(CGPointMake(x, y));
    tapLocation = kCGHIDEventTap; // used when specifying the tap location for CGEventPost
	CGEventRef moveMouse = CGEventCreateMouseEvent(sourceRef, kCGEventMouseMoved, CGPointMake(x, y), 0);
	CGEventPost(tapLocation, moveMouse);
	CFRelease(moveMouse);
} // mouse jumps directly from its current position to the new position and becomes visible, origin of CGPoint must be top-left

void stepMouseToPoint(float x, float y, int numSteps) {
	// get the current mouse location
	CGEventRef mouseEvent = CGEventCreate(NULL);
	CGPoint currentLoc = CGEventGetLocation(mouseEvent);
	CFRelease(mouseEvent);
	
	// calc x increment
	if (numSteps < 1) numSteps = 1;
	float xIncrement = (x - currentLoc.x) / numSteps;
	float yIncrement = (y - currentLoc.y) / numSteps;
	
	int i;
	float xNew, yNew, xPrevious, yPrevious;
	xPrevious = currentLoc.x;
	yPrevious = currentLoc.y;
	for (i=0; i<numSteps; i++) {
		xNew = xPrevious + xIncrement;
		yNew = yPrevious + yIncrement;
		moveMouseToPoint(xNew, yNew);
		xPrevious = xNew;
		yPrevious = yNew;
		myDelay(0.0008);
	}
	moveMouseToPoint(x, y); // make sure we're at the proper location
} // the mouse slowly moves from current position to new position incrementally, origin of CGPoint must be top-left
void moveMouseWithCoordinateOffsetOnLandscapeLeftRotation(float x, float y){
    //CGWarpMouseCursorPosition(CGPointMake(x, y));
    tapLocation = kCGHIDEventTap; // used when specifying the tap location for CGEventPost
    
    float screenWidth = [[NSScreen mainScreen] frame].size.width;
    float screenHeight = [[NSScreen mainScreen] frame].size.height;
    
    float mousePointX = mouseLocationWithServerTopLeft().x - y * mouseFlexibility;
    float mousePointY = mouseLocationWithServerTopLeft().y + x * mouseFlexibility;
    
    if (mousePointX > screenWidth) {
        mousePointX = screenWidth;
    }
    if (mousePointY > screenHeight) {
        mousePointY = screenHeight;
    }
    
	CGEventRef moveMouse = CGEventCreateMouseEvent(sourceRef, kCGEventMouseMoved, CGPointMake(mousePointX, mousePointY), 0);
	CGEventPost(tapLocation, moveMouse);
	CFRelease(moveMouse);
    
    NSLog(@">>> x move to: %f, y move to: %f",mousePointX,mousePointY);
}

void moveMouseWithCoordinateOffsetOnPortraitRotation(float x, float y){
    tapLocation = kCGHIDEventTap; // used when specifying the tap location for CGEventPost
    
    float screenWidth = [[NSScreen mainScreen] frame].size.width;
    float screenHeight = [[NSScreen mainScreen] frame].size.height - 2;
    
    float mousePointX = mouseLocationWithServerTopLeft().x + x * mouseFlexibility;
    float mousePointY = mouseLocationWithServerTopLeft().y + y * mouseFlexibility;
    
    if (mousePointX > screenWidth) {
        mousePointX = screenWidth;
    }
    if (mousePointY > screenHeight) {
        mousePointY = screenHeight;
    }
    
	CGEventRef moveMouse = CGEventCreateMouseEvent(sourceRef, kCGEventMouseMoved, CGPointMake(mousePointX, mousePointY), 0);
	CGEventPost(tapLocation, moveMouse);
	CFRelease(moveMouse);
    
    NSLog(@">>> x move to: %f, y move to: %f",mousePointX,mousePointY);
}
void moveMouseWithOffsetDistance(float distance){
    //
    NSLog(@"distance: >>> %f", distance);
}

void moveMouse(float x, float y){
    tapLocation = kCGHIDEventTap; // used when specifying the tap location for CGEventPost
	CGEventRef moveMouse = CGEventCreateMouseEvent(sourceRef, kCGEventMouseMoved, CGPointMake(x, y), 0);
	CGEventPost(tapLocation, moveMouse);
	CFRelease(moveMouse);
}

NSPoint mouseLocationWithServerBottomLeft(){
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSString* locString = [NSString stringWithFormat:@"%.0f %.0f", mouseLoc.x, mouseLoc.y];
//    fprintf(stdout, "%s\n", [locString UTF8String]);
    NSLog(@"mouse location: %@", locString);
    return mouseLoc;
}

NSPoint mouseLocationWithServerTopLeft(){
    CGEventRef mouseEvent = CGEventCreate(NULL);
    CGPoint mouseLoc = CGEventGetLocation(mouseEvent);
    NSString* locString = [NSString stringWithFormat:@"%.0f %.0f", (float)mouseLoc.x, (float)mouseLoc.y];
//    fprintf(stdout, "%s\n", [locString UTF8String]);
    NSLog(@"mouse location: %@", locString);
    CFRelease(mouseEvent);
    return mouseLoc;
}

void mouseLocation(BOOL isTopCoordinates) {
	// when getting mouse coordinates, CGEvent measures from top-left and NSEvent measures from bottom-left
	if (isTopCoordinates) {
		CGEventRef mouseEvent = CGEventCreate(NULL);
		CGPoint mouseLoc = CGEventGetLocation(mouseEvent);
		NSString* locString = [NSString stringWithFormat:@"%.0f %.0f", (float)mouseLoc.x, (float)mouseLoc.y];
		fprintf(stdout, "%s\n", [locString UTF8String]);
		CFRelease(mouseEvent);
	} else {
		NSPoint mouseLoc = [NSEvent mouseLocation];
		NSString* locString = [NSString stringWithFormat:@"%.0f %.0f", mouseLoc.x, mouseLoc.y];
		fprintf(stdout, "%s\n", [locString UTF8String]);
	}
} // print the current mouse location to stdout

//----------------------------------------
//            HELPERS
//----------------------------------------
#pragma mark -
#pragma mark HELPERS

BOOL isPointOnAScreen(NSPoint point, NSScreen** theScreen) {
	BOOL isPointOnAScreen = NO;
	
	NSArray* screens = [NSScreen screens];
	int i;
	for (i=0; i<[screens count]; i++) {
		if (NSPointInRect(point, [[screens objectAtIndex:i] frame])) {
			isPointOnAScreen = YES;
			if (theScreen) *theScreen = [screens objectAtIndex:i]; // return the screen
			break;
		}
	}
	return isPointOnAScreen;
} // this validates that a given point is on a screen and optionally returns that screen

void getXYStringCoordinatesFromArgs(NSString** x, NSString** y) {
	NSArray* pInfo = [[NSArray alloc] initWithArray:[[NSProcessInfo processInfo] arguments]];
	int pCount = (int)[pInfo count];
	NSString* xValue = nil;
	NSString* yValue = nil;
	
	// we get the values from the processInfo because if a value is negative then NSUserDefaults doesn't recognize it
	int i;
	for (i=0; i<pCount; i++) {
		NSString* thisInfo = [pInfo objectAtIndex:i];
		if ([thisInfo isEqualToString:@"-x"]) {
			if (pCount > (i+1)) xValue = [pInfo objectAtIndex:(i+1)];
		} else if ([thisInfo isEqualToString:@"-y"]) {
			if (pCount > (i+1)) yValue = [pInfo objectAtIndex:(i+1)];
		}
	}
	[pInfo release];
	
	// validate that we found both values
	if (!xValue) {
		fprintf(stderr, "Error: you did not supply an -x value\n");
		return;
	} else if (!yValue) {
		fprintf(stderr, "Error: you did not supply a -y value!\n");
		return;
	}
	
	*x = xValue;
	*y = yValue;
} // get the x, y location args and write their value to the passed memory locations

void myDelay(float value) {
	NSDate *future = [NSDate dateWithTimeIntervalSinceNow:value];
	[NSThread sleepUntilDate:future];
} // perform a delay

void printUsage() {
	fprintf(stdout, "\nMouseTools\nCreated 31 July 2010 by Hank McShane\nversion 0.4\nrequires Mac OS X 10.4 or higher\n\nUpdated 22 Feb 2011 by Hank McShane to v0.4\n- added a double click for the left mouse button\n\nUpdated 31 August 2010 by Hank McShane to v0.3\n- fixed and issue where negative x or y values were not being read properly\n- fixed issue where the mouse cursor wasn't updating properly\n\nUpdated 26 August 2010 by Hank McShane to v0.2\n- using simpler method to move the mouse: CGWarpMouseCursorPosition()\n- streamlined stepMouseToPoint()\n- added 64-bit builds for 10.5 and higher\n\nThis foundation tool will help you perform things with your mouse.\nBy default, Screen Coordinates are measured from the top-left\ncorner of the screen but with the [-b] switch they can be measured\nfrom the bottom-left.\n\nSWITCHES:\n [-h] return this help text\n [-b] coordinates are measured from bottom-left corner of the screen\n [-location] return the current mouse location\n [-x xValue -y yValue] move the mouse to the {xValue, yValue} location\n [-mouseSteps numSteps] move mouse in number-of-steps to the location\n [-leftClick] perform a mouse left-click at the current mouse location\n [-doubleLeftClick] perform a mouse double-click with the left mouse button\n [-rightClick] perform a mouse right-click at the current mouse location\n [-shiftKey] shift key down, useful when performing a left-click event\n [-commandKey] command key down, useful when performing a left-click event\n [-optionKey] option key down, useful when performing a left-click event\n [-controlKey] control key down, useful when performing a left-click event\n \nEXAMPLES:\n 1. get mouse location (measured from top-left)\n MouseTools -location\n \n 2. get mouse location (measured from bottom-left)\n MouseTools -b -location\n \n 3. move the mouse to a screen location\n MouseTools -x xValue -y yValue\n \n 4. move the mouse in 1000 steps to a screen location\n MouseTools -x xValue -y yValue -mouseSteps 1000\n \n 5. right-click the mouse at the current mouse position\n MouseTools -rightClick\n \n 6. move the mouse to the given coordinates and perform a left-click\n MouseTools -x xValue -y yValue -leftClick\n \n 7. move the mouse to the given coordinates and perform a shift-click\n MouseTools -x xValue -y yValue -leftClick -shiftKey\n\n");
} // help text
