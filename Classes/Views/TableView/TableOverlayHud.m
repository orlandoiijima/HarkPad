//
//  Created by wbison on 10-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "TableOverlayHud.h"
#import "UIImage+Tint.h"
#import "NSString+Utilities.h"
#import "Utils.h"
#import "MenuItem.h"


@implementation TableOverlayHud {

}

@synthesize drinkLabel, foodLabel, headerLabel,subHeaderLabel, drinkImage,foodImage;

- (id)initWithFrame: (CGRect)frame {
    self = [super initWithFrame:frame];
    self.autoresizingMask = (UIViewAutoresizing) -1;

    UIFont *font = [UIFont systemFontOfSize:13];

    headerLabel = [[UILabel alloc] init];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.shadowColor = [UIColor lightGrayColor];
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.numberOfLines = 0;
    [self addSubview:headerLabel];

    subHeaderLabel = [[UILabel alloc] init];
    subHeaderLabel.textAlignment = UITextAlignmentCenter;
    subHeaderLabel.font = [UIFont fontWithName:@"Baskerville-Italic" size:13];
    subHeaderLabel.backgroundColor = [UIColor clearColor];
    subHeaderLabel.numberOfLines = 0;
    [self addSubview:subHeaderLabel];

    drinkLabel = [[UILabel alloc] init];
    drinkLabel.textAlignment = UITextAlignmentLeft;
    drinkLabel.font = font;
    drinkLabel.backgroundColor = [UIColor clearColor];
    drinkLabel.numberOfLines = 0;
    [self addSubview:drinkLabel];

    foodLabel = [[UILabel alloc] init];
    foodLabel.textAlignment = UITextAlignmentRight;
    foodLabel.font = font;
    foodLabel.backgroundColor = [UIColor clearColor];
    foodLabel.numberOfLines = 0;
    [self addSubview:foodLabel];

    drinkImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"wine-glass"]];
    [self addSubview: drinkImage];
    drinkImage.contentMode = UIViewContentModeCenter;

    foodImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"fork-and-knife"]];
    [self addSubview: foodImage];
    foodImage.contentMode = UIViewContentModeCenter;

    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectZero;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOffset = CGSizeMake(5, 5);
    layer.shadowOpacity = 0.4;
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.borderWidth = 1;
    layer.cornerRadius = 4;
    layer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:1.0], nil];
    layer.backgroundColor = [[UIColor whiteColor] CGColor];
    [self.layer insertSublayer:layer atIndex:0];
    return self;
}

- (void)showForGuest: (Guest *) guest {
    NSString *infoText = @"";

    subHeaderLabel.text = @"";

    CGFloat y = 10;
    if (guest.isHost || guest.diet != 0) {
        if(guest.isHost)
            infoText = NSLocalizedString(@"Host", nil);
        if (guest.diet != 0) {
            if ([infoText length] > 0)
                infoText = [infoText stringByAppendingString:@", "];
            infoText = [infoText stringByAppendingFormat:@"%@: ", NSLocalizedString(@"Diet", nil)];
            infoText = [infoText stringByAppendingString: guest.dietString];
            infoText = [[infoText lowercaseString] capitalizeFirstLetter];
        }
        CGSize textSize = [infoText sizeWithFont: headerLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width  - 20, 100)];
        CGRect sectionFrame = CGRectMake(10, y, self.bounds.size.width - 20, textSize.height);
        headerLabel.frame = sectionFrame;

        y += 25;
    }
    else
        y += 12;
    headerLabel.text = infoText;

    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.frame = CGRectMake(20, y, self.bounds.size.width - 40, self.bounds.size.height - y - 20);
    layer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];

    NSMutableArray *products = [self getOrderedProductsForLines:guest.lines];
    NSMutableDictionary *productCounts = [self getCountsForProductsInLines:guest.lines forGuest:guest];

    CGRect sectionFrame = CGRectMake(30, y+10, (self.bounds.size.width - 60) / 2, self.bounds.size.height - y - 20);
    drinkImage.frame = CGRectMake(sectionFrame.origin.x, sectionFrame.origin.y - 22, 40, 20);
    [self setupLabel: drinkLabel withProducts: products counts:productCounts isFood:NO withFrame: sectionFrame];

    sectionFrame = CGRectMake(CGRectGetMaxX(sectionFrame), y+10, sectionFrame.size.width, sectionFrame.size.height);
    foodImage.frame = CGRectMake(CGRectGetMaxX(layer.frame) - 50, sectionFrame.origin.y - 22, 40, 20);
    [self setupLabel: foodLabel withProducts: products counts:productCounts isFood:YES withFrame: sectionFrame];
}

