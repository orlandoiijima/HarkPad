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

@property (retain, nonatomic) Order *order;
@property (retain) TableActionButton *buttonEditOrder;
@property (retain) TableActionButton *buttonPay;
@property (retain) TableActionButton *buttonBill;
@property (retain) TableActionButton *buttonRequestNextCourse;
@property (retain) id<TableCommandsDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<TableCommandsDelegate>) delegate;

@end
