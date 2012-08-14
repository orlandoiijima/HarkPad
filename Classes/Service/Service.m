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
        if([_location isEqualToString:@"annatest"])
            url = URL_ANNATEST;
        else if([_location isEqualToString:@"anna"])
            url = URL_ANNA;
        else if([_location isEqualToString:@"frascati"])
            url = URL_FRASCATI;
        else if([_location isEqualToString:@"club"])
            url = URL_CLUB;
        else if([_location isEqualToString:@"cafe5"])
            url = URL_CAFE5;
        else if([_location isEqualToString:@"droog"])
            url = URL_DROOG;
        else
            url = URL_DEV;
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
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getusers"
            withQuery: [NSString stringWithFormat:@"includeDeleted=%d", includeDeleted ? 1:0]
            delegate:self
            callback:@selector(getUsersCallback:finishedWithData:error:)
            userData:invocation];
	return;
}

- (void) getUsersCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    ServiceResult *result = [ServiceResult resultFromData:data error:error];

    if (result.isSuccess) {
        result.data = [User usersFromJson: [self getResultFromJson:data]];
    }
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&result atIndex:2];
    [invocation invoke];
}

- (void) undockTable: (int)tableId
{
    [self getPageCallback:@"undocktable" withQuery: [NSString stringWithFormat:@"tableId=%d", tableId] delegate:nil callback:nil userData:nil];
	return;    
}

- (void) transferOrder: (int)orderId toTable: (int) tableId delegate: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"transferorder"
            withQuery: [NSString stringWithFormat:@"orderId=%d&tableId=%d", orderId, tableId]
            delegate:self
            callback:@selector(simpleCallback:finishedWithData:error:)
            userData:invocation];
	return;    
}

- (void) insertSeatAtTable: (int) tableId beforeSeat: (int)seat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"insertSeat"
            withQuery: [NSString stringWithFormat:@"tableId=%d&tableSide=%d&beforeSeat=%d", tableId, side, seat]
            delegate:self
            callback:@selector(simpleCallback:finishedWithData:error:)
            userData:invocation];
	return;
}

- (void) moveSeat:(int)seat atTable: (int) tableId beforeSeat: (int) beforeSeat atSide:(TableSide)side delegate: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"moveSeat"
            withQuery: [NSString stringWithFormat:@"seat=%d&tableId=%d&tableSide=%d&beforeSeat=%d", seat, tableId, side, beforeSeat]
            delegate:self
            callback:@selector(simpleCallback:finishedWithData:error:)
            userData:invocation];
	return;
}

- (void)deleteSeat:(int)seat fromTable:(int)tableId delegate:(id)delegate callback:(SEL)callback {
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"deleteSeat"
            withQuery: [NSString stringWithFormat:@"tableId=%d&seat=%d", tableId, seat]
            delegate:self
            callback:@selector(simpleCallback:finishedWithData:error:)
            userData:invocation];
	return;
}

- (void) dockTables: (NSMutableArray*)tables
{
    NSMutableArray *tableIds = [[NSMutableArray alloc] init];
    for(Table *table in tables) {
        [tableIds addObject:[NSNumber numberWithInt:table.id]];
    }
    NSError *error = nil;
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject: tableIds error:&error];
    [self postPageCallback: @"DockTables" key: @"tables" value: jsonString  delegate: nil callback: nil userData: nil];
}

- (void) setGender: (NSString *)gender forGuest: (int)guestId
{
    [self getPageCallback:@"setgender" withQuery: [NSString stringWithFormat:@"guestId=%d&gender=%@", guestId, gender] delegate:nil callback:nil userData:nil];
	return;        
}

// *********************************

