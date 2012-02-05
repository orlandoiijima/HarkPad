//
//  Created by wbison on 01-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Order.h"
#import "TableView.h"
#import "CourseProgress.h"

@interface CourseGuestScrollView : UIView  <UIGestureRecognizerDelegate, ProgressDelegate>

@property int selectedCourse;
@property (retain) TableView *tableView;
@property (retain) CourseProgress *progressView;
@property (retain) UILabel *dateLabel;
@property (retain) UIButton *button;
@property (retain) NSMutableArray *cellLines;
+ (CourseGuestScrollView *)viewWithTableView: (TableView *) tableView;

- (void) swipe: (UITapGestureRecognizer *)swiper;
- (void)selectCourse: (NSUInteger) newSelection animate: (BOOL)animate;
- (void) slideCellsOut;
- (void) slideCellsIn;
- (void) removeCells;

@end