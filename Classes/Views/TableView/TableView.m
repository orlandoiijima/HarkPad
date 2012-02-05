//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "TableView.h"
#import "Guest.h"
#import "GuestProperties.h"
#import "Order.h"
#import "CourseGuestScrollView.h"
#import "GuestPropertiesViewController.h"

@implementation TableView {

}

@synthesize table, tableView, delegate = _delegate, order, tabBarController;

#define TOOLBAR_HEIGHT 60

+ (TableView *) viewWithFrame: (CGRect)frame order: (Order *)order
{
    TableView *view = [[TableView alloc] init];
    view.frame = frame;
    view.clipsToBounds = YES;
    view.table = order.table;
    view.order = order;
    Table *table = order.table;
    CGFloat minimumSize = frame.size.width / (table.seatsHorizontal+2) < frame.size.height / (table.seatsVertical+2) ? frame.size.width / (table.seatsHorizontal+2) : (frame.size.height - TOOLBAR_HEIGHT) / (table.seatsVertical+2);
    if (minimumSize > 50)
        minimumSize = 50;
    CGSize seatViewSize = CGSizeMake(minimumSize, minimumSize);

    view.tabBarController = [XTTabBarViewController controllerWithFrame: CGRectMake(
                    seatViewSize.width,
                    seatViewSize.height,
                    frame.size.width - 2 * seatViewSize.width,
                    frame.size.height - 2 * seatViewSize.height) barHeight:TOOLBAR_HEIGHT];
    view.tableView = view.tabBarController.view;
    [view addSubview:view.tableView];

    UIViewController *courseController = [[UIViewController alloc] init];
    courseController.title = NSLocalizedString(@"Courses", nil);
    courseController.tabBarItem.image = [UIImage imageNamed:@"food.png"];
    courseController.view = [CourseGuestScrollView viewWithTableView: view];

    GuestPropertiesViewController *guestController = [GuestPropertiesViewController controllerWithGuest: [order.guests objectAtIndex:0]];
    guestController.delegate = view;

    UIViewController *actionsController = [[UIViewController alloc] init];
    actionsController.title = NSLocalizedString(@"Actions", nil);
    actionsController.tabBarItem.image = [UIImage imageNamed:@"food.png"];

    UIViewController *infoController = [[UIViewController alloc] init];
    infoController.title = NSLocalizedString(@"Info", nil);
    infoController.tabBarItem.image = [UIImage imageNamed:@"food.png"];

    UIViewController *reservationsController = [[UIViewController alloc] init];
    reservationsController.title = NSLocalizedString(@"Reservations", nil);
    reservationsController.tabBarItem.image = [UIImage imageNamed:@"calendar.png"];

    view.tabBarController.viewControllers = [NSArray arrayWithObjects: actionsController, courseController, guestController, reservationsController, infoController, nil];
    view.tabBarController.selectedViewController = courseController;

    CGFloat extraSpace = (view.frame.size.width - (table.seatsHorizontal+2) * seatViewSize.width) / (table.seatsHorizontal + 1);
    for(int i=0; i < table.seatsHorizontal; i++) {
        SeatView *seatView = [SeatView viewWithFrame:CGRectMake((i+1) * (seatViewSize.width + extraSpace), 0, seatViewSize.width, seatViewSize.height) atSide:0];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.offset = i;
        [view addSubview:seatView];
        
        seatView = [SeatView viewWithFrame:CGRectMake(frame.size.width - seatViewSize.width - (i+1) * (seatViewSize.width + extraSpace), frame.size.height - seatViewSize.height, seatViewSize.width, seatViewSize.height) atSide:2];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.offset = i + table.seatsHorizontal + table.seatsVertical;
    }
    
    extraSpace = (view.frame.size.height - TOOLBAR_HEIGHT - (table.seatsVertical+2) * seatViewSize.height) / (table.seatsVertical + 1);
    for(int i=0; i < table.seatsVertical; i++) {
        SeatView *seatView = [SeatView viewWithFrame: CGRectMake(frame.size.width - seatViewSize.width,  (i+1) * (seatViewSize.height + extraSpace), seatViewSize.width, seatViewSize.height) atSide:1];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.offset = i + table.seatsHorizontal;
        if (i & 1)
        {
            seatView.isFemale = YES;
            seatView.hasDiet = YES;
        }

        seatView = [SeatView viewWithFrame:CGRectMake(0, frame.size.height - TOOLBAR_HEIGHT - seatViewSize.height - (i+1) * (seatViewSize.height + extraSpace), seatViewSize.width, seatViewSize.height) atSide:3];
        [view addSubview:seatView];
        [seatView addTarget:view action:@selector(tapSeat:) forControlEvents:UIControlEventTouchDown];
        seatView.offset = i + table.seatsHorizontal + table.seatsVertical + table.seatsHorizontal;
    }

    return view;
}

- (CGRect) rectInTableForSeat: (NSUInteger)seat
{
    SeatView *seatView = [self seatViewAtOffset:seat];
    if (seatView == nil) return CGRectZero;
    CGRect frame = CGRectOffset(seatView.frame, -tableView.frame.origin.x, -tableView.frame.origin.y);
    switch(seatView.side) {
        case 0:
            return CGRectMake(frame.origin.x - seatView.frame.size.width/2, frame.origin.y + seatView.frame.size.height + 7, seatView.bounds.size.width * 2, seatView.bounds.size.height);
            break;
        case 1:
            return CGRectMake(frame.origin.x - seatView.frame.size.width - seatView.frame.size.width - 7, frame.origin.y, seatView.bounds.size.width * 2, seatView.bounds.size.height);
            break;
        case 2:
            return CGRectMake(frame.origin.x - seatView.frame.size.width/2, frame.origin.y - (seatView.frame.size.height + 7) - TOOLBAR_HEIGHT, seatView.bounds.size.width * 2, seatView.bounds.size.height);
            break;
        case 3:
            return CGRectMake(frame.origin.x + seatView.frame.size.width + 7, frame.origin.y, seatView.bounds.size.width * 2, seatView.bounds.size.height);
            break;
    }
    return frame;
}

- (void)tapSeat: (id)sender {
    if (_delegate == nil) return;
    SeatView *seatView = (SeatView *)sender;
    if([self.delegate respondsToSelector:@selector(didTapSeat:)])
        [self.delegate didTapSeat: seatView.offset];
    [self selectSeat:seatView.offset];
}

- (SeatView *)seatViewAtOffset: (NSUInteger)offset
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            if (seatView.offset == offset)
                return seatView;
        }
    }
    return nil;
}

- (void) selectSeat: (int) offset
{
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[SeatView class]]) {
            SeatView *seatView = (SeatView *) view;
            seatView.isSelected = seatView.offset == offset;
        }
    }
}

- (void)didModifyItem:(id)item {
    Guest *guest = (Guest *)item;
    SeatView *seatView = [self seatViewAtOffset:guest.seat];
    if (seatView != nil) {
        seatView.isFemale = !guest.isMale;
        seatView.hasDiet = guest.diet != 0;
        seatView.isHost = guest.isHost;
    }
}

@end