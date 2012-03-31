//
//  Created by wbison on 10-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "TableOverlayHud.h"
#import "UIImage+Tint.h"


@implementation TableOverlayHud {

}

- (void)showForGuest: (Guest *) guest {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSString *infoText;

    UIFont *font = [UIFont systemFontOfSize:14];

    CGFloat y = 10;
    if (guest.diet != 0) {
        infoText = [NSString stringWithFormat:@"Diet: "];
        if (guest.diet) {
            NSString *diet = @"";
            for (int i = 0; i < 32; i++) {
                if (guest.diet & (1 << i)) {
                    NSString *dietName = [Guest dietName:i];
                    if ([dietName length] == 0) break;
                    diet = [diet stringByAppendingString:dietName];
                }
            }
            infoText = [infoText stringByAppendingString: diet];
        }
        else {
            infoText = [infoText stringByAppendingString:@"-"];
        }
        CGSize textSize = [infoText sizeWithFont: font constrainedToSize:CGSizeMake(self.bounds.size.width  - 20, 100)];
        CGRect sectionFrame = CGRectMake(10, y, self.bounds.size.width - 20, textSize.height);
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.frame = sectionFrame;
        [self addSubview:label];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.text = infoText;

        y += 25;
        }
    else
        y += 10;

    NSMutableArray *products = [self getOrderedProductsForLines:guest.lines];
    NSMutableDictionary *productCounts = [self getCountsForProductsInLines:guest.lines forGuest:guest];

    CGRect sectionFrame = CGRectMake(20, y, (self.bounds.size.width - 60) / 2, self.bounds.size.height - y - 20);
    [self createSectionWithProducts: products counts:productCounts isFood:NO withFrame: sectionFrame];
    sectionFrame = CGRectMake(sectionFrame.origin.x + sectionFrame.size.width + 20, y, sectionFrame.size.width, sectionFrame.size.height);
    [self createSectionWithProducts: products counts: productCounts isFood:YES withFrame: sectionFrame];
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

- (int) createSectionWithProducts: (NSMutableArray *) products counts: (NSMutableDictionary *) productCounts isFood: (BOOL) isFood withFrame: (CGRect) rect {
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(5, 5);
    view.layer.shadowOpacity = 0.4;
    view.layer.borderColor = [[UIColor grayColor] CGColor];
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 4;
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view ];

    NSString *text = @"";
    for (Product *product in products) {
        if (product.category.isFood != isFood) continue;
        int quantity = [[productCounts objectForKey:product] intValue];
        text = [self appendProduct:product quantity:quantity toString: text];
    }

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y - 12, rect.size.width, 20)];
    [self addSubview:imageView];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = [UIImage imageNamed: isFood ? @"fork-and-knife.png" : @"wine-glass.png"];

    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    if ([text length] == 0) {
        label.text = NSLocalizedString(isFood ? @"No food" : @"No drink", nil);
        label.textColor = [UIColor lightGrayColor];
    }
    else
        label.text = text;
    CGSize textSize = [label.text sizeWithFont: label.font constrainedToSize:CGSizeMake(rect.size.width  - 20, 1000)];
    label.frame = CGRectMake(10, 10, view.frame.size.width - 20, textSize.height);
    [view addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textAlignment = UITextAlignmentCenter;

    return MAX(textSize.height, imageView.image.size.height);
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
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat y = 10;

    CGRect sectionFrame = CGRectMake(10, y, self.bounds.size.width - 20, self.bounds.size.height);
    if (order.reservation && [order.reservation.name length] > 0) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16];
        CGSize textSize = [order.reservation.name sizeWithFont: label.font constrainedToSize:CGSizeMake(self.bounds.size.width  - 20, 1000)];
        label.frame = CGRectMake(10, y, self.bounds.size.width-20, textSize.height);
        label.textAlignment = UITextAlignmentCenter;
        [self addSubview:label];
        label.backgroundColor = [UIColor clearColor];
        label.text = order.reservation.name;
        y += textSize.height + 5;

        if ([order.reservation.notes length] > 0) {
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:14];
            CGSize textSize = [order.reservation.notes sizeWithFont: label.font constrainedToSize:CGSizeMake(self.bounds.size.width  - 20, 1000)];
            label.frame = CGRectMake(10, y, self.bounds.size.width-20, textSize.height);
            [self addSubview:label];
            label.backgroundColor = [UIColor clearColor];
            label.text = order.reservation.notes;

            y += textSize.height + 5;
        }
    }
    else
        y += 10;

    NSMutableArray *products = [self getOrderedProductsForLines: order.lines];
    NSMutableDictionary *productCounts = [self getCountsForProductsInLines: order.lines forGuest:nil];

    sectionFrame = CGRectMake(20, y, (self.bounds.size.width - 60) / 2, self.bounds.size.height - y - 20);
    [self createSectionWithProducts: products counts:productCounts isFood:NO withFrame: sectionFrame];
    sectionFrame = CGRectMake(sectionFrame.origin.x + sectionFrame.size.width + 20, y, sectionFrame.size.width, sectionFrame.size.height);
    [self createSectionWithProducts: products counts:productCounts isFood:YES withFrame: sectionFrame];

}

@end