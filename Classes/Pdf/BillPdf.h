//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Order.h"
#import "TemplatePrintDelegate.h"

@interface BillPdf : NSObject <TemplatePrintDelegate>

@property (retain) Order *order;

+ (BillPdf *)billByOrder: (Order *)order;
- (NSString *)create;

@end