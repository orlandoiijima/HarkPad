	//
//  OrderingService.m
//  HarkPad
//
//  Created by Willem Bison on 01-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Service.h"
#import "Backlog.h"
#import "Invoice.h"
#import "ProductTotals.h"
#import "urls.h"
#import "Reachability.h"
#import "CallbackInfo.h"
#import "NSDate-Utilities.h"
#import "AppVault.h"
#import "AuthorisationToken.h"
#import "SeatActionInfo.h"
#import "OrderGridHitInfo.h"
#import "CallbackBlockInfo.h"
#import "Logger.h"

@implementation Service {
@private
    NSString *_location;
}


@synthesize url;
@dynamic host;
@synthesize location = _location;


#define API_VERSION @"v1"

static Service *_service;

- (id)init {
    if ((self = [super init])) {
        [[NSUserDefaults standardUserDefaults] synchronize];	
        _location = [[[NSProcessInfo processInfo] environment] objectForKey:@"env"];
        if (_location == nil)
            _location = [[NSUserDefaults standardUserDefaults] stringForKey:@"env"];
        url = URL_DEV_LOCAL;
    }
    return self;
}

+ (Service*) getInstance {
    @synchronized(self)
    {
        if(!_service) 
        {
            _service = [[Service alloc] init];
        }
    }
    return _service;
}

+ (void) clear {
    _service  = nil;
    [Cache clear];
}

- (NSString *) host
{
    return [[NSURL URLWithString:self.url] host];
}

- (NSURL *) makeEndPoint:(NSString *)command withQuery: (NSString *) query
{	
	NSString *testUrl = [NSString stringWithFormat:@"%@/json/%@", url, command];
    if([query length] > 0)
        testUrl = [NSString stringWithFormat:@"%@?%@", testUrl, query];
    return [NSURL URLWithString:testUrl];
}

- (NSMutableArray *) getLog
{
    NSURL *urlToGet = [self makeEndPoint:@"getlog" withQuery:@""];
    NSError *error;
   	NSData *data = [NSData dataWithContentsOfURL: urlToGet options:0 error: &error];
    ServiceResult *result = [ServiceResult resultFromData:data error:error];
   	return (NSMutableArray *)result.jsonData;
}

- (void) getUsers: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self getUsersIncludingDeleted:NO success:success error:error];
	return;
}

- (void) getUsersIncludingDeleted:(bool)includeDeleted success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"user"
                            id:nil
                        action:nil
                        arguments:nil
                             body:nil
                        method:@"GET"
                   credentials:nil
                      success:success
                        error:error];
	return;
}

- (void) undockTable: (NSString *)tableId
{
    [self requestResourceBlock:@"table"
                       id:tableId
                   action: @"undock"
                arguments:nil
                     body:nil
                   method:@"POST"
              credentials:nil
                  success:nil
                    error:nil];
	return;
}

- (void) transferOrder: (int)orderId toTable: (NSString *) tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    Order *order = [[Order alloc] init];
    order.id = orderId;
    order.table = [[[Cache getInstance] map] getTable:tableId];
    NSDictionary *orderDic = [order toDictionary];
    [self requestResourceBlock:@"order"
                       id:[NSString stringWithFormat:@"%d", orderId]
                   action:nil
                arguments:nil
                     body:orderDic
                   method:@"PUT"
              credentials:nil
                       success:nil
                         error:nil];
	return;
}

- (void) insertSeatAtTable: (NSString *) tableId beforeSeat: (int)seat atSide:(TableSide)side success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:-1 beforeSeat:seat atSide:side];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResourceBlock:@"table"
                            id:tableId
                        action: @"InsertSeat"
                     arguments:nil
                          body:infoDic
                        method:@"POST"
                   credentials:nil
                       success:nil
                         error:nil];
	return;
}

- (void) moveSeat:(int)seat atTable: (NSString *) tableId beforeSeat: (int) beforeSeat atSide:(TableSide)side success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:seat beforeSeat:beforeSeat atSide:side];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResourceBlock:@"table"
                       id:tableId
                   action: @"MoveSeat"
                arguments:nil
                     body: infoDic
                   method:@"POST"
              credentials:nil
                success:nil
                  error:nil];
	return;
}

- (void)deleteSeat:(int)seat fromTable:(NSString *)tableId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:seat beforeSeat:-1 atSide:0];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResourceBlock:@"table"
                       id:tableId
                   action:@"DeleteSeat"
                arguments:nil
                     body: infoDic
                   method:@"POST"
              credentials:nil
                  success:nil
                    error:nil];
	return;
}

