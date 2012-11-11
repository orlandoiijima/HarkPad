//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LocationsView.h"
#import "ServiceResult.h"
#import "Session.h"
#import "Service.h"
#import "LocationCell.h"


@implementation LocationsView {

}
@synthesize locations = _locations;
@dynamic selectedLocationId;

- (int) selectedLocationId {
    if ([self.indexPathsForSelectedItems count] == 0)
        return -1;
    return [[self.indexPathsForSelectedItems objectAtIndex:0] row];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initView];
    return self;
}


- (void)initView
{
    [self registerClass:[LocationCell class] forCellWithReuseIdentifier:@"xjsjw"];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(150, 80)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self setCollectionViewLayout:flowLayout];

    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];

    self.dataSource = self;
    self.delegate = self;
    [[Service getInstance] requestResource:@"location"
                                        id:nil action:nil arguments:nil body:nil verb:HttpVerbGet
                                   success:^(ServiceResult *serviceResult) {
                                       self.locations = [[NSMutableArray alloc] init];
                                       for (NSMutableDictionary *dictionary in serviceResult.jsonData) {
                                           Location *location = [Location locationFromJsonDictionary:dictionary];
                                           [self.locations addObject:location];
                                       }
                                       [self reloadData];
                                   }
                                     error:^(ServiceResult *serviceResult) {
                                         [serviceResult displayError];
                                     }
                              progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Loading...", nil) parentView:self]];
    return;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    Location *location = [self locationAtIndexPath: indexPath];
    if (location == nil)
        return nil;

    static NSString *cellIdentifier = @"xjsjw";

    LocationCell *cell = (LocationCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.nameLabel.text = location.name;
    cell.logoImage.image = location.logo;
    return cell;
}

- (Location *)locationAtIndexPath:(NSIndexPath *)path {
    if (self.locations == nil || path.row >= self.locations.count)
        return nil;
    return [self.locations objectAtIndex:path.row];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.locations == nil)
        return 0;
    return [self.locations count];
}

- (void)addLocation:(Location *)location {
    [self.locations addObject:location];
    [self reloadData];
}

@end