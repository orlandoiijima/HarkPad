//
//  SelectOpenOrder.m
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectOpenOrder.h"
#import "Service.h"
#import "OrderView.h"

@implementation SelectOpenOrder

@synthesize orders, countColumns, scrollView, selectedOrder = _selectedOrder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    
    countColumns = 3;
    [[Service getInstance] getOpenOrdersForDistrict: -1 delegate:self callback:@selector(getOpenOrdersCallback:)];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView: self.view];
    for(OrderView *orderView in self.scrollView.subviews)
    {
        if ([orderView pointInside:[tapGestureRecognizer locationInView: orderView] withEvent:nil])
           self.selectedOrder = orderView.order;
    }
    return nil;
}

- (void) setSelectedOrder: (Order *)order
{
    if (_selectedOrder != nil) {
        OrderView *orderView = [self viewForOrder:_selectedOrder];
        if (orderView != nil) orderView.isSelected = NO;
    }
    _selectedOrder = order;
    if (_selectedOrder != nil) {
        OrderView *orderView = [self viewForOrder:_selectedOrder];
        if (orderView != nil) orderView.isSelected = YES;
    }
}

- (OrderView *)viewForOrder: (Order *)order
{
    for(OrderView *orderView in self.scrollView.subviews)
    {
        if (orderView.order == order) return orderView;
    }
    return nil;
}

- (void) getOpenOrdersCallback: (ServiceResult *)serviceResult {
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
        return;
    }

    self.orders = serviceResult.data;

    int i = 0;
    int leftMargin = 25;
    int topMargin = 15;
    int width = (self.view.frame.size.width - (countColumns - 1)*leftMargin - 2*leftMargin) / countColumns;
    int height = 250;
    for(Order *order in orders) {
        CGRect frame = CGRectMake(
                leftMargin + (i % countColumns) * (width + leftMargin),
                topMargin + (i / countColumns) * (height + topMargin),
                width,
                height);
        OrderView *orderView = [[OrderView alloc] initWithFrame:frame order:order];
        orderView.backgroundColor = self.scrollView.backgroundColor;
        [self.scrollView addSubview:orderView];
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, ((i-1)/countColumns + 1) * (height + topMargin));
}

- (void) done
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
