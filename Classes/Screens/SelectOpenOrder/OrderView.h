//
//  OrderView.h
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Order.h"
#import "../../Models/OrderDataSource.h"
#import "OrderTag.h"


@interface OrderView : UIView <UITableViewDelegate>{
    Order *_order;
    OrderDataSource *dataSource;
    UITableView *tableView;
    BOOL _isSelected;
}

@property (retain) Order *order;
@property (retain) OrderDataSource *dataSource;
@property (retain) UITableView *tableView;
@property (retain) OrderTag *label;
@property (retain) UILabel *infoLabel;
@property (retain) UILabel *amountLabel;
@property BOOL isSelected;

- (id)initWithFrame:(CGRect)frame order: (Order *)anOrder delegate: (id<OrderViewDelegate>) delegate;

@end
