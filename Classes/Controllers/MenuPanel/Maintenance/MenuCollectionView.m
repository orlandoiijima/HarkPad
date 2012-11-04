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
#import "LXReorderableCollectionViewFlowLayout.h"
#import "ProductCategory.h"
#import "Product.h"

@implementation MenuCollectionView
@synthesize show = _show;
@synthesize categories = _categories;
@synthesize isEditing = _isEditing;
@synthesize selectedItem = _selectedItem;
@synthesize menuDelegate = _menuDelegate;


+ (MenuCollectionView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show numberOfColumns:(int) numberOfColumns editing:(BOOL)editing menuDelegate:(id<MenuDelegate>)menuDelegate{

    LXReorderableCollectionViewFlowLayout *flowLayout = [[ LXReorderableCollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.headerReferenceSize = CGSizeMake(200, 40);
    if (numberOfColumns < 1 || frame.size.width / numberOfColumns == 0)
        [flowLayout setItemSize:CGSizeMake(50, 50)];
    else
        [flowLayout setItemSize:CGSizeMake(frame.size.width / numberOfColumns, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

    MenuCollectionView *view = [[MenuCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    view.allowsSelection = YES;
    view.show = show;
    view.isEditing = editing;

    view.numberOfColumns = numberOfColumns;
    view.menuDelegate = menuDelegate;
    view.delegate = view;
    view.dataSource = view;

    [view setMenuCard: menuCard];

    [view registerClass:[ProductPanelCell class] forCellWithReuseIdentifier:@"xjsjw"];
    [view registerNib:[UINib nibWithNibName:@"CategorySupplementaryView" bundle:[NSBundle mainBundle]]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"wsa"];

    [flowLayout setUpGestureRecognizersOnCollectionView];
    return view;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    LXReorderableCollectionViewFlowLayout *flowLayout = (LXReorderableCollectionViewFlowLayout *)self.collectionViewLayout;
    [flowLayout setItemSize:CGSizeMake(frame.size.width / _numberOfColumns, 50)];
}


- (void) setMenuCard:(MenuCard *)card {
    _menuCard = card;
    _categories = [[NSMutableArray alloc] init];

    if (_show == MenuPanelShowAll) {
        ProductCategory *favorites = [ProductCategory categoryFavorites];
        favorites.products = card.favorites;
        [_categories addObject:favorites];

        ProductCategory *menus = [ProductCategory categoryMenus];
        menus.products = card.menus;
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

- (NSMutableArray *)indexPathsForItem:(id)item {
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    int section = 0;
    NSString *key = [item key];
    for (ProductCategory *category in _categories) {
        int row = 0;
        for (id categoryItem in category.products) {
            if ([key isEqualToString: [categoryItem key]])
                [paths addObject: [NSIndexPath indexPathForItem:row  inSection:section]];
            row++;
        }
        section++;
    }
    return paths;
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
    [cell setPanelItem:item withCategory: category isFavorite: [_menuCard isFavorite:item]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ProductCategory *category = [self categoryBySection:indexPath.section];
    if (category == nil) return nil;
    CategorySupplementaryView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"wsa" forIndexPath:indexPath];
    [header setupForCategory:category isEditing:_isEditing delegate:self.menuDelegate ];
    return header;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_categories count];
}

- (void)setSelectedItem:(id)item {
    _selectedItem = item;
    NSMutableArray *paths = [self indexPathsForItem:item];
    if ([paths count] == 0) return;
    [self setSelectedIndexPath:paths[[paths count]-1]];
}

- (void) setSelectedIndexPath: (NSIndexPath *)indexPath {
    [self selectItemAtIndexPath: indexPath animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
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

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setSelectedIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if([self.menuDelegate canDeselect] == NO)
        return NO;
    return YES;
}

- (void)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath willMoveToIndexPath:(NSIndexPath *)theToIndexPath {
    ProductCategory *category = [self categoryBySection:theFromIndexPath.section];
    [self LogCategory:category];
    NSLog(@"%d:%d -> %d:%d", theFromIndexPath.section, theFromIndexPath.row, theToIndexPath.section, theToIndexPath.row);
    Product *product = [category.products objectAtIndex:theFromIndexPath.row];
    if (theFromIndexPath.section == theToIndexPath.section) {
        if (theFromIndexPath.row < theToIndexPath.row) {
            [category.products removeObjectAtIndex:theFromIndexPath.row];
            [category.products insertObject:product atIndex:theToIndexPath.row];
        }
        else {
            [category.products removeObjectAtIndex:theFromIndexPath.row];
            [category.products insertObject:product atIndex:theToIndexPath.row];
        }
    }
    else {
        [category.products removeObjectAtIndex:theFromIndexPath.row];
        category = [self categoryBySection:theToIndexPath.section];
        if (theToIndexPath.section != 0)
            product.category = category;
        [category.products insertObject:product atIndex:theToIndexPath.row];
    }
    [self LogCategory:category];
}

- (void)LogCategory:(ProductCategory *)category {
    int i = 0;
    for(Product *product in category.products) {
        NSLog(@"%d: %@", i++, product.key);
    }
}

- (BOOL)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath canMoveToIndexPath:(NSIndexPath *)theToIndexPath {
    ProductCategory *category = [self categoryBySection:theFromIndexPath.section];
    //  Cant move dummy Add product
    if (theFromIndexPath.row == [category.products count])
        return NO;
    //  Cant move past dummy Add product
    if (theToIndexPath.row == [category.products count])
        return NO;
    return YES;
}

- (void)collectionView:(UICollectionView *)view layout:(LXReorderableCollectionViewFlowLayout *)layout didDropAtIndexPath:(NSIndexPath *)path {
    if (path.section != 0) return;
    if (_draggingFromCategory == nil) return;
    if (_draggingFromCategory.type != CategoryTypeStandard) return;

    //  Restore category
    _draggingProduct.category = _draggingFromCategory;
    [self reloadItemsAtIndexPaths:@[path]];

    [_draggingFromCategory.products insertObject:_draggingProduct atIndex:_draggingFromIndexPath.row];
    [_menuCard.favorites insertObject:_draggingProduct atIndex:_draggingFromIndexPath.row];
    [self insertItemsAtIndexPaths:@[_draggingFromIndexPath]];
}

- (void)collectionView:(UICollectionView *)view layout:(LXReorderableCollectionViewFlowLayout *)layout didStartDragAtIndexPath:(NSIndexPath *)path {
    _draggingFromCategory = [self categoryBySection: path.section];
    _draggingFromIndexPath = path;
    _draggingProduct = [self itemAtIndexPath:path];
}

- (void) refreshItem:(id)item {
    NSMutableArray *paths = [self indexPathsForItem: item];
    [self reloadItemsAtIndexPaths:paths];
    self.selectedItem = _selectedItem;
}

- (void) deleteItem:(id)item {
    NSMutableArray *paths = [self indexPathsForItem:item];
    if ([paths count] == 0) return;
    ProductCategory *category = [item category];
    if (category == nil) return;
    [category.products removeObject:item];
    if ([_menuCard isFavorite:item])
        [_menuCard removeFromQuickMenu: item];
    [self deleteItemsAtIndexPaths:paths];
    [self setSelectedIndexPath: paths[[paths count] -1]];
}

- (void)addToFavorites:(id)item {
    int i = [_menuCard addToQuickMenu: item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
    [self insertItemsAtIndexPaths:[NSArray arrayWithObject: indexPath]];
    [self refreshItem:item];
}

- (void)removeFromFavorites:(id)item {
    int i = [_menuCard removeFromQuickMenu: item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
    [self deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    [self refreshItem:item];
}

- (void)insertCategory:(ProductCategory *)newCategory atIndex:(NSInteger)index {
    if (index < 2) return;
    [_categories insertObject:newCategory atIndex:index];
    [_menuCard.categories insertObject:newCategory atIndex:index - 2];
    [self insertSections:[NSIndexSet indexSetWithIndex:index]];
}

- (int) sectionFromPoint:(CGPoint) point {
    for(CategorySupplementaryView *headerView in [[self headerViews] reverseObjectEnumerator]) {
        if (point.y > headerView.frame.origin.y)
            return [self sectionByCategory: headerView.category];
    }
    return -1;
}

- (NSMutableArray *)headerViews {
    NSMutableArray *headers = [[NSMutableArray alloc] init];
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[CategorySupplementaryView class]]) {
            [headers addObject:view];
        }
    }
    [headers sortUsingComparator:(NSComparator)^(CategorySupplementaryView *view1, CategorySupplementaryView *view2){
        return view1.frame.origin.y > view2.frame.origin.y ? 1 : ( view1.frame.origin.y == view2.frame.origin.y ? 0:-1);
    }];
    return headers;
}
@end
