//
//  GuestPropertiesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 02/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Guest.h"
#import "ItemPropertiesDelegate.h"

@interface GuestPropertiesViewController : UIViewController

@property (retain, nonatomic) Guest *guest;
@property (retain) id<ItemPropertiesDelegate> delegate;

+ (GuestPropertiesViewController *) controllerWithGuest: (Guest *)guest;

@end
