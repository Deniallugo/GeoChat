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

- (void)updateAccountInfo
{


    //NSString *domain = [[NSString alloc] initWithString:@"192.168.1.100"];

    //int port = 5222;
//    [[self appDelega];

    NSString *usname =[[NSString alloc] initWithString:login.text];
    NSString *juser =[[NSString alloc] initWithString:[usname stringByAppendingString:@"your server ip"]];

    XMPPJID *jid = [XMPPJID jidWithString:juser];
    [self  xmppStream].myJID =jid;

    //allowSelfSignedCertificates =  NSOnState;
   // allowSSLHostNameMismatch    =  NSOnState;
    NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];

    //[dflts setObject:domain forKey:@"Account.Server"];

    //  [dflts setObject:(port ? [NSNumber numberWithInt:port] : nil)
    //    forKey:@"Account.Port"];

    [dflts setObject:juser
              forKey:@"Account.JID"];
    [dflts setObject:@"ios"
              forKey:@"Account.Resource"];

//    [dflts setBool:useSSL                      forKey:@"Account.UseSSL"];
 //   [dflts setBool:allowSelfSignedCertificates forKey:@"Account.AllowSelfSignedCert"];
   // [dflts setBool:allowSSLHostNameMismatch    forKey:@"Account.AllowSSLHostNameMismatch"];
    [dflts setBool:YES forKey:@"Account.RememberPassword"];

    [dflts setObject:password.text forKey:@"Account.Password"];
    [dflts synchronize];



}

- (void)createAccount
{
    [self updateAccountInfo];
    [[self xmppStream] setHostName:@"5.143.95.49"];
    [[self xmppStream] setHostPort:5222];
    NSError *error = nil;
    BOOL success;

    if(![[[self appDelegate] xmppStream] isConnected])
    {

   //     if (useSSL)
     //       success = [[self  xmppStream] oldSchoolSecureConnectWithTimeout:XMPPStreamTimeoutNone error:&error];
       // else
            success = [[self xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    }
    else
    {
        //NSString *password = [[NSString alloc] initWithString:@"321" ];

        success = [[self xmppStream] registerWithPassword:password.text error:&error];
    }


    if (success)
    {
//        [self appDelegate].isRegistering = YES;
        NSLog(@" succeed ");

    }
    else
    {
        NSLog(@"not succeed ");

    }
}


- (void)xmppStreamDidRegister:(XMPPStream *)sender{


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration with XMPP Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

}



- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{

    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];

    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration with XMPP   Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

    if([errorCode isEqualToString:@"409"]){
        
        [alert setMessage:@"Username Already Exists!"];
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



