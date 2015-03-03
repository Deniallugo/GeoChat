//
//  AppDelegate.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "AppDelegate.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "ViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize _chatDelegate, _messageDelegate;
@synthesize xmppCapabilities;
@synthesize xmppRoster;
@synthesize xmppvCardAvatarModule;
@synthesize xmppvCardTempModule;
@synthesize xmppStream;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure logging framework

    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // Setup the view controllers

    [window setRootViewController:viewController];
    [window makeKeyAndVisible];

    // Setup the XMPP stream

    [self setupStream];

    if (![self connect]) {

        [viewController presentViewController:loginViewController animated:YES completion:nil];

    }
    
    return YES;
}




- (void)setupStream {

    xmppStream = [[XMPPStream alloc] init];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:[XMPPCapabilitiesCoreDataStorage sharedInstance]];
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance]];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance]];
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];

    // Configure modules

    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    [xmppRoster setAutoFetchRoster:YES];
//    [xmppRoster setAutoRoster:YES];
    [xmppStream setHostName:@"5.143.95.49"];
    [xmppStream setHostPort:5222];

    /**
     * Add XMPPRoster as a delegate of XMPPvCardAvatarModule to cache roster photos in the roster.
     * This frees the view controller from having to save photos on the main thread.
     **/
    [xmppvCardAvatarModule addDelegate:xmppRoster delegateQueue:xmppRoster.moduleQueue];


    // Activate xmpp modules

    [xmppCapabilities activate:xmppStream];
    [xmppRoster activate:xmppStream];
    [xmppvCardTempModule activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];

    // Add ourself as a delegate to anything we may be interested in

    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

    allowSelfSignedCertificates = NO;
    allowSSLHostNameMismatch = NO;
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)connect {

    [self setupStream];

    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"];

    jabberID = [jabberID stringByAppendingString:@"@kampus_gid"];
    if (![xmppStream isDisconnected]) {
        return YES;
    }

    if (jabberID == nil || myPassword == nil) {

        return NO;
    }

    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;

    NSError *error = nil;
   // if ([xmppStream supportsInBandRegistration] )
     //   [xmppStream registerWithPassword:password error:&error];

    if (!
       [xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]
     // [xmppStream registerWithPassword:password error:&error]
        )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];


        return NO;
    }
   // if ([xmppStream supportsInBandRegistration] )
//        [xmppStream registerWithPassword:password error:&error];



    return YES;
}





- (void)disconnect {

    [self goOffline];
    [xmppStream disconnect];

}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {

    isOpen = YES;
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:password error:&error];

}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {

    [self goOnline];

}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {

    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];

    if (![presenceFromUser isEqualToString:myUsername]) {

        if ([presenceType isEqualToString:@"available"]) {

            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];

        } else if ([presenceType isEqualToString:@"unavailable"]) {

            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];

        }

    }

}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {

    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];

    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:@"msg"];
    [m setObject:from forKey:@"sender"];

    [_messageDelegate newMessageReceived:m];

}




@end
