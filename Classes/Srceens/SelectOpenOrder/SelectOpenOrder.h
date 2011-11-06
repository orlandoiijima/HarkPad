//
//  SelectOpenOrder.h
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Order.h"
#import "OrderView.h"

@interface SelectOpenOrder : UIViewController {
    NSMutableArray *orders;
    int countColumns;
    UIScrollView *scrollView;
    Order *_selectedOrder;
}

@property (retain) UIScrollView *scrollView;
@property (retain) NSMutableArray *orders;
@property int countColumns;
@property (retain) Order *selectedOrder;

- (OrderView *)viewForOrder: (Order *)order;

@end
