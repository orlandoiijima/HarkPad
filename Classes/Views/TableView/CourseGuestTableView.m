//
//  Created by wbison on 01-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "CourseGuestTableView.h"
#import "GridViewCellLine.h"
#import "NSDate-Utilities.h"
#import "CrystalButton.h"


@implementation CourseGuestTableView {

}

@synthesize tableView, progressView, cellLines, order;
@dynamic selectedCourse;

+ (CourseGuestTableView *)viewWithTableView: (TableView *) tableView
{
    CourseGuestTableView *view = [[CourseGuestTableView alloc] initWithFrame:CGRectMake(0, 0, tableView.tableView.bounds.size.width, tableView.tableView.bounds.size.height)];
    view.clipsToBounds = YES;
    view.tableView = tableView;

    CGRect courseInfoRect = CGRectInset([tableView tableInnerRect], 10, 10);
    if (courseInfoRect.size.width > courseInfoRect.size.height)
        courseInfoRect = CGRectMake( (view.frame.size.width - courseInfoRect.size.height * 0.9) / 2, (view.frame.size.height - courseInfoRect.size.height * 0.9) / 2, courseInfoRect.size.height * 0.9, courseInfoRect.size.height * 0.9);
    else
        courseInfoRect = CGRectMake( (view.frame.size.width - courseInfoRect.size.height * 0.9) / 2, (view.frame.size.height - courseInfoRect.size.height * 0.9) / 2, courseInfoRect.size.width * 0.9, courseInfoRect.size.width * 0.9);
    view.progressView = [CourseProgress progressWithFrame:courseInfoRect countCourses: tableView.orderInfo.countCourses currentCourseOffset: tableView.orderInfo.currentCourseOffset currentCourseState: tableView.orderInfo.currentCourseState selectedCourse: tableView.orderInfo.countCourses-1];
    view.progressView.delegate = view;
    [view addSubview:view.progressView];

    view.selectedCourse = tableView.orderInfo.countCourses - 1;

    view.cellLines = [[NSMutableArray alloc] init];

    [view selectCourse:view.selectedCourse animate:YES];
    return view;
}

- (BOOL)canSelectCourse:(NSUInteger)courseOffset {
    return YES;
}

- (void)setOrder: (Order *)newOrder
{
    order = newOrder;
    self.progressView.countCourses = [newOrder.courses count];
    Course *course = [newOrder currentCourse];
    if (course != nil) {
        self.progressView.currentCourse = course.offset;
        self.progressView.currentCourseState = course.state;
    }

    for (Guest *guest in order.guests) {
        TableSide side = [order.table sideForSeat: guest.seat];
        int dx = 5, dy = 2;
        switch(side) {
            case TableSideRight:
                dx *= -1;
                break;
            case TableSideBottom:
                dy *= -1;
                break;
        }
        CGRect frame = [tableView rectInTableForSeat: guest.seat];
        if (side == TableSideBottom)
            frame = CGRectOffset( frame, 0,  self.frame.size.height - tableView.tableView.bounds.size.height);
        for (int c = [order.courses count] - 1; c >= 0; c--) {
            course = [order.courses objectAtIndex:c];
            for(OrderLine *line in course.lines) {
                if (line.guest != nil && line.guest.id == guest.id && line.product.category.isFood) {
                    GridViewCellLine *cellLine = [[GridViewCellLine alloc] initWithTitle:line.product.key middleLabel:nil bottomLabel:nil backgroundColor:line.product.category.color path:nil];
                    cellLine.tag = [self tagForSeat: line.guest.seat course: line.course.offset];

                    cellLine.frame = frame;

                    [self addSubview:cellLine];
                    frame = CGRectOffset(frame, dx, dy);
                }
            }
        }
    }

    self.progressView.selectedCourse = 0;
}

