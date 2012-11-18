//
//  LoginPinViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Credentials.h"

#import "UserService.h"
#import "User.h"
#import "Session.h"

@interface LoginPinViewController : UIViewController

@property (retain) UITextField *pinField;

@property(nonatomic) int numberOfAttempts;

@property(nonatomic, copy) void (^didAuthenticateBlock)(User *);
@property(nonatomic, copy) void (^didCancel)(void);

@property(nonatomic, strong) NSMutableArray *pinLabels;

@property(nonatomic, strong) UILabel *captionField;

@property(nonatomic, strong) UIImageView *logoView;

@property(nonatomic, strong) UILabel *name;

@property(nonatomic) BOOL isConfigLoaded;

+ (LoginPinViewController *)controllerWithAuthenticatedBlock:(void (^)(User *))didAuthenticateBlock;

- (void) go;

@end
