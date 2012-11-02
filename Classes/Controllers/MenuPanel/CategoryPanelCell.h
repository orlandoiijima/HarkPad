//
// Created by wbison on 11-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface CategoryPanelCell :  UICollectionViewCell

@property(retain) UILabel * nameLabel;

@property(nonatomic, strong) UIColor *standardBackgroundColor;
@property(nonatomic, strong) id category;
@end