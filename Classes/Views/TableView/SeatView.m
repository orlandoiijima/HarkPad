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

@synthesize isFemale = _isFemale, isHost = _isHost, hasDiet = _hasDiet, imageTopLeft = _imageTopLeft, imageTopRight = _imageTopRight, isSelected = _isSelected, image = _image;

+ (SeatView *)viewWithFrame: (CGRect) frame atSide: (int)side{
    SeatView *view = [[SeatView alloc] initWithFrame:frame];
    view.image = [[UIImageView alloc] initWithFrame:CGRectInset(view.bounds, 6, 6)];
    view.image.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:view.image];
    
    view.imageTopLeft = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"BlueStar.png"]];
    view.imageTopLeft.frame = CGRectMake(2, 5, 18, 18);
    view.imageTopLeft.transform = CGAffineTransformRotate(view.transform, -side * M_PI_2);
    [view addSubview:view.imageTopLeft];

    view.imageTopRight = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"errorRedDot.png"]];
    view.imageTopRight.frame = CGRectMake(frame.size.width - 16 - 2, 5, 16, 16);
    view.imageTopRight.transform = CGAffineTransformRotate(view.transform, -side * M_PI_2);
    [view addSubview:view.imageTopRight];

    view.transform = CGAffineTransformRotate(view.transform, side * M_PI_2);
    view.alpha = 1.0;

    CALayer *layer = [CAGradientLayer layer];
    layer.cornerRadius = 6;
    layer.frame = CGRectInset(view.bounds, 1, 1);
    layer.borderColor = [[UIColor clearColor] CGColor];
    layer.borderWidth = 3;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
//    layer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
//    layer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.7], [NSNumber numberWithFloat:1.0], nil];
    [view.layer insertSublayer:layer atIndex:0];

    view.isFemale = NO;
    view.isHost = NO;
    view.hasDiet = NO;

    return view;
}

- (void) setIsFemale: (BOOL)isFemale {
    _isFemale = isFemale;
    _image.image = [[UIImage imageNamed:@"user.png"] imageTintedWithColor: _isFemale ? [UIColor colorWithRed:1.0 green:105/255.0 blue:180/255.0 alpha:1] : [UIColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:1]];
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
        layer.borderColor = [[UIColor blueColor] CGColor];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
    }
    else {
        layer.borderColor = [[UIColor clearColor] CGColor];
        layer.backgroundColor = [[UIColor clearColor] CGColor];
    }
}

@end