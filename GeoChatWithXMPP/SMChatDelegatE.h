//
//  SMChatDelegatE.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

@protocol SMChatDelegate

- (void)newBuddyOnline:(NSString *)buddyName;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;

@end