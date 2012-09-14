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
        url = URL_DEV_SHADOW;
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

- (id) getResultFromJson: (NSData *)data
{
    NSError *error = nil;
	NSDictionary *jsonDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
    if(error != nil)
        return [[NSMutableDictionary alloc] init];
    id result =  [jsonDictionary objectForKey:@"result"];
    if((NSNull *)result == [NSNull null])
        return [[NSMutableDictionary alloc] init];
    return result;
}

- (id)getFromUrlWithCommand:(NSString *)command query: (NSString *) query {
    NSURL *urlToGet = [self makeEndPoint:command withQuery:query];
    NSError *error;
   	NSData *data = [NSData dataWithContentsOfURL: urlToGet options:0 error: &error];
    ServiceResult *result = [ServiceResult resultFromData:data error:error];
   	return result.jsonData;
}

- (NSMutableArray *) getLog
{
	return (NSMutableArray *)[self getFromUrlWithCommand:@"getlog" query:@""];
}

- (void) getUsers: (id) delegate callback: (SEL)callback
{
    [self getUsersIncludingDeleted:NO delegate:delegate callback:callback];
	return;
}

- (void) getUsersIncludingDeleted:(bool)includeDeleted delegate: (id) delegate callback: (SEL)callback
{
    [self getRequestResource:@"user"
                          id:nil
                   arguments:nil
                   converter: ^(NSArray *users)
                   {
                       return [User usersFromJson: users];
                   }
                    delegate:delegate
                    callback:callback];
	return;
}

- (void) undockTable: (NSString *)tableId
{
    [self requestResource:@"table" method:@"POST" id:tableId action: @"undock" arguments:nil body:nil credentials:nil converter:nil delegate:nil callback:nil];
	return;
}

- (void) transferOrder: (int)orderId toTable: (NSString *) tableId delegate: (id) delegate callback: (SEL)callback
{
    Order *order = [[Order alloc] init];
    order.id = orderId;
    order.table = [[[Cache getInstance] map] getTable:tableId];
    NSDictionary *orderDic = [order toDictionary];
    [self requestResource:@"order" method:@"POST" id:[NSString stringWithFormat:@"%d", orderId] action:nil  arguments:nil body:orderDic credentials:nil converter:nil delegate:delegate callback:callback];
	return;
}

- (void) insertSeatAtTable: (NSString *) tableId beforeSeat: (int)seat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:-1 beforeSeat:seat atSide:side];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResource:@"table" method:@"POST" id:tableId action: @"InsertSeat"  arguments:nil body: infoDic credentials:nil converter:nil delegate:delegate callback:callback];
	return;
}

- (void) moveSeat:(int)seat atTable: (NSString *) tableId beforeSeat: (int) beforeSeat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback
{
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:seat beforeSeat:beforeSeat atSide:side];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResource:@"table" method:@"POST" id:tableId action: @"MoveSeat"  arguments:nil body: infoDic credentials:nil converter:nil delegate:delegate callback:callback];
	return;
}

- (void)deleteSeat:(int)seat fromTable:(NSString *)tableId delegate:(id)delegate callback:(SEL)callback {
    SeatActionInfo *info = [SeatActionInfo infoForTable:tableId seat:seat beforeSeat:-1 atSide:0];
    NSDictionary *infoDic = [info toDictionary];
    [self requestResource:@"table" method:@"POST" id:tableId action:@"DeleteSeat"  arguments:nil body: infoDic credentials:nil converter:nil delegate:delegate callback:callback];
	return;
}

- (void) dockTables: (NSMutableArray*)tables toTable:(Table *)masterTable
{
    NSMutableArray *tableNames = [[NSMutableArray alloc] init];
    for(Table *table in tables) {
        [tableNames addObject:table.name];
    }
    NSDictionary *infoDic = [NSDictionary dictionaryWithObject:tableNames forKey:@"Tables"];
    [self requestResource:@"table" method:@"POST" id: masterTable.name action:@"DockTables"  arguments:nil body: infoDic credentials:nil converter:nil delegate:nil callback:nil];
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
    NSError *error = nil;
    NSMutableDictionary *orderAsDictionary = [reservation toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderAsDictionary error:&error];
    
    [self postPageCallback: @"updatereservation" key: @"reservation" value: jsonString delegate:delegate callback:callback userData: reservation];
}

- (void) createReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
{
    NSMutableDictionary *reservationDic = [reservation toDictionary];
    [self requestResource:@"reservation" method:@"POST" id:nil action:nil arguments:nil body:reservationDic credentials:nil converter:nil delegate:delegate callback:callback];
}

- (void) deleteReservation: (int)reservationId
{
    NSURL *testUrl = [self makeEndPoint:@"deletereservation" withQuery:[NSString stringWithFormat:@"reservationId=%d", reservationId]];
    [NSData dataWithContentsOfURL: testUrl];
    return;
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
    NSError *error = nil;
    NSMutableDictionary *productAsDictionary = [product toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:productAsDictionary error:&error];
    
    [self postPageCallback: @"updateproduct" key: @"product" value: jsonString delegate:delegate callback:callback userData: product];
}

- (void) createProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback
{
    NSError *error = nil;
    NSMutableDictionary *productAsDictionary = [product toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:productAsDictionary error:&error];
    
    [self postPageCallback: @"createproduct" key: @"product" value: jsonString delegate:delegate callback:callback userData: product];
}

// *********************************

- (void) updateCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback
{
    NSError *error = nil;
    NSMutableDictionary *categoryAsDictionary = [category toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:categoryAsDictionary error:&error];
    
    [self postPageCallback: @"updatecategory" key: @"category" value: jsonString delegate:delegate callback:callback userData: category];
}

