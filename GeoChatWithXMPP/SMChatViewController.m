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

@synthesize  chatWithUser, GeoLength,GeoLtitude,radius1,slider;



- (void)viewDidLoad {

    [super viewDidLoad];
    messages = [[NSMutableArray alloc ] init];
    Radius = 500.0;
//bubble view
    bubbleTable.bubbleDataSource = self;


    bubbleTable.showAvatars = NO;



    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;

    [bubbleTable reloadData];

    // Keyboard events

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];    XMPPJID *jid = [XMPPJID jidWithString:[[self appDelegate] login ]];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];

    [turnSockets addObject:turnSocket];

    [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];


//GeoLocation

    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    [self->locationManager startUpdatingLocation];


//open camera
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 186.0f, 280.0f, 88.0f);
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
    //[errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{

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

    //[[self appDelegate] disconnect];

    UIStoryboard * Main= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SMLoginView * loginView = [Main instantiateViewControllerWithIdentifier:@"login"] ;
    [self presentViewController:loginView animated:YES completion:nil];



}

- (IBAction)radiusChange:(id)sender {
    float value = self.slider.value * 1000;
    self.radius1.text = [NSString stringWithFormat:@"%f",value ];
    Radius = value;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
}


- (void)newMessageReceived:(NSBubbleData *)messageContent {

    NSString *msg = [messageContent valueForKey:@"msg"];
    //NSString *sender = [messageContent valueForKey:@"sender"];
    NSBubbleData *m = [NSBubbleData dataWithText:msg date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];

    [messages addObject:m];

    [bubbleTable reloadData];

    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
                                                   inSection:0];

    [bubbleTable scrollToRowAtIndexPath:topIndexPath
                      atScrollPosition:UITableViewScrollPositionMiddle
                              animated:YES];
}


- (IBAction)sendMessage {

    NSString *messageStr = textField.text;

    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;

    NSString *f = [self getCurrentTime];
    if([messageStr length]) {

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];


        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        [message addAttributeWithName:@"latitude" stringValue:GeoLtitude];
        [message addAttributeWithName:@"length" stringValue:GeoLength];
        [message addAttributeWithName:@"time" stringValue:f];

        [message addChild:body];

        [self.xmppStream sendElement:message];

        textField.text = @"";




        NSBubbleData *m = [NSBubbleData dataWithText:messageStr date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];

        [messages addObject:m];

    }

    [bubbleTable reloadData];

    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
                                                   inSection:0];

    [bubbleTable scrollToRowAtIndexPath:topIndexPath
                       atScrollPosition:UITableViewScrollPositionMiddle
                               animated:YES];
}



#pragma mark - Bubble View



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [messages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [messages objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.2f animations:^{

        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;

        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.2f animations:^{

        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;

        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}

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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];


}

- (void)viewDidUnload {
    [super viewDidUnload];
}



- (NSString *) getCurrentTime {

    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowUTC];
    
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

    NSString *messageStr =  textField.text;
    NSString *f = [self getCurrentTime];


    if([messageStr length] > 0 || [imagePic isKindOfClass:[UIImage class]] )

    {
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];

        [body setStringValue:messageStr];


        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];

        [message addAttributeWithName:@"type"stringValue:@"chat"];

        [message addAttributeWithName:@"to"stringValue:nil];
        [message addAttributeWithName:@"latitude" stringValue:GeoLtitude];
        [message addAttributeWithName:@"length" stringValue:GeoLength];
        [message addAttributeWithName:@"time" stringValue:f];


        [message addChild:body];

        if([imagePic isKindOfClass:[UIImage class]])

        {

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
    textField.text = @"";

    NSBubbleData *m = [NSBubbleData dataWithImage:imagePic date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];

    [messages addObject:m];

    [bubbleTable reloadData];

    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count - 1
                                                   inSection:0];

    [bubbleTable scrollToRowAtIndexPath:topIndexPath
                       atScrollPosition:UITableViewScrollPositionMiddle
                               animated:YES];


}



#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];

    [self sendImage:chosenImage];

    [picker dismissViewControllerAnimated:YES completion:NULL];



}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [picker dismissViewControllerAnimated:YES completion:NULL];

}



@end