//
//  SMMessageDelegate.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

@protocol SMMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageContent animated:(BOOL)animated;
- (void)newMessagesReceived:(NSMutableArray *)messagesRecv;

@end
