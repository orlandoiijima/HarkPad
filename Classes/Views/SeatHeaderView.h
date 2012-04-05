//
//  Created by wbison on 05-04-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Table;
@class Guest;


@interface SeatHeaderView : UIView

+ (SeatHeaderView *)viewWithFrame:(CGRect) frame forGuest:(Guest *)guest table:(Table *)table showAmount:(BOOL)showAmount;

@end