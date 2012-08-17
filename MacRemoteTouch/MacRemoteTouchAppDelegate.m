//
//  MacRemoteTouchAppDelegate.m
//  MacRemoteTouch
//
//  Created by Jerry Zhu on 8/15/12.
//  Copyright (c) 2012 Jerry Zhu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MacRemoteTouchAppDelegate.h"
#import <AppKit/AppKit.h>

@interface MacRemoteTouchAppDelegate()
@property (nonatomic) NSArray *locationCoordinateBeforeOffset;
@end

@implementation MacRemoteTouchAppDelegate

@synthesize window;

@synthesize locationCoordinateBeforeOffset = _locationCoordinateBeforeOffset;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
	connectedRow = -1;
	self.services = [[NSMutableArray alloc] init];
	
	NSString *type = @"TestingProtocol";
	
	_server = [[Server alloc] initWithProtocol:type];
    _server.delegate = self;
	
    NSError *error = nil;
    if(![_server start:&error]) {
        NSLog(@"error = %@", error);
        self.message = [NSString stringWithFormat:@"Server has error: %@", error];
    } else {
        self.message = @"Server is ready to be connected";
    }
}

- (void)dealloc
{
	[_server release];
	[_services release];
	[_message release];
	[super dealloc];
}

#pragma mark -
#pragma mark Interface methods

- (IBAction)connectToService:(id)sender;
{
	[self.server connectToRemoteService:[self.services objectAtIndex:selectedRow]];
}

- (IBAction)sendText:(id)sender;
{
	NSData *data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	[self.server sendData:data error:&error];
	
}

#pragma mark -
#pragma mark Server delegate methods

- (void)serverRemoteConnectionComplete:(Server *)server
{
    NSLog(@"Connected to service");
	
	self.isConnectedToService = YES;
	
	connectedRow = selectedRow;
	[tableView reloadData];
}

- (void)serverStopped:(Server *)server
{
    NSLog(@"Disconnected from service");
	self.message = @"Disconnected from service";//
	self.isConnectedToService = NO;
	
//    [_server stop];//
	connectedRow = -1;
	[tableView reloadData];
}

- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict
{
    NSLog(@"Server did not start %@", errorDict);
    self.message = [NSString stringWithFormat:@"Server did not start %@", errorDict];//
}

- (void) touchPadMove:(float)locationX :(float)locationY{
    NSLog(@"location: %f, %f", locationX, locationY);
}

