//
//  Created by wbison on 26-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SeatGridView : UIView

@property int countHorizontal;
@property int countVertical;
@property int selectedOffset;

+ (SeatGridView *)viewWithFrame: (CGRect) frame countHorizontal: (int) countHorizontal countVertical: (int)countVertical selectedOffset: (int) selectedOffset;
- (void) drawStrokedRect: (CGRect)rect filled: (BOOL) isFilled;

@end