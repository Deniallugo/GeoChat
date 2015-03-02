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

@class ViewController;
@interface AppDelegate : NSObject{

    UIWindow *window;
    ViewController *viewController;

    XMPPStream *xmppStream;
    NSString *password;
    BOOL isOpen;

    __unsafe_unretained NSObject <SMChatDelegate> *chatDelegate;
    __unsafe_unretained NSObject <SMMessageDelegate> *messageDelegate;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ViewController *viewController;
@property (nonatomic, assign) id<SMChatDelegate>  _chatDelegate;
@property (nonatomic, assign) id <SMMessageDelegate> _messageDelegate;

@property (nonatomic, readonly) XMPPStream *xmppStream;

- (BOOL)connect;
- (void)disconnect;

@end
