
//  SMLoginView.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMLoginView.h"
#import "SMRegistrationView.h"
#import "SMChatViewController.h"
@implementation SMLoginView

@synthesize loginField, passwordField;





- (IBAction) login {

    [[self appDelegate]connect];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.loginField.text forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] setObject:self.hostField.text forKey:@"host"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction) hideLogin {

    [self dismissViewControllerAnimated:YES completion:nil];
    

}

- (IBAction)registration {

    SMRegistrationView* registrController = [[SMRegistrationView alloc] init];
    [self presentViewController:registrController animated:YES completion:nil];

}


- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

@end