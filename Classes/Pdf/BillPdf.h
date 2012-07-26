//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Order.h"
#import "TemplatePrintDataSource.h"
#import "OrderDataSource.h"

@interface BillPdf : NSObject <TemplatePrintDataSource>

@property (retain) Order *order;
@property (retain) OrderDataSource *orderDataSource;

+ (BillPdf *)billByOrder: (Order *)order;
- (NSString *)create;

- (NSString *)stringForVariable:(NSString *)variable row:(int)row section:(int)section;

@end