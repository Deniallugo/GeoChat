//
//  SMRegistrationView.h
//  GeoChatWithXMPP
//
//  Created by Данил on 03/03/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface SMRegistrationView : UIViewController

@property (nonatomic,retain) IBOutlet UITextField *password;
@property (nonatomic,retain) IBOutlet UITextField *login;
@property (nonatomic,retain) IBOutlet UITextField *name;

- (IBAction)registr;

- (IBAction)close:(id)sender;
@end
