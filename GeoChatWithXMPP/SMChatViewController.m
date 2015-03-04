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

@synthesize messageField, chatWithUser, tView, GeoLength,GeoLtitude,cameraView;



- (void)viewDidLoad {

    [super viewDidLoad];
    self.tView.delegate = self;
    self.tView.dataSource = self;
    messages = [[NSMutableArray alloc ] init];

    [self.messageField becomeFirstResponder];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    [self.messageField becomeFirstResponder];


    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }

    [self->locationManager startUpdatingLocation];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 186.0f, 280.0f, 88.0f);
    [button setTitle:@"Show Action Sheet" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor darkGrayColor];
    [button addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

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
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;

    if (currentLocation != nil) {
        GeoLtitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        GeoLength = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
}
- (void)stopUpdatingLocationWithMessage:(NSString *)state {

    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;


}


#pragma mark -
#pragma mark Actions

- (IBAction) closeChat {

    [[self appDelegate] disconnect];

    //SMLoginView *loginViewController = [[SMLoginView alloc]init];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[UIViewController presentViewController:loginViewController animated:YES completion:nil];



}

- (IBAction)radiusChange:(id)sender {
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

//    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
//
//    if (login) {
//
//        if ([[self appDelegate] connect]) {
//
//            NSLog(@"show buddy list");
//
//        }
//
//    } else {
//        
//        NSLog(@"all bad");
//    }

    
    
}




- (IBAction)sendMessage {

    NSString *messageStr = self.messageField.text;



    if([messageStr length]) {

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];

        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        [message addAttributeWithName:@"latitude" stringValue:GeoLtitude];
        [message addAttributeWithName:@"length" stringValue:GeoLength];
        [message addChild:body];

        [self.xmppStream sendElement:message];

        self.messageField.text = @"";


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



- (IBAction)openCamera:(id)sender {

    NSString *actionSheetTitle = @"Выбор камеры"; //Action Sheet Title
    NSString *destructiveTitle = @"Destructive Button"; //Action Sheet Button Titles
    NSString *other1 = @"Сфотографировать";
    NSString *other2 = @"Выбрать из галлереи";
    NSString *cancelTitle = @"Отмена";

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, nil];

    [actionSheet showInView:self.view];


}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if  ([buttonTitle isEqualToString:@"Destructive Button"]) {
        NSLog(@"Destructive pressed --> Delete Something");
    }



    if ([buttonTitle isEqualToString:@"Сфотографировать"]) {
        [self takePhoto];
    }
    if ([buttonTitle isEqualToString:@"Выбрать из галлереи"]) {
        [self selectPhoto];
    }

}

- (void)takePhoto {

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];

        [myAlertView show];
        [self selectPhoto];

    }
    else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

        [self presentViewController:picker animated:YES completion:NULL];
    }


}

- (void)selectPhoto {

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];


}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];

}



@end