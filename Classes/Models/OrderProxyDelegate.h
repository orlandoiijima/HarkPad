//
// Created by wbison on 06-05-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Course.h"
#import "Order.h"

typedef enum OrderGrouping {noGrouping, bySeat, byCourse, byCategory} OrderGrouping ;
typedef enum OrderState {
    OrderStateOrdering, OrderStateBilled, OrderStatePaid
} OrderState ;
typedef enum PaymentType {UnPaid, Cash, Pin, CreditCard} PaymentType ;

@protocol OrderProxyDelegate <NSObject>
@required
@property (nonatomic) int id;
@property (retain) NSDate *createdOn;
@property (retain) Table *table;
@property (retain) NSMutableArray *guests;
@property OrderState state;
@property int countCourses;
@property int currentCourseOffset;
@property CourseState currentCourseState;
@property (retain) NSString *language;

- (Guest *) getGuestBySeat: (int)seat;
- (Guest *) addGuest;
@end