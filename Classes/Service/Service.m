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
        url = @"10.211.55.5:9483"; //URL_DEV_SHADOW;
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
//
//- (id) getResultFromJson: (NSData *)data
//{
//    NSError *error = nil;
//	NSDictionary *jsonDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
//    if(error != nil)
//        return [[NSMutableDictionary alloc] init];
//    id result =  [jsonDictionary objectForKey:@"result"];
//    if((NSNull *)result == [NSNull null])
//        return [[NSMutableDictionary alloc] init];
//    return result;
//}


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

- (void) transferOrder: (int)orderId toTable: (NSString *) tableId delegate: (id) delegate callback: (SEL)callback
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

- (void) insertSeatAtTable: (NSString *) tableId beforeSeat: (int)seat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback
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

- (void) moveSeat:(int)seat atTable: (NSString *) tableId beforeSeat: (int) beforeSeat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback
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

- (void)deleteSeat:(int)seat fromTable:(NSString *)tableId delegate:(id)delegate callback:(SEL)callback {
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

- (void) getReservations: (NSDate *)date delegate: (id) delegate callback: (SEL)callback
{
    NSString *arg = [NSString stringWithFormat:@"from=%@&to=%@", [date stringISO8601], [date stringISO8601]];
    [self getRequestResource:@"reservation"
                            id:nil
                     arguments:arg
                     converter: ^(NSDictionary *dictionary)
                     {
                         NSMutableArray *reservations = [[NSMutableArray alloc] init];
                         for(NSDictionary *reservationDic in dictionary)
                         {
                             Reservation *reservation = [Reservation reservationFromJsonDictionary: reservationDic];
                             [reservations addObject:reservation];
                         }
                         return reservations;
                     }
                      delegate:delegate
                      callback:callback];
}


- (void) updateReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
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

- (void) createReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
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

- (void) getCountAvailableSeatsPerSlotFromDate: (NSDate *)from toDate: (NSDate *)to delegate: (id) delegate callback: (SEL)callback
{
    NSString *arg = [NSString stringWithFormat:@"from=%@&to=%@", [from stringISO8601], [to stringISO8601]];
    [self getRequestResource:@"reservationslot"
                            id:nil
                     arguments:arg
                     converter:nil
                      delegate:delegate
                      callback:callback];
}

// *********************************

- (void) updateProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback
{
}

- (void) createProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback
{
}

// *********************************

- (void) updateCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback
{
}

- (void) createCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback
{
}

// *********************************

- (void) updateTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback
{
}

- (void) createTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback
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

- (void) getBacklogStatistics : (id) delegate callback: (SEL)callback
{
    [self getRequestResource:@"backlog"
                          id:nil
                   arguments:nil
                   converter:^(NSArray *items) {
                       NSMutableArray *stats = [[NSMutableArray alloc] init];
                       for(NSDictionary *statDic in items)
                       {
                           Backlog *backlog = [Backlog backlogFromJsonDictionary: statDic];
                           [stats addObject:backlog];
                       }
                       return stats;
                   }
                    delegate:delegate
                    callback:callback];
    return;
}

- (void) getDashboardStatistics : (id) delegate callback: (SEL)callback
{
    [self getRequestResource:@"dashboard"
                          id:[[NSDate date] stringISO8601]
                   arguments:nil converter:nil delegate:delegate
                    callback:callback];
}

- (void) getInvoices: (id) delegate callback: (SEL)callback
{
}

- (Order *) getOrder: (int) orderId
{
    [self getRequestResource:@"order"
                          id:[NSString stringWithFormat:@"%d", orderId]
                   arguments:nil
                   converter: ^(NSDictionary *dictionary) {
                        return [Order orderFromJsonDictionary:dictionary];
                    }
                    delegate:nil callback:nil];
    return nil;
}

- (void) startCourse: (int) courseId forOrder:(int)orderId delegate: (id) delegate callback: (SEL)callback
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:courseId] forKey:@"id"];
    [self requestResource:@"order"
                   method:@"POST"
                       id:[NSString stringWithFormat:@"%d", orderId]
                   action:@"StartCourse"
                arguments:@""
                     body:dictionary
              credentials:nil
                converter:nil
                 delegate:delegate
                 callback:callback];
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

