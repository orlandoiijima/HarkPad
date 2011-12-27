//
//  Created by wbison on 06-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Order.h"

@protocol OrderViewDelegate <NSObject>
@optional
- (void) didTapPayButtonForOrder: (Order *)order;
- (void) didTapPrintButtonForOrder: (Order *)order;
@end

@interface OrderTag : UIView {
    UILabel *time;
    UILabel *name;
    UIButton *payButton;
}

@property (retain) id<OrderViewDelegate> delegate;
@property (retain) IBOutlet UILabel *name;
@property (retain) IBOutlet UIButton *payButton;
@property (retain) IBOutlet UILabel *time;
@property (retain)Order *order;
@property (retain) UIButton *printButton;
@property (retain) UILabel *dateLabel;

+ (OrderTag *)tagWithFrame: (CGRect) frame andOrder: (Order *)order delegate: (id<OrderViewDelegate>)delegate;
- (void)pay;

@end