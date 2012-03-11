//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Guest.h"
#import "Table.h"

@interface SeatView : UIButton {
    BOOL isEmpty;
    BOOL isFemale;
    BOOL hasDiet;
    BOOL isHost;
    BOOL isSelected;
    TableSide side;
    int offset;
}

+ (SeatView *)viewWithFrame: (CGRect) frame offset: (NSUInteger)offset atSide: (TableSide)side showSeatNumber: (BOOL)showSeatNumber;

@property (nonatomic) BOOL isEmpty;
@property (nonatomic) BOOL isFemale;
@property (nonatomic) BOOL hasDiet;
@property (nonatomic) BOOL isHost;
@property (nonatomic) BOOL isSelected;
@property TableSide side;
@property int offset;
@property (retain) UIImageView *image;
@property (retain) UIImageView *imageTopLeft;
@property (retain) UIImageView *imageTopRight;
@property (retain) UILabel *labelSeat;
- (void) initByGuest: (Guest *)guest;

@end