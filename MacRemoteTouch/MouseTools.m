/*
 MouseTools
 Created 31 July 2010 by Hank McShane
 version 0.4
 requires Mac OS X 10.4 or higher
 
 Updated 22 Feb 2011 by Hank McShane to v0.4
 - added a double click for the left mouse button
 
 Updated 31 August 2010 by Hank McShane to v0.3
 - fixed and issue where negative x or y values were not being read properly
 - fixed issue where the mouse cursor wasn't updating properly
 
 Updated 26 August 2010 by Hank McShane to v0.2
 - using simpler method to move the mouse: CGWarpMouseCursorPosition()
 - streamlined stepMouseToPoint()
 - added 64-bit builds for 10.5 and higher
 
 This foundation tool will help you perform things with your mouse.
 By default, Screen Coordinates are measured from the top-left
 corner of the screen but with the [-b] switch they can be measured
 from the bottom-left.
 
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

//int main (int argc, const char * argv[]) {
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//	
//	tapLocation = kCGHIDEventTap; // used when specifying the tap location for CGEventPost
//	sourceRef = CGEventSourceCreate(kCGEventSourceStatePrivate);
//	
//	// see if help is being requested
//	NSArray* pInfo = [[NSArray alloc] initWithArray:[[NSProcessInfo processInfo] arguments]];
//	if ([pInfo count] == 1 || [[pInfo objectAtIndex:1] isEqualToString:@"-h"]) {
//		printUsage();
//		[pInfo release];
//		return 0;
//	}
//	
//	
//	float xPt, yPt;
//	int numSteps;
//	NSString* xString = nil;
//	NSString* yString = nil;
//	BOOL isTopCoordinates = YES;
//	BOOL wantsMouseLocation = NO;
//	BOOL shouldStepMouseMovement = NO;
//	BOOL wantsMouseMoved = NO;
//	BOOL shouldPerformLeftClick = NO;
//	BOOL shouldPerformDoubleLeftClick = NO;
//	BOOL shouldPerformRightClick = NO;
//	BOOL useShift = NO;
//	BOOL useControl = NO;
//	BOOL useOption = NO;
//	BOOL useCommand = NO;
//	
//	
//	// determine all the BOOLs
//	if ([pInfo containsObject:@"-b"]) isTopCoordinates = NO; // should we use bottom coordinates
//	if ([pInfo containsObject:@"-location"]) wantsMouseLocation = YES; // should we return mouse location
//	if ([pInfo containsObject:@"-x"]) { // wants mouse moved and should we step it to the new location?
//		wantsMouseMoved = YES;
//		getXYStringCoordinatesFromArgs(&xString, &yString);
//		if (!xString || !yString) return 1; // there was an error getting one of the values
//		xPt = [xString floatValue];
//		yPt = [yString floatValue];
//		if ([pInfo containsObject:@"-mouseSteps"]) {
//			shouldStepMouseMovement = YES;
//			numSteps = [[[NSUserDefaults standardUserDefaults] valueForKey:@"mouseSteps"] intValue];
//		}
//	}
//	
//	if ([pInfo containsObject:@"-rightClick"]) shouldPerformRightClick = YES; // perform right-click
//	
//	if ([pInfo containsObject:@"-leftClick"]) {
//		shouldPerformLeftClick = YES; // perform left-click
//		if ([pInfo containsObject:@"-shiftKey"]) useShift = YES;
//		if ([pInfo containsObject:@"-commandKey"]) useCommand = YES;
//		if ([pInfo containsObject:@"-optionKey"]) useOption = YES;
//		if ([pInfo containsObject:@"-controlKey"]) useControl = YES;
//	}
//	
//	if ([pInfo containsObject:@"-doubleLeftClick"]) shouldPerformDoubleLeftClick = YES;
//	
//	[pInfo release];
//	
//	// error check, we can only perform 1 type of click at a time so make sure only 1 is specified
//	if (shouldPerformLeftClick && shouldPerformRightClick) {
//		fprintf(stderr, "Error: cannot perform multiple mouse clicks. Only specify either a left or right click\n");
//		return 1;
//	}
//	//stepMouseToPoint(400.0, 600.0, 500);
//	
//	if (wantsMouseLocation) {
//		mouseLocation(isTopCoordinates);
//	}
//	
//	if (wantsMouseMoved) {
//		NSScreen* ptScreen = nil;
//		if (isPointOnAScreen(NSMakePoint(xPt, yPt) , &ptScreen)) { // validate the point is on a screen before moving
//			// if using bottom coords then we convert y point because out moving functions need top-style coords
//			if (!isTopCoordinates) yPt = [ptScreen frame].size.height - yPt;
//			
//			if (shouldStepMouseMovement) {
//				stepMouseToPoint(xPt, yPt, numSteps);
//			} else {
//				moveMouseToPoint(xPt, yPt);
//				myDelay(0.02);
//			}
//		} else {
//			fprintf(stderr, "Error: the point to move to is not on any of your current screens: %s, %s\n", [xString UTF8String], [yString UTF8String]);
//			return 1;
//		}
//	}
//	
//	if (shouldPerformLeftClick) {
//		CGEventFlags modKeys = getModKeysValue(useShift, useCommand, useOption, useControl); // modifier mask ie. shift-click
//		performLeftClick(modKeys);
//		if (!modKeys == 0) allModifiersUp();
//	}
//	
//	if (shouldPerformDoubleLeftClick) performDoubleLeftClick();
//	
//	if (shouldPerformRightClick) performRightClick();
//	
//	CFRelease(sourceRef);
//    [pool drain];
//    return 0;
//}

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
	performLeftClick(0); // we make sure the proper thing is selected by performing a left-click first
	
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
void moveMouseWithOffset(float x, float y){
    //CGWarpMouseCursorPosition(CGPointMake(x, y));
    tapLocation = kCGHIDEventTap; // used when specifying the tap location for CGEventPost
	CGEventRef moveMouse = CGEventCreateMouseEvent(sourceRef, kCGEventMouseMoved, CGPointMake(mouseLocationWithNSEvent().x + x, mouseLocationWithNSEvent().y + y), 0);
	CGEventPost(tapLocation, moveMouse);
	CFRelease(moveMouse);
}

void moveMouse(float x, float y){
    tapLocation = kCGHIDEventTap; // used when specifying the tap location for CGEventPost
	CGEventRef moveMouse = CGEventCreateMouseEvent(sourceRef, kCGEventMouseMoved, CGPointMake(x, y), 0);
	CGEventPost(tapLocation, moveMouse);
	CFRelease(moveMouse);
}

NSPoint mouseLocationWithNSEvent(){
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSString* locString = [NSString stringWithFormat:@"%.0f %.0f", mouseLoc.x, mouseLoc.y];
    NSLog(@"mouse location: %@", locString);
    return mouseLoc;
}

void mouseLocation(BOOL isTopCoordinates) {
	// when getting mouse coordinates, CGEvent measures from top-left and NSEvent measures from bottom-left
	if (isTopCoordinates) {
		CGEventRef mouseEvent = CGEventCreate(NULL);
		CGPoint mouseLoc = CGEventGetLocation(mouseEvent);
		NSString* locString = [NSString stringWithFormat:@"%.0f\n%.0f", (float)mouseLoc.x, (float)mouseLoc.y];
		fprintf(stdout, "%s\n", [locString UTF8String]);
		CFRelease(mouseEvent);
	} else {
		NSPoint mouseLoc = [NSEvent mouseLocation];
		NSString* locString = [NSString stringWithFormat:@"%.0f\n%.0f", mouseLoc.x, mouseLoc.y];
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
	int pCount = [pInfo count];
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
