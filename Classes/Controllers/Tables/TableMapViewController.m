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

@implementation TableMapViewController

@synthesize map, tableMapView, districtPicker, currentDistrict;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    map = [[Cache getInstance] map];
    [self setupDistrictPicker];
    [self setupDistrictMap];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f
                                     target:self
                                   selector:@selector(refreshTableButtons)
                                   userInfo:nil
                                    repeats:YES];    
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
    NSMutableArray *orders = [[Service getInstance] getOpenOrdersInfo];
    for(TableButton *tableButton in tableMapView.subviews)
    {
        OrderInfo *info = [self orderInfoForTable:tableButton.table.id inOrders: orders];
        tableButton.orderInfo = info;
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
    
 //   tablePopupMenu.contentSizeForViewInPopover = CGSizeMake(300, 100);
    
    UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:tablePopupMenu];
    popOver.delegate = self;

    tablePopupMenu.popoverController = popOver;
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [popOver presentPopoverFromRect:tableButton.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (void) newOrderForTable: (Table *) table
{
    Order *newOrder = [Order orderForTable:table];
    UITabBarController *tabBarController = (UITabBarController *)self.parentViewController;
    tabBarController.selectedIndex = 3;
    NewOrderVC *newOrderVC = (NewOrderVC *)tabBarController.selectedViewController;
    newOrderVC.order = newOrder;
}

- (void) editOrder: (Order *) order
{
    UITabBarController *tabBarController = (UITabBarController *)self.parentViewController;
    tabBarController.selectedIndex = 3;
    NewOrderVC *newOrderVC = (NewOrderVC *)tabBarController.selectedViewController;
    newOrderVC.order = order;
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
