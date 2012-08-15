//
//  MacRemoteTouchAppDelegate.m
//  MacRemoteTouch
//
//  Created by Jerry Zhu on 8/15/12.
//  Copyright (c) 2012 Jerry Zhu. All rights reserved.
//

#import "MacRemoteTouchAppDelegate.h"

@implementation MacRemoteTouchAppDelegate

@synthesize window;

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


- (void)server:(Server *)server didAcceptData:(NSData *)data
{
    NSLog(@"Server did accept data %@", data);
    NSString *message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
    if(nil != message || [message length] > 0) {
        self.message = message;
    } else {
        self.message = @"no data received";
    }
	
    // touch pad //
	if ([message ]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to play"];
		[run executeAndReturnError:nil];
	}
    
    
    
	//iTunes
	if ([message isEqual:@"iTunesPlay"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to play"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesPause"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to pause"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesNext"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to next track"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesPrevious"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to previous track"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"iTunesVolumeUp"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to set sound volume to (sound volume + 25)"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"iTunesVolumeDown"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to set sound volume to (sound volume - 25)"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iTunesSearch"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"f\" using {command down, option down}"];
		[run executeAndReturnError:nil];
	}
	
	//FINDER
	
	if ([message isEqual:@"FinderCreateFolder"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"CreateFolder.scpt"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"FinderVol1"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 1"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"FinderVol2"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 3"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"FinderVol3"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 6"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"FinderVol4"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"set volume 10"];
		[run executeAndReturnError:nil];
	}
	
	
	if ([message isEqual:@"cmdA"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"a\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdC"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"c\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdV"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"v\" using command down"];
		[run executeAndReturnError:nil];
	}
	
    
	
	if ([message isEqual:@"cmdZ"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"z\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdH"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"h\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdT"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"t\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"cmdQ"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke \"q\" using command down"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"arrowU"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 126"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"arrowD"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 125 "];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"arrowL"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 123"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"arrowR"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 124"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"Delete"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 51"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"Enter"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 36"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"a"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"a\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"b"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"b\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"c"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"c\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"d"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"d\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"e"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"e\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"f"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"f\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"g"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"g\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"h"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"h\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"i"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"i\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"j"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"k\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"l"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"l\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"m"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"m\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"n"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"n\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"o"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"o\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"p"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"p\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"q"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"q\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"r"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"r\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"s"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"s\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"t"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"t\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"u"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"u\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"v"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"v\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"w"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"w\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"x"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"x\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"y"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"y\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"z"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"z\""];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"."]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \".\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@","]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \",\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"?"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"?\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"/"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"/\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"!"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"!\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"<"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"<\""];
		[run executeAndReturnError:nil];
	}if ([message isEqual:@">"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \">\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"{"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"{\""];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"}"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to keystroke \"}\""];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"Tab"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to key code 48"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"space"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  to key code 49"];
		[run executeAndReturnError:nil];
	}
	
	
	if ([message isEqual:@"iTunes"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" activate end tell"];
		[run executeAndReturnError:nil];
	}
	
	if ([message isEqual:@"iPhoto"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iPhoto\" activate"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"iMovie"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iMovie\" activate"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"iChat"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"iChat\" activate"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"Safari"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"Safari\"  activate"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"Terminal"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"Terminal\"  activate end tell"];
		[run executeAndReturnError:nil];
	}
	if ([message isEqual:@"Prefs"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"System Preferences\" activate"];
		[run executeAndReturnError:nil];
	}
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


