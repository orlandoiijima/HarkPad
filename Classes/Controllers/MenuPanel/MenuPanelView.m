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
@synthesize selectedProduct = _selectedProduct;


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
    ProductCategory *favorites = [[ProductCategory alloc] init];
    for (NSString *productKey in card.favorites) {
        Product *product = [card getProduct:productKey];
        if (product != nil)
            [favorites.products addObject:product];
    }
    if ([favorites.products count] > 0)
        [_categories addObject:favorites];

    for (ProductCategory *category in card.categories) {
        [_categories addObject: category];
    }
    [_categoryPanelView setCategories:_categories];
    _categoryPanelView.categories = _categories;
}

+ (MenuPanelView *)viewWithFrame:(CGRect)frame menuCard:(MenuCard *)menuCard delegate:(id<ProductPanelDelegate>)delegate{

    MenuPanelView *view = [[MenuPanelView alloc] initWithFrame:frame];

    view.categories = [[NSMutableArray alloc] init];
    ProductCategory *favorites = [[ProductCategory alloc] init];
    for (NSString *productKey in menuCard.favorites) {
        Product *product = [menuCard getProduct:productKey];
        if (product != nil)
            [favorites.products addObject:product];
    }
    if ([favorites.products count] > 0)
        [view.categories addObject:favorites];

    for (ProductCategory *category in menuCard.categories) {
        [view.categories addObject: category];
    }

    view.delegate = delegate;
    
    view.categoryPanelView = [CategoryPanelView panelWithFrame: CGRectMake(0, 0, frame.size.width, 100) delegate:view];
    view.categoryPanelView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [view addSubview: view.categoryPanelView];

    frame = CGRectMake(0, CGRectGetMaxY(view.categoryPanelView.frame) + 50, view.frame.size.width, view.frame.size.height - (CGRectGetMaxY(view.categoryPanelView.frame) + 50));
    view.productPanelView = [ProductPanelView panelWithFrame:frame  delegate: view];
    view.productPanelView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [view addSubview: view.productPanelView];
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

- (void)didTapMenu:(Menu *)menu {
    if (_delegate == nil) return;
    [_delegate didTapMenu: menu];
}

- (void)didTapProduct:(Product *)product {
    if (_delegate == nil) return;
    [_delegate didTapProduct:product];
}

- (void)didLongPressCategory:(ProductCategory *)category {

}

- (void)didTapCategory:(ProductCategory *)category {
    [_delegate didTapCategory:category];
    _productPanelView.products = category.products;
     _productPanelView.selectedProduct = [category.products objectAtIndex:0];
    [_delegate didTapProduct: _productPanelView.selectedProduct];
}

- (void)setSelectedProduct:(id)selectedProduct {
    _productPanelView.selectedProduct = selectedProduct;
}

@end
