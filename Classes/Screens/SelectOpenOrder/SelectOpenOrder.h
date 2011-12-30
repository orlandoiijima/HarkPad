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

@interface SelectOpenOrder : UIViewController <OrderViewDelegate, PaymentDelegate, SelectItemDelegate> {
    NSMutableArray *orders;
    int countColumns;
    UIScrollView *scrollView;
    Order *_selectedOrder;
    id<SelectItemDelegate> delegate;
}

typedef enum NewOrderType {byNothing = -1, byReservation = -2, byEmployee = -3} NewOrderType;

typedef enum SelectOpenOrderType {typeSelection, typeOverview} SelectOpenOrderType;

@property (retain) UIScrollView *scrollView;
@property (retain) NSMutableArray *orders;
@property int countColumns;
@property (retain) Order *selectedOrder;
@property (retain) id<SelectItemDelegate> delegate;
@property (retain) UIPopoverController *popoverController;
@property SelectOpenOrderType selectedOpenOrderType;

- (OrderView *)viewForOrder: (Order *)order;
- (OrderView *)orderViewAtGesture: (UIGestureRecognizer *)gesture;
- (void) selectUser;
- (void) selectReservation;
- (id) initWithType: (SelectOpenOrderType)type title: (NSString *)title;
- (void) refreshView;

- (void) done;

@end
