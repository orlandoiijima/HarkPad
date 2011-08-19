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
#import "InvoiceDataSource.h"

@interface OrderLinesViewController : UITableViewController {
    Order *order;
    InvoiceDataSource *dataSource;
}

@property (retain) Order *order;
@property (retain) InvoicesViewController *invoicesViewController;
@property (retain) InvoiceDataSource *dataSource;

@end
