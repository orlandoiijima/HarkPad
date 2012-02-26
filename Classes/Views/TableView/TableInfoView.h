//
//  Created by wbison on 10-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "Order.h"
#import "Utils.h"

@interface TableInfoView : UIView

@property (retain) Order *order;
@property (retain) UILabel *nameLabel;
@property (retain) UILabel *createdLabel;
@property (retain) UILabel *amountLabel;

- (id)initWithFrame: (CGRect) frame order: (Order *)order;

@end