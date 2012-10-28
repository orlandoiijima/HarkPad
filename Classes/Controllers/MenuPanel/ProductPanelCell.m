//
// Created by wbison on 11-10-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <QuartzCore/QuartzCore.h>
#import "ProductPanelCell.h"
#import "Product.h"
#import "Menu.h"


@implementation ProductPanelCell {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 5)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.autoresizingMask = (UIViewAutoresizing) -1;
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.nameLabel];

    _favoriteImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite.png"]];
    [self addSubview: _favoriteImage];
    _favoriteImage.frame = CGRectMake(self.bounds.size.width - 20 - 3, 3, 20, 20);
    _favoriteImage.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _favoriteImage.contentMode = UIViewContentModeScaleAspectFit;

    _addImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"ABAddCircle.png"]];
    _addImage.frame = CGRectInset(self.bounds, 5, 5);
    _addImage.contentMode = UIViewContentModeCenter;
    [self addSubview: _addImage];
    _addImage.hidden = YES;

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.cornerRadius = 1;
    gradientLayer.frame = self.bounds;
    gradientLayer.borderColor = [[UIColor blackColor] CGColor];
    gradientLayer.borderWidth = 2;
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:0.94] CGColor], nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil];
    self.layer.mask = gradientLayer;


    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 2;
    self.layer.cornerRadius = 4;

//    CAGradientLayer *l = [CAGradientLayer layer];
//    l.frame = self.bounds;
//    l.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
//    l.startPoint = CGPointMake(0.8f, 1.0f);
//    l.endPoint = CGPointMake(1.0f, 1.0f);
//    self.layer.mask = l;

    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderColor = selected ? [[UIColor blueColor] CGColor] : [[UIColor blackColor] CGColor];
}

- (void)setIsFavorite:(bool)favorite {
    _favoriteImage.hidden = !favorite;
}

- (void) setPanelItem:(id)item withCategory:(ProductCategory *)category isFavorite:(bool)favorite {
    self.isFavorite = favorite;
    if (item == nil) {
        _nameLabel.hidden = YES;
        _addImage.hidden = NO;
        self.backgroundColor = category.color;
    }
    else {
        NSString *key = [item key];
        _nameLabel.text = key;
        _nameLabel.hidden = NO;
        _addImage.hidden = YES;
        if ([item isKindOfClass:[Product class]]) {
            Product *product = (Product *)item;
            self.backgroundColor = product.category.color;
        }
        else {
            self.backgroundColor = [UIColor orangeColor]; // category.color;
        }
    }
}


@end