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
- (Order *) getLatestOrderByTable: (NSNumber *) tableId;
- (NSMutableArray *) getOpenOrdersInfo;
- (NSMutableArray *) getOrders;
- (void) startCourse: (int) course forOrder: (int) orderId;
- (void) makeBills: (NSMutableArray *) bills forOrder: (int) orderId;
- (void) setState: (int) state forOrder: (int) orderId;
- (void) updateOrder: (Order *) order;

@end
