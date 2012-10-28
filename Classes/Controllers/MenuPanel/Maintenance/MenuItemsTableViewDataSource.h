//
// Created by wbison on 28-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Menu;


@interface MenuItemsTableViewDataSource : NSObject <UITableViewDataSource>

@property(nonatomic, strong) Menu *menu;
@property(nonatomic, copy) UITableViewCell *(^createCell)(int);

+ (MenuItemsTableViewDataSource *)dataSourceWithMenu:(Menu *)menu createCell:(UITableViewCell * (^)(int))createCell;

@end