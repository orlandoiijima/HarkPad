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
- (Order *) getOrder: (int) orderId success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) getReservations: (NSDate *)date success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) transferOrder: (int)orderId toTable: (NSString *) tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) insertSeatAtTable: (NSString *) tableId beforeSeat: (int)seat atSide:(TableSide)side success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) deleteSeat: (int) seat fromTable: (NSString *) tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) moveSeat:(int)seat atTable: (NSString *) tableId beforeSeat: (int)beforeSeat atSide:(TableSide)side success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) getWorkInProgress:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) getBacklogStatistics :(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) getDashboardStatistics :(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) getInvoices: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) getOpenOrderByTable: (NSString *)tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) getOpenOrdersForDistrict: (int)districtId success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) getTablesInfoForDistrictBlock:(NSString *)district success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) getTablesInfoForAllDistricts: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) updateOrder: (Order *) order success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) createOrder: (Order *) order success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) startCourse: (int) courseId forOrder:(Order *)order success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void)serveCourse:(int)courseId forOrderId:(int)orderId success:(void (^)(ServiceResult *))success error: (void (^)(ServiceResult*))error;
- (void) processPayment: (int) paymentType forOrder: (int) orderId;

- (void) createReservation: (Reservation *)reservation success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) updateReservation: (Reservation *)reservation success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) deleteReservation: (int)reservationId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) searchReservationsForText: (NSString *)query success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) getPreviousReservationsForReservation: (int) reservationId delegate:(id)delegate callback:(SEL)callback;
- (void) getCountAvailableSeatsPerSlotFromDate: (NSDate *)from toDate: (NSDate *)to success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) createProduct: (Product *)product success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) updateProduct: (Product *)product success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) updateCategory: (ProductCategory *)category success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) createCategory: (ProductCategory *)category success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) createTreeNode: (TreeNode *)node success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) updateTreeNode: (TreeNode *)node success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (void) getConfig: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error view:(UIView *)view text:(NSString *)text;

- (void)getSalesForDate:(NSDate *)date success:(void (^)(ServiceResult *))success error:(void (^)(ServiceResult *))error view:(UIView *)parent textHUD:(NSString *)text;

- (void) signon: (Signon *)signon success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) createLocation: (NSString *)locationName credentials:(Credentials *)credentials success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;
- (void) registerDeviceAtLocation:(int)locationId withCredentials: (Credentials *)credentials success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

- (ServiceResult *) deleteOrderLine: (OrderLine *)orderLine;

- (void)getPageCallback: (NSString *)page withQuery: (NSString *)query  delegate:(id)delegate callback:(SEL)callback userData: (id)userData;

- (BOOL) checkReachability;

- (void)requestResource:(NSString *)resource
                     id:(NSString *)id
                 action:(NSString *)action
              arguments:(NSString *)arguments
                   body:(NSDictionary *)body
                 method:(NSString *)method
            credentials:(Credentials *)credentials
                success:(void (^)(ServiceResult *))onSuccess
                  error:(void (^)(ServiceResult*))onError;

@end
