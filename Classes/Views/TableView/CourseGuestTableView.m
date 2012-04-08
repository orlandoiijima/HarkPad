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

+ (CourseGuestTableView *)viewWithTableView: (TableWithSeatsView *) tableView
{
    CourseGuestTableView *view = [[CourseGuestTableView alloc] initWithFrame:CGRectMake(0, 0, tableView.tableView.bounds.size.width, tableView.tableView.bounds.size.height)];
    view.clipsToBounds = NO;
    view.tableView = tableView;

    CGRect courseInfoRect = CGRectInset([tableView tableInnerRect], 10, 10);
    if (courseInfoRect.size.width > courseInfoRect.size.height)
        courseInfoRect = CGRectMake( (view.frame.size.width - courseInfoRect.size.height * 0.9) / 2, (view.frame.size.height - courseInfoRect.size.height * 0.9) / 2, courseInfoRect.size.height * 0.9, courseInfoRect.size.height * 0.9);
    else
        courseInfoRect = CGRectMake( (view.frame.size.width - courseInfoRect.size.width * 0.9) / 2, (view.frame.size.height - courseInfoRect.size.width * 0.9) / 2, courseInfoRect.size.width * 0.9, courseInfoRect.size.width * 0.9);
    view.progressView = [CourseProgress progressWithFrame:courseInfoRect countCourses: tableView.orderInfo.countCourses currentCourseOffset: tableView.orderInfo.currentCourseOffset currentCourseState: tableView.orderInfo.currentCourseState selectedCourse: tableView.orderInfo.countCourses-1 orderState: (OrderState) tableView.orderInfo.state];
    view.progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
        int dx = 5, dy = 0;
        UIViewAutoresizing resizing;
        switch(side) {
            case TableSideTop:
                resizing = UIViewAutoresizingFlexibleLeftMargin;
                dx = 5; dy = 0;
                break;
            case TableSideRight:
                resizing = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin;
                dx = 0; dy = 5;
                break;
            case TableSideBottom:
                resizing = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin;
                dx = 5; dy = 0;
                break;
            case TableSideLeft:
                resizing = UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin;
                dx = 0; dy = 5;
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
                    cellLine.autoresizingMask = resizing;
                    cellLine.textLabel.font = [UIFont systemFontOfSize:14];
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