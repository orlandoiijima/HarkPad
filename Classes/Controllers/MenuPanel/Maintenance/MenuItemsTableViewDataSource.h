//
// Created by wbison on 28-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Product.h"

@interface MenuItemsTableViewDataSource : NSObject <UITableViewDataSource>

@property(nonatomic, strong) Product *product;
@property(nonatomic, copy) UITableViewCell *(^createCell)(int);

+ (MenuItemsTableViewDataSource *)dataSourceWithProduct:(Product *)product createCell:(UITableViewCell * (^)(int))createCell;

@end