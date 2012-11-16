//
// Created by wbison on 28-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MenuItemsTableViewDataSource.h"

@implementation MenuItemsTableViewDataSource {

}

+ (MenuItemsTableViewDataSource *) dataSourceWithProduct:(Product *)product createCell:(UITableViewCell *(^)(int))createCell {
    MenuItemsTableViewDataSource *dataSource = [[MenuItemsTableViewDataSource alloc] init];
    dataSource.product = product;
    dataSource.createCell = createCell;
    return dataSource;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_product.items count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _createCell(indexPath.row);
}

@end