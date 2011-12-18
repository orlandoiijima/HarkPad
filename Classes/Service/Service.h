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
#import "KitchenStatistics.h"
#import "TableInfo.h"	
#import "WorkInProgress.h"
#import "ServiceResult.h"
#import "GTMHTTPFetcher.h"

@interface Service : NSObject {    
    NSString *url;
}


@property (retain) NSString *url;
+ (Service *) getInstance;
+ (void) clear;
- (NSURL *) makeEndPoint:(NSString *)command withQuery: (NSString *) query;
- (void) getCard;
- (MenuCard *) getMenuCard;
- (NSMutableArray *) getMenus;
- (NSMutableArray *) getLog;
- (Map *) getMap;
- (TreeNode *) getTree;
- (void) undockTable: (int)tableId;
- (void) dockTables: (NSMutableArray*)tables;
- (Order *) getOrder: (int) orderId;
- (NSMutableArray *) getReservations: (NSDate *)date;
- (void) getReservations: (NSDate *)date delegate: (id) delegate callback: (SEL)callback;
- (NSMutableArray *) getCurrentSlots;
- (void) startNextSlot;
- (void) transferOrder: (int)orderId toTable: (int) tableId delegate: (id) delegate callback: (SEL)callback;
- (KitchenStatistics *) getKitchenStatistics;
- (void) getWorkInProgress: (id) delegate callback: (SEL)callback;
- (NSMutableArray *) getBacklogStatistics;
- (void) getSalesStatistics: (NSDate *)date delegate: (id) delegate callback: (SEL)callback;

- (void) getDashboardStatistics : (id) delegate callback: (SEL)callback;
- (void) getInvoices: (id) delegate callback: (SEL)callback;
- (void) getInvoicesCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
- (void) printSalesReport: (NSDate *)date;
- (Order *) getOpenOrderByTable: (int) tableId;
- (void) getOpenOrderByTable: (int)tableId delegate: (id) delegate callback: (SEL)callback;
- (void) getOpenOrdersForDistrict: (int)districtId delegate: (id) delegate callback: (SEL)callback;
- (void) getTablesInfoForDistrict: (int)districtid delegate: (id) delegate callback: (SEL)callback;
- (void) makeBills:(NSMutableArray *)bills forOrder:(int)orderId withPrinter:(NSString *)printer;
- (void) updateOrder: (Order *) order;
- (void) quickOrder: (Order *)order paymentType: (int)paymentType printInvoice: (BOOL)printInvoice  delegate: (id) delegate callback: (SEL)callback;
- (void) startCourse: (int) courseId delegate: (id) delegate callback: (SEL)callback;
- (void) serveCourse: (int) courseId;	
- (void) setGender: (NSString *)gender forGuest: (int)guestId;
- (void) startTable: (int)tableId fromReservation: (int) reservationId;
- (void) processPayment: (int) paymentType forOrder: (int) orderId;

- (void) createReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
- (void) updateReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
- (void) deleteReservation: (int)reservationId;
- (void) updateProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback;
- (void) searchReservationsForText: (NSString *)query delegate:(id)delegate callback:(SEL)callback;
- (void) getCountAvailableSeatsPerSlotFromDate: (NSDate *)from toDate: (NSDate *)to delegate: (id) delegate callback: (SEL)callback;

- (void) createProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback;
- (ServiceResult *) printInvoice: (int)orderId;

- (void) getUsers: (id) delegate callback: (SEL)callback;
- (void) getUsersIncludingDeleted:(bool)includeDeleted delegate: (id) delegate callback: (SEL)callback;

- (void) getDeviceConfig: (id) delegate callback: (SEL)callback;

- (ServiceResult *) deleteOrderLine: (int)orderLineId;
- (id) getResultFromJson: (NSData *)data;
- (void)postPage: (NSString *)page key: (NSString *)key value: (NSString *)value;
- (void)postPageCallback: (NSString *)page key: (NSString *)key value: (NSString *)value delegate:(id)delegate callback:(SEL)callback userData: (id)userData;
- (void)getPageCallback: (NSString *)page withQuery: (NSString *)query  delegate:(id)delegate callback:(SEL)callback userData: (id)userData;
- (NSString *)urlEncode: (NSString *)unencodedString;
- (NSString *) stringParameterForDate: (NSDate *)date;
- (NSString *) stringParameterForDateTimestamp: (NSDate *)date;

@end
