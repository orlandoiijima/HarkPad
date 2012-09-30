//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "Location.h"

@interface LocationsView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, strong) NSMutableArray *locations;

@property (nonatomic) int selectedLocationId;

- (void)addLocation:(Location *)location;
@end