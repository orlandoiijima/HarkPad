//
//  Created by wbison on 01-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "CourseGuestScrollView.h"
#import "GridViewCellLine.h"
#import "NSDate-Utilities.h"
#import "CrystalButton.h"


@implementation CourseGuestScrollView {

}

@synthesize selectedCourse, tableView, dateLabel, progressView, button, cellLines, order;

+ (CourseGuestScrollView *)viewWithTableView: (TableView *) tableView
{
    CourseGuestScrollView *view = [[CourseGuestScrollView alloc] initWithFrame:CGRectMake(0, 0, tableView.tableView.bounds.size.width, tableView.tableView.bounds.size.height)];
    view.clipsToBounds = YES;
    view.tableView = tableView;

    view.progressView = [CourseProgress progressWithFrame:CGRectZero countCourses: tableView.orderInfo.countCourses currentCourseOffset: tableView.orderInfo.currentCourseOffset currentCourseState: tableView.orderInfo.currentCourseState selectedCourse: tableView.orderInfo.countCourses-1];
    view.progressView.delegate = view;
    [view addSubview:view.progressView];

    view.dateLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    view.dateLabel.alpha = 0;
    view.dateLabel.backgroundColor = [UIColor clearColor];
    view.dateLabel.shadowColor = [UIColor lightTextColor];
    view.dateLabel.adjustsFontSizeToFitWidth = YES;
    [view addSubview: view.dateLabel];

    view.button = [[CrystalButton alloc] initWithFrame:CGRectMake(tableView.tableView.bounds.size.width/3, 0, 100, 44)];
    [view addSubview: view.button];

    view.selectedCourse = tableView.orderInfo.countCourses - 1;

    view.cellLines = [[NSMutableArray alloc] init];

    [view selectCourse:view.selectedCourse animate:YES];
    return view;
}

- (void)setOrder: (Order *)newOrder
{
    order = newOrder;
    self.progressView.countCourses = [newOrder.courses count];
    Course *course = [newOrder getCurrentCourse];
    if (course != nil) {
        self.progressView.currentCourse = course.offset;
        self.progressView.currentCourseState = course.state;
    }
    self.progressView.selectedCourse = 0;
}

- (void) layoutSubviews {

    Course *nextCourseToRequest = [order getNextCourseToRequest];
    Course *nextCourseToServe = [order getNextCourseToServe];

    Course *course = [order getCourseByOffset:selectedCourse];
    Course *nextCourse = course.nextCourse;

    CGRect seatRect = [tableView rectInTableForSeat: 0];
    CGRect courseInfoRect = CGRectInset([tableView tableInnerRect], 10, 10);
    
    CGFloat y = courseInfoRect.origin.y;
    CGFloat height = tableView.tableView.bounds.size.height - 3*seatRect.size.height - 20;
    if (nextCourseToRequest == course || nextCourseToServe == course)
        height -= 50;
    
    NSDate *date = nil;
    NSString *caption = nil;
    course.servedOn = [[NSDate date] dateBySubtractingMinutes:3];
    if (course.servedOn != nil && [course.servedOn isToday]) {
        date = course.servedOn;
        caption = NSLocalizedString(@"Served", nil);
    }
    else
    if (course.requestedOn != nil && [course.requestedOn isToday]) {
        date = course.requestedOn;
        caption = NSLocalizedString(@"Requested", nil);
    }

    y += height + 5;
    if (date != nil) {
        dateLabel.text = [NSString stringWithFormat:@"%@: %@", caption, [date dateDiff]];
        y += dateLabel.bounds.size.height + 5;
        dateLabel.alpha = 1;
    }
    else
        dateLabel.alpha = 0;

    button.alpha = 0;
    if (nextCourseToRequest == course) {
        [button setTitle:NSLocalizedString(@"Request course", nil) forState:UIControlStateNormal];
        button.alpha = 1;
    }
    else if (nextCourseToServe == course) {
        [button setTitle:NSLocalizedString(@"Serve course", nil) forState:UIControlStateNormal];
        button.alpha = 1;
    }

    if (courseInfoRect.size.width > courseInfoRect.size.height) {
        CGFloat x = courseInfoRect.origin.x;
        progressView.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.height, courseInfoRect.size.height);
        x += progressView.frame.size.width + 20;
        if (button == nil) {
            if (date != nil) {
                dateLabel.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.width - (progressView.frame.size.width + 20), courseInfoRect.size.height);
            }
        }
        else {
            if (date != nil) {
                dateLabel.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.width - (progressView.frame.size.width + 20), 20);
                button.frame = CGRectMake(x, courseInfoRect.origin.y + 20, courseInfoRect.size.width - (progressView.frame.size.width + 20), 44);
            }
            else {
                button.frame = CGRectMake(x, courseInfoRect.origin.y, courseInfoRect.size.width - (progressView.frame.size.width + 20), 44);
            }
        }
    }
    else {
        progressView.frame = CGRectMake(courseInfoRect.origin.x, courseInfoRect.origin.y, courseInfoRect.size.width, courseInfoRect.size.width);
    }
    
    for(GridViewCellLine *cellLine in self.cellLines) {
        int seat = (int)cellLine.tag;
        cellLine.frame = [tableView rectInTableForSeat: seat];
    }
}


