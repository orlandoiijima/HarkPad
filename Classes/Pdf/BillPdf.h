//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Order.h"
#import "TemplatePrintDataSource.h"
#import "OrderDataSource.h"

@interface BillPdf : NSObject

@property (retain) Order *order;
@property (retain) OrderDataSource *orderDataSource;

+ (BillPdf *)billByOrder: (Order *)order;
- (NSString *)createFile;

@end