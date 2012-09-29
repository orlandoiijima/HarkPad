//
//  AddDeviceViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "BaseAdminViewController.h"

@class LocationsView;

@interface AddDeviceViewController : BaseAdminViewController

@property (retain) IBOutlet LocationsView *locations;

- (IBAction) addLocation;
- (IBAction) go;

@end
