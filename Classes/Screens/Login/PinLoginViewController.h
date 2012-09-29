//
//  PinLoginViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Credentials.h"


@interface PinLoginViewController : UIViewController

@property (retain) IBOutlet UILabel *pin1Field;
@property (retain) IBOutlet UILabel *pin2Field;
@property (retain) IBOutlet UILabel *pin3Field;
@property (retain) IBOutlet UILabel *pin4Field;
@property (retain) IBOutlet UITextField *pinField;

@property (retain) IBOutlet UIButton *goButton;
@property (retain) IBOutlet UIActivityIndicatorView *activityView;
@property (retain) IBOutlet UIView *credentialsPanel;

@property(nonatomic) int numberOfAttempts;

@property(nonatomic, copy) void (^didAuthenticateBlock)(Credentials *);
@property(nonatomic, copy) void (^didCancel)(void);

+ (PinLoginViewController *)controllerWithAuthenticatedBlock:(void (^)(User *))didAuthenticateBlock onCancel:(void (^)(void))didCancel;

- (void)fillPinFields:(NSString *)pin;

- (NSString *)getPinFromFields;

- (IBAction) go;

@end
