//
//  Created by wbison on 06-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "OrderTag.h"
#import "Order.h"
#import "Utils.h"
#import "CrystalButton.h"


@implementation OrderTag 

@synthesize  name, amountButton, time, delegate, order;

+ (OrderTag *)tagWithFrame: (CGRect) frame andOrder: (Order *)anOrder delegate: (id<OrderViewDelegate>)delegate {
    OrderTag *tag = [[OrderTag alloc] initWithFrame:frame];
    tag.order = anOrder;
    tag.delegate = delegate;
//    float heightFirst =  (2*frame.size.height) / 3;
//    float heightSecond =  frame.size.height - heightFirst;
//    float buttonHeight = 30;
    float vSpace = 2;
    float amountWidth = 70;
    float amountHeight = frame.size.height - 2*vSpace;
//    tag.time = [[UILabel alloc] initWithFrame:CGRectMake(10, heightFirst, width, heightSecond)];
//    tag.time.textAlignment = UITextAlignmentLeft;
//    tag.time.backgroundColor = [UIColor clearColor];
//    tag.time.shadowColor = [UIColor lightGrayColor];
//    tag.time.font = [UIFont systemFontOfSize:12];
//    tag.time.text = [Utils getElapsedMinutesString:anOrder.createdOn];
//    [tag addSubview: tag.time];

    tag.amountButton = [CrystalButton buttonWithType:UIButtonTypeCustom];
    tag.amountButton.frame = CGRectMake(frame.size.width - amountWidth - 10, vSpace, amountWidth, amountHeight);
//    tag.amount.textAlignment = UITextAlignmentRight;
//    tag.amount.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    tag.amountButton.titleLabel.font = [UIFont systemFontOfSize:13];
    tag.amountButton.tintColor = [UIColor blackColor];
    [tag.amountButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [tag.amountButton setTitle: [Utils getAmountString: [anOrder getAmount] withCurrency:YES] forState:UIControlStateNormal];
    [tag.amountButton addTarget:tag action: @selector(pay) forControlEvents:UIControlEventTouchDown];
    [tag addSubview: tag.amountButton];

    tag.name = [[UILabel alloc] initWithFrame:CGRectMake(10, vSpace, frame.size.width - amountWidth, frame.size.height - 2 * vSpace)];
    tag.name.textAlignment = UITextAlignmentLeft;
    tag.name.font = [UIFont systemFontOfSize:16];
    tag.name.backgroundColor = [UIColor clearColor];
    tag.name.shadowColor = [UIColor lightGrayColor];
    [tag addSubview: tag.name];
    if ([anOrder.name length] > 0)
        tag.name.text = anOrder.name;
    else
    {
        tag.name.text = NSLocalizedString(@"Naamloos", nil);
        tag.name.textColor = [UIColor grayColor];
    }
    return tag;
}

- (void)pay
{
    if([self.delegate respondsToSelector:@selector(didTapPayButtonForOrder:)])
        [self.delegate didTapPayButtonForOrder: self.order];
}

@end