- (void) getWorkInProgress : (id) delegate callback: (SEL)callback
{
    [self getRequestResource:@"workinprogress"
                       id:nil
                arguments:nil
                converter:^(NSDictionary *statsDic)
                {
                    NSMutableArray *stats = [[NSMutableArray alloc] init];
                    for(NSDictionary *statDic in statsDic)
                    {
                        WorkInProgress *work = [WorkInProgress workFromJsonDictionary: statDic];
                        [stats addObject: work];
                    }
                    return stats;
                }
                 delegate:delegate
                 callback:callback];
}

- (void) processPayment: (int) paymentType forOrder: (int) orderId
{
    Order *order = [[Order alloc] init];
    order.id = orderId;
    order.paymentType = paymentType;
    NSDictionary *orderDic = [order toDictionary];
    [self requestResource:@"order" method:@"PUT" id:[NSString stringWithFormat:@"%d", orderId] action:nil  arguments:nil body:orderDic credentials:nil converter:nil delegate:nil callback:nil];
	return;
}

- (void) getSalesForDate:(NSDate *)date delegate: (id) delegate callback: (SEL)callback
{
    [self getRequestResource: @"Sales"
                          id: [date stringISO8601]
                   arguments: nil
                   converter: ^(NSDictionary *dictionary)
                   {
                       NSMutableDictionary *sales = [[NSMutableDictionary alloc] init];
                       NSMutableArray *stats = [[NSMutableArray alloc] init];
                       for(NSDictionary *statDic in dictionary)
                       {
                           ProductTotals *totals = [ProductTotals totalsFromJsonDictionary: statDic];
                           [stats addObject:totals];
                       }
                       [sales setObject: stats forKey: @"Sales"];
                       return sales;
                   }
                    delegate: delegate
                    callback: callback];
}

- (void) getTablesInfoForAllDistricts: (id) delegate callback: (SEL)callback
{
    id converter = ^(NSArray *districts)
        {
            NSMutableArray *tables = [[NSMutableArray alloc] init];
            for(NSDictionary *districtDic in districts) {
                NSArray *tablesDic = [districtDic objectForKey:@"Tables"];
                for(NSDictionary *tableDic in tablesDic) {
                    TableInfo *tableInfo = [[TableInfo alloc] init];
                    tableInfo.table = [Table tableFromJsonDictionary: tableDic];
                    if (tableInfo.table == nil) continue;
                    tableInfo.table.district = [[[Cache getInstance] map] getTableDistrict:tableInfo.table.name];
                    NSDictionary *orderDic = [tableDic objectForKey:@"Order"];
                    if(orderDic != nil)
                        tableInfo.orderInfo = [OrderInfo infoFromJsonDictionary: orderDic];
                    [tables addObject:tableInfo];
                }
            }
            return tables;
        };

    [self getRequestResource:@"DistrictInfo"
                          id: nil
                   arguments: @""
                   converter: converter
                    delegate: delegate
                    callback: callback];
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
    [self getRequestResource:@"TableOrder"
                          id: tableId
                   arguments: @""
                   converter: ^(NSDictionary *dictionary)
                   {
                        return [Order orderFromJsonDictionary: dictionary];
                   }
                    delegate: delegate
                    callback: callback];
}

- (void) getOpenOrdersForDistrict: (int)districtId delegate: (id) delegate callback: (SEL)callback
{
    [self getRequestResource: @"TableOrder"
                          id: nil
                   arguments: @""
                   converter: ^(NSDictionary *ordersDic)
                       {
                           NSMutableArray *orders = [[NSMutableArray alloc] init];
                           for(NSDictionary *orderDic in ordersDic)
                           {
                              Order *order = [Order orderFromJsonDictionary: orderDic];
                              [orders addObject:order];
                           }
                           return orders;
                       }
                    delegate: delegate
                    callback: callback];
}

