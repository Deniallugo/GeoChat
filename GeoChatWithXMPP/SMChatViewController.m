//
//  SMChatViewController.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMChatViewController.h"
#import "AppDelegate.h"
@implementation SMChatViewController

@synthesize messageField, chatWithUser, tView;

- (void)viewDidLoad {

    [super viewDidLoad];
    self.tView.delegate = self;
    self.tView.dataSource = self;
    messages = [[NSMutableArray alloc ] init];

    [self.messageField becomeFirstResponder];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    [self.messageField becomeFirstResponder];

}

#pragma mark -
#pragma mark Actions

- (IBAction) closeChat {

    [self dismissModalViewControllerAnimated:YES];

}

- (IBAction)sendMessage {

    NSString *messageStr = self.messageField.text;

    if([messageStr length]) {

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];

        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        [message addChild:body];

        [self.xmppStream sendElement:message];

        self.messageField.text = @"";

     //   NSString *m = [NSString stringWithFormat:@"%@:%@", messageStr, @"you"];

        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:messageStr forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];

        [messages addObject:m];
        [self.tView reloadData];

    }
}

#pragma mark -
#pragma mark Table view delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *s = (NSDictionary *) [messages objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"MessageCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }

    cell.textLabel.text = [s objectForKey:@"msg"];
    cell.detailTextLabel.text = [s objectForKey:@"sender"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;

    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [messages count];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;

}

#pragma mark -
#pragma mark Chat delegates

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

- (id) initWithUser:(NSString *) userName {

    if (self = [super init]) {

        chatWithUser = userName;

    }

    return self;

}
@end