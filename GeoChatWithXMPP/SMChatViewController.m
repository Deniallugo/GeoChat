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
#import "TURNSocket.h"
@implementation SMChatViewController{

    CLLocationManager *locationManager;

}

@synthesize messageField, chatWithUser, tView, GeoLength,GeoLtitude,radius1,slider;



- (void)viewDidLoad {

    [super viewDidLoad];
    self.tView.delegate = self;
    self.tView.dataSource = self;
    messages = [[NSMutableArray alloc ] init];

    [self.messageField becomeFirstResponder];
    XMPPJID *jid = [XMPPJID jidWithString:[[self appDelegate] login ]];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    [self.messageField becomeFirstResponder];
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];

    [turnSockets addObject:turnSocket];

    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];




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


- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {

    NSLog(@"TURN Connection succeeded!");
    NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");

    [turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender {

    NSLog(@"TURN Connection failed!");
    [turnSockets removeObject:sender];
    
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
    float value = self.slider.value * 1000;
    self.radius1.text = [NSString stringWithFormat:@"%f",value ];
    Radius = value;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
}


- (void)newMessageReceived:(NSDictionary *)messageContent {

    NSString *m = [messageContent objectForKey:@"msg"];
    NSString  *f = [self getCurrentTime];
    [messageContent setValue:m  forKey:@"msg"];
    [messageContent setValue:f forKey:@"time"];

    [messages addObject:messageContent];
    [self.tView reloadData];

    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
                                                   inSection:0];

    [self.tView scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:YES];
}


- (IBAction)sendMessage {

    NSString *messageStr = self.messageField.text;



    if([messageStr length]) {

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSString *f =[self getCurrentTime];


        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        [message addAttributeWithName:@"latitude" stringValue:GeoLtitude];
        [message addAttributeWithName:@"length" stringValue:GeoLength];
        [message addAttributeWithName:@"time" stringValue:f];

        [message addChild:body];

        [self.xmppStream sendElement:message];

        self.messageField.text = @"";


        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:messageStr forKey:@"msg"];
        [m setObject:@"you" forKey:@"sender"];
        [m setObject:f forKey:@"time"];
        [messages addObject:m];
        [self.tView reloadData];

    }

    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
                                                   inSection:0];

    [self.tView scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:YES];
}

#pragma mark -
#pragma mark Table view delegates


static float padding = 20.0;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    NSDictionary *s = (NSDictionary *) [messages objectAtIndex:indexPath.row];

    static NSString *CellIdentifier = @"MessageCellIdentifier";

    SMMessageViewTableCell *cell = (SMMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[SMMessageViewTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] ;
    }

    NSString *sender = [s objectForKey:@"sender"];
    NSString *message = [s objectForKey:@"msg"];
    NSString *time = [s objectForKey:@"time"];
    UIImage *img =[s objectForKey:@"img"];

    UIImage *bgImage = nil;
    CGSize  textSize = { 260.0, 10000.0 };

    CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:20]
                      constrainedToSize:textSize
                          lineBreakMode:UILineBreakModeWordWrap];


    size.width += (padding/2);

    int originX,originY;

    cell.messageContentView.text  = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;


    if ([sender isEqualToString:@"you"]) { // left aligned

        bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];

        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width, size.height)];
        if ( img){
            originX = img.size.height;
            originY = img.size.width;
        }
        else{
            originX = cell.messageContentView.frame.origin.x;
            originY = cell.messageContentView.frame.origin.y;
            
        }
        [cell.bgImageView setFrame:CGRectMake( originX - padding/2,
                                              originY - padding/2,
                                              size.width+padding,
                                              size.height+padding)];

        
    } else {

        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];

        [cell.messageContentView setFrame:CGRectMake(320 - size.width - padding,
                                                     padding*2,
                                                     size.width,
                                                     size.height)];

        if ( img){
            originX = img.size.height;
            originY = img.size.width;
        }
        else{
            originX = cell.messageContentView.frame.origin.x;
            originY = cell.messageContentView.frame.origin.y;
            
        }

        [cell.bgImageView setFrame:CGRectMake(originX - padding/2,
                                              originY - padding/2,
                                              size.width+padding, 
                                              size.height+padding)];
        
    }

    cell.imageView.image = img;
    cell.bgImageView.image = bgImage;
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
    return cell;
    
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [messages count];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *dict = (NSDictionary *)[messages objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:@"msg"];

    CGSize  textSize = { 260.0, 10000.0 };

    CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13]
                  constrainedToSize:textSize
                      lineBreakMode:UILineBreakModeWordWrap];

    size.height += padding*3;

    CGFloat height = size.height < 65 ? 65 : size.height;
    return height;
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

#pragma mark -
#pragma mark Chat delegates

- (NSString *) getCurrentTime {

    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowUTC];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];


}

- (void)viewDidUnload {
    [super viewDidUnload];
}



#pragma mark - Send image method


- (IBAction)openCamera:(id)sender {

    NSString *actionSheetTitle = @"Выбор камеры"; //Action Sheet Title
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
                                                    otherButtonTitles: nil
                                    ];

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



-(void) sendImage: (UIImage*) imagePic{

    NSString *messageStr =  self.messageField.text;

    NSString *f =[self getCurrentTime];

    if([messageStr length] > 0 || [imagePic isKindOfClass:[UIImage class]] )

    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];

        [body setStringValue:messageStr];

        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];

        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];

        [message addAttributeWithName:@"type"stringValue:@"chat"];

        [message addAttributeWithName:@"to"stringValue:nil];
        [message addAttributeWithName:@"latitude" stringValue:GeoLtitude];
        [message addAttributeWithName:@"length" stringValue:GeoLength];
        [message addAttributeWithName:@"time" stringValue:f];


        [message addChild:body];

        if([imagePic isKindOfClass:[UIImage class]])

        {

            [m setObject:imagePic forKey:@"mage"];

            NSData *dataPic =  UIImagePNGRepresentation(imagePic);

            NSXMLElement *photo = [NSXMLElement elementWithName:@"PHOTO"];

            NSXMLElement *binval = [NSXMLElement elementWithName:@"BINVAL"];

            [photo addChild:binval];

            NSString *base64String = [dataPic base64EncodedStringWithOptions:0];
            
            [binval setStringValue:base64String];
            
            [message addChild:photo];
            
        }
        
        [self.xmppStream sendElement:message];

    }
    self.messageField.text = @"";


    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:imagePic forKey:@"img"];
    [m setObject:messageStr forKey:@"msg"];
    [m setObject:@"you" forKey:@"sender"];
    [m setObject:f forKey:@"time"];


    [messages addObject:m];
    [self.tView reloadData];

}



#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
//    self.imageView.image = chosenImage;

    [self sendImage:chosenImage];

    [picker dismissViewControllerAnimated:YES completion:NULL];



}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];

}



@end