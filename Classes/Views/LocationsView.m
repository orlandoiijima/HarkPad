//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LocationsView.h"
#import "ServiceResult.h"
#import "Session.h"
#import "Service.h"
#import "OrderLineCell.h"
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
    [flowLayout setItemSize:CGSizeMake(200, 200)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self setCollectionViewLayout:flowLayout];

    self.dataSource = self;
    self.delegate = self;
    [[Service getInstance]
            requestResource:@"location"
                         id:nil
                     action:nil
                  arguments:nil
                       body:nil
                     method:@"GET"
                credentials:[Session credentials]
                    success: ^(ServiceResult *serviceResult) {
                            self.locations = [[NSMutableArray alloc] init];
                        for (NSMutableDictionary *dictionary in serviceResult.jsonData) {
                            [self.locations addObject: [dictionary objectForKey:@"name"]];
                        }
                        [self reloadData];
                    }
                      error:nil];
    return;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.locations == nil)
        return nil;

    static NSString *cellIdentifier = @"xjsjw";

    LocationCell *cell = (LocationCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.nameLabel.text = [self.locations objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.locations == nil)
        return 0;
    return [self.locations count];
}


@end