- (NSMutableDictionary *)getCountsForProductsInLines: (NSMutableArray *)lines forGuest: (Guest*)guest {
    NSMutableDictionary *productCounts = [[NSMutableDictionary alloc] init];
    for (OrderLine *line in lines) {
        if ((line.guest == nil && guest == nil) || (line.guest.id == guest.id)) {
            NSNumber *countForProduct = [productCounts objectForKey:line.product];
            if (countForProduct == nil) {
                countForProduct = [NSNumber numberWithInt:0];
            }
            countForProduct = [NSNumber numberWithInt: [countForProduct intValue] + line.quantity];
            [productCounts setObject: countForProduct forKey:line.product];
        }
    }
    return productCounts;
}

- (NSMutableArray *)getOrderedProductsForLines: (NSMutableArray *)lines {
    NSArray *orderedLines = [lines sortedArrayUsingComparator: ^(OrderLine *line1, OrderLine *line2) {
        if (line1.course == nil && line2.course == nil) return 0;
        if (line1.course == nil) return -1;
        if (line2.course == nil) return 1;
        return line1.course.offset - line2.course.offset;
    }];
    NSMutableArray *products = [[NSMutableArray alloc] init];
    for (OrderLine *line in orderedLines) {
        if ([products containsObject:line.product] == NO)
            [products addObject:line.product];
    }
    return products;
}

- (void) setupLabel: (UILabel *)label withProducts: (NSMutableArray *) products counts: (NSMutableDictionary *) productCounts isFood: (BOOL) isFood withFrame: (CGRect) rect {
    NSString *text = @"";
    for (Product *product in products) {
        if (product.category.isFood != isFood) continue;
        int quantity = [[productCounts objectForKey:product] intValue];
        text = [self appendProduct:product quantity:quantity toString: text];
    }

    if ([text length] == 0) {
        label.text = NSLocalizedString(isFood ? @"No food" : @"No drink", nil);
        label.textColor = [UIColor lightGrayColor];
    }
    else {
        label.text = text;
        label.textColor = [UIColor blackColor];
    }
    label.textAlignment = isFood ? UITextAlignmentRight : UITextAlignmentLeft;
    CGSize textSize = [label.text sizeWithFont: label.font constrainedToSize:CGSizeMake(rect.size.width, 1000)];
    label.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, textSize.height);
    return;
}

- (NSString *) appendProduct: (Product *) product quantity: (int) quantity toString: (NSString *)text
{
    if (quantity == 0)
        return text;
    if ([text length] > 0)
        text = [text stringByAppendingString:@", "];
    text = [text stringByAppendingString: product.key];
    if (quantity > 1)
        text = [text stringByAppendingFormat:@" (%d)", quantity];
    return text;
}

