//
//  PropertyOptionViewController.h
//  HarkPad2
//
//  Created by Willem Bison on 29-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderLineProperty.h"
#import "OrderLinePropertyValue.h"

@interface PropertyOptionViewController : UITableViewController {
}

@property (retain) OrderLinePropertyValue* orderLinePropertyValue;

@end
