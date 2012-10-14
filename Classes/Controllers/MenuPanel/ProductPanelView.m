//
//  ProductPanelView.m
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductPanelView.h"
#import "Product.h"
#import "Menu.h"
#import "CategoryPanelCell.h"
#import "MenuCard.h"
#import "ProductPanelCell.h"
#import "ProductCategory.h"

@implementation ProductPanelView
@synthesize products = _products;
@synthesize selectedItem = _selectedItem;


+ (ProductPanelView *) panelWithFrame:(CGRect) frame delegate: (id<ProductPanelDelegate>)delegate {

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setItemSize:CGSizeMake(125, 60)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    ProductPanelView *view = [[ProductPanelView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    view.panelDelegate = delegate;
    view.backgroundView = nil;
    view.backgroundColor = [UIColor clearColor];

    view.dataSource = view;
    view.delegate = view;
    [view registerClass:[ProductPanelCell class] forCellWithReuseIdentifier:@"xjsjw"];
    return view;
}

- (void)setProducts:(NSMutableArray *)p {
    _products = p;
    [self reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_products count];
}

- (Product *)itemAtIndexPath:(NSIndexPath *)path {
    if (_products == nil || path.row >= _products.count)
        return nil;
    return [self.products objectAtIndex:path.row];
}

- (NSIndexPath *)indexPathForProduct:(Product *)product {
    int i = 0;
    for (Product *p in _products) {
        if ([p.key isEqualToString: product.key])
            return [NSIndexPath indexPathForItem:i  inSection:0];
        i++;
    }
    return nil;
}

- (void) refreshProduct:(Product *)product {
    NSIndexPath *indexPath = [self indexPathForProduct:product];
    if (indexPath == nil) return;
    [self reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    id item = [self itemAtIndexPath:indexPath];
    if (item == nil)
        return nil;

    static NSString *cellIdentifier = @"xjsjw";

    ProductPanelCell *cell = (ProductPanelCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    if ([item isKindOfClass:[Product class]]) {
        Product *product = (Product *)item;
        cell.nameLabel.text = product.key;
        cell.backgroundColor = product.category.color;
    }
    else {
        Menu *menu = (Menu *)item;
        cell.nameLabel.text = menu.key;
        cell.backgroundColor = [UIColor greenColor];
    }
    return cell;
}

- (void)setSelectedItem:(Product *)product {
    _selectedItem = product;
    NSIndexPath *indexPath = [self indexPathForProduct:product];
    if (indexPath == nil) return;
    [self selectItemAtIndexPath: indexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Product *product = [self itemAtIndexPath:indexPath];
    if (product == nil)
        return;
    if (self.panelDelegate == nil) return;
    if ([product isKindOfClass:[Product class]])
        [self.panelDelegate didTapProduct: product];
    else
        [self.panelDelegate didTapMenu: (Menu *)product];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_selectedItem == nil)
        return YES;
    BOOL canDeselect = [self.panelDelegate canDeselect];
    if (canDeselect)
        return YES;
    self.selectedItem = _selectedItem;
    return NO;
}


@end
