//
//  Created by wbison on 05-04-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Table;
@class Guest;


@interface SeatHeaderView : UIView

@property(nonatomic, strong) UIColor *textColor;

+ (SeatHeaderView *)viewWithFrame:(CGRect) frame forGuest:(Guest *)guest table:(Table *)table showAmount:(BOOL)showAmount textColor:(UIColor *)textcolor backgroundColor:(UIColor *)bgr;

@end