//
//  AddDeviceViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "BaseAdminViewController.h"
#import "ItemPropertiesDelegate.h"

@class LocationsView;

@interface AddDeviceViewController : BaseAdminViewController <ItemPropertiesDelegate>

@property (retain) IBOutlet LocationsView *locationsView;
@property (retain) IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain) IBOutlet UILabel *indicatorLabel;

- (IBAction) addLocation;
- (IBAction) go;

@end