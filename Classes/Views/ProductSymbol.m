//
//  ProductSymbol.m
//  HarkPad
//
//  Created by Willem Bison on 23-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductSymbol.h"


@implementation ProductSymbol

@synthesize product, seat;


+ (ProductSymbol *) symbolWithFrame: (CGRect) frame product: (Product *)product seat: (int)seat {
    ProductSymbol *symbol = [[ProductSymbol alloc] initWithFrame:frame]; 
    symbol.product = product;
    symbol.seat = seat;
    symbol.backgroundColor = [UIColor clearColor];
    symbol.userInteractionEnabled = false;
    return symbol;
}

- (void) setProduct:(Product *)newProduct
{
    [product release];
    product = [newProduct retain];
    product = newProduct;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if(self.product == nil) return;
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 1);
    
    float radius = rect.size.height/2 * 0.9;
    CGPoint center = CGPointMake(rect.size.width/2.0f, rect.size.height/2.0f);
    //    if(exploded) {
    //        center.x += radius/4 * cosf(startAngle + (endAngle - startAngle)/2) ;	
    //        center.y += radius/4 * sinf(startAngle + (endAngle - startAngle)/2) ;	
    //    }
    CGContextMoveToPoint(context, center.x + radius, center.y);
    CGContextAddArc(context, center.x, center.y, radius, 0, 2 * 3.14159f, 0);
  //  CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, [self.product.category.color CGColor]);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end
