//
//  ServiceProtocol.h
//  HarkPad2
//
//  Created by Willem Bison on 19-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Map.h"
#import "Menu.h"
#import "Order.h"
#import "TreeNode.h"

@protocol ServiceProtocol

- (MenuCard *) getMenuCard;
- (Map *) getMap;
- (TreeNode *) getTree;
- (Order *) getOrder: (NSNumber *) orderId;
- (Order *) getOpenOrderByTable: (NSNumber *) tableId;
- (NSMutableArray *) getOpenOrdersInfo;
- (void) startCourse: (int) courseId;
- (void) makeBills: (NSMutableArray *) invoices forOrder: (int) orderId withPrinter: (NSString *)printer;
- (void) setState: (int) state forOrder: (int) orderId;
- (void) updateOrder: (Order *) order;

@end