- (void) showForOrder: (Order *) order {
    CGFloat y = 10;

    CGRect sectionFrame = CGRectMake(10, y, self.bounds.size.width - 20, self.bounds.size.height);
    if (order.reservation && [order.reservation.name length] > 0) {
        headerLabel.hidden = NO;
        headerLabel.text = order.reservation.name;
        CGSize textSize = [order.reservation.name sizeWithFont: headerLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width  - 20, 1000)];
        headerLabel.frame = CGRectMake(10, y, self.bounds.size.width-20, textSize.height);
        y += textSize.height;

        if ([order.reservation.notes length] > 0) {
            NSString *notes = [NSString stringWithFormat:@"'%@'", order.reservation.notes];
            textSize = [notes sizeWithFont: subHeaderLabel.font constrainedToSize:CGSizeMake(self.bounds.size.width  - 100, 1000)];
            subHeaderLabel.frame = CGRectMake(60, y, self.bounds.size.width-120, textSize.height);
            subHeaderLabel.text = notes;
            y += textSize.height;
        }
        else
            subHeaderLabel.text = @"";
    }
    else {
        y += 12;
        headerLabel.text = @"";
        subHeaderLabel.text = @"";
    }

    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.frame = CGRectMake(20, y, self.bounds.size.width - 40, self.bounds.size.height - y - 20);
    layer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];

    NSMutableArray *products = [self getOrderedProductsForLines: order.lines];
    NSMutableDictionary *productCounts = [self getCountsForProductsInLines: order.lines forGuest:nil];

    sectionFrame = CGRectMake(30, y+10, (self.bounds.size.width - 60) / 2, self.bounds.size.height - y - 20);
    drinkImage.frame = CGRectMake(sectionFrame.origin.x, sectionFrame.origin.y - 22, 40, 20);
    [self setupLabel: drinkLabel withProducts: products counts:productCounts isFood:NO withFrame: sectionFrame];

    sectionFrame = CGRectMake(CGRectGetMaxX(sectionFrame), y+10, sectionFrame.size.width, sectionFrame.size.height);
    foodImage.frame = CGRectMake(CGRectGetMaxX(layer.frame) - 50, sectionFrame.origin.y - 22, 40, 20);
    [self setupLabel: foodLabel withProducts: products counts:productCounts isFood:YES withFrame: sectionFrame];
}

-(void)showForNode:(TreeNode *)treeNode {
    if (treeNode.product == nil && treeNode.menu == nil)
        return;

    CGFloat y = 15;

    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.frame = CGRectMake(20, y, self.bounds.size.width - 40, self.bounds.size.height - y - 15);
    layer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:0.7 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.6 alpha:1] CGColor], nil];

    y += 5;

    if (treeNode.product) {
        headerLabel.text = treeNode.product.name;
        drinkLabel.text = treeNode.product.description;
        foodLabel.text = [Utils getAmountString: treeNode.product.price withCurrency:YES];
    }
    else {
        headerLabel.text = treeNode.menu.name;
        drinkLabel.text = @"";
        for(MenuItem *item in treeNode.menu.items) {
            if ([drinkLabel.text length] > 0)
                drinkLabel.text = [drinkLabel.text stringByAppendingString:@", "];
            drinkLabel.text = [drinkLabel.text stringByAppendingString: item.product.name];
        }
        foodLabel.text = [Utils getAmountString: treeNode.menu.price withCurrency:YES];
    }
    CGSize textSize = [headerLabel.text sizeWithFont: headerLabel.font constrainedToSize:CGSizeMake(layer.frame.size.width  - 20, 100)];
    headerLabel.frame = CGRectMake(layer.frame.origin.x + 10, y, layer.frame.size.width - 20, textSize.height);
    headerLabel.textColor = [UIColor blackColor];
    y += textSize.height + 2;

    if ([headerLabel.text isEqualToString:drinkLabel.text] == NO && [drinkLabel.text length] > 0) {
        textSize = [drinkLabel.text sizeWithFont: drinkLabel.font constrainedToSize:CGSizeMake(layer.frame.size.width  - 20, layer.frame.size.height - (y - layer.frame.origin.y) - 20)];
        drinkLabel.frame = CGRectMake(layer.frame.origin.x + 10, y, layer.frame.size.width - 20, textSize.height);
        drinkLabel.textAlignment = UITextAlignmentCenter;
        drinkLabel.textColor = [UIColor blackColor];
        y += textSize.height + 2;
    }
    else
        drinkLabel.text = @"";

    foodLabel.frame = CGRectMake(layer.frame.origin.x + 10, y, layer.frame.size.width - 20, textSize.height);
    foodLabel.textColor = [UIColor blackColor];
    foodLabel.textAlignment = UITextAlignmentCenter;

    drinkImage.frame = CGRectInfinite;
    foodImage.frame = CGRectInfinite;
}

@end