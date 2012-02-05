//
//  Created by wbison on 01-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "CourseGuestScrollView.h"
#import "Utils.h"
#import "GridViewCellLine.h"
#import "NSDate-Utilities.h"
#import "CourseProgress.h"
#import "CrystalButton.h"


@implementation CourseGuestScrollView {

}

@synthesize selectedCourse, tableView, dateLabel, progressView, button, cellLines;

+ (CourseGuestScrollView *)viewWithTableView: (TableView *) tableView
{
    CourseGuestScrollView *view = [[CourseGuestScrollView alloc] initWithFrame:CGRectMake(0, 0, tableView.tableView.bounds.size.width, tableView.tableView.bounds.size.height - 44)];
    view.clipsToBounds = YES;
    view.tableView = tableView;

    view.progressView = [CourseProgress progressWithFrame:CGRectZero countCourses:[tableView.order.courses count] currentCourse:0 selectedCourse: 0];
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
    
    view.selectedCourse = [tableView.order.courses count] - 1;

    view.cellLines = [[NSMutableArray alloc] init];
    
    UISwipeGestureRecognizer *panGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:view action:@selector(swipeLeft:)];
    panGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    panGesture.delegate = view;
    [view addGestureRecognizer:panGesture];

    panGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:view action:@selector(swipeRight:)];
    panGesture.direction = UISwipeGestureRecognizerDirectionRight;
    panGesture.delegate = view;
    [view addGestureRecognizer:panGesture];

    CALayer *layer = [CALayer layer];
    layer.cornerRadius = 6;
    layer.frame = view.bounds;
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.borderWidth = 3;
    layer.backgroundColor = [[UIColor underPageBackgroundColor] CGColor];
    [view.layer insertSublayer:layer atIndex:0];

    [view selectCourse:view.selectedCourse animate:YES];
    return view;
}

- (void) layoutSubviews {

    Course *nextCourseToRequest = [tableView.order getNextCourseToRequest]; 
    Course *nextCourseToServe = [tableView.order getNextCourseToServe]; 

    Course *course = [self.tableView.order getCourseByOffset:selectedCourse];
    
    CGRect seatRect = [tableView rectInTableForSeat: 0];
    CGRect courseInfoRect = CGRectInset(self.bounds, seatRect.size.width + 20, seatRect.size.height + 20);
    
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

- (void) swipeLeft: (UITapGestureRecognizer *)swiper {
    [self selectCourse: selectedCourse + 1 animate:YES];
}

- (void) swipeRight: (UITapGestureRecognizer *)swiper {
    [self selectCourse: selectedCourse - 1 animate:YES];
}


- (void)didTapCourse:(NSUInteger)courseOffset {
    [self selectCourse: courseOffset animate:YES];
}

- (void)selectCourse: (NSUInteger) newSelection animate: (BOOL)animate {
    if (selectedCourse == newSelection)
        return;
    if (newSelection < 0 || newSelection >= [self.tableView.order.courses count])
        return;

    [UIView animateWithDuration:0.1
                     animations:^{ [self slideCellsOut]; }
                      completion:^(BOOL completed)
        {
            [self removeCells];

            progressView.selectedCourse = newSelection;
            [self layoutSubviews];
            Course *course = [tableView.order getCourseByOffset:newSelection];
            if(course != nil) {
                for(OrderLine *line in course.lines) {
                    GridViewCellLine *cellLine = [[GridViewCellLine alloc] initWithTitle:line.product.key middleLabel:nil bottomLabel:nil backgroundColor:line.product.category.color path:nil];
                    cellLine.tag = line.guest.seat;
                    cellLine.frame = [tableView rectInTableForSeat:line.guest.seat];
                    [self addSubview:cellLine];
                }
                [self slideCellsOut];
                [UIView animateWithDuration:0.2 animations:^{ [self slideCellsIn]; }];
            }
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