- (void) getReservations: (NSDate *)date delegate: (id) delegate callback: (SEL)callback
{
    int dateSeconds = (int) [date timeIntervalSince1970];
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation retainArguments];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [invocation setArgument:&date atIndex:3];
    [self getPageCallback:@"getreservations"
                withQuery:[NSString stringWithFormat:@"date=%d", dateSeconds]
                 delegate: self
                 callback:@selector(getReservationsCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getReservationsCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    ServiceResult *result = [ServiceResult resultFromData:data error:error];

    if (result.isSuccess) {
        NSMutableArray *reservationsDic = [self getResultFromJson: data];
        NSMutableArray *reservations = [[NSMutableArray alloc] init];
        for(NSDictionary *reservationDic in reservationsDic)
        {
            Reservation *reservation = [Reservation reservationFromJsonDictionary: reservationDic];
            [reservations addObject:reservation];
        }
        result.data = reservations;
    }
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&result atIndex:2];
    [invocation invoke];
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
    NSError *error = nil;
    NSMutableDictionary *orderAsDictionary = [reservation toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderAsDictionary error:&error];
    
    [self postPageCallback: @"createreservation" key: @"reservation" value: jsonString delegate:delegate callback:callback userData: reservation];
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
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getcountavailableseatsperslot"
                withQuery:[NSString stringWithFormat:@"date1=%@&date2=%@", [self stringParameterForDate:from], [self stringParameterForDate:to]]
                 delegate:self
                 callback:@selector(simpleCallback:finishedWithData:error:)
                 userData:invocation];
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
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getdashboardstatistics"
                withQuery:@""
                 delegate:self
                 callback:@selector(simpleCallback:finishedWithData:error:)
                 userData:invocation];
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

//- (ServiceResult *) printInvoice: (int)orderId
//{
//    NSURL *testUrl = [self makeEndPoint:@"printinvoice" withQuery:[NSString stringWithFormat:@"orderId=%d", orderId]];
//	NSData *data = [NSData dataWithContentsOfURL: testUrl];
//	return [ServiceResult resultFromData:data error:nil];
//}

//- (void) printSalesReport:(NSDate *)date
//{
//    int dateSeconds = (int) [date timeIntervalSince1970];
//	    NSURL *testUrl = [self makeEndPoint:@"printsalesreport"  withQuery:[NSString stringWithFormat:@"date=%d", dateSeconds]];
//	[NSData dataWithContentsOfURL: testUrl];
//	return;
//}

- (Order *) getOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"getorder" withQuery:[NSString stringWithFormat:@"orderId=%d", orderId]];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	NSDictionary *orderDic = [self getResultFromJson: data];
	return [Order orderFromJsonDictionary:orderDic];
}

- (void) simpleCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    ServiceResult *result = [ServiceResult resultFromData:data error:error];

    if(fetcher.userData != nil) {
        NSInvocation *invocation = (NSInvocation *)fetcher.userData;
        [invocation setArgument:&result atIndex:2];
        [invocation invoke];
    }
}

- (void) startCourse: (int) courseId delegate: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"startcourse"
                withQuery: [NSString stringWithFormat:@"courseId=%d", courseId]
                 delegate:self
                 callback:@selector(simpleCallback:finishedWithData:error:)
                 userData:invocation];
//
//    [self getPageCallback:@"startcourse"
//                withQuery: [NSString stringWithFormat:@"courseId=%d", courseId]
//                 delegate:delegate
//                 callback:@selector(simpleCallback:finishedWithData:error:)
//                 callback:callback userData:nil];
	return;
}

- (void) serveCourse: (int) courseId
{
    [self getPageCallback:@"servecourse" withQuery: [NSString stringWithFormat:@"courseId=%d", courseId] delegate:nil callback:nil userData:nil];
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

- (void) makeBills:(NSMutableArray *)bills forOrder:(int)orderId withPrinter:(NSString *)printer
{
    NSMutableDictionary *billsInfo = [[NSMutableDictionary alloc] init];
    [billsInfo setObject:[NSNumber numberWithInt: orderId] forKey:@"orderId"];
    [billsInfo setObject:printer forKey:@"printerId"];
    
    NSError *error = nil;
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:billsInfo error:&error];

    [self postPageCallback: @"makebills" key: @"bills" value: jsonString delegate: nil callback: nil userData: nil];
}


- (void) startTable: (int)tableId fromReservation: (int) reservationId
{
    NSURL *testUrl = [self makeEndPoint:@"starttable" withQuery:[NSString stringWithFormat:@"tableId=%d&reservationId=%d", tableId, reservationId]];
    
	[NSData dataWithContentsOfURL: testUrl];
}

