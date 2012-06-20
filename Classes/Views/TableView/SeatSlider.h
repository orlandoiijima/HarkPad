//
// Created by wbison on 19-06-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@protocol SelectSeatDelegate;

@interface SeatSlider : UIView
@property(nonatomic, strong) UIButton *goLeftButton;
@property(nonatomic, strong) UIButton *goRightButton;
@property(nonatomic, assign) int numberOfSeats;
@property(nonatomic, assign) char currentSeat;
@property(nonatomic, strong) UIButton *guestButton;
@property (retain) id<SelectSeatDelegate> delegate;

@property(nonatomic, strong) UILabel *caption;

@property(nonatomic, strong) UILabel *subCaption;

+ (SeatSlider *) sliderWithFrame: (CGRect) frame numberOfSeats: (int) seats delegate: (id) delegate;

@end