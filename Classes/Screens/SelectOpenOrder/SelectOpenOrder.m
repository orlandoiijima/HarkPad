//
//  SelectOpenOrder.m
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SelectOpenOrder.h"
#import "Service.h"
#import "SelectItemDelegate.h"
#import "UserListViewController.h"
#import "ModalAlert.h"
#import "ReservationListController.h"

@implementation SelectOpenOrder

@synthesize orders, countColumns, scrollView, selectedOrder = _selectedOrder, delegate, popoverController;

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
    if (orderView.order.id == byEmployee) {
        [self selectUser];
    }
    if (orderView.order.id == byReservation) {
        [self selectReservation];
    }
}


- (void) handleDoubleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    OrderView *orderView = [self orderViewAtGesture:tapGestureRecognizer];
    if (orderView == nil) return;
    [self done];
    return;
}

- (void) selectUser
{
    OrderView *orderView = [self viewForOrder:self.selectedOrder];
    UserListViewController *usersController = [[UserListViewController alloc] init];
    usersController.delegate = self;

    self.popoverController = [[UIPopoverController alloc] initWithContentViewController: usersController];

    [popoverController presentPopoverFromRect: orderView.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) selectReservation
{
    OrderView *orderView = [self viewForOrder:self.selectedOrder];
    ReservationListController *reservationsController = [[ReservationListController alloc] init];
    reservationsController.delegate = self;

    self.popoverController = [[UIPopoverController alloc] initWithContentViewController: reservationsController];

    [popoverController presentPopoverFromRect: orderView.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)didSelectItem:(id)item {
    if ([item isKindOfClass:[User class]]) {
        User *user = (User *)item;
        [self.popoverController dismissPopoverAnimated:YES];
        if (user.isNullUser) {
            [ModalAlert inform:NSLocalizedString(@"Geen gebruikers gevonden !", nil)];
        }
        else {
            self.selectedOrder.invoicedTo = user;
        }
    }
    if ([item isKindOfClass:[Reservation class]]) {
        Reservation *reservation = (Reservation *)item;
        [self.popoverController dismissPopoverAnimated:YES];
        if (reservation.isNullReservation) {
            [ModalAlert inform:NSLocalizedString(@"Geen reserveringen gevonden !", nil)];
        }
        else {
            self.selectedOrder.reservation = reservation;
        }
    }
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
    
    Order *order = [Order orderNull];
    order.name = NSLocalizedString(@"Rekening", nil);
    order.id = byNothing;
    [self.orders insertObject: order atIndex:0];

    Order *orderEmployee = [Order orderNull];
    orderEmployee.name = NSLocalizedString(@"Personeel", nil);
    orderEmployee.id = byEmployee;
    [self.orders insertObject: orderEmployee atIndex:1];

    Order *orderReservation = [Order orderNull];
    orderReservation.name = NSLocalizedString(@"Reservering", nil);
    orderReservation.id = byReservation;
    [self.orders insertObject: orderReservation atIndex:2];
    
//    if ([self.orders count] == 0) {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollView.bounds.size.height / 3, scrollView.bounds.size.width, 50)];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor whiteColor];
//        label.text = NSLocalizedString(@"Geen open orders gevonden", nil);
//        label.textAlignment = UITextAlignmentCenter;
//        [self.scrollView addSubview:label];
//        return;    
//    }
    
    int i = 0;
    int leftMargin = 25;
    int topMargin = 5;
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

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.cornerRadius = 4;
        gradientLayer.borderColor = [[UIColor grayColor] CGColor];
        gradientLayer.borderWidth = 1;
        gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor], nil];
        gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil];
        [orderView.layer insertSublayer:gradientLayer atIndex:1];

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
