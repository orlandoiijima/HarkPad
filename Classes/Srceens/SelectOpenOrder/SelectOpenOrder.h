//
//  SelectOpenOrder.h
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Order.h"
#import "OrderView.h"
#import "PaymentViewController.h"
#import "SelectItemDelegate.h"

@interface SelectOpenOrder : UIViewController <OrderViewDelegate, PaymentDelegate> {
    NSMutableArray *orders;
    int countColumns;
    UIScrollView *scrollView;
    Order *_selectedOrder;
    id<SelectItemDelegate> delegate;
}

@property (retain) UIScrollView *scrollView;
@property (retain) NSMutableArray *orders;
@property int countColumns;
@property (retain) Order *selectedOrder;
@property (retain) id<SelectItemDelegate> delegate;

- (OrderView *)viewForOrder: (Order *)order;
- (OrderView *)orderViewAtGesture: (UIGestureRecognizer *)gesture;

- (void) done;

@end
