//
// Created by wbison on 11-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ProductCategory.h"

@interface ProductPanelCell : UICollectionViewCell
@property(retain) UILabel * nameLabel;
@property(nonatomic, strong) UIImageView *addImage;

@property(nonatomic, strong) UIImageView *favoriteImage;

@property(nonatomic, strong) UIColor *standardBackgroundColor;

- (void)setPanelItem:(id)item withCategory:(ProductCategory *)category isFavorite:(bool)isFavorite;


@end