- (void) updateOrder: (Order *) order  delegate: (id) delegate callback: (SEL)callback
{
    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    [self requestResource:@"order" method:@"PUT" id:nil body:orderAsDictionary delegate: delegate callback: callback];
}

- (void) createOrder: (Order *) order  delegate: (id) delegate callback: (SEL)callback
{
    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    [self requestResource:@"order" method:@"POST" id:nil body:orderAsDictionary delegate: delegate callback: callback];
}

- (void) getConfig:(id)delegate callback:(SEL)callback {
    [self requestResource:@"config" method:@"GET" id:@"1" body:nil delegate:delegate callback:callback];
}

- (void) createLocation: (NSString *)locationName withIp: (NSString *)ip credentials:(Credentials *)credentials  delegate: (id) delegate callback: (SEL)callback {
    NSMutableDictionary *dictionary  = [[NSMutableDictionary alloc] initWithObjectsAndKeys: locationName, @"Name", ip, @"Ip", nil];
    [self requestResource:@"location" method:@"POST" id:nil action:nil arguments:nil body:dictionary credentials:credentials converter:nil delegate:delegate callback:callback];
}

- (void) registerDeviceWithCredentials: (Credentials *)credentials delegate: (id)delegate callback: (SEL)callback {
    [self requestResource:@"device" method:@"POST" id:nil action: nil arguments:nil body:nil credentials:credentials converter:nil delegate:delegate callback:callback];
}

- (void) signon: (Signon *)signon  delegate: (id) delegate callback: (SEL)callback {
    NSMutableDictionary *dictionary  = [signon toDictionary];
    [self requestResource:@"tenant" method:@"POST" id:nil body:dictionary delegate:delegate callback:callback];
}

- (void) requestResource: (NSString *)resource method:(NSString *)method id:(NSString *)id body: (NSDictionary *)body delegate:(id)delegate callback:(SEL)callback {
    [self requestResource: resource method:method id:id action:nil arguments:nil body:body credentials:nil converter:nil delegate:delegate callback:callback];
}

- (void) getRequestResource: (NSString *)resource
                         id: (NSString *)id
                  arguments: (NSString *) arguments
                  converter:(id (^)(id))converter
                   delegate:(id)delegate
                   callback:(SEL)callback
{
    [self requestResource: resource method: @"GET" id:id action:nil  arguments:arguments body:nil credentials:nil converter:converter delegate:delegate callback:callback];
}

- (void) requestResource: (NSString *)resource
                  method:(NSString *)method
                      id:(NSString *)id
                  action:(NSString *)action
               arguments: (NSString *) arguments
                    body: (NSDictionary *)body
             credentials:(Credentials *)credentials
               converter:(id (^)(id))converter
                delegate:(id)delegate
                callback:(SEL)callback
{
    CallbackInfo *info = [CallbackInfo infoWithDelegate:delegate callback:callback converter:converter];

    NSError *error = nil;

    NSString *urlRequest = [NSString stringWithFormat:@"%@/api/%@/%@", URL_DEV_SHADOW, API_VERSION, resource];
    if (id != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", id];
    if (action != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", action];
    if (arguments != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"?%@", arguments];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRequest]];
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
    [fetcher beginFetchWithDelegate:self didFinishSelector: @selector(callbackWithConversion:finishedWithData:error:)];
}

- (void) callbackWithConversion:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    CallbackInfo *info = fetcher.userData;
    ServiceResult *result = [ServiceResult resultFromData:data error:error];

    if (result.isSuccess) {
        if (info.converter != nil && (NSNull *)result.jsonData != [NSNull null])
            result.data = info.converter(result.jsonData);
    }
    [info.invocation setArgument:&result atIndex:2];
    [info.invocation invoke];
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

    NSString *urlRequest = [NSString stringWithFormat:@"%@/api/%@/%@", URL_DEV_SHADOW, API_VERSION, resource];
    if (id != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", id];
    if (action != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", action];
    if (arguments != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"?%@", arguments];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRequest]];
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
    ServiceResult *result = [ServiceResult resultFromData:data error:error];

    if (result.isSuccess) {
        info.success(result);
    }
    else {
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
