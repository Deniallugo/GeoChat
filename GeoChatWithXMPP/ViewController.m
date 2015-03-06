//
//  ViewController.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "ViewController.h"
#import "SMLoginView.h"
@interface ViewController ()

@end

@implementation ViewController

@synthesize tView;

- (void)viewDidLoad {

    [super viewDidLoad];
    self.tView.delegate = self;
    self.tView.dataSource = self;
    onlineBuddies = [[NSMutableArray alloc ] init];
    AppDelegate *del = [self appDelegate];
    del._chatDelegate = self;
    

}

- (IBAction) showLogin {
    [[self appDelegate] disconnect];
//    SMLoginView *loginController = [[SMLoginView alloc] init];
//    [self presentViewController:loginController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Table view delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *s = (NSString *) [onlineBuddies objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"UserCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }

    cell.textLabel.text = s;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [onlineBuddies count];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


        NSString *userName = (NSString *) [onlineBuddies objectAtIndex:indexPath.row];
        SMChatViewController *chatController = [[SMChatViewController alloc] initWithUser:userName];
        [self presentViewController:chatController animated:YES completion:nil];
        
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];

    if (login) {

        if ([[self appDelegate] connect]) {

            NSLog(@"show buddy list");

        }

    } else {

        [self showLogin];
    }

    

}

- (void)newBuddyOnline:(NSString *)buddyName {
    [onlineBuddies addObject:buddyName];
    [self.tView reloadData];
}

- (void)buddyWentOffline:(NSString *)buddyName {
    [onlineBuddies removeObject:buddyName];
    [self.tView reloadData];
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}


@end
