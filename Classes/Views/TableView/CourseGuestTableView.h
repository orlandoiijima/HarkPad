//
//  Created by wbison on 01-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Order.h"
#import "TableView.h"
#import "CourseProgress.h"
#import "GridViewCellLine.h"

@interface CourseGuestTableView : UIView  <UIGestureRecognizerDelegate, ProgressDelegate> {
    CourseProgress *progressView;
}

@property int selectedCourse;
@property (retain) TableView *tableView;
@property (retain) CourseProgress *progressView;
@property (retain) NSMutableArray *cellLines;
@property (retain, nonatomic) Order *order;

+ (CourseGuestTableView *)viewWithTableView: (TableView *) tableView;

- (void) swipe: (UITapGestureRecognizer *)swiper;
- (void)selectCourse: (int) newSelection animate: (BOOL)animate;
- (void) slideInCellLine: (GridViewCellLine *)cellLine;
- (void) slideOutCellLine: (GridViewCellLine *)cellLine;
- (int)courseFromCellLine: (GridViewCellLine *)cellLine;
- (int)seatFromCellLine: (GridViewCellLine *)cellLine;
- (int) tagForSeat: (int)seat course:(int)course;
- (void) slideCellsInOutOnNewCourse: (int)newCourse;

@end