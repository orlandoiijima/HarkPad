//
//  Created by wbison on 26-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Table.h"
#import "Guest.h"

@interface SeatGridView : UIView

@property (retain) NSArray *countSeats;
@property (retain, nonatomic) NSMutableArray *guests;

+ (SeatGridView *)viewWithFrame: (CGRect) frame table: (Table *)table guests: (NSMutableArray *)guests;

- (void) drawStrokedRect: (CGRect)rect fillColor: (UIColor *) fillColor;
- (UIColor *) fillColorForSeat: (int)seat;

@end