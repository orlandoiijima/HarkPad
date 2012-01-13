//
//  InvoicesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "PullToRefreshTableViewController.h"

@interface InvoicesViewController : PullToRefreshTableViewController {
    NSMutableArray *invoices;
    NSDate *lastUpdate;
}

@property (retain) NSMutableArray *invoices;
@property (retain) NSDate *lastUpdate;

- (void) onUpdateOrder: (Order *)order;
- (void) refresh;

@end
