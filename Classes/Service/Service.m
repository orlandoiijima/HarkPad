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
#import "User.h"

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
        return [[NSMutableDictionary alloc] init];
    id result =  [jsonDictionary objectForKey:@"result"];
    if((NSNull *)result == [NSNull null])
        return [[NSMutableDictionary alloc] init];
    return result;
}

- (NSMutableArray *) getLog
{
	NSURL *testUrl = [self makeEndPoint:@"getlog" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [self getResultFromJson:data];
}

- (void) getCard
{
	NSURL *testUrl = [self makeEndPoint:@"getcard" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	NSMutableDictionary *resultDic = [self getResultFromJson:data];
    Cache *cache = [Cache getInstance];
    cache.menuCard = [MenuCard menuFromJson: [resultDic objectForKey:@"categories"]];
    cache.menuCard.menus = [Menu menuFromJson: [resultDic objectForKey:@"menus"]];
    NSMutableArray *productProperties = [resultDic objectForKey:@"productproperties"];
    cache.productProperties = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *propDic in productProperties) {
        [cache.productProperties addObject:[OrderLineProperty propertyFromJsonDictionary:propDic]];
    }
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
            callback:@selector(serviceCallback:finishedWithData:error:)
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
    NSMutableArray *tables = [[NSMutableArray alloc] init];
    for(NSDictionary *tableDic in tablesDic)
    {
        TableInfo *tableInfo = [[TableInfo alloc] init];
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
    NSLog(@"Service: getReservations: %@", date);
    if(date == nil)
        date = [NSDate date];
    int dateSeconds = (int) [date timeIntervalSince1970];
	NSURL *testUrl = [self makeEndPoint:@"getreservations" withQuery:[NSString stringWithFormat:@"date=%d", dateSeconds]];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *reservationsDic = [self getResultFromJson: data];
    NSMutableArray *reservations = [[NSMutableArray alloc] init];
    for(NSDictionary *reservationDic in reservationsDic)
    {
        Reservation *reservation = [Reservation reservationFromJsonDictionary: reservationDic]; 
        [reservations addObject:reservation];
    }
    return reservations;
}

- (void) getReservations: (NSDate *)date delegate: (id) delegate callback: (SEL)callback
{
    NSLog(@"Service: getReservations: %@", date);
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
	return [ServiceResult resultFromData:data error:nil];
}

- (NSMutableArray *) getCurrentSlots
{
	NSURL *testUrl = [self makeEndPoint:@"getCurrentSlots" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *slotsDic = [self getResultFromJson: data];
    NSMutableArray *slots = [[NSMutableArray alloc] init];
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
                 callback:@selector(serviceCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) serviceCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    ServiceResult *result = [ServiceResult resultFromData:data error:error];
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
	NSMutableArray *invoices = [[NSMutableArray alloc] init];
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
    int dateSeconds = (int) [date timeIntervalSince1970];    
	NSURL *testUrl = [self makeEndPoint:@"getSales" withQuery:[NSString stringWithFormat:@"date=%d", dateSeconds]];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *stats = [[NSMutableArray alloc] init];
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
    int dateSeconds = (int) [date timeIntervalSince1970];    
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

- (void) getOpenOrdersForDistrict: (int)districtId delegate: (id) delegate callback: (SEL)callback
{
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:delegate];
    [invocation setSelector:callback];
    [self getPageCallback:@"getopenorders"
                withQuery:[NSString stringWithFormat:@"districtId=%d", districtId]
                 delegate:self
                 callback:@selector(getOpenOrdersCallback:finishedWithData:error:)
                 userData:invocation];
}

- (void) getOpenOrdersCallback:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error
{
    ServiceResult *result = [ServiceResult resultFromData:data error:error];
    
    if (result.isSuccess) {
        NSMutableArray *ordersDic = [self getResultFromJson: data];
        NSMutableArray *orders = [[NSMutableArray alloc] init];
        for(NSDictionary *orderDic in ordersDic)
        {
           Order *order = [Order orderFromJsonDictionary: orderDic];
           [orders addObject:order];
        }

        result.data = orders;
    }
    NSInvocation *invocation = (NSInvocation *)fetcher.userData;
    [invocation setArgument:&result atIndex:2];
    [invocation invoke];
}

- (void) updateOrder: (Order *) order
{
    NSError *error = nil;
    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderAsDictionary error:&error];
//    NSURL *testUrl = [self makeEndPoint:@"updateorder" withQuery:@""];

    [self postPageCallback: @"updateorder" key: @"order" value: jsonString delegate: nil callback: nil userData: nil];
}

- (void)quickOrder: (Order *)order paymentType: (int)paymentType printInvoice: (BOOL)printInvoice  delegate: (id) delegate callback: (SEL)callback {
    NSMutableDictionary *orderAsDictionary = [order toDictionary];
    NSMutableDictionary *orderInfo = [[NSMutableDictionary alloc] init];
    [orderInfo setObject:orderAsDictionary forKey:@"order"];
    [orderInfo setObject: [NSNumber numberWithInt:paymentType] forKey:@"paymentType"];
    [orderInfo setObject: [NSNumber numberWithBool:printInvoice] forKey:@"printInvoice"];

    NSError *error = nil;
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderInfo error:&error];

    [self postPageCallback: @"quickOrder" key: @"order" value: jsonString delegate: nil callback: nil userData: nil];
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
    NSString *postString = [NSString stringWithFormat: @"%@=%@", key, [self urlEncode:value]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];    
}

- (void)postPageCallback: (NSString *)page key: (NSString *)key value: (NSString *)value delegate:(id)delegate callback:(SEL)callback userData: (id)userData
{
    NSURL *testUrl = [self makeEndPoint:page withQuery:@""];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: testUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];    
    NSString *postString = [NSString stringWithFormat: @"%@=%@", key, [self urlEncode:value]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    fetcher.userData = userData;
    [fetcher beginFetchWithDelegate:delegate didFinishSelector:callback];
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


@end
