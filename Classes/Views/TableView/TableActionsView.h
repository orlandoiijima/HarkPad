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

@interface TableActionsView : UIView

@property (retain) Order *order;
@property (retain) UIButton *buttonEditOrder;
@property (retain) UIButton *buttonPay;
@property (retain) UIButton *buttonBill;
@property (retain) UIButton *buttonRequestNextCourse;

- (id)initWithFrame:(CGRect)frame orderInfo: (OrderInfo *)orderInfo delegate:(id<NSObject>) delegate;
- (UIButton *) createButtonWithFrame: (CGRect)frame UIImage: (UIImage *)image title: (NSString *) title delegate:(id<NSObject>) delegate action: (SEL)action;

@end
