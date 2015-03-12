//
//  SMMessageDelegate.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

@protocol SMMessageDelegate

- (void)newMessageReceived:(NSDictionary *)messageConten animated:(BOOL) animated;
- (void)newMessagesReceived:(NSMutableArray*)messageContent;
@end
