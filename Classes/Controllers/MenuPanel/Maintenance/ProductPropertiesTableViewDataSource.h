//
// Created by wbison on 28-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Product;


@interface ProductPropertiesTableViewDataSource : NSObject <UITableViewDataSource>
@property(nonatomic, strong) Product *product;
@property(nonatomic, strong) id delegate;
@property(nonatomic, copy) UITableViewCell *(^createCell)(int);

+ (ProductPropertiesTableViewDataSource *)dataSourceWithProduct:(Product *)product createCell:(UITableViewCell * (^)(int))createCell;

@end