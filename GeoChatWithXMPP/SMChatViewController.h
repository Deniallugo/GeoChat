//
//  SMChatViewController.h
//  GeoChatWithXMPP
//
//  Created by Данил on 26/02/2015.
//  Copyright (c) 2015 Данил. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMMessageDelegate.h"   
#import <CoreLocation/CoreLocation.h>


//#import "JSQMessages.h"
#import <JSQMessagesViewController/JSQMessages.h>    // import all the things

#import "DemoModelData.h"
#import "NSUserDefaults+DemoSettings.h"

@class SMChatViewController;
@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(SMChatViewController *)vc;

@end


@interface SMChatViewController : JSQMessagesViewController<SMMessageDelegate, CLLocationManagerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{

    UITextField     *messageField;
    NSString        *chatWithUser;
    UITableView     *tView;
    NSMutableArray  *messages;
    NSString        *GeoLtitude;
    NSString        *GeoLength;
    float           Radius;
    bool            firstUpdateLocation;
    NSMutableArray *turnSockets;

//    IBOutlet UIView *textInputView;
  //  IBOutlet UITextField *textField;



    

}


@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) DemoModelData *demoData;



@property (weak, nonatomic) IBOutlet UILabel *waitingConnection;

@property (nonatomic,retain) NSString *chatWithUser;
@property (nonatomic,retain) NSString *GeoLtitude;
@property (nonatomic,retain) NSString *GeoLength;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *radius1;

@property (nonatomic, retain) IBOutlet UIWindow *window;

-(void) sendQuery;
- (id) initWithUser:(NSString *) userName;
- (IBAction) sendMessage;
- (IBAction) closeChat;
- (IBAction)radiusChange:(id)sender;
- (IBAction)openCamera: (id)sender;


@end