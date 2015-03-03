
//  SMLoginView.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMLoginView.h"
#import "SMRegistrationView.h"
@implementation SMLoginView

@synthesize loginField, passwordField;
- (IBAction) login {

    [[NSUserDefaults standardUserDefaults] setObject:self.loginField.text forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] setObject:self.hostField.text forKey:@"host"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction) hideLogin {

    [self dismissViewControllerAnimated:YES completion:nil];
    

}
//
- (IBAction)registration {

    SMRegistrationView* registrController = [[SMRegistrationView alloc] init];
    [self presentViewController:registrController animated:YES completion:nil];

}

- (IBAction)reg {
}

@end