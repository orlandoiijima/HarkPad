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
@property (assign) NSString *host;

+ (Service *) getInstance;
+ (void) clear;
- (NSURL *) makeEndPoint:(NSString *)command withQuery: (NSString *) query;
- (void) getCard;
- (NSMutableArray *) getMenus;
- (NSMutableArray *) getLog;
- (Map *) getMap;
- (TreeNode *) getTree;
- (void) undockTable: (int)tableId;
- (void) dockTables: (NSMutableArray*)tables;
- (Order *) getOrder: (int) orderId;
- (NSMutableArray *) getReservations: (NSDate *)date;
- (void) getReservations: (NSDate *)date delegate: (id) delegate callback: (SEL)callback;
- (void) transferOrder: (int)orderId toTable: (int) tableId delegate: (id) delegate callback: (SEL)callback;
- (void) getWorkInProgress: (id) delegate callback: (SEL)callback;
- (NSMutableArray *) getBacklogStatistics;
- (void) getSalesStatistics: (NSDate *)date delegate: (id) delegate callback: (SEL)callback;

- (void) getDashboardStatistics : (id) delegate callback: (SEL)callback;
- (void) getInvoices: (id) delegate callback: (SEL)callback;
- (void) getInvoicesCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error;
- (void) printSalesReport: (NSDate *)date;
- (void) getOpenOrderByTable: (int)tableId delegate: (id) delegate callback: (SEL)callback;
- (void) getOpenOrdersForDistrict: (int)districtId delegate: (id) delegate callback: (SEL)callback;
- (void) getTablesInfoForDistrict: (int)districtid delegate: (id) delegate callback: (SEL)callback;
- (void) makeBills:(NSMutableArray *)bills forOrder:(int)orderId withPrinter:(NSString *)printer;
- (void) updateOrder: (Order *) order  delegate: (id) delegate callback: (SEL)callback;
- (void) quickOrder: (Order *)order paymentType: (PaymentType)paymentType printInvoice: (BOOL)printInvoice  delegate: (id) delegate callback: (SEL)callback;
- (void) startCourse: (int) courseId delegate: (id) delegate callback: (SEL)callback;
- (void) serveCourse: (int) courseId;	
- (void) setGender: (NSString *)gender forGuest: (int)guestId;
- (void) startTable: (int)tableId fromReservation: (int) reservationId;
- (void) processPayment: (int) paymentType forOrder: (int) orderId;

- (void) createReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
- (void) updateReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
- (void) deleteReservation: (int)reservationId;
- (void) searchReservationsForText: (NSString *)query delegate:(id)delegate callback:(SEL)callback;
- (void) getCountAvailableSeatsPerSlotFromDate: (NSDate *)from toDate: (NSDate *)to delegate: (id) delegate callback: (SEL)callback;

- (void) createProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback;
- (void) updateProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback;

- (void) updateCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback;
- (void) createCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback;

- (void) createTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback;
- (void) updateTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback;

- (ServiceResult *) printInvoice: (int)orderId;

- (void) getUsers: (id) delegate callback: (SEL)callback;
- (void) getUsersIncludingDeleted:(bool)includeDeleted delegate: (id) delegate callback: (SEL)callback;

- (void) getDeviceConfig: (id) delegate callback: (SEL)callback;

- (ServiceResult *) deleteOrderLine: (int)orderLineId;
- (id) getResultFromJson: (NSData *)data;
- (void)postPageCallback: (NSString *)page key: (NSString *)key value: (NSString *)value delegate:(id)delegate callback:(SEL)callback userData: (id)userData;
- (void)getPageCallback: (NSString *)page withQuery: (NSString *)query  delegate:(id)delegate callback:(SEL)callback userData: (id)userData;
- (NSString *)urlEncode: (NSString *)unencodedString;
- (NSString *) stringParameterForDate: (NSDate *)date;
- (NSString *) stringParameterForDateTimestamp: (NSDate *)date;

- (BOOL) checkReachability;

@end
