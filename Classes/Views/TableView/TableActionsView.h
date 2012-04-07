//
//  TableActionsView.h
//  HarkPad
//
//  Created by Willem Bison on 02/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TablePopupDelegate.h"
#import "CrystalButton.h"
#import "OrderInfo.h"

@class TableActionButton;

@interface TableActionsView : UIView

@property (retain) Order *order;
@property (retain) TableActionButton *buttonEditOrder;
@property (retain) TableActionButton *buttonPay;
@property (retain) TableActionButton *buttonBill;
@property (retain) TableActionButton *buttonRequestNextCourse;

- (id)initWithFrame:(CGRect)frame orderInfo: (OrderInfo *)orderInfo delegate:(id<NSObject>) delegate;

@end
