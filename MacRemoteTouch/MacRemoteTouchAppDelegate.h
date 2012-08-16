//
//  MacRemoteTouchAppDelegate.h
//  MacRemoteTouch
//
//  Created by Jerry Zhu on 8/15/12.
//  Copyright (c) 2012 Jerry Zhu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Server.h"
#import "MouseTools.h"

@interface MacRemoteTouchAppDelegate : NSObject <NSApplicationDelegate, ServerDelegate>
{
	IBOutlet NSTableView *tableView;
    NSWindow *window;
	Server *_server;
	NSMutableArray *_services;
	NSString *textToSend, *_message;
	NSInteger selectedRow, connectedRow;
	BOOL isConnectedToService;
	
	NSAppleScript *iTunesPlay;
    
   
}


@property (assign) IBOutlet NSWindow *window;

@property(nonatomic, retain) Server *server;
@property(nonatomic, retain) NSMutableArray *services;
@property(readwrite, copy) NSString *message;
@property(readwrite, copy) NSString *message2;

@property(readwrite, nonatomic) BOOL isConnectedToService;
@end
