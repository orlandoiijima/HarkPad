//
//  Created by wbison on 10-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "TableOverlayHud.h"


@implementation TableOverlayHud {

}

- (void)showForGuest: (Guest *) guest {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSString *infoText;

    UIFont *font = [UIFont systemFontOfSize:14];

    infoText = [NSString stringWithFormat:@"Gast %d: ", guest.seat + 1];
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
    CGRect sectionFrame = CGRectMake(10,10, self.bounds.size.width - 20, textSize.height);
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.frame = sectionFrame;
    [self addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = infoText;

    sectionFrame = CGRectOffset(sectionFrame, 0, 20);

    NSMutableArray *products = [self getOrderedProductsForLines:guest.lines];
    NSMutableDictionary *productCounts = [self getCountsForProductsInLines:guest.lines forGuest:guest];

    int height = 10 + [self createSectionWithProducts: products counts:productCounts isFood:NO withFrame: sectionFrame];
    sectionFrame  = CGRectOffset(sectionFrame, 0, height);
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
    NSString *text = @"";
    for (Product *product in products) {
        if (product.category.isFood != isFood) continue;
        int quantity = [[productCounts objectForKey:product] intValue];
        text = [self appendProduct:product quantity:quantity toString: text];
    }
    if ([text length] == 0) return 0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, 16, 16)];
    [self addSubview:imageView];
    imageView.image = [UIImage imageNamed: isFood ? @"fork-and-knife.png" : @"wine-glass.png"];

    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    CGSize textSize = [text sizeWithFont: label.font constrainedToSize:CGSizeMake(rect.size.width  - 20, 100)];
    label.frame = CGRectMake(rect.origin.x + 20, rect.origin.y, rect.size.width - 20, textSize.height);
    [self addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = text;

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

    CGRect sectionFrame = CGRectMake(10,10, self.bounds.size.width - 20, self.bounds.size.height);

    if (order.reservation) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16];
        label.frame = sectionFrame;
        label.textAlignment = UITextAlignmentCenter;
        [self addSubview:label];
        label.backgroundColor = [UIColor clearColor];
        label.text = order.reservation.name;
        sectionFrame = CGRectOffset(sectionFrame, 0, 30);

        if ([order.reservation.notes length] > 0) {
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:14];
            label.frame = sectionFrame;
            [self addSubview:label];
            label.backgroundColor = [UIColor clearColor];
            label.text = order.reservation.name;

            sectionFrame = CGRectOffset(sectionFrame, 0, 20);
        }
    }

    NSMutableArray *products = [self getOrderedProductsForLines: order.lines];
    NSMutableDictionary *productCounts = [self getCountsForProductsInLines: order.lines forGuest:nil];

    int height = 10 + [self createSectionWithProducts: products counts:productCounts isFood:NO withFrame: sectionFrame];
    sectionFrame  = CGRectOffset(sectionFrame, 0, height);
    [self createSectionWithProducts: products counts:productCounts isFood:YES withFrame: sectionFrame];

}

@end