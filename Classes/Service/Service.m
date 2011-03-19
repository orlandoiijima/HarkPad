//
//  OrderingService.m
//  HarkPad
//
//  Created by Willem Bison on 01-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Service.h"
#import "KitchenStatistics.h"

@implementation Service

@synthesize url;
static Service *_service;

- (id)init {
    if ((self = [super init])) {
        url = @"http://80.101.82.103:10089";
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

- (NSMutableArray *) getOpenOrdersInfo
{
	NSURL *testUrl = [self makeEndPoint:@"getopenordersinfo" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	NSMutableArray *ordersDic = [self getResultFromJson: data];
    NSMutableArray *orders = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary *orderDic in ordersDic)
    {
        OrderInfo *order = [OrderInfo infoFromJsonDictionary: orderDic]; 
        [orders addObject:order];
    }
    return orders;
}

- (NSMutableArray *) getReservations
{
	NSURL *testUrl = [self makeEndPoint:@"getreservations" withQuery:@""];
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

- (Order *) getOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"getorder" withQuery:@""];
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

- (void) updateOrder: (Order *) order
{
    NSError *error = nil;
    NSMutableDictionary *orderAsDictionary = [order initDictionary];
    NSString *jsonString = [[CJSONSerializer serializer] serializeObject:orderAsDictionary error:&error];
    NSURL *testUrl = [self makeEndPoint:@"updateorder" withQuery:@""];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: testUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];    
    NSString *postString = [NSString stringWithFormat: @"order=%@", jsonString];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void) startCourse: (int) courseId
{
    NSURL *testUrl = [self makeEndPoint:@"startcourse" withQuery:[NSString stringWithFormat:@"courseId=%d", courseId]];
    
	[NSData dataWithContentsOfURL: testUrl];
	return;
}

- (void) setState: (int) state forOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"setorderstate" withQuery:[NSString stringWithFormat:@"orderId=%d&state=%d", orderId, state]];
    
	[NSData dataWithContentsOfURL: testUrl];
	return;
}

- (void) processPayment: (int) paymentType forOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"processpayment" withQuery:[NSString stringWithFormat:@"orderId=%d&type=%d", orderId, paymentType]];
    
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
    NSURL *testUrl = [self makeEndPoint:@"makebills" withQuery:@""];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: testUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];    
    NSString *postString = [NSString stringWithFormat: @"bills=%@", jsonString];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
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
	
@end
