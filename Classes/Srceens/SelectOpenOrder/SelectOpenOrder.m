//
//  SelectOpenOrder.m
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectOpenOrder.h"
#import "Service.h"
#import "SelectItemDelegate.h"
//#import "OrderView.h"
//#import "PaymentViewController.h"

@implementation SelectOpenOrder

@synthesize orders, countColumns, scrollView, selectedOrder = _selectedOrder, delegate;

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

    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
}

- (OrderView *)orderViewAtGesture: (UIGestureRecognizer *)gesture
{
    for(OrderView *orderView in self.scrollView.subviews)
    {
        if ([orderView pointInside:[gesture locationInView: orderView] withEvent:nil]) {
            return orderView;
        }
    }
    return nil;
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    OrderView *orderView = [self orderViewAtGesture:tapGestureRecognizer];
    if (orderView == nil) return;

    self.selectedOrder = orderView.order;
}

- (void) handleDoubleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    OrderView *orderView = [self orderViewAtGesture:tapGestureRecognizer];
    if (orderView == nil) return;
    [self done];
    return;
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

    if ([self.orders count] == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollView.bounds.size.height / 3, scrollView.bounds.size.width, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = NSLocalizedString(@"Geen open orders gevonden", nil);
        label.textAlignment = UITextAlignmentCenter;
        [self.scrollView addSubview:label];
        return;    
    }
    
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
        OrderView *orderView = [[OrderView alloc] initWithFrame:frame order:order delegate:self];
        orderView.backgroundColor = self.scrollView.backgroundColor;
        [self.scrollView addSubview:orderView];
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, ((i-1)/countColumns + 1) * (height + topMargin));
}

- (void) done
{
    if([self.delegate respondsToSelector:@selector(didSelectItem:)])
        [self.delegate didSelectItem: self.selectedOrder];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void) didTapPayButtonForOrder: (Order *)order
{
    PaymentViewController *paymentController = [[PaymentViewController alloc] init];
    paymentController.order = order;
    paymentController.delegate = self;
    [self.navigationController pushViewController:paymentController animated:YES];
}

- (void)didProcessPaymentType:(PaymentType)type forOrder:(Order *)order {
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
