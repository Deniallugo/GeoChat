//
//  SMMessageViewTableCell.h
//  GeoChatWithXMPP
//
//  Created by Данил on 04/03/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMMessageViewTableCell : UITableViewCell {

    UILabel	*senderAndTimeLabel;
    UITextView *messageContentView;
    UIImageView *bgImageView;

}

@property (nonatomic,retain) UILabel *senderAndTimeLabel;
@property (nonatomic,retain) UITextView *messageContentView;
@property (nonatomic,retain) UIImageView *bgImageView;

@end