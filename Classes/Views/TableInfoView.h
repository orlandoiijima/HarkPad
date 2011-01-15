//
//  TableInfoView.h
//  HarkPad2
//
//  Created by Willem Bison on 30-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface TableInfoView : UIView {
}

+ (TableInfoView *) viewWithOrder: (Order *) order;

@end
