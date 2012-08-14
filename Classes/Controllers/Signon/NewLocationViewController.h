//
//  NewLocationViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11-08-12.
//  Copyright (c) 2012 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceResult.h"

@interface NewLocationViewController : UIViewController

@property (retain) IBOutlet UITextField *ip;
@property (retain) IBOutlet UITextField *locationName;

- (IBAction) registerLocation;

- (void) registerLocationCallback:(ServiceResult *)result;

@end
