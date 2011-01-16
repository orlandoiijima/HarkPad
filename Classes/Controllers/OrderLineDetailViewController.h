//
//  OrderLineDetailViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderLine.h"
//#import "OrderViewDetailController.h"

@interface OrderLineDetailViewController : UITableViewController {    
}

@property (retain) OrderLine* orderLine;
@property (retain) UIPopoverController *popoverContainer;
@property (retain) UITextField *noteTextField;
@property (retain) UIViewController *controller;
@end