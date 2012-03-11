//
//  Created by wbison on 10-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Guest.h"
#import "Order.h"

@interface TableOverlayHud : UIView

- (void)showForGuest: (Guest *) guest;
- (void) showForOrder: (Order *) order;
- (int) createSectionWithProducts: (NSMutableArray *) products counts: (NSMutableDictionary *) productCounts isFood: (BOOL) isFood withFrame: (CGRect) rect;


@end