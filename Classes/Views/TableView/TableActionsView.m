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

@implementation TableActionsView

@synthesize buttonBill, buttonEditOrder, buttonPay, buttonRequestNextCourse;
@dynamic order;

#define COUNT_BUTTONS 4

- (id)initWithFrame:(CGRect)frame orderInfo: (OrderInfo *)orderInfo delegate:(id<NSObject>) delegate
{
    self = [super initWithFrame:frame];
    if (self) {

        CGFloat size, dx, dy, x, y;
        CGFloat space = 10;
        if (frame.size.width > frame.size.height) {
            size = MIN( (frame.size.width - (COUNT_BUTTONS + 1)*space) / COUNT_BUTTONS, 100);
            space = (frame.size.width - COUNT_BUTTONS * size) / (COUNT_BUTTONS+1);
            dx = size + space;
            dy = 0;
            x = space;
            y = (frame.size.height - size) / 2;
        }
        else {
            size = MIN( (frame.size.height - (COUNT_BUTTONS + 1)*space) / COUNT_BUTTONS, 100);
            space = (frame.size.height - COUNT_BUTTONS * size) / (COUNT_BUTTONS+1);
            dx = 0;
            dy = size + space;
            x = (frame.size.width - size) / 2;
            y = space;
        }

        CGRect rect = CGRectMake(x, y, size, size);
        self.buttonEditOrder = [self createButtonWithFrame: rect UIImage: [UIImage imageNamed:@"food.png"] title:NSLocalizedString(@"Order", nil) delegate: delegate action: @selector(editOrder)];

        rect = CGRectOffset(rect, dx, dy);
        self.buttonRequestNextCourse = [self createButtonWithFrame: rect UIImage: [UIImage imageNamed:@"action.png"] title:NSLocalizedString(@"Request", nil) delegate: delegate action: @selector(startNextCourse)];

        rect = CGRectOffset(rect, dx, dy);
        self.buttonBill = [self createButtonWithFrame:rect UIImage: [UIImage imageNamed:@"order.png"] title:NSLocalizedString(@"Bill", nil) delegate: delegate action: @selector(makeBillForOrder)];

        rect = CGRectOffset(rect, dx, dy);
        self.buttonPay = [self createButtonWithFrame:rect UIImage: [UIImage imageNamed:@"creditcard.png"] title:NSLocalizedString(@"Pay", nil) delegate: delegate action: @selector(getPaymentForOrder)];
    }
    return self;
}

- (UIButton *) createButtonWithFrame: (CGRect)frame UIImage: (UIImage *)image title: (NSString *) title delegate:(id<NSObject>) delegate action: (SEL)action {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.autoresizingMask = (UIViewAutoresizing)-1;
    [button addTarget:delegate action:action forControlEvents:UIControlEventTouchDown];

    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitle: title forState: UIControlStateNormal];
    [button setImage: image forState:UIControlStateNormal];

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    CGFloat spacing = 8.0;
    CGSize imageSize = image.size;
    CGSize titleSize = button.titleLabel.frame.size;

    button.titleEdgeInsets = UIEdgeInsetsMake(
      0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);

    titleSize = button.titleLabel.frame.size;

    // raise the image and push it right to center it
    button.imageEdgeInsets = UIEdgeInsetsMake(
      - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);

    CALayer *layer = [CALayer layer];
    layer.cornerRadius = 8;
    layer.frame = button.bounds;
    layer.borderColor = [[UIColor blackColor] CGColor];
    layer.borderWidth = 1;
    layer.shadowOffset = CGSizeMake(5, 5);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.4;
    layer.backgroundColor = [[UIColor whiteColor] CGColor];
    [button.layer insertSublayer:layer atIndex:0];

    [self addSubview:button];

    return button;
}

- (void)setOrder: (Order *)order
{
    if(order == nil) return;

    switch (order.state) {
        case OrderStateOrdering:
            if (order.entityState == EntityStateNew) {
                buttonBill.enabled = NO;
                buttonPay.enabled = NO;
                buttonRequestNextCourse.enabled = NO;
            }
            else {
                buttonBill.enabled = YES;
                buttonPay.enabled = NO;
                buttonRequestNextCourse.enabled = order.nextCourseToRequest != nil;
            }
            break;
        case OrderStateBilled:
            buttonBill.enabled = YES;
            buttonPay.enabled = YES;
            buttonRequestNextCourse.enabled = NO;
            break;
        case OrderStatePaid:
            buttonBill.enabled = NO;
            buttonPay.enabled = NO;
            buttonRequestNextCourse.enabled = NO;
            break;
    }
}

@end
