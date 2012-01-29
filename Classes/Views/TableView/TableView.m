//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "TableView.h"
#import "Guest.h"
#import "GuestProperties.h"

@implementation TableView {

}

@synthesize table, tableView, delegate = _delegate;

+ (TableView *) viewWithFrame: (CGRect)frame table: (Table *)table
{
    TableView *view = [[TableView alloc] init];
    view.frame = frame;
    view.table = table;
    view.backgroundColor = [UIColor clearColor];
    int countSeats = 0;
    CGFloat minimumSize = frame.size.width / (table.seatsHorizontal+2) < frame.size.height / (table.seatsVertical+2) ? frame.size.width / (table.seatsHorizontal+2) : frame.size.height / (table.seatsVertical+2);
    if (minimumSize > 50)
        minimumSize = 50;
    CGSize seatViewSize = CGSizeMake(minimumSize, minimumSize);
    

    GuestProperties *guestPropertiesView = [GuestProperties viewWithGuest: [[Guest alloc] init] frame:CGRectMake(0, 45, 100, 100)];
    guestPropertiesView.delegate = view;

    view.tableView = [SimpleTableView
            viewWithFrame: CGRectMake(
                seatViewSize.width,
                seatViewSize.height,
                frame.size.width - 2 * seatViewSize.width,
                frame.size.height - 2 * seatViewSize.height)
            content:guestPropertiesView];
    [view addSubview:view.tableView];
//    view.tableView.backgroundColor = [UIColor lightGrayColor];

    int seatOffset = 0;
    CGFloat extraSpace = (view.frame.size.width - (table.seatsHorizontal+2) * seatViewSize.width) / (table.seatsHorizontal + 1);
    for(int i=0; i < table.seatsHorizontal; i++) {
        SeatView *seatView = [SeatView viewWithFrame:CGRectMake((i+1) * (seatViewSize.width + extraSpace), 0, seatViewSize.width, seatViewSize.height) atSide:0];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.tag = seatOffset++;
        seatView.isFemale = i&1;
        seatView.isSelected = i&1;
        [view addSubview:seatView];
        
        seatView = [SeatView viewWithFrame:CGRectMake(frame.size.width - seatViewSize.width - (i+1) * (seatViewSize.width + extraSpace), frame.size.height - seatViewSize.height, seatViewSize.width, seatViewSize.height) atSide:2];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.tag = seatOffset++;
    }
    
    extraSpace = (view.frame.size.height - (table.seatsVertical+2) * seatViewSize.height) / (table.seatsVertical + 1);
    for(int i=0; i < table.seatsVertical; i++) {
        SeatView *seatView = [SeatView viewWithFrame: CGRectMake(frame.size.width - seatViewSize.width,  (i+1) * (seatViewSize.height + extraSpace), seatViewSize.width, seatViewSize.height) atSide:1];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.tag = seatOffset++;

        seatView = [SeatView viewWithFrame:CGRectMake(0, frame.size.height - seatViewSize.height - (i+1) * (seatViewSize.height + extraSpace), seatViewSize.width, seatViewSize.height) atSide:3];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.tag = seatOffset++;
    }

    return view;
}

- (void)tapSeat: (id)sender {
    if (_delegate == nil) return;
    SeatView *seatView = (SeatView *)sender;
    if([self.delegate respondsToSelector:@selector(didTapSeat:)])
        [self.delegate didTapSeat: seatView.tag];
    [self selectSeat:seatView.tag];
}

- (void) selectSeat: (int) offset
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            seatView.isSelected = seatView.tag == offset;
        }
    }
}

- (void) setTableContentView: (UIView *)view {
    self.tableView.contentView = view;
}

- (void)didModifyItem:(id)item {
    Guest *guest = (Guest *)item;
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (seatView.tag == guest.seat) {
                seatView.isFemale = !guest.isMale;
                seatView.hasDiet = guest.diet != 0;
                seatView.isHost = guest.isHost;
            }
        }
    }
}

@end