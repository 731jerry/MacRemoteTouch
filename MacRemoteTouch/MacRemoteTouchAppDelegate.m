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
@property (nonatomic, assign) NSArray *locationCoordinateBeforeOffset;
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

- (void) runAppleScriptWithSource:(NSString *)souceSnippets ToShowMessageToServer:(NSString *)messageToServer {
    self.message = messageToServer;
    NSString *source = [NSString stringWithFormat:@"tell application \"System Events\"  to %@", souceSnippets];
    NSAppleScript *run = [[NSAppleScript alloc] initWithSource:source];
    [run executeAndReturnError:nil];
}

- (void)server:(Server *)server didAcceptData:(NSData *)data
{
    dispatch_queue_t acceptData = dispatch_queue_create("acceptData", NULL);
    dispatch_async(acceptData, ^{

    NSLog(@"Server did accept data %@", data);
    NSString *message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
    if(nil != message || [message length] > 0) {
//        self.message = message;
    } else {
        self.message = @"no data received";
    }

    // ConnectionTo:
    if ([message hasPrefix:@"Connection To: "]){
            
//        NSString * messageFinal = [_server getLocalName];
//        NSData *data = [messageFinal dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *error = nil;
//        NSLog(@"%@",data);
//        [_server sendData:data error:&error];
        
        self.message = message;
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
        
        dispatch_queue_t mouseMove = dispatch_queue_create("mouseMove", NULL);
        dispatch_async(mouseMove, ^{
            moveMouseWithCoordinateOffsetOnPortraitRotation(offsetX, offsetY);
        });
        dispatch_release(mouseMove);
	}
    
    if ([message hasPrefix:@"LocOffsetDis:"]){
        self.message = @"Mouse Moving";
        NSString *locationOffsetDistanceString = [message substringFromIndex:13];
        float distance = [locationOffsetDistanceString floatValue];
        
        dispatch_queue_t mouseMove = dispatch_queue_create("mouseMove", NULL);
        dispatch_async(mouseMove, ^{
            moveMouseWithOffsetDistance(distance);
        });
        dispatch_release(mouseMove);
	}
    
    
    // OneFingerSingleTap
    if ([message isEqual:@"OneFingerSingleTap"]) {
        self.message = @"Left click";
        dispatch_queue_t leftClick = dispatch_queue_create("leftClick", NULL);
        dispatch_async(leftClick, ^{
            performLeftClickWithoutModKeys();
        });
        dispatch_release(leftClick);
		
	}
    // OneFingerDoubleTap
    if ([message isEqual:@"OneFingerDoubleTap"]) {
        self.message = @"Double click";
        dispatch_queue_t leftDoubleClick = dispatch_queue_create("leftDoubleClick", NULL);
        dispatch_async(leftDoubleClick, ^{
            performDoubleLeftClick();
        });
        dispatch_release(leftDoubleClick);
	}
    // TwoFingerSingleTap
    if ([message isEqual:@"TwoFingerSingleTap"]) {
        self.message = @"Right click";
        dispatch_queue_t rightClick = dispatch_queue_create("RightClick", NULL);
        dispatch_async(rightClick, ^{
            performRightClickWell();
        });
        dispatch_release(rightClick);
		
        NSLog(@"right click down");
	}

    // VerticalDistance
    if ([message hasPrefix:@"VerticalDistance:"]){
        self.message = @"Vertical Scrolling";
        NSString *verticalDistance = [message substringFromIndex:17];
        float distance = [verticalDistance floatValue];
        NSLog(@"%@",message);
        NSLog(@"Vertical:%f",distance);
        dispatch_queue_t verticalScrolling =dispatch_queue_create("verticalScrolling", NULL);
        dispatch_async(verticalScrolling, ^{
            wheelScrollVertical(distance);
        });
        dispatch_release(verticalScrolling);
    }
        // HorizontalDistance
        if ([message hasPrefix:@"HorizontalDistance:"]){
            self.message = @"Horizontal Scrolling";
            NSString *horizontalDistance = [message substringFromIndex:19];
            float distance = [horizontalDistance floatValue];
//            NSLog(@"%@",message);
            NSLog(@"Horizontal:%f",distance);
            dispatch_queue_t horizontalScrolling =dispatch_queue_create("horizontalScrolling", NULL);
            dispatch_async(horizontalScrolling, ^{
                wheelScrollHorizontal(distance);
            });
            dispatch_release(horizontalScrolling);
        }
        
        // scroll
        if ([message hasPrefix:@"Scroll:"]){
            self.message = @"Scrolling";
            NSLog(@"data:%@",message);
            NSString *locationOffsetString = [message substringFromIndex:7];
            NSArray *locationCoordinateOffset = [locationOffsetString componentsSeparatedByString:@"+"];
            
            float offsetX = [[locationCoordinateOffset objectAtIndex:0] floatValue];
            float offsetY = [[locationCoordinateOffset objectAtIndex:1] floatValue];
            
            dispatch_queue_t scrolling = dispatch_queue_create("scrolling", NULL);
            dispatch_async(scrolling, ^{
                wheelScroll(offsetX, offsetY);
            });
            dispatch_release(scrolling);
        }
#pragma  mark -
#pragma  mark keyboard
    // KeyboardCode:
    if ([message hasPrefix:@"KeyboardCode:"]) {
        
//        CGKeyCode keyCode = 0xffff;
        NSString *keyboardCode = [message substringFromIndex:13];
//        char keyboardCodeChar = [keyboardCode characterAtIndex:0];
//        keyCode = keyCodeForChar(keyboardCodeChar);
        [self runAppleScriptWithSource:[NSString stringWithFormat:@"keystroke \"%@\"", keyboardCode] ToShowMessageToServer:@"Keyboard Inputing"];
	}
    // back space key code KeyboardBackSpaceCode
    if ([message isEqual:@"KeyboardBackSpaceCode"]) {
        [self runAppleScriptWithSource:@"key code 51" ToShowMessageToServer:@"Keyboard Inputing"];
	}
    
    if ([message isEqualToString:@"KeyboardReturnCode"]) {
        [self runAppleScriptWithSource:@"key code 36" ToShowMessageToServer:@"Keyboard Inputing"];
    }
        
    if ([message isEqualToString:@"KeyboardSpaceCode"]){
        [self runAppleScriptWithSource:@"key code 49" ToShowMessageToServer:@"Keyboard Inputing"];
    }

    // F14
    if ([message isEqualToString:@"BrightDown"]){
        [self runAppleScriptWithSource:@"key code 107" ToShowMessageToServer:@"Bright Down"];
    }
    // F15
    if ([message isEqualToString:@"BrightUp"]){
        [self runAppleScriptWithSource:@"key code 113" ToShowMessageToServer:@"Bright Up"];
    }
    if ([message isEqualToString:@"MissionControl"]){
        [self runAppleScriptWithSource:@"key code 126 using control down" ToShowMessageToServer:@"Mission Control Key"];
    }
#pragma mark -
    // NewFile
    if ([message isEqual:@"NewFile"]) {
        [self runAppleScriptWithSource:@"key code 45 using {command down, shift down}" ToShowMessageToServer:@"Add a New File"];
    }
    // CommandDelete
    if ([message isEqual:@"CommandDelete"]) {
        [self runAppleScriptWithSource:@"key code 51 using command down" ToShowMessageToServer:@"Command Delete"];
    }
    // ExitPresentation  keystroke \"h\" using command down"
    if ([message isEqual:@"ExitPresentation"]) {
        [self runAppleScriptWithSource:@"key code 53" ToShowMessageToServer:@"Exit Presentation"];
	}
    
    // PresentationBeginFromFirstPage
    if ([message isEqual:@"PresentationBeginFromFirstPage"]) {
        [self runAppleScriptWithSource:@"key code 52 using {command down, shift down}" ToShowMessageToServer:@"Presentation Begin at 1st Slide"];
	}
    // PresentationBeginFromCurrentPage
    if ([message isEqual:@"PresentationBeginFromCurrentPage"]) {
        [self runAppleScriptWithSource:@"key code 52 using {command down}" ToShowMessageToServer:@"Presentation Begin at 1st Slide"];
	}
    
    // KeynoteNext
    if ([message isEqual:@"KeynoteNext"]) {
        [self runAppleScriptWithSource:@"key code 125" ToShowMessageToServer:@"Next Slide"];
	}
    
    // KeynoteBack
    if ([message isEqual:@"KeynoteBack"]) {
        [self runAppleScriptWithSource:@"key code 126" ToShowMessageToServer:@"Previous Slide"];
	}
#pragma mark -
    // gamePlayUpArrow
    if ([message isEqual:@"gamePlayUpArrow"]) {
        [self runAppleScriptWithSource:@"key code 126" ToShowMessageToServer:@"Game Playing"];
	}
    
    // gamePlayRightArrow
    if ([message isEqual:@"gamePlayRightArrow"]) {
        [self runAppleScriptWithSource:@"key code 124" ToShowMessageToServer:@"Game Playing"];
	}
    
    // gamePlayLeftArrow
    if ([message isEqual:@"gamePlayLeftArrow"]) {
        [self runAppleScriptWithSource:@"key code 123" ToShowMessageToServer:@"Game Playing"];
	}
    
    // gamePlayDownArrow
    if ([message isEqual:@"gamePlayDownArrow"]) {
        [self runAppleScriptWithSource:@"key code 125" ToShowMessageToServer:@"Game Playing"];
        self.message = @"Game Playing";
	}
    
    // gamePlayA -> 'j' key
    if ([message isEqual:@"gamePlayA"]) {
        [self runAppleScriptWithSource:@"keystroke \"j\"" ToShowMessageToServer:@"Game Playing"];
	}
    
    // gamePlayB -> 'k' key
    if ([message isEqual:@"gamePlayB"]) {
        [self runAppleScriptWithSource:@"keystroke \"k\"" ToShowMessageToServer:@"Game Playing"];
	}
    
    // gamePlayC -> 'u' key
    if ([message isEqual:@"gamePlayC"]) {
        [self runAppleScriptWithSource:@"keystroke \"u\"" ToShowMessageToServer:@"Game Playing"];
	}
    
    // gamePlayD -> 'i' key
    if ([message isEqual:@"gamePlayD"]) {
        [self runAppleScriptWithSource:@"keystroke \"i\"" ToShowMessageToServer:@"Game Playing"];
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
        self.message = @"Selected next song";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to next track"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesPrevious"]) {
        self.message = @"Selected previous song";
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
        self.message = @"set volume to 1";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 1"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"FinderVol2"]) {
        self.message = @"set volume 2";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 3"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"FinderVol3"]) {
        self.message = @"set volume 6";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 6"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"FinderVol4"]) {
        self.message = @"set volume 10";
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 10"];
		[run executeAndReturnError:nil];
	}
	
	
	if ([message isEqual:@"cmdA"]) {
        [self runAppleScriptWithSource:@"keystroke \"a\" using command down" ToShowMessageToServer:@"Command + A"];
	}
	if ([message isEqual:@"cmdC"]) {
        [self runAppleScriptWithSource:@"keystroke \"c\" using command down" ToShowMessageToServer:@"Command + C"];
	}
	if ([message isEqual:@"cmdV"]) {
        [self runAppleScriptWithSource:@"keystroke \"v\" using command down" ToShowMessageToServer:@"Command + V"];
	}
	
	if ([message isEqual:@"cmdZ"]) {
        [self runAppleScriptWithSource:@"keystroke \"z\" using command down" ToShowMessageToServer:@"Command + Z"];
	}
	if ([message isEqual:@"cmdH"]) {
        [self runAppleScriptWithSource:@"keystroke \"h\" using command down" ToShowMessageToServer:@"Command + H"];
	}
	if ([message isEqual:@"cmdT"]) {
        [self runAppleScriptWithSource:@"keystroke \"t\" using command down" ToShowMessageToServer:@"Command + T"];
	}
	if ([message isEqual:@"cmdQ"]) {
        [self runAppleScriptWithSource:@"keystroke \"q\" using command down" ToShowMessageToServer:@"Command + Q"];
	}
    
    // shiftButtonAction
    if ([message isEqual:@"shiftButtonAction"]) {
        [self runAppleScriptWithSource:@"key code 56" ToShowMessageToServer:@"Shift Key"];
	}
    
    // CommandSpaceKey
	if ([message isEqual:@"CommandSpaceKey"]) {
        [self runAppleScriptWithSource:@"key code 49 using command down" ToShowMessageToServer:@"Command Space"];
	}
    
    // TabPrevious
    if ([message isEqual:@"TabPrevious"]) {
        [self runAppleScriptWithSource:@"key code 48 using shift down" ToShowMessageToServer:@"Previous Tab"];
	}
    
    // TabNext
    if ([message isEqual:@"TabNext"]) {
        [self runAppleScriptWithSource:@"key code 48" ToShowMessageToServer:@"Next Tab"];
	}
    
    // FOneKey
    if ([message isEqual:@"FOneKey"]) {
        [self runAppleScriptWithSource:@"key code 122" ToShowMessageToServer:@"F1 Key"];
	}
    
    // FTwoKey
    if ([message isEqual:@"FTwoKey"]) {
        [self runAppleScriptWithSource:@"key code 120" ToShowMessageToServer:@"F2 Key"];
	}
    
    // FThreeKey
    if ([message isEqual:@"FThreeKey"]) {
        [self runAppleScriptWithSource:@"key code 99" ToShowMessageToServer:@"F3 Key"];
	}
    
    // FFiveKey
    if ([message isEqual:@"FFiveKey"]) {
        [self runAppleScriptWithSource:@"key code 96" ToShowMessageToServer:@"F5 Key"];
	}
    
    // FSixKey
    if ([message isEqual:@"FSixKey"]) {
        [self runAppleScriptWithSource:@"key code 97" ToShowMessageToServer:@"F6 Key"];
	}

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
    });
    dispatch_release(acceptData);
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
	self.message = [NSString stringWithFormat:@"Added a service: %@", [service name]];//
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
    return (int)[self.services count];
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


