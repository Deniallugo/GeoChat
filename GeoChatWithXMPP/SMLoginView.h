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
}

@property (nonatomic,retain) IBOutlet UITextField *loginField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;


- (IBAction) login;
- (IBAction) hideLogin;
- (IBAction) registration;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *wait;
@property (weak, nonatomic) IBOutlet UILabel *labelWait;

@end