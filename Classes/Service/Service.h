//
//  OrderingService.h
//  HarkPad
//
//  Created by Willem Bison on 01-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"
#import "OrderInfo.h"
#import "MenuCard.h"
#import "Map.h"
#import "CJSONSerializer.h"
#import "ServiceProtocol.h"

@interface Service : NSObject <ServiceProtocol> {    
}


@property (retain) NSString *url;
+ (Service *) getInstance;
- (NSURL *) makeEndPoint:(NSString *)command withQuery: (NSString *) query;
- (MenuCard *) getMenuCard;
- (NSMutableArray *) getMenus;
- (Map *) getMap;
- (Order *) getOrder: (int) orderId;
- (Order *) getLatestOrderByTable: (int) tableId;
- (NSMutableArray *) getOpenOrdersInfo;
- (NSMutableArray *) getOrders;
- (void) makeBills:(NSMutableArray *)bills forOrder:(int)orderId;
- (void) updateOrder: (Order *) order;

@end
