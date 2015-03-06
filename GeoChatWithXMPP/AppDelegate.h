//
//  AppDelegate.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
#import "SMChatDelegatE.h"
#import "SMMessageDelegate.h"
#import "SMChatViewController.h"
#import "XMPPRoster.h"

@class SMLoginView;
@class XMPPStream;
@class XMPPCapabilities;
@class XMPPRosterCoreDataStorage;
@class XMPPvCardAvatarModule;
@class XMPPvCardTempModule;


@class ViewController;

@interface AppDelegate : NSObject <
UIApplicationDelegate,
XMPPRosterDelegate>

{

    UIWindow *window;
    ViewController *viewController;
    SMLoginView* loginViewController;
    NSString *login;
    NSString *password;
    BOOL isOpen;

    __unsafe_unretained NSObject <SMChatDelegate> *chatDelegate;
    __unsafe_unretained NSObject <SMMessageDelegate> *messageDelegate;


        XMPPStream *xmppStream;
        XMPPCapabilities *xmppCapabilities;
        XMPPRoster *xmppRoster;

        XMPPvCardAvatarModule *xmppvCardAvatarModule;
        XMPPvCardTempModule *xmppvCardTempModule;

        BOOL allowSelfSignedCertificates;
        BOOL allowSSLHostNameMismatch;
        NSError *error;
        NSString *host;

}

@property (nonatomic, retain) NSString *login;

@property (nonatomic, retain) NSString *host;



@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IBOutlet SMChatViewController *chatViewController;
@property (nonatomic, retain) IBOutlet ViewController *viewController;
@property (nonatomic, assign) id <SMChatDelegate>  _chatDelegate;
@property (nonatomic, assign) id <SMMessageDelegate> _messageDelegate;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, readonly) XMPPvCardTempModule *xmppvCardTempModule;



-(void)setupStream;
- (BOOL)connect;
- (void)disconnect;

@end
