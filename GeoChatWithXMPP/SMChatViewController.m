//
//  SMChatViewController.m
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import "SMChatViewController.h"
#import "AppDelegate.h"
#import "SMLoginView.h"
@implementation SMChatViewController{

    CLLocationManager *locationManager;

}

@synthesize messageField, chatWithUser, tView, hLocation,wLocation;
;

- (void)viewDidLoad {

    [super viewDidLoad];
    self.tView.delegate = self;
    self.tView.dataSource = self;
    messages = [[NSMutableArray alloc ] init];

    [self.messageField becomeFirstResponder];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    [self.messageField becomeFirstResponder];

    if (self->locationManager == nil)
    {
        self->locationManager = [[CLLocationManager alloc] init];
        self->locationManager.desiredAccuracy =
        kCLLocationAccuracyNearestTenMeters;
        self->locationManager.delegate = self;
    }
    [self->locationManager startUpdatingLocation];

}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;

    if (currentLocation != nil) {
        hLocation = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        wLocation = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
}
- (void)stopUpdatingLocationWithMessage:(NSString *)state {
    //self.stateString = state;
    //[self.tableView reloadData];
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;

    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", @"Reset")
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(reset)];
    [self.navigationItem setLeftBarButtonItem:resetItem animated:YES];
}


#pragma mark -
#pragma mark Actions

- (IBAction) closeChat {

    [self dismissViewControllerAnimated:YES completion:nil];


}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];

    if (login) {

        if ([[self appDelegate] connect]) {

            NSLog(@"show buddy list");

        }

    } else {
        
        NSLog(@"all bad");
    }
    
    
    
}




- (IBAction)sendMessage {

    NSString *messageStr = self.messageField.text;
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;


    [locationManager startUpdatingLocation];
    hLocation;
    if([messageStr length]) {

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];

        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        [message addChild:body];

        [self.xmppStream sendElement:message];

        self.messageField.text = @"";


        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:messageStr forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];

        [messages addObject:m];
        [self.tView reloadData];

    }

//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//
//    [locationManager startUpdatingLocation];
//    hLocation;


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