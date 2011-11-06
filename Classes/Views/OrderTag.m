//
//  Created by wbison on 06-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "OrderTag.h"
#import "Order.h"
#import "Utils.h"


@implementation OrderTag 

@synthesize  name, amount, time;

+ (OrderTag *)tagWithFrame: (CGRect) frame andOrder: (Order *)order {
    OrderTag *tag = [[OrderTag alloc] initWithFrame:frame];
    
    float heightFirst =  (2*frame.size.height) / 3;
    float heightSecond =  frame.size.height - heightFirst;
    int width = 70;
    tag.time = [[UILabel alloc] initWithFrame:CGRectMake(10, heightFirst, width, heightSecond)];
    tag.time.textAlignment = UITextAlignmentLeft;
    tag.time.backgroundColor = [UIColor clearColor];
    tag.time.shadowColor = [UIColor lightGrayColor];
    tag.time.font = [UIFont systemFontOfSize:12];
    tag.time.text = [Utils getElapsedMinutesString:order.createdOn];
    [tag addSubview: tag.time];

    tag.amount = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - width - 10, heightFirst, width, heightSecond)];
    tag.amount.textAlignment = UITextAlignmentRight;
    tag.amount.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    tag.amount.backgroundColor = [UIColor clearColor];
    tag.amount.shadowColor = [UIColor lightGrayColor];
    tag.amount.font = [UIFont systemFontOfSize:12];
    tag.amount.text = [Utils getAmountString: [order getAmount] withCurrency:YES];
    [tag addSubview: tag.amount];

    tag.name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, heightFirst)];
    tag.name.textAlignment = UITextAlignmentCenter;
    tag.name.font = [UIFont systemFontOfSize:16];
    tag.name.backgroundColor = [UIColor clearColor];
    tag.name.shadowColor = [UIColor lightGrayColor];
    [tag addSubview: tag.name];
    if ([order.name length] > 0)
        tag.name.text = order.name;
    else
    {
        tag.name.text = NSLocalizedString(@"Naamloos", nil);
        tag.name.textColor = [UIColor grayColor];
    }
    return tag;
}


@end