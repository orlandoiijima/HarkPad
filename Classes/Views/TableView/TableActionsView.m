//
//  TableActionsView.m
//  HarkPad
//
//  Created by Willem Bison on 02/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TableActionsView.h"
#import "TableActionButton.h"
#import "Utils.h"

@implementation TableActionsView

@synthesize buttonBill, buttonEditOrder, buttonPay, buttonRequestNextCourse;
@dynamic order;

#define COUNT_BUTTONS 4

- (id)initWithFrame:(CGRect)frame orderInfo: (OrderInfo *)orderInfo delegate:(id<NSObject>) delegate
{
    self = [super initWithFrame:frame];
    if (self) {

        CGSize imageSize = CGSizeMake(60, 60);
        self.buttonEditOrder = [TableActionButton buttonWithFrame:CGRectZero imageName:@"food@2x" imageSize: imageSize caption:NSLocalizedString(@"Order", nil) description:NSLocalizedString(@"", nil) delegate:delegate action:@selector(editOrder)];
        self.buttonEditOrder.autoresizingMask = (UIViewAutoresizing) -1;
        [self addSubview:self.buttonEditOrder];

        self.buttonRequestNextCourse = [TableActionButton buttonWithFrame:CGRectZero imageName:@"action@2x" imageSize: imageSize caption:NSLocalizedString(@"Request", nil) description:NSLocalizedString(@"", nil) delegate:delegate action:@selector(startNextCourse)];
        self.buttonRequestNextCourse.autoresizingMask = (UIViewAutoresizing)-1;
        [self addSubview:self.buttonRequestNextCourse];

        self.buttonBill = [TableActionButton buttonWithFrame:CGRectZero imageName:@"order@2x" imageSize: imageSize caption:NSLocalizedString(@"Bill", nil) description:NSLocalizedString(@"", nil) delegate:delegate action:@selector(makeBillForOrder)];
        self.buttonBill.autoresizingMask = (UIViewAutoresizing)-1;
        [self addSubview:self.buttonBill];

        self.buttonPay = [TableActionButton buttonWithFrame:CGRectZero imageName:@"creditcard@2x" imageSize: imageSize caption:NSLocalizedString(@"Pay", nil) description:NSLocalizedString(@"", nil) delegate:delegate action:@selector(getPaymentForOrder)];
        self.buttonPay.autoresizingMask = (UIViewAutoresizing)-1;
        [self addSubview:self.buttonPay];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat dx, dy, x, y;
    CGFloat space = 10;
    CGSize size;
    if (self.frame.size.width > self.frame.size.height) {
        size = CGSizeMake((self.frame.size.width - (COUNT_BUTTONS + 1)*space) / COUNT_BUTTONS, self.frame.size.height - 2*space);
        space = (self.frame.size.width - COUNT_BUTTONS * size.width) / (COUNT_BUTTONS+1);
        dx = size.width + space;
        dy = 0;
        x = space;
        y = (self.frame.size.height - size.height) / 2;
    }
    else {
        size = CGSizeMake(self.frame.size.width - 2*space, (self.frame.size.height - (COUNT_BUTTONS + 1)*space) / COUNT_BUTTONS);
        space = (self.frame.size.height - COUNT_BUTTONS * size.height) / (COUNT_BUTTONS+1);
        dx = 0;
        dy = size.height + space;
        x = (self.frame.size.width - size.width) / 2;
        y = space;
    }

    self.buttonEditOrder.frame = CGRectMake(x, y, size.width, size.height);
    self.buttonRequestNextCourse.frame = CGRectOffset(self.buttonEditOrder.frame, dx, dy);
    self.buttonBill.frame = CGRectOffset(self.buttonRequestNextCourse.frame, dx, dy);
    self.buttonPay.frame = CGRectOffset(self.buttonBill.frame, dx, dy);
}

- (void)setOrder: (Order *)order
{
    if(order == nil) return;

    switch (order.state) {
        case OrderStateOrdering:
            if (order.entityState == EntityStateNew) {
                [buttonEditOrder setCommandDescription: NSLocalizedString(@"Tap to start new order", nil)];
                buttonBill.enabled = NO;
                buttonPay.enabled = NO;
                buttonRequestNextCourse.enabled = NO;
            }
            else {
                [buttonEditOrder setCommandDescription: NSLocalizedString(@"Tap to update existing order", nil)];
                buttonBill.enabled = YES;
                [buttonBill setCommandDescription: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Total amount: ", nil), [Utils getAmountString: [order totalAmount] withCurrency:YES]]];

                buttonPay.enabled = NO;
                [buttonPay setCommandDescription: NSLocalizedString(@"Bill has not been printed yet", nil)];

                if (order.nextCourseToRequest != nil) {
                    buttonRequestNextCourse.enabled = YES;
                    [buttonRequestNextCourse setCommandDescription: [NSString stringWithFormat:@"%@: %@", order.nextCourseToRequest.description, order.nextCourseToRequest.stringForCourse]];
                }
                else {
                    buttonRequestNextCourse.enabled = NO;
                }
            }
            break;

        case OrderStateBilled:
            [buttonEditOrder setCommandDescription: NSLocalizedString(@"Tap to update existing order", nil)];
            buttonBill.enabled = YES;
            [buttonBill setCommandDescription: NSLocalizedString(@"Tap to reprint bill", nil)];

            buttonPay.enabled = YES;
            [buttonPay setCommandDescription: [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Total amount: ", nil), [Utils getAmountString: [order totalAmount] withCurrency:YES]]];

            if (order.nextCourseToRequest != nil) {
                buttonRequestNextCourse.enabled = YES;
            }
            else {
                buttonRequestNextCourse.enabled = NO;
                [buttonPay setCommandDescription: NSLocalizedString(@"No course to request", nil)];
            }
            break;

        case OrderStatePaid:
            buttonBill.enabled = NO;
            buttonPay.enabled = NO;
            buttonRequestNextCourse.enabled = NO;
            break;
    }
}

@end
