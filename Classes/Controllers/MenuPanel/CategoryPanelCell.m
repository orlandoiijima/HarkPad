//
// Created by wbison on 11-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "CategoryPanelCell.h"
#import "ProductCategory.h"


@implementation CategoryPanelCell {

}
@synthesize nameLabel = _nameLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 5)];
    self.nameLabel.shadowColor = [UIColor lightGrayColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.autoresizingMask = (UIViewAutoresizing) -1;
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.nameLabel];

    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 2;
    self.layer.cornerRadius = 10;

    return self;
}

-(void) setCategory:(ProductCategory *) category {
    _standardBackgroundColor = category.color;
    _nameLabel.text = category.name;
    [self setSelected: self.selected];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderColor = selected ? [[UIColor whiteColor] CGColor] : [[UIColor blackColor] CGColor];
    self.backgroundColor = selected ? [UIColor blackColor] : _standardBackgroundColor;
    _nameLabel.backgroundColor = self.backgroundColor;
    _nameLabel.textColor = selected ? [UIColor whiteColor] : [UIColor blackColor];
}

@end