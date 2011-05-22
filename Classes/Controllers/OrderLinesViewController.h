//
//  OrderLinesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "Invoice.h"

@interface OrderLinesViewController : UITableViewController {
    Order *order;
}

@property (retain) Order *order;
@property (retain) UIViewController *invoicesViewController;

@end