- (void)didTapCourse:(NSUInteger)courseOffset {
    [self selectCourse: courseOffset animate:YES];
}

- (void)selectCourse: (NSUInteger) newSelection animate: (BOOL)animate {
    if (selectedCourse == newSelection)
        return;
    if (newSelection >= self.tableView.orderInfo.countCourses)
        return;

    [UIView animateWithDuration:0.1
                     animations:^{ [self slideCellsOut]; }
                      completion:^(BOOL completed)
        {
            [self removeCells];

            progressView.selectedCourse = newSelection;
            [self layoutSubviews];
                for(Guest *guest in order.guests) {
                    TableSide side = [order.table sideForSeat:guest.seat];
                    int dx = 5, dy = 2;
                    switch(side) {
                        case TableSideRight:
                            dx *= -1;
                            break;
                        case TableSideBottom:
                            dy *= -1;
                            break;
                    }
                    CGRect frame = [tableView rectInTableForSeat:guest.seat];
                    for(Course *course in order.courses) {
                        for(OrderLine *line in course.lines) {
                            if (line.guest.id == guest.id) {
                                GridViewCellLine *cellLine = [[GridViewCellLine alloc] initWithTitle:line.product.key middleLabel:nil bottomLabel:nil backgroundColor:line.product.category.color path:nil];
                                cellLine.tag = line.guest.seat;
                                cellLine.frame = CGRectOffset(frame, course.offset * dx, course.offset * dy);
                                [self addSubview:cellLine];
                            }
                        }
                        if (course.offset == newSelection)
                            break;
                    }
                }
                [self slideCellsOut];
                [UIView animateWithDuration:0.2 animations:^{ [self slideCellsIn]; }];
        }];

    selectedCourse = newSelection;
}

- (void) slideCellsOut
{
    for(GridViewCellLine *cellLine in self.subviews) {
        if ([cellLine isKindOfClass:[GridViewCellLine class]] == false) continue;
        int side = [self.tableView.table sideForSeat:cellLine.tag];
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
}

- (void) removeCells
{
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for(GridViewCellLine *cellLine in self.subviews) {
        if ([cellLine isKindOfClass:[GridViewCellLine class]])
            [cells addObject:cellLine];
    }
    [cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void) slideCellsIn
{
    for(GridViewCellLine *cellLine in self.subviews) {
        if ([cellLine isKindOfClass:[GridViewCellLine class]] == false) continue;
        int side = [self.tableView.table sideForSeat:cellLine.tag];
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
}

@end