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
    NSInteger identificator;
}

@synthesize  chatWithUser, GeoLongtitude,GeoLatitude,radius1,slider;



- (void)viewDidLoad {

    [super viewDidLoad];
    messages = [[NSMutableArray alloc ] init];
    Radius = 500.0;
    //bubble view
    bubbleTable.bubbleDataSource = self;
    identificator = 0 ;

    bubbleTable.showAvatars = YES;


 //   bubbleTable.delegate=self;


    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;

    [bubbleTable reloadData];

    // Keyboard events

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    XMPPJID *jid = [XMPPJID jidWithString:[[self appDelegate] login ]];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    [self waitingConnection].alpha = 0;
    //  TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];
    //  [turnSockets addObject:turnSocket];
    //  [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];


    //  GeoLocation

    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    
    [self->locationManager startUpdatingLocation];

    GeoLatitude =@"43.0288";
    GeoLongtitude = @"131.9013";


    //open camera
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 186.0f, 280.0f, 88.0f);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor darkGrayColor];
    [button addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    firstUpdateLocation = true;
    [self sendQuery];
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 1
                                                  target: self
                                                selector:@selector(sendQuery)
                                                userInfo: nil repeats:YES];

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

    CLLocation *currentLocation = newLocation;

    if (currentLocation != nil) {
        GeoLongtitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
       GeoLatitude  = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }

    if (firstUpdateLocation){
        [self sendQuery];
        firstUpdateLocation = false;
    }


}


- (void)stopUpdatingLocationWithMessage:(NSString *)state {

    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;


}


#pragma mark -
#pragma mark Actions

- (IBAction) closeChat {


    UIStoryboard * Main= [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SMLoginView * loginView = [Main instantiateViewControllerWithIdentifier:@"login"] ;

    [self presentViewController:loginView animated:YES completion:nil];

}

- (IBAction)radiusChange:(id)sender {
    float value = self.slider.value * 1000;
    self.radius1.text = [NSString stringWithFormat:@"%f",value ];
    Radius = value;
    [self sendQuery];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

}

-(NSBubbleData*) foundIdMessage:(NSString*) identifier{

    for(NSBubbleData* i in messages){
        if ( [i.identificator isEqualToString:identifier])
            return i;
    }
    return nil;

}

- (void)newMessageReceived:(NSMutableDictionary *)messageContent animated:(BOOL)animated {

    NSString *msg = [messageContent valueForKey:@"msg"];
    NSString *sender = [messageContent valueForKey:@"sender"];
    NSDate *data = [messageContent valueForKey:@"date"];
    identificator = [[messageContent valueForKey:@"id"] integerValue];
    NSBubbleData *m;
    NSString* s  = [NSString stringWithFormat: @"%ld", (long)identificator];
    if([sender isEqual:@"okMsg" ]){

        NSBubbleData* okMsg = [self foundIdMessage:s];
        if(okMsg)
            okMsg.delivered = YES;
        [bubbleTable reloadData];
        return;
    }

    if([sender  isEqual: @"you"]){
        m = [NSBubbleData dataWithText:msg date:data type:BubbleTypeMine ];
    }
    else
        m = [NSBubbleData dataWithText:msg date:data type:BubbleTypeSomeoneElse ];
    m.identificator = s;
    if([[messageContent valueForKey:@"delivered"] isEqual:@"yes"] ){
        m.delivered = YES;

    }
    [messages addObject:m];

    [bubbleTable reloadData];

    [bubbleTable scrollBubbleViewToBottomAnimated:animated];


}


- (void)newMessagesReceived:(NSMutableArray *)messagesRecv {
//    NSBubbleData* mes = [messages lastObject];

    [messages removeAllObjects];
    for(NSMutableDictionary* i in messagesRecv){

        [self newMessageReceived:i animated:NO];
    }
//    if( [messages lastObject] != mes){
      //  }

}



- (IBAction)sendMessage {

    NSString *messageStr = textField.text;
    identificator++;

    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    if([messageStr length]) {

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];


        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"id" integerValue: identificator];
        DDXMLElement *geoloc = [DDXMLElement elementWithName:@"geoloc" xmlns:@"http://jabber.org/protocol/geoloc"];



        NSXMLElement * latitude = [NSXMLElement elementWithName:@"lat" stringValue:GeoLatitude];
        NSXMLElement * longitude = [NSXMLElement elementWithName:@"lon" stringValue:GeoLongtitude];
        DDXMLElement *request = [DDXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];

        [geoloc addChild:latitude];
        [geoloc addChild:longitude];

        [message addChild:body];
        [message addChild:geoloc];
        [message addChild:request];

        [self.xmppStream sendElement:message];

        textField.text = @"";
        NSBubbleData *m = [NSBubbleData dataWithText:messageStr date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine ];
        m.delivered = NO;
        m.identificator = [NSString stringWithFormat: @"%ld", (long)identificator];
        [messages addObject:m];
        
        
    }

    [bubbleTable reloadData];

    [bubbleTable scrollBubbleViewToBottomAnimated:YES];

}


-(void) sendImage: (UIImage*) imagePic{

    NSString *messageStr =  textField.text;
    NSString *f = [self getCurrentTime];


    if([messageStr length] > 0 || [imagePic isKindOfClass:[UIImage class]] )

    {



        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];


        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];

        [message addAttributeWithName:@"id" integerValue: identificator];
        DDXMLElement *geoloc = [DDXMLElement elementWithName:@"geoloc" xmlns:@"http://jabber.org/protocol/geoloc"];



        NSXMLElement * latitude = [NSXMLElement elementWithName:@"lat" stringValue:GeoLatitude];
        NSXMLElement * longitude = [NSXMLElement elementWithName:@"lon" stringValue:GeoLongtitude];
        DDXMLElement *request = [DDXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];

        [geoloc addChild:latitude];
        [geoloc addChild:longitude];

        [message addChild:body];
        [message addChild:geoloc];
        [message addChild:request];

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

//        [self.xmppStream sendElement:message];

    }
    textField.text = @"";

    NSBubbleData *m = [NSBubbleData dataWithImage:imagePic date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];

    [messages addObject:m];

    [bubbleTable reloadData];

    [bubbleTable scrollBubbleViewToBottomAnimated:YES];


}


-(void) sendQuery{
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"get"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"geo:list:messages"];
    DDXMLElement *geo = [DDXMLElement elementWithName:@"geoloc"];

    NSXMLElement  * latitude = [NSXMLElement elementWithName:@"lat" stringValue:GeoLatitude];
    NSXMLElement * longitude = [NSXMLElement elementWithName:@"lon" stringValue:GeoLongtitude];
    NSXMLElement * radius = [NSXMLElement elementWithName:@"radius" stringValue:[NSString stringWithFormat:@"%.20lf", Radius ] ];
    NSXMLElement * number = [NSXMLElement elementWithName:@"number" stringValue:@"30"];

    [query addChild:geo];
    [geo addChild:latitude];
    [geo addChild:longitude];
    [query addChild:radius];
    [query addChild:number];
    [iq addChild:query];


    [[[self appDelegate] xmppStream] sendElement:iq];
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





#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self sendImage:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}




@end