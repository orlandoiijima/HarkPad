	//
//  OrderingService.m
//  HarkPad
//
//  Created by Willem Bison on 01-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Service.h"
#import "KitchenStatistics.h"
#import "Backlog.h"
#import "Invoice.h"
#import "ProductTotals.h"
#import "urls.h"

@implementation Service

@synthesize url;				
static Service *_service;

- (id)init {
    if ((self = [super init])) {
        [[NSUserDefaults standardUserDefaults] synchronize];	
	    NSString *env = [[NSUserDefaults standardUserDefaults] stringForKey:@"env"];
        if([env isEqualToString:@"test"])
            url = URL_TEST; 
        else if([env isEqualToString:@"development"])
            url = URL_DEV;
        else if([env isEqualToString:@"development2"])
            url = URL_DEV_EXT;
        else
            url = URL_PRODUCTION;
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
        return [[[NSMutableDictionary alloc] init] autorelease];
    id result =  [jsonDictionary objectForKey:@"result"];
    if((NSNull *)result == [NSNull null])
        return [[[NSMutableDictionary alloc] init] autorelease];
    return result;
}

- (NSMutableArray *) getLog
{
	NSURL *testUrl = [self makeEndPoint:@"getlog" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [self getResultFromJson:data];
}

- (MenuCard *) getMenuCard
{
	NSURL *testUrl = [self makeEndPoint:@"getmenucard" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [MenuCard menuFromJson: [self getResultFromJson:data]];
}

- (NSMutableArray *) getMenus
{
	NSURL *testUrl = [self makeEndPoint:@"getmenus" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [Menu menuFromJson:[self getResultFromJson: data]];
}

- (TreeNode *) getTree
{
	NSURL *testUrl = [self makeEndPoint:@"getmenutree" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
    if(data == nil)
    {
        return nil;
    }
	return [TreeNode nodeFromJsonDictionary:[self getResultFromJson:data] parent:nil];
}

- (Map *) getMap
{
	NSURL *testUrl = [self makeEndPoint:@"getmap" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	return [Map mapFromJson:[self getResultFromJson: data]];    
}

- (void) undockTable: (int)tableId
{
    [self getPageCallback:@"undocktable" withQuery: [NSString stringWithFormat:@"tableId=%d", tableId] delegate:nil callback:nil userData:nil];
	return;    
}

- (void) transferOrder: (int)orderId toTable: (int) tableId
{
    [self getPageCallback:@"transferorder" withQuery: [NSString stringWithFormat:@"orderId=%d&tableId=%d", orderId, tableId] delegate:nil callback:nil userData:nil];
	return;    
}


- (void) dockTables: (NSMutableArray*)tables
{
    NSMutableArray *tableIds = [[[NSMutableArray alloc] init] autorelease];
    for(Table *table in tables) {
        [tableIds addObject:[NSNumber numberWithInt:table.id]];
    }
    NSError *error = nil;
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject: tableIds error:&error];
    [self postPage: @"DockTables" key: @"tables" value: jsonString];
}

- (void) getTablesInfoForDistrict:(int)districtId delegate: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"gettablesinfo"
                withQuery:[NSString stringWithFormat:@"districtId=%d", districtId]
                 delegate: self
                 callback:@selector(getTablesInfoCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getTablesInfoCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSMutableArray *tablesDic = [self getResultFromJson: data];
    NSMutableArray *tables = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary *tableDic in tablesDic)
    {
        TableInfo *tableInfo = [[[TableInfo alloc] init] autorelease];
        tableInfo.table = [Table tableFromJsonDictionary: tableDic]; 
        NSDictionary *orderDic = [tableDic objectForKey:@"order"];
        if(orderDic != nil)
            tableInfo.orderInfo = [OrderInfo infoFromJsonDictionary: orderDic]; 
        [tables addObject:tableInfo];
    }
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&tables atIndex:2];
    [invocation invoke];
}

- (void) setGender: (NSString *)gender forGuest: (int)guestId
{
    [self getPageCallback:@"setgender" withQuery: [NSString stringWithFormat:@"guestId=%d&gender=%@", guestId, gender] delegate:nil callback:nil userData:nil];
	return;        
}

- (NSMutableArray *) getReservations: (NSDate *)date
{
    int dateSeconds = [date timeIntervalSince1970];
	NSURL *testUrl = [self makeEndPoint:@"getreservations" withQuery:[NSString stringWithFormat:@"date=%d", dateSeconds]];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *reservationsDic = [self getResultFromJson: data];
    NSMutableArray *reservations = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary *reservationDic in reservationsDic)
    {
        Reservation *reservation = [Reservation reservationFromJsonDictionary: reservationDic]; 
        [reservations addObject:reservation];
    }
    return reservations;
}

- (void) getReservations: (NSDate *)date delegate: (id) delegate callback: (SEL)callback
{
    int dateSeconds = [date timeIntervalSince1970];
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
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
	NSMutableArray *reservationsDic = [self getResultFromJson: data];
    NSMutableArray *reservations = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary *reservationDic in reservationsDic)
    {
        Reservation *reservation = [Reservation reservationFromJsonDictionary: reservationDic]; 
        [reservations addObject:reservation];
    }

    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&reservations atIndex:2];
    [invocation invoke];
}