- (void) dockTables: (NSMutableArray*)tables toTable:(Table *)masterTable
{
    NSMutableArray *tableNames = [[NSMutableArray alloc] init];
    for(Table *table in tables) {
        [tableNames addObject:table.name];
    }
    NSDictionary *infoDic = [NSDictionary dictionaryWithObject:tableNames forKey:@"Tables"];
    [self requestResourceBlock:@"table"
                       id: masterTable.name
                   action:@"DockTables"
                arguments:nil
                     body: infoDic
                   method:@"POST"
              credentials:nil
                  success:nil
                    error:nil];
}

// *********************************

- (void) getReservations: (NSDate *)date success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSString *arg = [NSString stringWithFormat:@"from=%@&to=%@", [date stringISO8601], [date stringISO8601]];
    [self requestResourceBlock:@"reservation"
                            id:nil
            action:nil
                     arguments:arg
            body:nil
            method:@"GET"
            credentials:nil
                     success: success
                         error:error];
}


- (void) updateReservation: (Reservation *)reservation success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *reservationDic = [reservation toDictionary];
    [self requestResourceBlock:@"reservation"
                       id:nil
                   action:nil
                arguments:nil
                     body:reservationDic
                   method:@"PUT"
              credentials:nil
                  success:nil
                    error:nil];
}

- (void) createReservation: (Reservation *)reservation success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *reservationDic = [reservation toDictionary];
    [self requestResourceBlock:@"reservation"
                       id:nil
                   action:nil
                arguments:nil
                     body:reservationDic
                   method:@"POST"
              credentials:nil
                  success:nil
                    error:nil];
}

- (void) deleteReservation: (int)reservationId
{
    [self requestResourceBlock:@"reservation"
                       id:[NSString stringWithFormat:@"%d", reservationId]
                   action:nil
                arguments:nil
                     body:nil
                   method:@"DELETE"
              credentials:nil
                  success:nil
                    error:nil];
}

- (void) searchReservationsForText: (NSString *)query delegate:(id)delegate callback:(SEL)callback;
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation retainArguments];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"searchreservations"
                withQuery:[NSString stringWithFormat:@"q=%@", query]
                 delegate: self
                 callback:@selector(getReservationsCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getPreviousReservationsForReservation: (int) reservationId delegate:(id)delegate callback:(SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation retainArguments];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getpreviousreservations"
                withQuery:[NSString stringWithFormat:@"reservationId=%d", reservationId]
                 delegate: self
                 callback:@selector(getReservationsCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getCountAvailableSeatsPerSlotFromDate: (NSDate *)from toDate: (NSDate *)to success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSString *arg = [NSString stringWithFormat:@"from=%@&to=%@", [from stringISO8601], [to stringISO8601]];
    [self requestResourceBlock:@"reservationslot"
                            id:nil
                        action:nil
                     arguments:arg
                          body:nil
                        method:@"GET"
                   credentials:nil
                       success:success
                         error:error];
}

// *********************************

- (void) updateProduct: (Product *)product success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

- (void) createProduct: (Product *)product success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

// *********************************

- (void) updateCategory: (ProductCategory *)category success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

- (void) createCategory: (ProductCategory *)category success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

// *********************************

- (void) updateTreeNode: (TreeNode *)node success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

- (void) createTreeNode: (TreeNode *)node success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

// *********************************

- (ServiceResult *) deleteOrderLine: (OrderLine *)orderLine
{
    Order *order = [[Order alloc] init];
    order.id = orderLine.order.id;
    orderLine.entityState = EntityStateDeleted;
    [order addOrderLine:orderLine];
    NSDictionary *orderDic = [order toDictionary];
    [self requestResourceBlock:@"order"
                       id:[NSString stringWithFormat:@"%d", order.id]
                   action:nil
                arguments:nil
                     body:orderDic
                   method:@"PUT"
              credentials:nil
                  success:nil
                    error:nil];
    return nil;
}

- (void) getBacklogStatistics : (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"backlog"
                          id:nil
                      action:nil
                   arguments:nil
                        body:nil
                      method:@"GET"
                 credentials:nil
                     success:^(ServiceResult *serviceResult) {
                               NSMutableArray *stats = [[NSMutableArray alloc] init];
                               for(NSDictionary *statDic in serviceResult.jsonData)
                               {
                                   Backlog *backlog = [Backlog backlogFromJsonDictionary: statDic];
                                   [stats addObject:backlog];
                               }
                               serviceResult.data =  stats;
                           }
                       error:nil];
    return;
}

- (void) getDashboardStatistics : (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"dashboard"
                          id:[[NSDate date] stringISO8601]
            action:nil
            arguments:nil
            body:nil
            method:nil
            credentials:nil
            success:nil
            error:nil];
}

