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

@interface AddDeviceViewController : UIViewController <ItemPropertiesDelegate>

@property (retain) IBOutlet LocationsView *locationsView;

- (IBAction) addLocation;
- (IBAction) go;

@end
