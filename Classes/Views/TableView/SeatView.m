//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SeatView.h"
#import "UIImage+Tint.h"


@implementation SeatView {

}

@synthesize isFemale = _isFemale, isHost = _isHost, hasDiet = _hasDiet, imageTopLeft = _imageTopLeft, imageTopRight = _imageTopRight, isSelected = _isSelected, image = _image, side, offset, isEmpty = _isEmpty, labelSeat;

+ (SeatView *)viewWithFrame: (CGRect) frame offset: (NSUInteger)offset atSide: (TableSide)side showSeatNumber: (BOOL)showSeatNumber {
    SeatView *view = [[SeatView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizing)-1;
    view.side = side;
    view.offset = offset;
    CGFloat imageSize = MIN(frame.size.height, frame.size.width) - 8;
    view.image = [[UIImageView alloc] initWithFrame:CGRectMake(
            (frame.size.width - imageSize) / 2,
            (frame.size.height - imageSize) / 2,
            imageSize,
            imageSize)
            ];
    view.image.autoresizingMask = (UIViewAutoresizing)-1;
    view.image.contentMode = UIViewContentModeScaleAspectFit;

    [view addSubview:view.image];

    view.imageTopLeft = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BlueStar.png"]];
    view.imageTopLeft.frame = CGRectMake(2, 5, 18, 18);
    [view addSubview:view.imageTopLeft];

    view.imageTopRight = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"reddotbig.png"]];
    view.imageTopRight.frame = CGRectMake(frame.size.width - 16 - 2, 5, 18, 18);
    [view addSubview:view.imageTopRight];

    if (showSeatNumber) {
        view.labelSeat = [[UILabel alloc] initWithFrame:CGRectInset(view.image.frame, 5, 5)];
        [view addSubview:view.labelSeat];
        view.labelSeat.backgroundColor = [UIColor clearColor];
        view.labelSeat.shadowColor = [UIColor whiteColor];
        view.labelSeat.shadowOffset = CGSizeMake(1, 1);
        view.labelSeat.textAlignment = UITextAlignmentCenter;
        view.labelSeat.font = [UIFont systemFontOfSize:18];
        view.labelSeat.text = [NSString stringWithFormat:@"%d", offset + 1];
    }

    view.alpha = 1.0;

    CALayer *layer = [CALayer layer];
    layer.cornerRadius = 6;
    layer.frame = CGRectInset(view.image.frame, -5, -5);
    layer.borderColor = [[UIColor clearColor] CGColor];
    layer.borderWidth = 3;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(3, 3);
    layer.shadowColor = [[UIColor orangeColor] CGColor];
    [view.layer insertSublayer:layer atIndex:0];

    view.isEmpty = YES;
    view.isFemale = NO;
    view.isHost = NO;
    view.hasDiet = NO;

    return view;
}

- (void)setFrame:(CGRect)aFrame {
    [super setFrame:aFrame];
    CALayer *layer = [self.layer.sublayers objectAtIndex:0];
    if (layer == nil) return;
    layer.frame = CGRectInset(self.image.frame, -8, -8);
}

- (void)layoutSubviews {
    self.imageTopLeft.frame = CGRectMake(self.image.frame.origin.x, 9, self.image.frame.size.width/4, self.image.frame.size.width/4);
    self.imageTopRight.frame = CGRectMake(self.image.frame.origin.x + self.image.frame.size.width - self.image.frame.size.width/4 - 2, 9, self.image.frame.size.width/4, self.image.frame.size.width/4);
}

- (void) initByGuest: (Guest *)guest {
    if(guest == nil || guest.isEmpty) {
        self.hasDiet = NO;
        self.isHost = NO;
        self.isEmpty = YES;
    }
    else {
        self.isEmpty = NO;
        self.isFemale = guest.isMale == false;
        self.hasDiet = guest.diet != 0;
        self.isHost = guest.isHost;
    }
}

- (void) setIsEmpty: (BOOL)empty {
    _isEmpty = empty;
    [self setIsFemale:_isFemale];
}

- (void) setIsFemale: (BOOL)female {
    _isFemale = female;
    if (_isEmpty)
        _image.image = [[UIImage imageNamed:@"userbig.png"] imageTintedWithColor: [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
    else
        _image.image = [[UIImage imageNamed:@"userbig.png"] imageTintedWithColor: _isFemale ? [UIColor colorWithRed:1.0 green:105/255.0 blue:180/255.0 alpha:1] : [UIColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:1]];
}

- (void) setHasDiet: (BOOL)newHasDiet {
    _hasDiet = newHasDiet;
    self.imageTopRight.hidden = !newHasDiet;
}

- (void) setIsHost: (BOOL)newIsHost {
    _isHost = newIsHost;
    self.imageTopLeft.hidden = !newIsHost;
}

- (void)setIsSelected:(BOOL)anIsSelected {
    _isSelected = anIsSelected;
    CALayer *layer = [self.layer.sublayers objectAtIndex:0];
    if (_isSelected) {
        layer.borderColor = [[UIColor whiteColor] CGColor];
        layer.backgroundColor = [[UIColor clearColor] CGColor];
    }
    else {
        layer.borderColor = [[UIColor clearColor] CGColor];
        layer.backgroundColor = [[UIColor clearColor] CGColor];
    }
}

@end