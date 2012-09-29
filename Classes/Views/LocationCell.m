//
// Created by wbison on 29-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LocationCell.h"


@implementation LocationCell {

}
@synthesize nameLabel = _nameLabel;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.nameLabel];
    return self;
}

- (void)setSelected:(BOOL)selected {
    _nameLabel.backgroundColor = selected ? [UIColor blueColor]: [UIColor clearColor];
}

@end