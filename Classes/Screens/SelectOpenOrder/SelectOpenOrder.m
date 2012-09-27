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
#import "BillViewController.h"
#import "BillPdf.h"

@implementation SelectOpenOrder

@synthesize orders, countColumns, scrollView, selectedOrder = _selectedOrder, delegate, popoverController, selectedOpenOrderType;

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

- (id) initWithType: (SelectOpenOrderType)type title: (NSString *)title {
    self = [super init];
    if (self) {
        self.title = title;
        self.selectedOpenOrderType = type;
        if (type == typeSelection) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
        }
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    
    countColumns = 3;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;

    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshView];
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

//    BillPdf *pdf = [BillPdf billByOrder:orderView.order];
//    NSString *pdfFilename = [pdf createFile];
//
//    NSData *pdfData = [NSData dataWithContentsOfFile:pdfFilename];
//    if ([UIPrintInteractionController canPrintData: pdfData]) {
//        UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
//        controller.printingItem = pdfData;
//        UIPrintInfo *info = [UIPrintInfo printInfo];
//        info.jobName = pdfFilename;
//        info.outputType = UIPrintInfoOutputGeneral;
//        controller.printInfo = info;
//        [controller presentAnimated:YES completionHandler:nil];
//    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)tapGestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

- (void) handleDoubleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (selectedOpenOrderType != typeSelection)
        return;
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
    OrderView *orderView = [self viewForOrder:self.selectedOrder];
    if ([item isKindOfClass:[User class]]) {
        User *user = (User *)item;
        [self.popoverController dismissPopoverAnimated:YES];
        if (user.isNullUser) {
            [ModalAlert inform:NSLocalizedString(@"No users found !", nil)];
        }
        else {
            self.selectedOrder.invoicedTo = user;
            self.selectedOrder.name = user.name;
            orderView.infoLabel.text = [NSString stringWithFormat: NSLocalizedString(@"New bill for coworker '%@'", nil), user.name];
        }
    }
    if ([item isKindOfClass:[Reservation class]]) {
        Reservation *reservation = (Reservation *)item;
        [self.popoverController dismissPopoverAnimated:YES];
        if (reservation.isNullReservation) {
            [ModalAlert inform:NSLocalizedString(@"No reservations found", nil)];
        }
        else {
            self.selectedOrder.reservation = reservation;
            self.selectedOrder.name = reservation.name;
            orderView.infoLabel.text = [NSString stringWithFormat: NSLocalizedString(@"New bill for reservation '%@'", nil), reservation.name];
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

- (void) refreshView {
    [MBProgressHUD showProgressAddedTo: self.view withText: NSLocalizedString(@"Loading orders", nil)];
    [[Service getInstance] getOpenOrdersForDistrict: -1
    success:^(ServiceResult *serviceResult) {
        orders = [[NSMutableArray alloc] init];
        for(NSDictionary *orderDic in serviceResult.jsonData)
        {
           Order *order = [Order orderFromJsonDictionary: orderDic];
           [orders addObject:order];
        }
        [self getOpenOrdersCallback: orders];
    }
    error:^(ServiceResult *serviceResult) {
        [serviceResult displayError];
    }];
}

- (void) getOpenOrdersCallback: (NSMutableArray *)openOrders {
    [MBProgressHUD hideHUDForView: self.view animated:YES];

    int selectedOrderId = -1;
    if (self.selectedOrder != nil)
        selectedOrderId = self.selectedOrder.id;

    [self.scrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];

    self.orders = openOrders;

    if (selectedOpenOrderType == typeSelection) {
        Order *order = [Order orderNull];
        order.name = NSLocalizedString(@"Bill", nil);
        order.id = byNothing;
        [self.orders insertObject: order atIndex:0];

        Order *orderEmployee = [Order orderNull];
        orderEmployee.name = NSLocalizedString(@"Personel", nil);
        orderEmployee.id = byEmployee;
        [self.orders insertObject: orderEmployee atIndex:1];

        Order *orderReservation = [Order orderNull];
        orderReservation.name = NSLocalizedString(@"Reservation", nil);
        orderReservation.id = byReservation;
        [self.orders insertObject: orderReservation atIndex:2];
    }

    int i = 0;
    int leftMargin = 15;
    int topMargin = 15;
    int width = (int)(self.view.frame.size.width - (countColumns - 1)*leftMargin - 2*leftMargin) / countColumns;
    int height = 250;
    for(Order *order in orders) {
        if ([order.lines count] > 0 || order.id <= 0) {
            CGRect frame = CGRectMake(
                    leftMargin + (i % countColumns) * (width + leftMargin),
                    topMargin + (i / countColumns) * (height + topMargin),
                    width,
                    height);
            OrderView *orderView = [[OrderView alloc] initWithFrame:frame order:order delegate:self];
            orderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
            orderView.backgroundColor = [UIColor clearColor];//self.scrollView.backgroundColor;
            [self.scrollView addSubview:orderView];
            i++;

            if (order.id == selectedOrderId)
                self.selectedOrder = order;
        }
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
    self.selectedOrder = order;
    PaymentViewController *paymentController = [[PaymentViewController alloc] init];
    paymentController.order = order;
    paymentController.delegate = self;
    [self.navigationController pushViewController:paymentController animated:YES];
}

- (void) didTapPrintButtonForOrder: (Order *)order
{
    self.selectedOrder = order;
    BillViewController *billController = [[BillViewController alloc] init];
    billController.order = order;
    [self.navigationController pushViewController: billController animated:YES];
    billController.printers = nil;
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
