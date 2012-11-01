//
// Created by wbison on 20-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@class Product;
@class ProductCategory;
@class Menu;
@class CategorySupplementaryView;

@protocol MenuDelegate <NSObject>

@optional
- (void) didTapProduct: (Product *)product;
- (void) didTapDummyInCategory:(ProductCategory *)category;
- (void) didDeleteItem:(id)item;
- (void) didModifyItem:(id)item;
- (void) didSelectProduct: (Product *)product;
- (void) didSelectColor:(UIColor *)color forCategory: (ProductCategory *)category;
- (void) didToggleFoodForCategory: (ProductCategory *)category;
- (void) didUpdateProduct:(Product *)product;
- (void) didUpdateMenu:(Menu *)menu;
- (BOOL) canDeselect;
- (void) didTapCategory: (ProductCategory *)category;
- (void) didTapMenu: (Menu *)menu;
- (void) didSelectMenu: (Menu *)menu;
- (void) didInclude: (id)item inFavorites: (bool)include;
- (void) didLongPressProduct: (Product *)product;
- (void) didLongPressMenu: (Menu *)menu;
- (void) didLongPressCategory: (ProductCategory *)category;
@end
