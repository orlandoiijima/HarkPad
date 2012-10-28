//
//  Created by wbison on 05-04-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "SeatHeaderView.h"
#import "Guest.h"
#import "SeatView.h"
#import "SeatGridView.h"
#import "Table.h"
#import "Utils.h"


@implementation SeatHeaderView {

}

+ (SeatHeaderView *)viewWithFrame:(CGRect) frame forGuest:(Guest *)guest table:(Table *)table showAmount:(BOOL)showAmount
{
    SeatHeaderView *view = [[SeatHeaderView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizing)-1;

    if (guest == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, view.bounds.size.width-40, view.bounds.size.height)];
        label.autoresizingMask = (UIViewAutoresizing)-1;
        label.text = NSLocalizedString(@"Table", nil);
        [view addSubview:label];
    }
    else {
        CGFloat x = 40;
        SeatView *seatView = [SeatView viewWithFrame:CGRectMake(x, 0, 40, frame.size.height) offset:guest.seat atSide:TableSideTop];
        [seatView initByGuest:guest];
        [view addSubview:seatView];
        x += 40;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, frame.size.width - x, frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"";
        if (guest.isHost) {
            label.text = NSLocalizedString(@"Host", nil);
        }

        if (guest.diet != 0) {
            if ([label.text length] > 0)
                label.text = [label.text stringByAppendingFormat:@" (%@: %@)", [NSLocalizedString(@"Diet", nil) lowercaseString], [guest dietString]];
            else
                label.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Diet", nil), [guest dietString]];
        }

        [view addSubview:label];

        if (showAmount) {
            x = frame.size.width - 113;
            UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(x, 0, 70, frame.size.height)];
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            label.textAlignment = NSTextAlignmentRight;
            label.text = [Utils getAmountString: [guest totalAmount] withCurrency:YES];
            [view addSubview:label];
        }
        else
            x = frame.size.width - 30;

        if (table != nil) {
            x -= 50;
            SeatGridView *seatGridView = [SeatGridView viewWithFrame:CGRectMake(x, 0, 50, frame.size.height) table:table guests:[NSMutableArray arrayWithObject:guest]];
            seatGridView.alignment = NSTextAlignmentRight;
            seatGridView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [view addSubview:seatGridView];
        }
    }

    return view;
}

@end