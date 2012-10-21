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

- (void)setPanelItem:(id)item withCategory:(ProductCategory *)category;


@end