//
// Created by wbison on 28-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ProductPropertiesTableViewDataSource.h"
#import "Product.h"


@implementation ProductPropertiesTableViewDataSource {

}

+ (ProductPropertiesTableViewDataSource *) dataSourceWithProduct:(Product *)product createCell:(UITableViewCell *(^)(int))createCell {
    ProductPropertiesTableViewDataSource *dataSource = [[ProductPropertiesTableViewDataSource alloc] init];
    dataSource.product = product;
    dataSource.createCell = createCell;
    return dataSource;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_product == nil || _product.properties == nil)
        return 0;
    return [_product.properties count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _createCell(indexPath.row);
}

@end