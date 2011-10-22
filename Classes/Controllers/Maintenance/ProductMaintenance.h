//
//  Created by wbison on 18-10-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "MaintenanceSplitViewController.h"
#import "ProductCategory.h"

@interface ProductMaintenance : MaintenanceSplitViewController <MaintenanceViewDelegate,UITableViewDataSource>

- (ProductCategory *) categoryForSection: (int)section;

@end