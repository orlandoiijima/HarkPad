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

@synthesize isHost = _isHost, hasDiet = _hasDiet, imageTopLeft = _imageTopLeft, imageTopRight = _imageTopRight, isSelected = _isSelected, image = _image, side, offset, guestType = _guestType, labelOverlay, overlayText;

+ (SeatView *)viewWithFrame: (CGRect) frame offset: (NSUInteger)offset atSide: (TableSide)side {
    SeatView *view = [[SeatView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    view.autoresizingMask = (UIViewAutoresizing)-1;
    view.side = side;
    view.offset = offset;
    CGFloat imageSize = MIN(frame.size.height, frame.size.width);
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
    view.imageTopLeft.frame = CGRectMake(2, 1, 18, 18);
    [view addSubview:view.imageTopLeft];

    view.imageTopRight = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"reddotbig.png"]];
    view.imageTopRight.frame = CGRectMake(frame.size.width - 16 - 2, 1, 18, 18);
    [view addSubview:view.imageTopRight];

    view.labelOverlay = [[UILabel alloc] initWithFrame:CGRectMake(0, view.image.frame.origin.y + 5, frame.size.width, view.image.frame.size.height / 2)];
    [view addSubview:view.labelOverlay];
    view.labelOverlay.backgroundColor = [UIColor clearColor];
    view.labelOverlay.shadowColor = [UIColor whiteColor];
    view.labelOverlay.shadowOffset = CGSizeMake(1, 1);
    view.labelOverlay.textAlignment = UITextAlignmentCenter;
    view.labelOverlay.font = [UIFont systemFontOfSize:18];

    view.alpha = 1.0;

    view.guestType = offset == -1 ? guestSpare : guestEmpty;
    view.isHost = NO;
    view.hasDiet = NO;

    return view;
}

- (void)layoutSubviews {
    CGFloat imageSize = MIN(self.frame.size.height, self.frame.size.width);
    self.image.frame = CGRectMake( (self.frame.size.width - imageSize) / 2, (self.frame.size.height - imageSize) / 2, imageSize, imageSize);
    self.imageTopLeft.frame = CGRectMake(
            self.image.frame.origin.x,
            self.image.frame.origin.y,
            self.image.frame.size.width/4,
            self.image.frame.size.width/4);
    self.imageTopRight.frame = CGRectMake(
            self.image.frame.origin.x + self.image.frame.size.width - self.image.frame.size.width/4 - 2,
            self.image.frame.origin.y,
            self.image.frame.size.width/4,
            self.image.frame.size.width/4);
    self.labelOverlay.frame = CGRectMake(0, self.image.frame.origin.y + 5, self.frame.size.width, self.image.frame.size.height / 2);
}

- (void) initByGuest: (Guest *)guest {
    if(guest == nil || guest.guestType == guestEmpty) {
        self.hasDiet = NO;
        self.isHost = NO;
        self.guestType = guestEmpty;
    }
    else {
        self.guestType =  guest.guestType;
        self.hasDiet = guest.diet != 0;
        self.isHost = guest.isHost;
    }
}

- (void)setOverlayText:(NSString *)anOverlayText {
    overlayText = anOverlayText;
    labelOverlay.text = anOverlayText;
}

- (void)setGuestType:(GuestType)aSeatType {
    _guestType = aSeatType;
    switch (aSeatType) {
        case guestEmpty:
            _image.image = [[UIImage imageNamed:@"user_114.png"] imageTintedWithColor: [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
            break;
        case guestMale:
            _image.image = [[UIImage imageNamed:@"user_114.png"] imageTintedWithColor: [UIColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:1]];
            break;
        case guestFemale:
            _image.image = [[UIImage imageNamed:@"user_woman_114.png"] imageTintedWithColor: [UIColor colorWithRed:1.0 green:105/255.0 blue:180/255.0 alpha:1]];
            break;
        case guestSpare:
            _image.image = [[UIImage imageNamed:@"user_114.png"] imageTintedWithColor: [UIColor colorWithRed:0.4 green:1 blue:0.7 alpha:1]];
            break;
    }
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
    if (_isSelected) {
//        int dx = self.side == TableSideTop || self.side == TableSideBottom ? 5 : 0;
//        int dy = self.side == TableSideTop || self.side == TableSideBottom ? 0 : 5;
//        self.transform = CGAffineTransformMakeTranslation(dx, dy);
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations: ^
        {
//            self.transform = CGAffineTransformMakeTranslation(-dx, -dy);
              self.alpha = 0.6;
        } completion: nil];
        labelOverlay.hidden = NO;
    }
    else {
        [self.layer removeAllAnimations];
//        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
        labelOverlay.hidden = YES;
    }
}

@end