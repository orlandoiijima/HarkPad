//
// Created by wbison on 19-06-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "SeatSlider.h"
#import "SelectSeatDelegate.h"
#import "UIImage+Tint.h"


@implementation SeatSlider {
@private
    UIButton *_goLeftButton;
    UIButton *_goRightButton;
    int _numberOfSeats;
    char _currentSeat;
    UIButton *_guestButton;
    UILabel *_caption;
}
@synthesize goLeftButton = _goLeftButton;
@synthesize goRightButton = _goRightButton;
@synthesize numberOfSeats = _numberOfSeats;
@synthesize currentSeat = _currentSeat;
@synthesize guestButton = _guestButton;
@synthesize delegate = _delegate;
@synthesize caption = _caption;
@synthesize subCaption = _subCaption;


- (void)goLeft {
    if (_currentSeat == 0) return;
    self.currentSeat--;
}

- (void)goRight {
    if (_currentSeat == _numberOfSeats - 1) return;
    self.currentSeat++;
}

- (void)goFirst {
    self.currentSeat = 0;
}

- (void)setCurrentSeat:(char)aCurrentSeat {
    _currentSeat = aCurrentSeat;
    _caption.text = [NSString stringWithFormat:@"%d / %d", _currentSeat + 1, _numberOfSeats];
    [_delegate didSelectSeat:_currentSeat];
    _goLeftButton.enabled = _currentSeat != 0;
    _goRightButton.enabled = _currentSeat != _numberOfSeats - 1;
}

+ (SeatSlider *) sliderWithFrame: (CGRect) frame numberOfSeats: (int) seats delegate: (id) delegate {

    SeatSlider *slider = [[SeatSlider alloc] initWithFrame:frame];
    slider.delegate = delegate;

    slider.goLeftButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, frame.size.height, frame.size.height)];
    [slider addSubview:slider.goLeftButton];
    slider.goLeftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [slider.goLeftButton setImage: [[UIImage imageNamed:@"prev48.png"] imageTintedWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [slider.goLeftButton addTarget:slider action:@selector(goLeft) forControlEvents:UIControlEventTouchUpInside];

    slider.guestButton = [[UIButton alloc] initWithFrame: CGRectMake(frame.size.height, 0, frame.size.width - 2*frame.size.height, frame.size.height)];
    [slider addSubview: slider.guestButton];
    slider.guestButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [slider.guestButton setImage: [[UIImage imageNamed:@"user.png"] imageTintedWithColor: [UIColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:1]] forState:UIControlStateNormal];
    [slider.guestButton addTarget:slider action:@selector(goFirst) forControlEvents:UIControlEventTouchUpInside];

    slider.caption = [[UILabel alloc] initWithFrame: CGRectMake(slider.guestButton.frame.origin.x, 0, slider.guestButton.frame.size.width, frame.size.height/2)];
    [slider addSubview:slider.caption];
    slider.caption.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    slider.caption.textAlignment = NSTextAlignmentCenter;
    slider.caption.textColor = [UIColor whiteColor];
    slider.caption.backgroundColor = [UIColor clearColor];
    slider.caption.font = [UIFont systemFontOfSize:24];

    slider.subCaption = [[UILabel alloc] initWithFrame:CGRectMake(slider.guestButton.frame.origin.x, frame.size.height/2, slider.guestButton.frame.size.width, frame.size.height/2)];
    [slider addSubview:slider.subCaption];
    slider.subCaption.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    slider.subCaption.textAlignment = NSTextAlignmentCenter;
    slider.subCaption.textColor = [UIColor whiteColor];
    slider.subCaption.backgroundColor = [UIColor clearColor];
    slider.subCaption.font = [UIFont systemFontOfSize:20];

    slider.goRightButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(frame) - frame.size.height, 0, frame.size.height, frame.size.height)];
    [slider addSubview: slider.goRightButton];
    slider.goRightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [slider.goRightButton setImage: [[UIImage imageNamed:@"next48.png"] imageTintedWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [slider.goRightButton addTarget: slider action:@selector(goRight) forControlEvents:UIControlEventTouchUpInside];

    slider.numberOfSeats = seats;
    slider.currentSeat = 0;

    return slider;
}

- (void)layoutSubviews {
}

@end