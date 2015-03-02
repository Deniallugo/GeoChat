//
//  ViewController.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMChatDelegatE.h"
#import "AppDelegate.h"
#import "SMChatViewController.h"
@interface ViewController : UIViewController <SMChatDelegate>{

UITableView *tView;
NSMutableArray *onlineBuddies;

}

@property (nonatomic,retain) IBOutlet UITableView *tView;

- (IBAction) showLogin;

@end


