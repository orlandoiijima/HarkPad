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

- (void)setCategory:(ProductCategory *)category {
    _category = category;
    [self reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_category.products count];
}

- (Product *)itemAtIndexPath:(NSIndexPath *)path {
    if (_category == nil || path.row >= _category.products.count)
        return nil;
    return [_category.products objectAtIndex:path.row];
}

- (NSIndexPath *)indexPathForProduct:(Product *)product {
    int i = 0;
    for (Product *p in _category.products) {
        if ([p.key isEqualToString: product.key])
            return [NSIndexPath indexPathForItem:i  inSection:0];
        i++;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"xjsjw";

    ProductPanelCell *cell = (ProductPanelCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    id item = [self itemAtIndexPath:indexPath];
    [cell setPanelItem:item withCategory: _category isFavorite: [_menuCard isFavorite:item]];
    
    return cell;
}

- (void)setSelectedItem:(Product *)product {
    _selectedItem = product;
    NSIndexPath *indexPath = [self indexPathForProduct:product];
    if (indexPath == nil) return;
    [self selectItemAtIndexPath: indexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.panelDelegate == nil) return;

    Product *product = [self itemAtIndexPath:indexPath];
    if (product == nil)
        return;
    [self.panelDelegate didTapProduct: product];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_selectedItem == nil)
        return YES;
    BOOL canDeselect = YES;
    if (self.panelDelegate != nil && [self.panelDelegate respondsToSelector:@selector(canDeselect)])
        canDeselect = [self.panelDelegate canDeselect];
    if (canDeselect)
        return YES;
    self.selectedItem = _selectedItem;
    return NO;
}


@end
