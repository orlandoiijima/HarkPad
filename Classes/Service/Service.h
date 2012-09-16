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
#import "Signon.h"
#import "ServiceResult.h"
#import "GTMHTTPFetcher.h"
#import "Credentials.h"

@interface Service : NSObject {    
    NSString *url;
}


@property (retain) NSString *url;
@property (assign) NSString *host;
@property (retain) NSString *location;

+ (Service *) getInstance;
+ (void) clear;
- (NSURL *) makeEndPoint:(NSString *)command withQuery: (NSString *) query;
- (NSMutableArray *) getLog;
- (void) undockTable: (NSString *)tableId;
- (void) dockTables: (NSMutableArray*)tables toTable:(Table *)table;
- (Order *) getOrder: (int) orderId;
- (void) getReservations: (NSDate *)date delegate: (id) delegate callback: (SEL)callback;
- (void) transferOrder: (int)orderId toTable: (NSString *) tableId delegate: (id) delegate callback: (SEL)callback;
- (void) insertSeatAtTable: (NSString *) tableId beforeSeat: (int)seat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback;
- (void) deleteSeat: (int) seat fromTable: (NSString *) tableId delegate: (id) delegate callback: (SEL)callback;
- (void) moveSeat:(int)seat atTable: (NSString *) tableId beforeSeat: (int)beforeSeat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback;

- (void) getWorkInProgress: (id) delegate callback: (SEL)callback;
- (void) getBacklogStatistics : (id) delegate callback: (SEL)callback;

- (void) getDashboardStatistics : (id) delegate callback: (SEL)callback;
- (void) getInvoices: (id) delegate callback: (SEL)callback;
- (void) getOpenOrderByTable: (NSString *)tableId delegate: (id) delegate callback: (SEL)callback;
- (void) getOpenOrdersForDistrict: (int)districtId delegate: (id) delegate callback: (SEL)callback;
- (void) getTablesInfoForDistrict: (NSString *)district delegate: (id) delegate callback: (SEL)callback;

- (void) getTablesInfoForDistrictBlock:(NSString *)district success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) getTablesInfoForAllDistricts: (id) delegate callback: (SEL)callback;
- (void) updateOrder: (Order *) order  delegate: (id) delegate callback: (SEL)callback;
- (void) createOrder: (Order *) order  delegate: (id) delegate callback: (SEL)callback;

- (void) startCourse: (int) courseId forOrder:(int)orderId  delegate: (id) delegate callback: (SEL)callback;
- (void) serveCourse: (int) courseId forOrder:(int)orderId;
- (void) processPayment: (int) paymentType forOrder: (int) orderId;

- (void) createReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
- (void) updateReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
- (void) deleteReservation: (int)reservationId;
- (void) searchReservationsForText: (NSString *)query delegate:(id)delegate callback:(SEL)callback;
- (void) getCountAvailableSeatsPerSlotFromDate: (NSDate *)from toDate: (NSDate *)to delegate: (id) delegate callback: (SEL)callback;
- (void) getPreviousReservationsForReservation: (int) reservationId delegate:(id)delegate callback:(SEL)callback;

- (void) createProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback;
- (void) updateProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback;

- (void) updateCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback;
- (void) createCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback;

- (void) createTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback;
- (void) updateTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback;

- (void) getUsers: (id) delegate callback: (SEL)callback;
- (void) getUsersIncludingDeleted:(bool)includeDeleted delegate: (id) delegate callback: (SEL)callback;

- (void) getConfig: (id) delegate callback: (SEL)callback;
- (void) getSalesForDate:(NSDate *)date delegate: (id) delegate callback: (SEL)callback;

- (void) signon: (Signon *)signon  delegate: (id) delegate callback: (SEL)callback;
- (void) createLocation: (NSString *)locationName withIp: (NSString *)ip credentials:(Credentials *)credentials  delegate: (id) delegate callback: (SEL)callback;
- (void) registerDeviceWithCredentials: (Credentials *)credentials delegate: (id)delegate callback: (SEL)callback;

- (ServiceResult *) deleteOrderLine: (OrderLine *)orderLine;

- (id) getResultFromJson: (NSData *)data;
- (void)getPageCallback: (NSString *)page withQuery: (NSString *)query  delegate:(id)delegate callback:(SEL)callback userData: (id)userData;

- (BOOL) checkReachability;

- (void) getRequestResource: (NSString *)resource
                         id: (NSString *)id
                  arguments: (NSString *) arguments
                  converter:(id (^)(id))converter
                   delegate:(id)delegate
                   callback:(SEL)callback;

- (void) requestResource: (NSString *)resource
                  method:(NSString *)method
                      id:(NSString *)id
                  action:(NSString *)action
               arguments: (NSString *) arguments
                    body: (NSDictionary *)body
             credentials:(Credentials *)credentials
               converter:(id (^)(id))converter
                delegate:(id)delegate
                callback:(SEL)callback;

- (void) requestResourceBlock: (NSString *)resource
                  method:(NSString *)method
                      id:(NSString *)id
                  action:(NSString *)action
               arguments: (NSString *) arguments
                    body: (NSDictionary *)body
             credentials:(Credentials *)credentials
                 success:(void (^)(ServiceResult*))onSuccess
                 error:(void (^)(ServiceResult*))onError;

@end
