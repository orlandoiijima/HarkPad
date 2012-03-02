//
//  Created by wbison on 10-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "TableInfoView.h"
#import "NSDate-Utilities.h"


@implementation TableInfoView

@synthesize createdLabel, nameLabel, amountLabel;
@dynamic order;

- (id)initWithFrame: (CGRect) frame order: (Order *)order
{
    self = [super initWithFrame:frame];
    if (self) {

        CGRect rect = CGRectInset(self.bounds, 10, 10);
        if (order.reservation != nil) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, 40)];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview: nameLabel];

            rect = CGRectOffset(rect, 0, nameLabel.frame.size.height);
        }

        createdLabel = [[UILabel alloc] initWithFrame:CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, 20)];
        createdLabel.backgroundColor = [UIColor clearColor];
        [self addSubview: createdLabel];
        rect = CGRectOffset(rect, 0, createdLabel.frame.size.height);

        amountLabel = [[UILabel alloc] initWithFrame:CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, 20)];
        amountLabel.backgroundColor = [UIColor clearColor];
        [self addSubview: amountLabel];
        rect = CGRectOffset(rect, 0, amountLabel.frame.size.height);

//        label.numberOfLines = 0;
//        int duration = [order.createdOn minutesBeforeDate: (order.paidOn == nil ? [NSDate date] : order.paidOn)];
//        label.text = [NSString stringWithFormat:
//           @"Order aangemaakt: %@\n"
//           "Aantal gangen: %d\n"
//           "Aantal gasten: %d\n"
//           "Lopende gang: %@\n"
//           "Bedrag: %@\n"
//           "Tijd: %d minuten\n"
//           "Reservering: %@\n",
//        order.createdOn, [order.courses count], [order.guests count], [Utils getCourseChar: [order getCurrentCourse].offset], order.getAmount, duration, order.reservation.name
//        ];
//        label.textColor = [UIColor blackColor];
//        label.backgroundColor = [UIColor clearColor];
//        [self addSubview:label];
    }
    return self;
}

- (void) setOrder: (Order *)order {
    nameLabel.text = order.reservation.name;
    createdLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@: %@ (%@)", nil), NSLocalizedString(@"Started", nil), [order.createdOn shortTime], [order.createdOn dateDiff]];
    amountLabel.text = [NSString stringWithFormat: @"%@: %@", NSLocalizedString(@"Amount", nil), [Utils getAmountString:[order totalAmount] withCurrency:YES]];
}

@end