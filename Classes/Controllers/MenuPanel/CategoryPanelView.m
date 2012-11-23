//
//  CategoryPanelView.m
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryPanelView.h"
#import "ProductCategory.h"
#import "MenuCard.h"
#import "CategoryPanelCell.h"
#import "ProductPanelView.h"

@implementation CategoryPanelView
@synthesize panelDelegate = _panelDelegate;
@synthesize categories = _categories;
@synthesize selectedCategory = _selectedCategory;


+ (CategoryPanelView *) panelWithFrame:(CGRect)frame  delegate: (id<ProductPanelDelegate>)delegate {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setItemSize:CGSizeMake(75, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CategoryPanelView *view = [[CategoryPanelView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    view.panelDelegate = delegate;
    [view registerClass:[CategoryPanelCell class] forCellWithReuseIdentifier:@"xjsjw"];

    view.backgroundView = nil;
    view.backgroundColor = [UIColor clearColor];

    view.dataSource = view;
    view.delegate = view;
    return view;
}

- (void)setCategories:(NSMutableArray *)c {
    _categories = c;
    [self reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_categories count];
}

- (ProductCategory *)categoryAtIndexPath:(NSIndexPath *)path {
    if (_categories == nil || path.row >= _categories.count)
        return nil;
    return [_categories objectAtIndex:path.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"xjsjw";

    ProductCategory *category = [self categoryAtIndexPath: indexPath];
    if (category == nil)
        return nil;


    CategoryPanelCell *cell = (CategoryPanelCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    cell.category = category;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCategory *category = [self categoryAtIndexPath: indexPath];
    if (category == nil)
        return;
    [self.panelDelegate didTapCategory:category];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canDeselect = [self.panelDelegate canDeselect];
    if (canDeselect)
        return YES;
    return NO;
}

- (NSIndexPath *)indexPathForCategory:(ProductCategory *)category {
    int i = 0;
    for (ProductCategory *c in _categories) {
        if ([c.name isEqualToString:category.name])
            return [NSIndexPath indexPathForItem:i inSection:0];
        i++;
    }
    return nil;
}

- (void)setSelectedCategory:(ProductCategory *)category {
    NSIndexPath *indexPath = [self indexPathForCategory:category];
    if (indexPath == nil) return;
    [self selectItemAtIndexPath: indexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
    [self.panelDelegate didTapCategory:category];
}

- (void)refreshCategory:(ProductCategory *)category {
    NSIndexPath *indexPath = [self indexPathForCategory: category];
    if (indexPath == nil) return;
    [self reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

@end
