//
//  SMLoginView.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMLoginView.h"

@implementation SMLoginView

@synthesize loginField, passwordField;

- (IBAction) login {

    [[NSUserDefaults standardUserDefaults] setObject:self.loginField.text forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissModalViewControllerAnimated:YES];

}

- (IBAction) hideLogin {

    [self dismissModalViewControllerAnimated:YES];

}

@end