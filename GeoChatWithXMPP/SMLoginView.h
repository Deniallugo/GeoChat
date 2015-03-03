//
//  SMLoginView.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface SMLoginView : UIViewController{
    UITextField *loginField;
    UITextField *passwordField;
    UITextField *hostField;
    ViewController* view;
}

@property (nonatomic,retain) IBOutlet UITextField *loginField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;
@property (nonatomic,retain) IBOutlet UITextField *hostField;
@property (nonatomic,retain) IBOutlet ViewController* view;

- (IBAction) login;
- (IBAction) hideLogin;
- (IBAction) registration;

@end