//- (void) getDeviceConfig: (id) delegate callback: (SEL)callback
//{
//    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
//    [invocation setTarget:delegate];
//    [invocation setSelector:callback];
//    [self getPageCallback:@"getdeviceconfig"
//                withQuery:@""
//                 delegate:self
//                 callback:@selector(simpleCallback:finishedWithData:error:)
//                 userData:invocation];
//}

- (NSString *) stringParameterForDate: (NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

- (NSString *) stringParameterForDateTimestamp: (NSDate *)date
{
    if(date == nil)
        date = [NSDate date];
    int dateSeconds = (int) [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"%d", dateSeconds];
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

- (void) getTablesInfoForDistrict:(NSString *)district delegate: (id) delegate callback: (SEL)callback
{
    id converter = ^(NSDictionary *district)
        {
            NSMutableArray *tables = [[NSMutableArray alloc] init];
            NSArray *tablesDic = [district objectForKey:@"Tables"];
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
    [self requestResource:@"config" method:@"GET" id:nil body:nil delegate:delegate callback:callback];
}

- (void) createLocation: (NSString *)locationName withIp: (NSString *)ip credentials:(Credentials *)credentials  delegate: (id) delegate callback: (SEL)callback {
    NSMutableDictionary *dictionary  = [[NSMutableDictionary alloc] initWithObjectsAndKeys: locationName, @"Name", ip, @"Ip", nil];
    [self requestResource:@"location" method:@"POST" id:nil body:dictionary  credentials:credentials delegate:delegate callback:callback];
}

- (void) registerDeviceWithCredentials: (Credentials *)credentials delegate: (id)delegate callback: (SEL)callback {
    [self requestResource:@"device" method:@"POST" id:nil body:nil credentials:credentials delegate:delegate callback:callback];
}

- (void) signon: (Signon *)signon  delegate: (id) delegate callback: (SEL)callback {
    NSMutableDictionary *dictionary  = [signon toDictionary];
    [self requestResource:@"tenant" method:@"POST" id:nil body:dictionary delegate:delegate callback:callback];
}

- (void) requestResource: (NSString *)resource method:(NSString *)method id:(NSString *)id body: (NSDictionary *)body delegate:(id)delegate callback:(SEL)callback {
    [self requestResource: resource method:method id:id body: body credentials:nil delegate:delegate callback:callback];
}

- (void) requestResource: (NSString *)resource method:(NSString *)method id:(NSString *)id body: (NSDictionary *)body credentials:(Credentials *)credentials delegate:(id)delegate callback:(SEL)callback {
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];

    NSError *error = nil;

    NSString *database = [AppVault database];
    if ([database length] == 0)
        database = @"default";
    NSString *urlRequest = [NSString stringWithFormat:@"%@/api/%@/database/%@/%@", URL_DEV_SHADOW, API_VERSION, database, resource];
    if (id != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", id];
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
    fetcher.userData = invocation;
    [fetcher beginFetchWithDelegate:self didFinishSelector: @selector(simpleCallback:finishedWithData:error:)];
}

- (void) getRequestResource: (NSString *)resource id: (NSString *)id arguments: (NSString *) arguments converter:(id (^)(NSDictionary *))converter delegate:(id)delegate callback:(SEL)callback {
    CallbackInfo *info = [CallbackInfo infoWithDelegate:delegate callback:callback converter:converter];

    NSString *database = [AppVault database];
    if ([database length] == 0)
        database = @"default";
    NSString *urlRequest = [NSString stringWithFormat:@"%@/api/%@/database/%@/%@", URL_DEV_SHADOW, API_VERSION, database, resource];
    if (id != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"/%@", id];
    if (arguments != nil)
        urlRequest = [urlRequest stringByAppendingFormat:@"?%@", arguments];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod: @"GET"];
    [request setValue:[[AuthorisationToken tokenFromVault] toHttpHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    if (body != nil) {
//        NSError *error = nil;
//        NSString *jsonString = [[CJSONSerializer serializer] serializeObject: body error:&error];
//        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
//    }
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = info;
    [fetcher beginFetchWithDelegate: self didFinishSelector:@selector(callbackWithConversion:finishedWithData:error:)];
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
