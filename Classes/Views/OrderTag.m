//
//  Created by wbison on 06-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "OrderTag.h"
#import "Order.h"
#import "Utils.h"
#import "CrystalButton.h"
#import "NSDate-Utilities.h"


@implementation OrderTag 

@synthesize  name, payButton, time, delegate, order, printButton, dateLabel;

+ (OrderTag *)tagWithFrame: (CGRect) frame andOrder: (Order *)anOrder delegate: (id<OrderViewDelegate>)delegate {
    OrderTag *tag = [[OrderTag alloc] initWithFrame:frame];
    tag.order = anOrder;
    tag.delegate = delegate;
    float vSpace = 2;
    float buttonWidth = 35;
    float amountHeight = frame.size.height - 2*vSpace;
    float nameWidth = frame.size.width;
    if ([anOrder.lines count] > 0) {
        tag.payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tag.payButton.frame = CGRectMake(frame.size.width - buttonWidth - 10, vSpace, buttonWidth, amountHeight);
        [tag.payButton setImage:[UIImage imageNamed:@"creditcard.png"] forState:UIControlStateNormal];
        tag.payButton.titleLabel.font = [UIFont systemFontOfSize:14];
        tag.payButton.tintColor = [UIColor blackColor];
        [tag.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tag.payButton setTitle: [Utils getAmountString: [anOrder getAmount] withCurrency:YES] forState:UIControlStateNormal];
        [tag.payButton addTarget:tag action: @selector(pay) forControlEvents:UIControlEventTouchDown];
        [tag addSubview: tag.payButton];

        tag.printButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tag.printButton.frame = CGRectMake(tag.payButton.frame.origin.x - buttonWidth - 10, vSpace, buttonWidth, amountHeight);
        [tag.printButton setImage:[UIImage imageNamed:@"printer"] forState:UIControlStateNormal];
        [tag.printButton addTarget:tag action: @selector(print) forControlEvents:UIControlEventTouchDown];
        [tag addSubview: tag.printButton];

        tag.dateLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, frame.size.height - 14, frame.size.width, 10)];
        [tag addSubview: tag.dateLabel];
        tag.dateLabel.backgroundColor = [UIColor clearColor];
        tag.dateLabel.textColor = [UIColor lightGrayColor];
        tag.dateLabel.font = [UIFont systemFontOfSize:11];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        if ([anOrder.createdOn isToday]) {
            tag.dateLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate: anOrder.createdOn]];
        }
        else {
            tag.dateLabel.text = [NSString stringWithFormat:@"%@ %@", [anOrder.createdOn prettyDateString], [formatter stringFromDate: anOrder.createdOn]];
        }
        nameWidth = tag.printButton.frame.origin.x;
    }

    tag.name = [[UILabel alloc] initWithFrame:CGRectMake(13, vSpace, nameWidth - 13, frame.size.height - 2 * vSpace - 10)];
    tag.name.textAlignment = UITextAlignmentLeft;
    tag.name.font = [UIFont boldSystemFontOfSize:16];
    tag.name.backgroundColor = [UIColor clearColor];
    [tag addSubview: tag.name];
    if ([anOrder.name length] > 0) {
        tag.name.text = anOrder.name;
        tag.name.textColor = [UIColor colorWithRed:0 green:0 blue:0.7 alpha:1];
    }
    else
    {
        tag.name.text = NSLocalizedString(@"No name", nil);
        tag.name.textColor = [UIColor lightGrayColor];
    }
    return tag;
}

- (void)pay
{
    if([self.delegate respondsToSelector:@selector(didTapPayButtonForOrder:)])
        [self.delegate didTapPayButtonForOrder: self.order];
}
- (void)print
{
    if([self.delegate respondsToSelector:@selector(didTapPrintButtonForOrder:)])
        [self.delegate didTapPrintButtonForOrder: self.order];
}


@end