- (void)server:(Server *)server didAcceptData:(NSData *)data
{
    NSLog(@"Server did accept data %@", data);
    NSString *message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
    if(nil != message || [message length] > 0) {
//        self.message = message;
    } else {
        self.message = @"no data received";
    }

#pragma mark -
#pragma mark touch pad
    // touch pad move //
	if ([message hasPrefix:@"Location:"]){
        self.message = @"Mouse Moving";
        NSString *locationString = [message substringFromIndex:9];
        NSArray *locationCoordinate = [locationString componentsSeparatedByString:@"+"];
        
        float locationX = [[locationCoordinate objectAtIndex:0] floatValue];
        float locationY = [[locationCoordinate objectAtIndex:1] floatValue];
//        CGFloat locationX = [locationCoordinate stringAtIndex:0];
//        [self touchPadMove:locationX :locationY];
        

        moveMouseToPoint(locationX, locationY);
	}
    
    if ([message hasPrefix:@"LocCoorOffset:"]){
        self.message = @"Mouse Moving";
        NSString *locationOffsetString = [message substringFromIndex:14];
        NSArray *locationCoordinateOffset = [locationOffsetString componentsSeparatedByString:@"+"];
        
        float offsetX = [[locationCoordinateOffset objectAtIndex:0] floatValue];
        float offsetY = [[locationCoordinateOffset objectAtIndex:1] floatValue];
        //        CGFloat locationX = [locationCoordinate stringAtIndex:0];
        //        [self touchPadMove:locationX :locationY];
        
        mouseFlexibility = 5; // set mouse flexibility
        moveMouseWithCoordinateOffset(offsetX, offsetY);
	}
    
    if ([message hasPrefix:@"LocOffsetDis:"]){
        self.message = @"Mouse Moving";
        NSString *locationOffsetDistanceString = [message substringFromIndex:13];
        float distance = [locationOffsetDistanceString floatValue];
        
        moveMouseWithOffsetDistance(distance);
	}
    
    
    // OneFingerSingleTap
    if ([message isEqual:@"OneFingerSingleTap"]) {
        self.message = @"Left click";
		performLeftClickWithoutModKeys();
	}
    // OneFingerDoubleTap
    if ([message isEqual:@"OneFingerDoubleTap"]) {
        self.message = @"Double click";
		performDoubleLeftClick();
	}
    // TwoFingerSingleTap
    if ([message isEqual:@"TwoFingerSingleTap"]) {
        self.message = @"Right click";
		performRightClick();
	}

#pragma  mark -
#pragma  mark keyboard
    // KeyboardCode:
    if ([message hasPrefix:@"KeyboardCode:"]) {
        self.message = @"Keyboard Inputing";
//        CGKeyCode keyCode = 0xffff;
        NSString *keyboardCode = [message substringFromIndex:13];
//        char keyboardCodeChar = [keyboardCode characterAtIndex:0];
//        keyCode = keyCodeForChar(keyboardCodeChar);
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to keystroke \"%@\"", keyboardCode];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    // back space key code KeyboardBackSpaceCode
    if ([message isEqual:@"KeyboardBackSpaceCode"]) {
        self.message = @"Keyboard Inputing";
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 51"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}

#pragma mark -
    // ExitPresentation
    if ([message isEqual:@"ExitPresentation"]) {
        self.message = @"Exit Presentation";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 53"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // PresentationBegin
    if ([message isEqual:@"PresentationBegin"]) {
        self.message = @"Presentation Begin";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 96"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // KeynoteNext
    if ([message isEqual:@"KeynoteNext"]) {
        self.message = @"Next Slide";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 125"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // KeynoteBack
    if ([message isEqual:@"KeynoteBack"]) {
        self.message = @"Previous Slide";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 126"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
#pragma mark -
    // gamePlayUpArrow
    if ([message isEqual:@"gamePlayUpArrow"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 126"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // gamePlayRightArrow
    if ([message isEqual:@"gamePlayRightArrow"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 124"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // gamePlayLeftArrow
    if ([message isEqual:@"gamePlayLeftArrow"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 123"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // gamePlayDownArrow
    if ([message isEqual:@"gamePlayDownArrow"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 125"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // gamePlayA -> 'j' key
    if ([message isEqual:@"gamePlayA"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 8"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // gamePlayB -> 'k' key
    if ([message isEqual:@"gamePlayB"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 9"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // gamePlayC -> 'u' key
    if ([message isEqual:@"gamePlayC"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 3"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
    // gamePlayD -> 'i' key
    if ([message isEqual:@"gamePlayD"]) {
        self.message = @"Game Playing";
		performRightClick();
        NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to key code 5"];
        NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
        [run executeAndReturnError:nil];
	}
    
#pragma mark -
#pragma mark others
	//iTunes
	if ([message isEqual:@"iTunesPlay"]) {
        self.message = @"iTunes playing";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to play"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesPause"]) {
        self.message = @"iTunes get paused";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to pause"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesNext"]) {
        self.message = @"Playing next song";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to next track"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesPrevious"]) {
        self.message = @"Playing the previous song";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to previous track"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"iTunesVolumeUp"]) {
        self.message = @"iTunes volume up (+10)";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to set sound volume to (sound volume + 10)"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"iTunesVolumeDown"]) {
        self.message = @"iTunes volume down (-10)";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to set sound volume to (sound volume - 10)"];
		[run executeAndReturnError:nil];
	}
	
//	if ([message isEqual:@"iTunesSearch"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"f\" using {command down, option down}"];
//		[run executeAndReturnError:nil];
//	}
	
	//FINDER
	
//	if ([message isEqual:@"FinderCreateFolder"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"CreateFolder.scpt"];
//		[run executeAndReturnError:nil];
//	}
	
	if ([message isEqual:@"FinderVol1"]) {
        self.message = message;
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 1"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"FinderVol2"]) {
        self.message = message;
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 3"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"FinderVol3"]) {
        self.message = message;
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 6"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"FinderVol4"]) {
        self.message = message;
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 10"];
		[run executeAndReturnError:nil];
	}
	
	
	if ([message isEqual:@"cmdA"]) {
        self.message = @"Command + A";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"a\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdC"]) {
        self.message = @"Command + C";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"c\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdV"]) {
        self.message = @"Command + V";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"v\" using command down"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"cmdZ"]) {
        self.message = @"Command + Z";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"z\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdH"]) {
        self.message = @"Command + H";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"h\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdT"]) {
        self.message = @"Command + T";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"t\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdQ"]) {
        self.message = @"Command + Q";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"q\" using command down"];
		[run executeAndReturnError:nil];
	}
    
	if ([message isEqual:@"arrowU"]) {
        self.message = @"Up Arrow";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 126"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"arrowD"]) {
        self.message = @"Down Arrow";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 125 "];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"arrowL"]) {
        self.message = @"Left Arrow";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 123"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"arrowR"]) {
        self.message = @"Right Arrow";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 124"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"Delete"]) {
        self.message = message;
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 51"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"Enter"]) {
        self.message = message;
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 36"];
		[run executeAndReturnError:nil];
	}
	
//	if ([message isEqual:@"a"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"a\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"b"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"b\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"c"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"c\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"d"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"d\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"e"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"e\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"f"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"f\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"g"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"g\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"h"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"h\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"i"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"i\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"j"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"k\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"l"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"l\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"m"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"m\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"n"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"n\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"o"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"o\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"p"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"p\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"q"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"q\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"r"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"r\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"s"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"s\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"t"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"t\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"u"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"u\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"v"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"v\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"w"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"w\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"x"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"x\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"y"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"y\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"z"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"z\""];
//		[run executeAndReturnError:nil];
//	}
//	
//	if ([message isEqual:@"."]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \".\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@","]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \",\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"?"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"?\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"/"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"/\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"!"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"!\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"<"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"<\""];
//		[run executeAndReturnError:nil];
//	}if ([message isEqual:@">"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \">\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"{"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"{\""];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"}"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"}\""];
//		[run executeAndReturnError:nil];
//	}
//	
//	if ([message isEqual:@"Tab"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to key code 48"];
//		[run executeAndReturnError:nil];
//	}
//	
//	if ([message isEqual:@"space"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to key code 49"];
//		[run executeAndReturnError:nil];
//	}
//	
//	
//	if ([message isEqual:@"iTunes"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" activate end tell"];
//		[run executeAndReturnError:nil];
//	}
//	
//	if ([message isEqual:@"iPhoto"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iPhoto\" activate"];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"iMovie"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iMovie\" activate"];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"iChat"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iChat\" activate"];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"Safari"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\"  activate"];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"Terminal"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"Terminal\"  activate end tell"];
//		[run executeAndReturnError:nil];
//	}
//	if ([message isEqual:@"Prefs"]) {
//        self.message = message;
//		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Preferences\" activate"];
//		[run executeAndReturnError:nil];
//	}
}

- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict
{
	NSLog(@"Lost connection");
	
    self.message = @"Lost connection";//
	self.isConnectedToService = NO;
	connectedRow = -1;
	[tableView reloadData];
//    [_server stop];//
}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more
{
	NSLog(@"Added a service: %@", [service name]);
	self.message = [NSString stringWithFormat:@"Added a service: %@", [service name]];;//
    [self.services addObject:service];
    if(!more) {
        [tableView reloadData];
    }
}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more
{
	NSLog(@"Removed a service: %@", [service name]);
	
    [self.services removeObject:service];
    if(!more) {
        [tableView reloadData];
    }
//    [_server stop]; //
}

#pragma mark -
#pragma mark NSTableView delegate methods

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (rowIndex == connectedRow)
		[aCell setTextColor:[NSColor redColor]];
	else
		[aCell setTextColor:[NSColor blackColor]];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [[self.services objectAtIndex:rowIndex] name];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	//NSLog(@"Count: %d", [self.services count]);
    return [self.services count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
	selectedRow = [[aNotification object] selectedRow];
}

#pragma mark -
#pragma mark Accessors

@synthesize server = _server;
@synthesize services = _services;
@synthesize message = _message;
@synthesize isConnectedToService;


@end


