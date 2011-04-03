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
#import "Reservation.h"
#import "Slot.h"
#import "CJSONSerializer.h"
#import "ServiceProtocol.h"
#import "KitchenStatistics.h"
#import "TableInfo.h"

@interface Service : NSObject <ServiceProtocol> {    
}


@property (retain) NSString *url;
+ (Service *) getInstance;
- (NSURL *) makeEndPoint:(NSString *)command withQuery: (NSString *) query;
- (MenuCard *) getMenuCard;
- (NSMutableArray *) getMenus;
- (NSMutableArray *) getLog;
- (Map *) getMap;
- (void) undockTable: (int)tableId;
- (void) dockTables: (NSMutableArray*)tables;
- (Order *) getOrder: (int) orderId;
- (NSMutableArray *) getReservations: (NSDate *)date;
- (NSMutableArray *) getCurrentSlots;
- (void) startNextSlot;
- (KitchenStatistics *) getKitchenStatistics;
- (Order *) getOpenOrderByTable: (int) tableId;
- (NSMutableArray *) getTablesInfo;
- (void) makeBills:(NSMutableArray *)bills forOrder:(int)orderId withPrinter:(NSString *)printer;
- (void) updateOrder: (Order *) order;
- (void) setGender: (NSString *)gender forGuest: (int)guestId;
- (void) startTable: (int)tableId fromReservation: (int) reservationId;
- (void) processPayment: (int) paymentType forOrder: (int) orderId;
- (void) updateReservation: (Reservation *)reservation;
- (void) createReservation: (Reservation *)reservation;
- (void) deleteReservation: (int)reservationId;
- (id) getResultFromJson: (NSData *)data;
- (void)postToPage: (NSString *)page key: (NSString *)key value: (NSString *)value;

@end