- (void) updateReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
{
    NSError *error = nil;
    NSMutableDictionary *orderAsDictionary = [reservation initDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderAsDictionary error:&error];
    
    [self postPageCallback: @"updatereservation" key: @"reservation" value: jsonString delegate:delegate callback:callback userData: reservation];
}

- (void) createReservation: (Reservation *)reservation delegate:(id)delegate callback:(SEL)callback;
{
    NSError *error = nil;
    NSMutableDictionary *orderAsDictionary = [reservation initDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderAsDictionary error:&error];
    
    [self postPageCallback: @"createreservation" key: @"reservation" value: jsonString delegate:delegate callback:callback userData: reservation];
}

- (void) updateProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback
{
    NSError *error = nil;
    NSMutableDictionary *productAsDictionary = [product initDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:productAsDictionary error:&error];
    
    [self postPageCallback: @"updateproduct" key: @"product" value: jsonString delegate:delegate callback:callback userData: product];
}

- (void) createProduct: (Product *)product delegate:(id)delegate callback:(SEL)callback
{
    NSError *error = nil;
    NSMutableDictionary *productAsDictionary = [product initDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:productAsDictionary error:&error];
    
    [self postPageCallback: @"createproduct" key: @"product" value: jsonString delegate:delegate callback:callback userData: product];
}

- (void) deleteReservation: (int)reservationId
{
    NSURL *testUrl = [self makeEndPoint:@"deletereservation" withQuery:[NSString stringWithFormat:@"reservationId=%d", reservationId]];
	[NSData dataWithContentsOfURL: testUrl];
	return;        
}

- (ServiceResult *) deleteOrderLine: (int)orderLineId
{
    NSURL *testUrl = [self makeEndPoint:@"deleteorderline" withQuery:[NSString stringWithFormat:@"orderlineId=%d", orderLineId]];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [ServiceResult resultFromData:data];
}

- (NSMutableArray *) getCurrentSlots
{
	NSURL *testUrl = [self makeEndPoint:@"getCurrentSlots" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *slotsDic = [self getResultFromJson: data];
    NSMutableArray *slots = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary *slotDic in slotsDic)
    {
        Slot *slot = [Slot slotFromJsonDictionary: slotDic]; 
        [slots addObject:slot];
    }
    return slots;
}

- (void) startNextSlot
{
    NSURL *testUrl = [self makeEndPoint:@"startnextslot" withQuery:@""];
	[NSData dataWithContentsOfURL: testUrl];
	return;
}

- (KitchenStatistics *) getKitchenStatistics
{
	NSURL *testUrl = [self makeEndPoint:@"getKitchenStatistics" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableDictionary *statsDic = [self getResultFromJson: data];
    return [KitchenStatistics statsFromJsonDictionary: statsDic];
}

- (NSMutableArray *) getBacklogStatistics
{
	NSURL *testUrl = [self makeEndPoint:@"getBacklogStatistics" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *stats = [[[NSMutableArray alloc] init] autorelease];
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
                 callback:@selector(serviceCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) serviceCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    ServiceResult *result = [ServiceResult resultFromData:data];
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&result atIndex:2];
    [invocation invoke];
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
	NSMutableArray *invoices = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary *invoicesDic = [self getResultFromJson: data];
    for(NSDictionary *invoiceDic in invoicesDic)
    {
        Invoice *invoice = [Invoice invoiceFromJsonDictionary: invoiceDic];
        [invoices addObject:invoice];
    }
    
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&invoices atIndex:2];
    [invocation invoke];

    return;
}

