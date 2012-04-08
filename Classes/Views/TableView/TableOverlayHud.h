//
//  Created by wbison on 10-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Guest.h"
#import "Order.h"

@interface TableOverlayHud : UIView

@property (retain) UILabel *headerLabel;
@property (retain) UILabel *subHeaderLabel;
@property (retain) UILabel *drinkLabel;
@property (retain) UILabel *foodLabel;
@property (retain) UIImageView *drinkImage;
@property (retain) UIImageView *foodImage;

- (void)showForGuest: (Guest *) guest;
- (void) showForOrder: (Order *) order;
- (void) setupLabel: (UILabel *)label withProducts: (NSMutableArray *) products counts: (NSMutableDictionary *) productCounts isFood: (BOOL) isFood withFrame: (CGRect) rect;

@end