//
//  TestService.m
//  HarkPad2
//
//  Created by Willem Bison on 19-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TestService.h"
#import "ServiceProtocol.h"

@implementation TestService

- (MenuCard *) getMenuCard
{
    MenuCard *menu = [[[MenuCard alloc] init] autorelease];
	return menu;
}

- (Map *) getMap
{
    Map *map = [[[Map alloc] init] autorelease];
    
    District *district = [[[District alloc] init] autorelease];
    district.name = @"Zaal";
    [map.districts addObject:district];
    
    Table *table = [[[Table alloc] initWithBounds:CGRectMake(1, 1, 2, 2) name:@"1" countSeats:2] autorelease];
    [district.tables addObject:table];

    table = [[[Table alloc] initWithBounds:CGRectMake(4, 1, 2, 2) name:@"2" countSeats:2] autorelease];
    [district.tables addObject:table];
    
    table = [[[Table alloc] initWithBounds:CGRectMake(7, 1, 2, 2) name:@"3" countSeats:2] autorelease];
    [district.tables addObject:table];
    
    table = [[[Table alloc] initWithBounds:CGRectMake(1, 4, 4, 2) name:@"4" countSeats:4] autorelease];
    [district.tables addObject:table];
    
    table = [[[Table alloc] initWithBounds:CGRectMake(6, 4, 4, 2) name:@"5" countSeats:4] autorelease];
    [district.tables addObject:table];
    
    table = [[[Table alloc] initWithBounds:CGRectMake(1, 7, 4, 2) name:@"6" countSeats:4] autorelease];
    [district.tables addObject:table];
    
	return map;    
}

- (TreeNode *) getTree
{
    return nil;
}

- (NSMutableArray *) getOrders
{
    NSMutableArray *orders = [[[NSMutableArray alloc] init] autorelease];
    return orders;
}

- (NSMutableArray *) getOpenOrdersInfo
{
    NSMutableArray *orders = [[[NSMutableArray alloc] init] autorelease];
    return orders;
}

- (Order *) getOrder: (NSNumber *) orderId
{
	return [[[Order alloc] init] autorelease];
}

- (Order *) getLatestOrderByTable:(NSNumber *)tableId
{
	return [[[Order alloc] init] autorelease];
}

- (void) startCourse: (int) course forOrder: (int) orderId
{
}

- (void) setState: (int) state forOrder: (int) orderId
{
}

- (void) makeBills: (NSMutableArray *) bills forOrder: (int) orderId
{
}

- (void) updateOrder: (Order *) order
{
}

@end
