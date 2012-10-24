//
//  MenuCollectionView.m
//  HarkPad
//
//  Created by Willem Bison on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCollectionView.h"
#import "MenuCard.h"
#import "MenuPanelView.h"
#import "ProductPanelCell.h"
#import "Table.h"
#import "MenuDelegate.h"
#import "CategorySupplementaryView.h"

@implementation MenuCollectionView
@synthesize show = _show;
@synthesize categories = _categories;
@synthesize isEditing = _isEditing;
@synthesize selectedItem = _selectedItem;
@synthesize menuDelegate = _menuDelegate;


+ (MenuCollectionView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show editing:(BOOL)editing delegate:(id<MenuDelegate>)delegate{

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.headerReferenceSize = CGSizeMake(100, 40);
    [flowLayout setItemSize:CGSizeMake(125, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

    MenuCollectionView *view = [[MenuCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    view.allowsSelection = YES;
    view.show = show;
    view.isEditing = editing;

    view.menuDelegate = delegate;
    view.delegate = view;
    view.dataSource = view;

    [view setMenuCard: menuCard];

    [view registerClass:[ProductPanelCell class] forCellWithReuseIdentifier:@"xjsjw"];
    [view registerNib:[UINib nibWithNibName:@"CategorySupplementaryView" bundle:[NSBundle mainBundle]]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"wsa"];
    return view;
}


- (void) setMenuCard:(MenuCard *)card {
    _menuCard = card;
    _categories = [[NSMutableArray alloc] init];

    if (_show == MenuPanelShowAll) {
        ProductCategory *favorites = [[ProductCategory alloc] init];
        favorites.name = NSLocalizedString(@"Favorites", nil);
        favorites.type = CategoryTypeFavorites;
        favorites.color = [UIColor clearColor];
        for (Product *product in card.favorites) {
            [favorites.products addObject:product];
        }
        [_categories addObject:favorites];

        ProductCategory *menus = [[ProductCategory alloc] init];
        menus.name = NSLocalizedString(@"Menus", nil);
        menus.type = CategoryTypeMenus;
        menus.color = [UIColor orangeColor];
        for (Menu *menu in card.menus) {
            [menus.products addObject:menu];
        }
        [_categories addObject:menus];
    }

    for (ProductCategory *category in card.categories) {
        [_categories addObject: category];
    }
}

- (ProductCategory *)categoryBySection:(int) section {
    return [_categories objectAtIndex:section];
}

- (int) sectionByCategory: (ProductCategory *)category {
    int section = 0;
    for (ProductCategory *c in _categories) {
        if ([c.name isEqualToString:category.name])
            return section;
        section++;
    }
    return -1;
}

- (id)itemAtIndexPath:(NSIndexPath *)path {
    ProductCategory *category = [self categoryBySection: path.section];
    if (category == nil) return nil;
    if (category.products == nil || path.row >= category.products.count)
        return nil;
    return [category.products objectAtIndex:path.row];
}

- (NSIndexPath *)indexPathForItem:(id)item {
    int section = 0;
    NSString *key = [item key];
    for (ProductCategory *category in _categories) {
        int row = 0;
        for (id categoryItem in category.products) {
            if ([key isEqualToString: [categoryItem key]])
                return [NSIndexPath indexPathForItem:row  inSection:section];
            row++;
        }
        section++;
    }
    return nil;
}

- (BOOL) isDummyAddCell:(NSIndexPath *) indexPath {
    ProductCategory *category = [self categoryBySection: indexPath.section];
    if (category == nil) return NO;
    return indexPath.row == [category.products count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ProductCategory *category = [self categoryBySection:section];
    if (category == nil) return 0;
    if (_isEditing && category.type != CategoryTypeFavorites)
        return [category.products count] + 1;
    return [category.products count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"xjsjw";

    ProductPanelCell *cell = (ProductPanelCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    id item = [self itemAtIndexPath:indexPath];
    ProductCategory *category = [self categoryBySection: indexPath.section];
    [cell setPanelItem:item withCategory: category];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ProductCategory *category = [self categoryBySection:indexPath.section];
    if (category == nil) return nil;
    CategorySupplementaryView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"wsa" forIndexPath:indexPath];
    [header setupForCategory:category delegate:self.menuDelegate];
    return header;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_categories count];
}

- (void)setSelectedItem:(id)item {
    _selectedItem = item;
    NSIndexPath *indexPath = [self indexPathForItem:item];
    if (indexPath == nil) return;
    [self selectItemAtIndexPath: indexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];

}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    _selectedItem = item;
    if ([self isDummyAddCell:indexPath]) {
        ProductCategory *category = [self categoryBySection:indexPath.section];
        [self.menuDelegate didTapDummyInCategory:category];
    }
    else
    if ([item isKindOfClass:[Product class]])
        [self.menuDelegate didSelectProduct: (Product *)item];
    else
        [self.menuDelegate didSelectMenu: (Menu *)item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) refreshItem:(id)item {
    NSIndexPath *indexPath = [self indexPathForItem: item];
    if (indexPath == nil) return;
    [self reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void) deleteItem:(id)item {
    NSIndexPath *indexPath = [self indexPathForItem: item];
    if (indexPath == nil) return;
    ProductCategory *category = [item category];
    if (category == nil) return;
    [category.products removeObject:item];
    [self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)addToFavorites:(id)item {
    [_menuCard addToQuickMenu: item];
    ProductCategory *category = [_categories objectAtIndex:0];
    [category.products addObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[category.products count] - 1 inSection:0];
    [self insertItemsAtIndexPaths:[NSArray arrayWithObject: indexPath]];
}
- (void)removeFromFavorites:(id)item {
    [_menuCard removeFromQuickMenu: item];
    ProductCategory *category = [_categories objectAtIndex:0];
    int i = [category.products indexOfObjectPassingTest:^(id p, NSUInteger i, BOOL *x){
        return [[item key] isEqualToString:[p key]];
    }];
    [category.products removeObjectAtIndex:i];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
    [self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

@end
