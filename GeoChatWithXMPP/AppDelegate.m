//
//  AppDelegate.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize _chatDelegate, _messageDelegate;

- (void)setupStream {
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream setHostName:@"5.143.95.49"];
    [xmppStream setHostPort:5222];

    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
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




    if (![xmppStream isDisconnected]) {
        return YES;
    }

    if (jabberID == nil || myPassword == nil) {

        return NO;
    }

    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;

    NSError *error = nil;
     
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];


        return NO;
    }


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