- (void) createCategory: (ProductCategory *)category delegate:(id)delegate callback:(SEL)callback
{
    NSError *error = nil;
    NSMutableDictionary *categoryAsDictionary = [category toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:categoryAsDictionary error:&error];
    
    [self postPageCallback: @"createcategory" key: @"category" value: jsonString delegate:delegate callback:callback userData: category];
}

// *********************************

- (void) updateTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback
{
    NSError *error = nil;
    NSMutableDictionary *nodeAsDictionary = [node toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:nodeAsDictionary error:&error];

    [self postPageCallback: @"updatetreenode" key: @"node" value: jsonString delegate:delegate callback:callback userData: node];
}

- (void) createTreeNode: (TreeNode *)node delegate:(id)delegate callback:(SEL)callback
{
    NSError *error = nil;
    NSMutableDictionary *nodeAsDictionary = [node toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:nodeAsDictionary error:&error];

    [self postPageCallback: @"createtreenode" key: @"node" value: jsonString delegate:delegate callback:callback userData: node];
}

// *********************************

- (ServiceResult *) deleteOrderLine: (int)orderLineId
{
    NSURL *testUrl = [self makeEndPoint:@"deleteorderline" withQuery:[NSString stringWithFormat:@"orderlineId=%d", orderLineId]];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [ServiceResult resultFromData:data error:nil];
}

- (NSMutableArray *) getBacklogStatistics
{
	NSURL *testUrl = [self makeEndPoint:@"getBacklogStatistics" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *stats = [[NSMutableArray alloc] init];
    NSMutableDictionary *statsDic = [self getResultFromJson: data];
    for(NSDictionary *statDic in statsDic)
    {
        Backlog *backlog = [Backlog backlogFromJsonDictionary: statDic];
        [stats addObject:backlog];
    }
    return stats;
}

- (void) getDashboardStatistics : (id) delegate callback: (SEL)callback
{
//    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
//    [invocation setTarget:delegate];
//    [invocation setSelector:callback];
//    [self getPageCallback:@"getdashboardstatistics"
//                withQuery:@""
//                 delegate:self
//                 callback:@selector(simpleCallback:finishedWithData:error:)
//                 userData:invocation];
}

- (void) getInvoices: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getinvoices"
                withQuery:@""
                 delegate:self
                 callback:@selector(getInvoicesCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getInvoicesCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    ServiceResult *result = [ServiceResult resultFromData:data error:error];

    if (result.isSuccess) {
        NSMutableArray *invoices = [[NSMutableArray alloc] init];
        NSMutableDictionary *invoicesDic = [self getResultFromJson: data];
        for(NSDictionary *invoiceDic in invoicesDic)
        {
            Invoice *invoice = [Invoice invoiceFromJsonDictionary: invoiceDic];
            [invoices addObject:invoice];
        }
        result.data = invoices;
    }
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&result atIndex:2];
    [invocation invoke];

    return;
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
    [self requestResource:@"order"
                   method:@"POST"
                       id:[NSString stringWithFormat:@"%d", orderId]
                   action:@"StartCourse"
                arguments:@""
                     body:nil
              credentials:nil
                converter:nil
                 delegate:delegate
                 callback:callback];
	return;
}

- (void) serveCourse: (int) courseId forOrder:(int)orderId
{
    [self requestResource:@"order"
                   method:@"POST"
                       id:[NSString stringWithFormat:@"%d", orderId]
                   action:@"ServeCourse"
                arguments:@""
                     body:nil
              credentials:nil
                converter:nil
                 delegate:nil
                 callback:nil];
	return;
}

- (void) getWorkInProgress : (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getworkinprogress"
                withQuery:@""
                 delegate:self
                 callback:@selector(getWorkInProgressCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getWorkInProgressCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSMutableArray *stats = [[NSMutableArray alloc] init];
    NSMutableDictionary *statsDic = [self getResultFromJson: data];
    for(NSDictionary *statDic in statsDic)
    {
        WorkInProgress *work = [WorkInProgress workFromJsonDictionary: statDic];
        [stats addObject: work];
    }

    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&stats atIndex:2];
    [invocation invoke];
}

- (void) processPayment: (int) paymentType forOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"processpayment" withQuery:[NSString stringWithFormat:@"orderId=%d&paymentType=%d", orderId, paymentType]];
    
	[NSData dataWithContentsOfURL: testUrl];
	return;
}

- (void)postPageCallback: (NSString *)page key: (NSString *)key value: (NSString *)value delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
    NSURL *postUrl = [self makeEndPoint:page withQuery:@""];
    [self postPageCallbackWithUrl: postUrl key:key value:value delegate:delegate callback:callback userData:userData];
}

- (void)postPageCallbackWithUrl: (NSURL *)postUrl key: (NSString *)key value: (NSString *)value delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: postUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];    
    NSString *postString = [NSString stringWithFormat: @"%@=%@", key, [self urlEncode:value]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = userData;
    [fetcher beginFetchWithDelegate:delegate didFinishSelector:callback];

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


- (void) getTablesInfoForDistrict:(NSString *)district delegate: (id) delegate callback: (SEL)callback
{
   id converter = ^(NSDictionary *districtDic)
       {
           NSMutableArray *tables = [[NSMutableArray alloc] init];
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
           return tables;
       };

   [self getRequestResource:@"DistrictInfo"
                         id: district
                  arguments: @""
                  converter: converter
                   delegate: delegate
                   callback: callback];
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