- (void) getInvoices:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
}

- (Order *) getOrder: (int) orderId success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"order"
                          id:[NSString stringWithFormat:@"%d", orderId]
            action:nil
                   arguments:nil
            body:nil
            method:@"GET"
            credentials:nil
                   success: ^(ServiceResult *serviceResult) {
                        serviceResult.data =  [Order orderFromJsonDictionary: serviceResult.jsonData];
                    }
                         error:nil];
    return nil;
}

- (void) startCourse: (int) courseId forOrder:(int)orderId success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:courseId] forKey:@"id"];
    [self requestResourceBlock:@"order"
                       id:[NSString stringWithFormat:@"%d", orderId]
                   action:@"StartCourse"
                arguments:@""
                     body:dictionary
                        method:@"POST"
              credentials:nil
                  success:nil
                    error:nil];
	return;
}

- (void) serveCourse: (int) courseId forOrder:(int)orderId
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:courseId] forKey:@"id"];
    [self requestResourceBlock:@"order"
                       id:[NSString stringWithFormat:@"%d", orderId]
                   action:@"ServeCourse"
                arguments:@""
                     body:dictionary
                   method:@"POST"
              credentials:nil
                  success:nil
                    error:nil];
	return;
}

- (void) getWorkInProgress : (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"workinprogress"
                       id:nil
                           action:nil
                arguments:nil
            body:nil
            method:@"GET"
            credentials:nil
                success:success
                         error:error
];
}

- (void) processPayment: (int) paymentType forOrder: (int) orderId
{
    Order *order = [[Order alloc] init];
    order.id = orderId;
    order.paymentType = paymentType;
    NSDictionary *orderDic = [order toDictionary];
    [self requestResourceBlock:@"order"
                            id:[NSString stringWithFormat:@"%d", orderId]
                        action:nil
                     arguments:nil
                          body:orderDic
                        method:@"PUT"
                   credentials:nil
                       success:nil
                         error:nil
    ];
	return;
}

- (void) getSalesForDate:(NSDate *)date success:(void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock: @"Sales"
                          id: [date stringISO8601]
            action:nil
                   arguments: nil
            body:nil
            method:@"GET"
            credentials:nil
            success:success
                         error:error
];
}

- (void) getTablesInfoForAllDistricts: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"DistrictInfo"
                          id: nil
            action:nil
                   arguments: @""
            body:nil
            method:@"GET"
            credentials:nil
               success:success
            error: error];
}

//- (void) getTablesInfoForDistrict:(NSString *)district delegate: (id) delegate callback: (SEL)callback
//{
//   id converter = ^(NSDictionary *districtDic)
//       {
//           NSMutableArray *tables = [[NSMutableArray alloc] init];
//           NSArray *tablesDic = [districtDic objectForKey:@"Tables"];
//           for(NSDictionary *tableDic in tablesDic) {
//               TableInfo *tableInfo = [[TableInfo alloc] init];
//               tableInfo.table = [Table tableFromJsonDictionary: tableDic];
//               if (tableInfo.table == nil) continue;
//               tableInfo.table.district = [[[Cache getInstance] map] getTableDistrict:tableInfo.table.name];
//               NSDictionary *orderDic = [tableDic objectForKey:@"Order"];
//               if(orderDic != nil)
//                   tableInfo.orderInfo = [OrderInfo infoFromJsonDictionary: orderDic];
//               [tables addObject:tableInfo];
//           }
//           return tables;
//       };
//
//   [self getRequestResource:@"DistrictInfo"
//                         id: district
//                  arguments: @""
//                  converter: converter
//                   delegate: delegate
//                   callback: callback];
//}

- (void) getTablesInfoForDistrictBlock:(NSString *)district success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"districtinfo"
                            id:district
                        action:nil
                     arguments:@""
                          body:nil
                        method:@"GET"
                   credentials:nil
                       success:success
                         error:error];
}

- (void) getOpenOrderByTable: (NSString *)tableId delegate: (id) delegate callback: (SEL)callback
{
    [self requestResourceBlock: @"TableOrder"
                          id: tableId
            action:nil
                   arguments: @""
            body:nil
            method:@"GET"
            credentials:nil
                   success: ^(ServiceResult *serviceResult)
                       {
                           serviceResult.data = [Order orderFromJsonDictionary: serviceResult.jsonData];
                       }
error:nil];
}

