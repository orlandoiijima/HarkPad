//
//  OrderingService.m
//  HarkPad
//
//  Created by Willem Bison on 01-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Service.h"
#import "TestService.h"

@implementation Service

@synthesize url;
static Service *_service;

- (id)init {
    if ((self = [super init])) {
        url = @"http://localhost:10089";
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

- (MenuCard *) getMenuCard
{
	NSURL *testUrl = [self makeEndPoint:@"getmenucard" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [MenuCard menuFromJson:data];
}

- (NSMutableArray *) getMenus
{
	NSURL *testUrl = [self makeEndPoint:@"getmenus" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
	return [Menu menuFromJson:data];
}

- (TreeNode *) getTree
{
	NSURL *testUrl = [self makeEndPoint:@"getmenutree" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
    if(data == nil)
    {
        return nil;
    }
    NSError *error = nil;
	NSDictionary *treeDic = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];  
	return [TreeNode nodeFromJsonDictionary:treeDic parent:nil];
}

- (Map *) getMap
{
	NSURL *testUrl = [self makeEndPoint:@"getmap" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
	return [Map mapFromJson:data];    
}

- (NSMutableArray *) getOrders
{
	NSURL *testUrl = [self makeEndPoint:@"getorders" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
    NSError *error = nil;
	NSMutableArray *ordersDic = [[CJSONDeserializer deserializer] deserializeAsArray:data error:&error ];
    NSMutableArray *orders = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary *orderDic in ordersDic)
    {
        Order *order = [Order orderFromJsonDictionary: orderDic]; 
        [orders addObject:order];
    }
    return orders;
}

- (NSMutableArray *) getOpenOrdersInfo
{
	NSURL *testUrl = [self makeEndPoint:@"getopenordersinfo" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL:testUrl];
    NSError *error = nil;
	NSMutableArray *ordersDic = [[CJSONDeserializer deserializer] deserializeAsArray:data error:&error ];
    NSMutableArray *orders = [[[NSMutableArray alloc] init] autorelease];
    for(NSDictionary *orderDic in ordersDic)
    {
        OrderInfo *order = [OrderInfo infoFromJsonDictionary: orderDic]; 
        [orders addObject:order];
    }
    return orders;
}

- (Order *) getOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"getorder" withQuery:@""];
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
    NSError *error = nil;
	NSDictionary *orderDic = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
	return [Order orderFromJsonDictionary:orderDic];
}

- (Order *) getLatestOrderByTable: (int) tableId
{
    NSURL *testUrl = [self makeEndPoint:@"getlatestorderbytable" withQuery:[NSString stringWithFormat:@"tableId=%d", tableId]];
    
	NSData *data = [NSData dataWithContentsOfURL: testUrl];
    NSError *error = nil;
	NSDictionary *orderDic = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
    if(error != nil) return nil;
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

- (void) startCourse: (int) course forOrder: (int) orderId
{
    NSURL *testUrl = [self makeEndPoint:@"startcourse" withQuery:[NSString stringWithFormat:@"orderId=%d&course=%d", orderId, course]];
    
	[NSData dataWithContentsOfURL: testUrl];
	return;
}

- (void) setState: (int) state forOrder: (int) orderId
{
}

- (void) makeBills:(NSMutableArray *)bills forOrder:(int)orderId
{
    NSMutableDictionary *billsInfo = [[NSMutableDictionary alloc] init];
    [billsInfo setObject:[NSNumber numberWithInt: orderId] forKey:@"orderId"];
    
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

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}
	
@end
