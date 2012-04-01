//
//  Created by wbison on 10-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "Order.h"
#import "Utils.h"

@interface TableOverlayInfo : UIView

@property (retain) Order *order;
@property (retain) UIScrollView *scrollView;

- (id)initWithFrame: (CGRect) frame order: (Order *)order;

@end