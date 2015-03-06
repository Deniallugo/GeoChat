//
//  SMRegistrationView.m
//  GeoChatWithXMPP
//
//  Created by Данил on 03/03/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMRegistrationView.h"
#import "AppDelegate.h"
#import "ViewController.h"
@implementation SMRegistrationView

@synthesize login,name,password;

-(IBAction)registr{
    [self createAccount];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)createAccount
{
    NSError *error = nil;
    NSString *juser =[[NSString alloc] initWithString:[login.text stringByAppendingString:@"@kampus_gid"]];

        NSMutableArray *elements = [NSMutableArray array];
        [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:juser]];
        [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:password.text]];

    if(
    [[self xmppStream ] registerWithElements:elements error:&error]){
        [self xmppStreamDidRegister:[self xmppStream]];
    }
    else
        [self xmppStream:[self xmppStream] didNotRegister:[NSXMLElement alloc]];



}


- (void)xmppStreamDidRegister:(XMPPStream *)sender{


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration with XMPP Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

}



- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration with XMPP   Failed!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    if (error) {
        [alert setMessage:@"error "];
        [alert show];
        return;
    }

    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];

    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];

    alert = [[UIAlertView alloc] initWithTitle:@"Registration with XMPP   Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

    if([errorCode isEqualToString:@"409"]){
        
        [alert setMessage:@"Username Already Exists!"];
    }
    if([errorCode isEqualToString:@"405"]){

        [alert setMessage:@"Bad login or password"];
    }
    [alert show];
}


- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}








@end




