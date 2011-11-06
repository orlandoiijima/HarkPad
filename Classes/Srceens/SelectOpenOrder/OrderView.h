//
//  OrderView.h
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Order.h";
#import "InvoiceDataSource.h"
#import "OrderTag.h"

@interface OrderView : UIView <UITableViewDelegate>{
    Order *_order;
    InvoiceDataSource *dataSource;
    UITableView *tableView;
    BOOL _isSelected;
}

@property (retain) Order *order;
@property (retain) InvoiceDataSource *dataSource;
@property (retain) UITableView *tableView;
@property (retain) OrderTag *label;
@property BOOL isSelected;

- (id)initWithFrame:(CGRect)frame order: (Order *)anOrder;

@end
