//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SeatView : UIButton

+ (SeatView *)viewWithFrame: (CGRect) frame atSide:(int)side;

@property BOOL isFemale;
@property BOOL hasDiet;
@property BOOL isHost;
@property BOOL isSelected;
@property int side;
@property int offset;
@property (retain) UIImageView *image;
@property (retain) UIImageView *imageTopLeft;
@property (retain) UIImageView *imageTopRight;

@end