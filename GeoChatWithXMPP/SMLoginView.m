
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

-(void) viewDidLoad{
    [self wait].alpha = 0;
    [self labelWait].alpha = 0;
}

- (IBAction) login {



    [[NSUserDefaults standardUserDefaults] setObject:self.loginField.text forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordField.text forKey:@"userPassword"];
    if ([self.loginField.text isEqualToString:@""]){
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Введите login и пароль"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    [[self appDelegate]connect];
    [self wait].alpha = 1;
    [self labelWait].alpha = 1;


}

- (IBAction) hideLogin {

    [self dismissViewControllerAnimated:YES completion:nil];


}

- (IBAction)registration {

    UIStoryboard * Main= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SMRegistrationView * regView = [Main instantiateViewControllerWithIdentifier:@"registration"] ;


    [self presentViewController:regView animated:UIViewAnimationOptionTransitionCrossDissolve completion:nil];


}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}


- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

@end