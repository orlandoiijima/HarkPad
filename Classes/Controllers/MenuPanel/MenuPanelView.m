//
//  MenuPanelView.m
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuPanelView.h"
#import "ProductCategory.h"
#import "MenuCard.h"

@implementation MenuPanelView
@synthesize categories = _categories;
@synthesize categoryPanelView = _categoryPanelView;
@synthesize productPanelView = _productPanelView;
@synthesize delegate = _delegate;
@synthesize selectedItem = _selectedItem;
@synthesize show = _show;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        self.categoryPanelView = [CategoryPanelView panelWithFrame:CGRectZero delegate:self];
        self.categoryPanelView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview: self.categoryPanelView];

        self.productPanelView = [ProductPanelView panelWithFrame:CGRectZero delegate:self];
        self.productPanelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview: self.productPanelView];
    }
    return self;
}

- (void) setMenuCard:(MenuCard *)card {
    _categories = [[NSMutableArray alloc] init];

    if (_show == MenuPanelShowAll) {
        ProductCategory *favorites = [[ProductCategory alloc] init];
        favorites.name = NSLocalizedString(@"Favorites", nil);
        for (NSString *productKey in card.favorites) {
            Product *product = [card getProduct:productKey];
            if (product != nil)
                [favorites.products addObject:product];
        }
        if ([favorites.products count] > 0)
            [_categories addObject:favorites];

        ProductCategory *menus = [[ProductCategory alloc] init];
        menus.name = NSLocalizedString(@"Menus", nil);
        for (Menu *menu in card.menus) {
            [menus.products addObject:menu];
        }
        if ([menus.products count] > 0)
            [_categories addObject:menus];
    }

    for (ProductCategory *category in card.categories) {
        [_categories addObject: category];
    }
    [_categoryPanelView setCategories:_categories];
    _categoryPanelView.categories = _categories;
}

+ (MenuPanelView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show delegate:(id<ProductPanelDelegate>)delegate{

    MenuPanelView *view = [[MenuPanelView alloc] initWithFrame:frame];
    view.show = show;

    view.delegate = delegate;

    view.categoryPanelView = [CategoryPanelView panelWithFrame: CGRectMake(0, 0, frame.size.width, 100) delegate:view];
    view.categoryPanelView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [view addSubview: view.categoryPanelView];

    frame = CGRectMake(0, CGRectGetMaxY(view.categoryPanelView.frame) + 50, view.frame.size.width, view.frame.size.height - (CGRectGetMaxY(view.categoryPanelView.frame) + 50));
    view.productPanelView = [ProductPanelView panelWithFrame:frame  delegate: view];
    view.productPanelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view addSubview: view.productPanelView];

    [view setMenuCard: menuCard];

    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    int countPerRow = self.frame.size.width / 80;

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) _productPanelView.collectionViewLayout;
    layout.itemSize = CGSizeMake( self.frame.size.width / countPerRow, layout.itemSize.height);
    layout = (UICollectionViewFlowLayout *) _categoryPanelView.collectionViewLayout;
    layout.itemSize = CGSizeMake( self.frame.size.width / countPerRow, layout.itemSize.height);

    float y = 0;
    if ([_categories count] <= 1) {
        _categoryPanelView.hidden = YES;
    }
    else {
        _categoryPanelView.hidden = NO;
        _categoryPanelView.frame = CGRectMake(0, 0, self.frame.size.width, layout.itemSize.height * (ceil([_categories count] / countPerRow)));
        y = CGRectGetMaxY(_categoryPanelView.frame) + 20;
    }
    _productPanelView.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height - y);

}

- (void)didLongPressMenu:(Menu *)menu {

}

- (void)didLongPressProduct:(Product *)product {

}

- (BOOL)canDeselect {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(canDeselect)])
        return [_delegate canDeselect];
    return YES;
}

- (void)didTapMenu:(Menu *)menu {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didTapMenu:)])
        [_delegate didTapMenu: menu];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didSelectMenu:)])
        [_delegate didSelectMenu: menu];
}

- (void)didTapProduct:(Product *)product {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didTapProduct:)])
        [_delegate didTapProduct:product];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didSelectProduct:)])
        [_delegate didSelectProduct:product];
}

- (void)didLongPressCategory:(ProductCategory *)category {

}

- (void)didTapCategory:(ProductCategory *)category {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didTapCategory:)])
        [_delegate didTapCategory:category];
    _productPanelView.products = category.products;
    [self setSelectedItem:[category.products objectAtIndex:0]];
    if ([_productPanelView.selectedItem isKindOfClass:[Product class]]) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(didSelectProduct:)])
            [_delegate didSelectProduct: _productPanelView.selectedItem];
    }
    else {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(didSelectMenu:)])
            [_delegate didSelectMenu: (Menu *)_productPanelView.selectedItem];
    }
}

- (void)setSelectedItem:(id)selectedItem {
    _productPanelView.selectedItem = selectedItem;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[Product class]]) {
        Product *product = (Product *)object;
        if (product == nil) return;
        [_productPanelView refreshProduct:product];
    }
    else
    if ([object isKindOfClass:[ProductCategory class]]) {
        ProductCategory *category = (ProductCategory *)object;
        if (category == nil) return;
        [_categoryPanelView refreshCategory: category];
        [_productPanelView reloadData];
    }
}

@end
