//
//  PinLoginViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Credentials.h"

#import "UserService.h"
#import "User.h"
#import "Session.h"

@interface PinLoginViewController : UIViewController

@property (retain) UITextField *pinField;

@property(nonatomic) int numberOfAttempts;

@property(nonatomic, copy) void (^didAuthenticateBlock)(User *);
@property(nonatomic, copy) void (^didCancel)(void);

@property(nonatomic, strong) NSMutableArray *pinLabels;

+ (PinLoginViewController *)controllerWithAuthenticatedBlock:(void (^)(User *))didAuthenticateBlock onCancel:(void (^)(void))didCancel;

- (NSString *)getPinFromFields;

- (void) go;

@end
