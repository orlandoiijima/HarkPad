//
//  TableMapViewController.m
//  HarkPad
//
//  Created by Willem Bison on 03-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TableMapViewController.h"
#import "Service.h"
#import "Table.h"
#import "TableButton.h"
#import "TablePopupMenu.h"
#import "NewOrderVC.h"
#import "ReservationsTableViewController.h"
#import "ChefViewController.h"
#import "PaymentViewController.h"

@implementation TableMapViewController

@synthesize map, tableMapView, districtPicker, currentDistrict, isRefreshTimerDisabled;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    map = [[Cache getInstance] map];
    [self setupDistrictPicker];
    [self setupDistrictMap];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(refreshTableButtons)
                                   userInfo:nil
                                    repeats:YES];    
    [self refreshTableButtons];	
}

- (void) setupDistrictMap
{
    for(UIView *view in tableMapView.subviews) [view removeFromSuperview];
    if(districtPicker.selectedSegmentIndex >= map.districts.count) return; 
    currentDistrict = [map.districts objectAtIndex:districtPicker.selectedSegmentIndex];
    CGRect boundingRect = [currentDistrict getRect];
    float scaleX = ((float)tableMapView.bounds.size.width - 20) / boundingRect.size.width;
    //    float scaleY = ((float)self.view.bounds.size.height - 20) / boundingRect.size.height;
    float scaleY = scaleX;
    boundingRect.origin.x = boundingRect.origin.x * scaleX - 10;
    boundingRect.origin.y = boundingRect.origin.y * scaleY - 10;
    for(Table *table in [currentDistrict tables])
    {
        TableButton *button = [TableButton buttonWithTable:table offset:boundingRect.origin scaleX:scaleX scaleY:scaleY];
        [button addTarget:self action:@selector(clickTable:) forControlEvents:UIControlEventTouchDown];
        [tableMapView addSubview:button];
    }
    
}

- (void) setupDistrictPicker
{
    [districtPicker removeAllSegments];
    for(District *district in map.districts)
    {
        [districtPicker insertSegmentWithTitle:district.name atIndex:districtPicker.numberOfSegments animated:YES];
    }
    districtPicker.selectedSegmentIndex = 0;
}

- (void) refreshTableButtons
{
    if(isRefreshTimerDisabled) return;
    
    NSMutableArray *orders = [[Service getInstance] getOpenOrdersInfo];
    for(TableButton *tableButton in tableMapView.subviews)
    {
        OrderInfo *info = [self orderInfoForTable:tableButton.table.id inOrders: orders];
        tableButton.orderInfo = info;
    }
    NSMutableDictionary *districtTables = [[NSMutableDictionary alloc] init];
    for(OrderInfo *info in orders)
    {
        District *district = [[info.tables objectAtIndex:0] district];
        NSNumber *count = [districtTables objectForKey:district.name];
        if(count == nil)
            count = [NSNumber numberWithInt:0];
        [districtTables setObject:[NSNumber numberWithInt:[count intValue]+1] forKey:district.name];
    }
    int i = 0;
    for(District *district in map.districts)
    {
        NSNumber *count = [districtTables valueForKey:district.name];
        NSString *countString = count == nil ? @"" : [NSString stringWithFormat:@" (%@)", count];
        NSString *title = [NSString stringWithFormat:@"%@%@", district.name, countString];
        [districtPicker setTitle:title forSegmentAtIndex: i];
        i++;
    }
}

- (OrderInfo *) orderInfoForTable: (int)tableId inOrders: (NSMutableArray *) orders
{
    for(OrderInfo *order in orders)
    {
        for(Table *table in order.tables)
        {
            if(table.id == tableId)
            {
                return order;
            }
        }
    }
    return nil;
}

- (void) clickTable: (UIControl *) sender
{
    TableButton *tableButton = (TableButton *)sender;
    Order *order = [[Service getInstance] getLatestOrderByTable: tableButton.table.id];
    
    TablePopupMenu *tablePopupMenu = [TablePopupMenu menuForTable: tableButton.table withOrder: order];
    tablePopupMenu.contentSizeForViewInPopover = CGSizeMake(300, 300);
    
    UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:tablePopupMenu];

    popOver.delegate = self;

    tablePopupMenu.popoverController = popOver;
    
    [popOver presentPopoverFromRect:tableButton.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (void)payOrder: (Order *)order
{
    if(order == nil)
        return;
    PaymentViewController *paymentVC = [[PaymentViewController alloc] init];	
    paymentVC.order = order;
    paymentVC.tableMapViewController = self;
    paymentVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;    
    [self presentModalViewController: paymentVC animated:YES];
}

- (void)gotoOrderViewWithOrder: (Order *)order
{
    if(order == nil)
        return;
    isRefreshTimerDisabled = true;
    NewOrderVC *newOrderVC = [[NewOrderVC alloc] init];
    newOrderVC.order = order;
    newOrderVC.tableMapViewController = self;

    newOrderVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;    
    [self presentModalViewController:newOrderVC animated:YES];
}

- (void) closeOrderView
{
    isRefreshTimerDisabled = false;
    [self dismissModalViewControllerAnimated:YES];
    [self refreshTableButtons];
}

- (void) newOrderForTable: (Table *) table
{
    Order *newOrder = [Order orderForTable:table];
    if(newOrder == nil) return;
    [self gotoOrderViewWithOrder:newOrder];
}

- (void) startTable: (Table *)table fromReservation: (Reservation *)reservation
{
    Service *service = [Service getInstance];
    [service startTable:table.id fromReservation: reservation.id];
}

- (void) editOrder: (Order *) order
{
    [self gotoOrderViewWithOrder: order];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
