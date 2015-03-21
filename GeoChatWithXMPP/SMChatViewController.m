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

    self.title = @"JSQMessages";

    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = @"you";
    self.senderDisplayName = kJSQDemoAvatarDisplayNameSquires;


    /**
     *  Load up our fake data for the demo
     */
 //   self.demoData = [[DemoModelData alloc] init];
       self.demoData = [[DemoModelData alloc] init] ;

    /**
     *  You can set custom avatar sizes
     */
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }

    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }

    self.showLoadEarlierMessagesHeader = YES;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:nil];



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
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    button.frame = CGRectMake(20.0f, 186.0f, 280.0f, 88.0f);
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    button.tintColor = [UIColor darkGrayColor];
//    [button addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    firstUpdateLocation = true;
    [self sendQuery];
//    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 1
//                                                  target: self
//                                                selector:@selector(sendQuery)
//                                                userInfo: nil repeats:YES];

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(closeChat)];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:nil];

    NSArray *actionButtonItems = @[shareItem, cameraItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
//                                                                   style:UIBarButtonItemStyleBordered
//                                                                  target:self
//                                                                  action:nil];
//    [self.navigationController.toolbar setItems:[NSArray arrayWithObjects: doneButton, nil] animated:YES];
//    

    
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





- (void)pushMainViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:nc.topViewController animated:YES];
}





-(JSQMessage*) foundIdMessage:(NSString*) identifier{

    for(JSQMessage* i in self.demoData.messages){
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
    NSString* s  = [NSString stringWithFormat: @"%ld", (long)identificator];


    if([sender isEqual:@"okMsg" ]){

        JSQMessage* okMsg = [self foundIdMessage:s];
        if(okMsg)
            okMsg.delivered = YES;
        [self finishReceivingMessageAnimated:YES];
        return;
    }




    JSQMessage *m = [[JSQMessage alloc] initWithSenderId:sender
                                       senderDisplayName:sender
                                                    date:data
                                                    text:msg];

    m.identificator = s;
    if([[messageContent valueForKey:@"delivered"] isEqual:@"yes"] ){
        m.delivered = YES;

    }



    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self.demoData.messages addObject:m];
    [self finishReceivingMessageAnimated:YES];

//
//    if (m.isMediaMessage) {
//        /**
//         *  Simulate "downloading" media
//         */
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            /**
//             *  Media is "finished downloading", re-display visible cells
//             *
//             *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
//             *
//             *  Reload the specific item, or simply call `reloadData`
//             */
//
//            if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
//                ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
//                [self.collectionView reloadData];
//            }
//            else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
//                [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
//                    [self.collectionView reloadData];
//                }];
//            }
//            else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
//                ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
//                ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
//                [self.collectionView reloadData];
//            }
//            else {
//                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
//            }
//
//        });
//    }

//});





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






#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{

    identificator++;

    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:text];


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




    [JSQSystemSoundPlayer jsq_playMessageSentSound];

    JSQMessage *m = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];



    m.delivered = NO;
    m.identificator = [NSString stringWithFormat: @"%ld", (long)identificator];
    [messages addObject:m];











    [self.demoData.messages addObject:m];

    [self finishSendingMessageAnimated:YES];
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

    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:imagePic];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:@"you"
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.demoData.messages addObject:photoMessage];
    [self finishSendingMessageAnimated:YES];

}


-(void) sendQuery{
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"get"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"geo:list:messages"];
    DDXMLElement *geo = [DDXMLElement elementWithName:@"geoloc"];

    NSXMLElement  * latitude = [NSXMLElement elementWithName:@"lat" stringValue:GeoLatitude];
    NSXMLElement * longitude = [NSXMLElement elementWithName:@"lon" stringValue:GeoLongtitude];
    NSXMLElement * radius = [NSXMLElement elementWithName:@"radius" stringValue:[NSString stringWithFormat:@"%.20lf", Radius ] ];
    NSXMLElement * number = [NSXMLElement elementWithName:@"number" stringValue:@"1"];

    [query addChild:geo];
    [geo addChild:latitude];
    [geo addChild:longitude];
    [query addChild:radius];
    [query addChild:number];
    [iq addChild:query];


    [[[self appDelegate] xmppStream] sendElement:iq];
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


- (void)didPressAccessoryButton:(UIButton *)sender{

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




#pragma mark - JSQVIEW



- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */

    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }

    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */

    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }


    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }

    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];

    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }

    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */

    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];

    if (!msg.isMediaMessage) {

        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }

        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }

    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */

    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }

    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }

    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}








@end