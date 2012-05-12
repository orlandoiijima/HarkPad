//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Guest.h"
#import "Table.h"

typedef enum SeatType {seatMale, seatFemale, seatEmpty, seatSpare} SeatType ;

@interface SeatView : UIButton {
    SeatType seatType;
    BOOL isFemale;
    BOOL hasDiet;
    BOOL isHost;
    BOOL isSelected;
    TableSide side;
    int offset;
}

+ (SeatView *)viewWithFrame: (CGRect) frame offset: (NSUInteger)offset atSide: (TableSide)side;

@property (nonatomic) SeatType seatType;
@property (nonatomic) BOOL hasDiet;
@property (nonatomic) BOOL isHost;
@property (nonatomic) BOOL isSelected;
@property TableSide side;
@property int offset;
@property (retain) UIImageView *image;
@property (retain) UIImageView *imageTopLeft;
@property (retain) UIImageView *imageTopRight;
@property (retain) UILabel *labelOverlay;
@property (retain, nonatomic) NSString *overlayText;
- (void) initByGuest: (Guest *)guest;

@end