//
//  Created by wbison on 06-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Order.h"

@interface OrderTag : UIView {
    UILabel *time;
    UILabel *name;
    UILabel *amount;
}

@property (retain) IBOutlet UILabel *name;
@property (retain) IBOutlet UILabel *amount;
@property (retain) IBOutlet UILabel *time;

+ (OrderTag *)tagWithFrame: (CGRect) frame andOrder: (Order *)order;

@end