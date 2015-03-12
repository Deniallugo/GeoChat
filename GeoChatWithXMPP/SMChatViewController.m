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

@synthesize  chatWithUser, GeoLength,GeoLtitude,radius1,slider,navigationItem;



- (void)viewDidLoad {

    [super viewDidLoad];
    self.title = @"JSQMessages";
//self.navigationItem.titleView =
    
    messages = [[NSMutableArray alloc ] init];
    Radius = 500.0;
    // Jsq
    self.senderId = kJSQDemoAvatarIdSquires;
    self.senderDisplayName = kJSQDemoAvatarDisplayNameSquires;
    self.demoData = [[DemoModelData alloc] init];

    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }

    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }

    self.showLoadEarlierMessagesHeader = YES;
//
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(closeChat)];





    XMPPJID *jid = [XMPPJID jidWithString:[[self appDelegate] login ]];

    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    [self waitingConnection].alpha = 0;
//      TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];
//      [turnSockets addObject:turnSocket];
//      [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];


    //  GeoLocation

    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self->locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self->locationManager requestWhenInUseAuthorization];
    }
    [self->locationManager startUpdatingLocation];

    GeoLtitude = [NSString stringWithFormat:@"%.8f", [locationManager location].coordinate.longitude];
    GeoLength = [NSString stringWithFormat:@"%.8f", [locationManager location].coordinate.latitude];

    //open camera
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 186.0f, 280.0f, 88.0f);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor darkGrayColor];
    [button addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    firstUpdateLocation = true;
    [self sendQuery];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                            action:@selector(closeChat)];
    //}
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
}

//- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
//
//    NSLog(@"TURN Connection succeeded!");
//    NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
//
//    [turnSockets removeObject:sender];
//}
//
//- (void)turnSocketDidFail:(TURNSocket *)sender {
//
//    NSLog(@"TURN Connection failed!");
//    [turnSockets removeObject:sender];
//
//}




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
        GeoLtitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        GeoLength = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
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



-(void) sendQuery{
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"get"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" xmlns:@"geo:list:messages"];
    NSXMLElement * latitude = [NSXMLElement elementWithName:@"latitude" stringValue:GeoLtitude];
    NSXMLElement * longitude = [NSXMLElement elementWithName:@"longitude" stringValue:GeoLength];
    NSXMLElement * radius = [NSXMLElement elementWithName:@"radius" stringValue:[NSString stringWithFormat:@"%.20lf", Radius ] ];
    [query addChild:latitude];
    [query addChild:longitude];
    [query addChild:radius];
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


//- (void)newMessageReceived:(NSMutableArray*)messageContent animated:(BOOL)animated {
//
//    NSString *msg = [messageContent valueForKey:@"msg"];
//    NSString *sender = [messageContent valueForKey:@"sender"];
//    NSDate *data = [messageContent valueForKey:@"date"];
//    NSDate * data1 = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSMutableArray *m;

//    if([sender  isEqual: @"you"]){
//        m = [NSMutableArray dataWithText:msg date:data type:BubbleTypeMine];
//    }
//    else
//        m = [NSMutableArray dataWithText:msg date:data type:BubbleTypeSomeoneElse];
//    [messages addObject:m];
//
//    [bubbleTable reloadData];
//
//   // NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count - 1
//                             //                      inSection:0];
//    [bubbleTable scrollBubbleViewToBottomAnimated:animated];
//
////    [bubbleTable scrollToRowAtIndexPath:topIndexPath
////                       atScrollPosition:UITableViewScrollPositionTop
////                               animated:YES];
//}


- (void)newMessagesReceived:(NSMutableArray *)messagesRecv {

    [messages removeAllObjects];
    for(NSMutableArray* i in messagesRecv){

        [self newMessageReceived:i animated:NO];
    }

}



- (void)newMessageReceived:(NSMutableArray*)messageContent animated:(BOOL)animated {



    NSString *msg = [messageContent valueForKey:@"msg"];
    NSString *sender = [messageContent valueForKey:@"sender"];
    NSDate *data = [messageContent valueForKey:@"date"];
    //NSDate * data1 = [NSDate dateWithTimeIntervalSinceNow:0];


    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;

    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:animated];

    /**
     *  Copy last sent message, this will be the new "received" message
     */

    JSQMessage* message = [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdJobs senderDisplayName:sender date:data text:msg];

    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{


            NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
            [userIds removeObject:self.senderId];
    //        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];

            id<JSQMessageMediaData> newMediaData = nil;
            id newMediaAttachmentCopy = nil;
            /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.demoData.messages addObject:message];
        [self finishReceivingMessageAnimated:YES];


        if (message.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */

                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }

            });
        }

    });
}







- (void)didPressSendButton:(UIButton *)button
withMessageText:(NSString *)text
senderId:(NSString *)senderId
senderDisplayName:(NSString *)senderDisplayName
date:(NSDate *)date
    {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        [JSQSystemSoundPlayer jsq_playMessageSentSound];

        JSQMessage *message1 = [[JSQMessage alloc] initWithSenderId:senderId
                                                 senderDisplayName:senderDisplayName
                                                              date:date
                                                              text:text];

        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:text];


        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];



        NSXMLElement * latitude = [NSXMLElement elementWithName:@"latitude" stringValue:GeoLtitude];
        NSXMLElement * longitude = [NSXMLElement elementWithName:@"longitude" stringValue:GeoLength];


        [message addChild:body];
        [message addChild:latitude];
        [message addChild:longitude];
        
        
        [self.xmppStream sendElement:message];
        [self.demoData.messages addObject:message1];

        [self finishSendingMessageAnimated:YES];
    }



- (void)didPressAccessoryButton:(UIButton *)sender
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Выбор камеры"
                                                           delegate:self
                                                  cancelButtonTitle:@"отмена"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Сфотографировать", @"Выбрать из галлереи",  nil];

        [sheet showFromToolbar:self.inputToolbar];
}





#pragma mark -
#pragma mark Chat delegates



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


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
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
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:chosenImage];

    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];

    [self.demoData.messages addObject:photoMessage];

    [self finishSendingMessageAnimated:YES];

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
}




- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - JSQMessages CollectionView DataSource

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


    return [self.demoData.avatars objectForKey:message.senderId];
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
    [self sendQuery];
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