- (void) getOpenOrdersForDistrict: (int)districtId success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock: @"TableOrder"
                          id: nil
            action:nil
                   arguments: @""
            body:nil
            method:@"GET"
            credentials:nil
                   success: ^(ServiceResult *serviceResult)
                       {
                           NSMutableArray *orders = [[NSMutableArray alloc] init];
                           for(NSDictionary *orderDic in serviceResult.jsonData)
                           {
                              Order *order = [Order orderFromJsonDictionary: orderDic];
                              [orders addObject:order];
                           }
                           serviceResult.data =  orders;
                       }
error:nil];
}

- (void) updateOrder: (Order *) order success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    [self requestResourceBlock:@"order"
                       id:nil
            action:nil
            arguments:nil
                     body:orderAsDictionary
                   method:@"PUT"
            credentials:nil
                  success:success
                    error:error];
}

- (void) createOrder: (Order *) order success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    [self requestResourceBlock:@"order"
                       id:nil
            action:nil
            arguments:nil
                     body:orderAsDictionary
                   method:@"POST"
            credentials:nil
                  success:success
                    error:error];
}

- (void) getConfig: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error {
    [self requestResourceBlock:@"config"
                            id:@"1"
            action:nil
            arguments:nil
                          body:nil
    method:@"GET"
            credentials:nil
            success:success
                         error:error
    ];
}

- (void) createLocation: (NSString *)locationName credentials:(Credentials *)credentials success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *dictionary  = [[NSMutableDictionary alloc] initWithObjectsAndKeys: locationName, @"Name",  nil];
    [self requestResourceBlock:@"location"
                       id:nil
                   action:nil
                arguments:nil
                     body:dictionary
                   method:@"POST"
              credentials:credentials
                  success:success
                    error:error];
}

- (void) registerDeviceWithCredentials: (Credentials *)credentials success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    [self requestResourceBlock:@"device"
                            id:nil
                        action: nil
                     arguments:nil
                          body:nil
                        method:@"POST"
                   credentials:credentials
                       success:success
                         error:error];
}

- (void) signon: (Signon *)signon success: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error
{
    NSMutableDictionary *dictionary  = [signon toDictionary];
    [self requestResourceBlock:@"tenant"
                       id:nil
                   action: nil
                arguments:nil
                     body:dictionary
                   method:@"POST"
              credentials:nil
                  success:success
                    error:error];
}

- (void) requestResourceBlock: (NSString *)resource
                      id:(NSString *)id
                  action:(NSString *)action
               arguments: (NSString *) arguments
                    body: (NSDictionary *)body
                  method:(NSString *)method
             credentials:(Credentials *)credentials
                 success:(void (^)(ServiceResult*))onSuccess
                 error:(void (^)(ServiceResult*))onError
{
    CallbackBlockInfo *info = [CallbackBlockInfo infoWithSuccess:onSuccess error:onError];

    NSError *error = nil;

    NSString *urlRequest = [NSString stringWithFormat:@"%@/api/%@/%@", url, API_VERSION, resource];
    if ([id length] > 0)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", id];
    if ([action length] > 0)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", action];
    if ([arguments length] > 0)
        urlRequest = [urlRequest stringByAppendingFormat:@"?%@", arguments];
    [Logger Info:urlRequest];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRequest]];
    if([method isEqualToString:@"POST"])
        [Logger Info:@"test"];
    [request setHTTPMethod: method];
    AuthorisationToken *authorisationToken = [AuthorisationToken tokenFromVault];
    if (credentials != nil)
        [authorisationToken addCredentials:credentials];
    [request setValue:[authorisationToken toHttpHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (body != nil) {
        NSString *jsonString = [[CJSONSerializer serializer] serializeObject: body error:&error];
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = info;
    [fetcher beginFetchWithDelegate:self didFinishSelector: @selector(callbackWithBlock:finishedWithData:error:)];
}

- (void) callbackWithBlock:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    CallbackBlockInfo *info = fetcher.userData;
    if (info == nil) return;

    ServiceResult *result = [ServiceResult resultFromData:data error:error];
    if (result == nil) return;

    if (result.isSuccess) {
        if (info.success)
            info.success(result);
    }
    else {
        if (info.error)
            info.error(result);
    }
}

- (NSString *)urlEncode: (NSString *)unencodedString
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (__bridge CFStringRef)unencodedString,
        NULL,
        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
        kCFStringEncodingUTF8 );    
}

- (void)getPageCallback: (NSString *)page withQuery: (NSString *)query  delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
    NSURL *u = [self makeEndPoint:page withQuery:query];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: u];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = userData;
    [fetcher beginFetchWithDelegate:delegate didFinishSelector:callback];
}

- (BOOL) checkReachability {
    Reachability *reachability = [Reachability reachabilityWithHostname: self.host];
    return reachability.isReachable && !reachability.isConnectionRequired;
}
    
@end
