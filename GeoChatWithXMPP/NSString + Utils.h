//
//  NSString+Utils.h
//  GeoChatWithXMPP
//
//  Created by Данил on 04/03/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Utils)

+ (NSString *) getCurrentTime;
- (NSString *) substituteEmoticons;

@end