//- (void) layoutSubviews {
//
//    Course *nextCourseToRequest = [order nextCourseToRequest];
//    Course *nextCourseToServe = [order nextCourseToServe];
//
//    Course *course = [order getCourseByOffset: self.selectedCourse];
//    Course *nextCourse = course.nextCourse;
//
//    CGRect seatRect = [tableView rectInTableForSeat: 0];
//    CGRect courseInfoRect = CGRectInset([tableView tableInnerRect], 10, 10);
//
//    CGFloat y = courseInfoRect.origin.y;
//    CGFloat height = tableView.tableView.bounds.size.height - 3*seatRect.size.height - 20;
//    if (nextCourseToRequest == course || nextCourseToServe == course)
//        height -= 50;
//
//    NSDate *date = nil;
//    NSString *caption = nil;
//    if (course.servedOn != nil && [course.servedOn isToday]) {
//        date = course.servedOn;
//        caption = NSLocalizedString(@"Served", nil);
//    }
//    else
//    if (course.requestedOn != nil && [course.requestedOn isToday]) {
//        date = course.requestedOn;
//        caption = NSLocalizedString(@"Requested", nil);
//    }
//
//    y += height + 5;
//    if (date != nil) {
//        dateLabel.text = [NSString stringWithFormat:@"%@: %@", caption, [date dateDiff]];
//        y += dateLabel.bounds.size.height + 5;
//        dateLabel.alpha = 1;
//    }
//    else
//        dateLabel.alpha = 0;
//
//    button.alpha = 0;
//    if (nextCourseToRequest == course) {
//        [button setTitle:NSLocalizedString(@"Request course", nil) forState:UIControlStateNormal];
//        button.alpha = 1;
//    }
//    else if (nextCourseToServe == course) {
//        [button setTitle:NSLocalizedString(@"Serve course", nil) forState:UIControlStateNormal];
//        button.alpha = 1;
//    }
//
//    if (courseInfoRect.size.width > courseInfoRect.size.height) {
//        CGFloat x = courseInfoRect.origin.x;
//        progressView.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.height, courseInfoRect.size.height);
//        x += progressView.frame.size.width + 20;
//        if (button == nil) {
//            if (date != nil) {
//                dateLabel.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.width - (progressView.frame.size.width + 20), courseInfoRect.size.height);
//            }
//        }
//        else {
//            if (date != nil) {
//                dateLabel.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.width - (progressView.frame.size.width + 20), 20);
//                button.frame = CGRectMake(x, courseInfoRect.origin.y + 20, courseInfoRect.size.width - (progressView.frame.size.width + 20), 44);
//            }
//            else {
//                button.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.width - (progressView.frame.size.width + 20), 44);
//            }
//        }
//    }
//    else {
//        progressView.frame = CGRectMake(courseInfoRect.origin.x, courseInfoRect.origin.y, courseInfoRect.size.width, courseInfoRect.size.width);
//    }
//}

- (int)seatFromCellLine: (GridViewCellLine *)cellLine
{
    return cellLine.tag & 0xff;
}

- (int)courseFromCellLine: (GridViewCellLine *)cellLine
{
    return ((cellLine.tag & 0xff00) >> 8) & 0xff;
}

- (int) tagForSeat: (int)seat course:(int)course
{
    return seat + (course << 8) + 0xff0000;
}

- (void)didTapCourse:(NSUInteger)courseOffset {
    [self selectCourse: courseOffset animate:YES];
}

- (int)selectedCourse
{
    return self.progressView.selectedCourse;
}

- (void)setSelectedCourse:(int)aSelectedCourse {
    [self selectCourse:aSelectedCourse animate:YES];
    self.progressView.selectedCourse = aSelectedCourse;
}


- (void)selectCourse: (int) newSelection animate: (BOOL)animate {
    if (self.selectedCourse == newSelection)
        return;
    if (newSelection >= self.tableView.orderInfo.countCourses)
        return;

    if (animate)
        [UIView animateWithDuration: 0.5 animations:^{
            [self slideCellsInOutOnNewCourse: newSelection];
        }];
    else
        [self slideCellsInOutOnNewCourse: newSelection];
}

- (void) slideCellsInOutOnNewCourse: (int)newCourse
{
    for(GridViewCellLine *cellLine in self.subviews) {
        if ([cellLine isKindOfClass:[GridViewCellLine class]] == false) continue;
        int courseOffset = [self courseFromCellLine:cellLine];
        if (courseOffset >= newCourse && courseOffset < self.selectedCourse) {
            //  Slide in
            [self slideInCellLine: cellLine];
        }
        else
        if (courseOffset < newCourse && courseOffset >= self.selectedCourse) {
            [self slideOutCellLine: cellLine];
        }
    }
}

- (void) slideOutCellLine: (GridViewCellLine *)cellLine
{
    int side = [self.tableView.table sideForSeat: [self seatFromCellLine: cellLine]];
    switch(side) {
        case 0:
            cellLine.frame = CGRectOffset(cellLine.frame, 0,  - cellLine.frame.size.height * 2);
            break;
        case 1:
            cellLine.frame = CGRectOffset(cellLine.frame, cellLine.frame.size.width * 2, 0);
            break;
        case 2:
            cellLine.frame = CGRectOffset(cellLine.frame, 0, cellLine.frame.size.height * 2);
            break;
        case 3:
            cellLine.frame = CGRectOffset(cellLine.frame, -cellLine.frame.size.width * 2, 0);
            break;
    }
}

- (void) slideInCellLine: (GridViewCellLine *)cellLine
{
    int side = [self.tableView.table sideForSeat:[self seatFromCellLine: cellLine]];
    switch(side) {
        case 0:
            cellLine.frame = CGRectOffset(cellLine.frame, 0,  cellLine.frame.size.height * 2);
            break;
        case 1:
            cellLine.frame = CGRectOffset(cellLine.frame, - cellLine.frame.size.width * 2, 0);
            break;
        case 2:
            cellLine.frame = CGRectOffset(cellLine.frame, 0, - cellLine.frame.size.height * 2);
            break;
        case 3:
            cellLine.frame = CGRectOffset(cellLine.frame, cellLine.frame.size.width * 2, 0);
            break;
    }
}

@end