- (NSMutableArray *) getSalesStatistics: (NSDate *)date
{
    int dateSeconds = [date timeIntervalSince1970];    
	NSURL *testUrl = [self makeEndPoint:@"getSales" withQuery:[NSString stringWithFormat:@"date=%d", dateSeconds]];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *stats = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary *statsDic = [self getResultFromJson: data];
    for(NSDictionary *statDic in statsDic)
    {
        ProductTotals *totals = [ProductTotals totalsFromJsonDictionary: statDic];
        [stats addObject:totals];
    }
    return stats;
}

- (void) printSalesReport:(NSDate *)date
{
    int dateSeconds = [date timeIntervalSince1970];    
	    NSURL *testUrl = [self makeEndPoint:@"printsalesreport"  withQuery:[NSString stringWithFormat:@"date=%d", dateSeconds]];
	[NSData dataWithContentsOfURL: testUrl];
	return;
}

- (Order *) getOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"getorder" withQuery:[NSString stringWithFormat:@"orderId=%d", orderId]];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	NSDictionary *orderDic = [self getResultFromJson: data];
	return [Order orderFromJsonDictionary:orderDic];
}

- (Order *) getOpenOrderByTable: (int) tableId
{
    NSURL *testUrl = [self makeEndPoint:@"getopenorderbytable" withQuery:[NSString stringWithFormat:@"tableId=%d", tableId]];
    
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	NSDictionary *orderDic = [self getResultFromJson:data];
    if((orderDic == nil) || ([orderDic count] == 0)) return nil;
	return [Order orderFromJsonDictionary:orderDic];
}

- (void) getOpenOrderByTable: (int)tableId delegate: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getopenorderbytable"
                withQuery:[NSString stringWithFormat:@"tableId=%d", tableId]
                 delegate:self
                 callback:@selector(getOpenOrderByTableCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getOpenOrderByTableCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSDictionary *orderDic = [self getResultFromJson:data];
    Order *order = nil;
    if(orderDic != nil && [orderDic count] > 0) {
        order = [Order orderFromJsonDictionary:orderDic];
    }
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&order atIndex:2];
    [invocation invoke];
}

- (void) updateOrder: (Order *) order
{
    NSError *error = nil;
    NSMutableDictionary *orderAsDictionary = [order initDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderAsDictionary error:&error];
//    NSURL *testUrl = [self makeEndPoint:@"updateorder" withQuery:@""];

    [self postPageCallback: @"updateorder" key: @"order" value: jsonString delegate: nil callback: nil userData: nil];
}

- (void) startCourse: (int) courseId delegate: (id) delegate callback: (SEL)callback
{
    [self getPageCallback:@"startcourse"
                withQuery: [NSString stringWithFormat:@"courseId=%d", courseId]
                 delegate:delegate
                 callback:callback userData:nil];
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
	NSMutableArray *stats = [[[NSMutableArray alloc] init] autorelease];
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


- (void) setState: (int) state forOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"setorderstate" withQuery:[NSString stringWithFormat:@"orderId=%d&state=%d", orderId, state]];
    
	[NSData dataWithContentsOfURL: testUrl];
	return;
}

- (void) processPayment: (int) paymentType forOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"processpayment" withQuery:[NSString stringWithFormat:@"orderId=%d&paymentType=%d", orderId, paymentType]];
    
	[NSData dataWithContentsOfURL: testUrl];
	return;
}


- (void) makeBills:(NSMutableArray *)bills forOrder:(int)orderId withPrinter:(NSString *)printer
{
    NSMutableDictionary *billsInfo = [[[NSMutableDictionary alloc] init] autorelease];
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

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)postPage: (NSString *)page key: (NSString *)key value: (NSString *)value
{
    NSURL *testUrl = [self makeEndPoint:page withQuery:@""];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: testUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];    
    NSString *postString = [NSString stringWithFormat: @"%@=%@", key, value];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];    
}

- (void)postPageCallback: (NSString *)page key: (NSString *)key value: (NSString *)value delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
    NSURL *testUrl = [self makeEndPoint:page withQuery:@""];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: testUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];    
    NSString *postString = [NSString stringWithFormat: @"%@=%@", key, value];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = userData;
    [fetcher beginFetchWithDelegate:delegate didFinishSelector:callback];
}

- (void)getPageCallback: (NSString *)page withQuery: (NSString *)query  delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
    NSURL *u = [self makeEndPoint:page withQuery:query];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: u];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = userData;
    [fetcher beginFetchWithDelegate:delegate didFinishSelector:callback];
}

@end
