//
//  ProductSymbol.m
//  HarkPad
//
//  Created by Willem Bison on 23-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductSymbol.h"


@implementation ProductSymbol

@synthesize food, drink, seat, label, gradient;


+ (ProductSymbol *) symbolWithFrame: (CGRect) frame seat: (int)seat {
    ProductSymbol *symbol = [[ProductSymbol alloc] initWithFrame:frame]; 
    symbol.seat = seat;
    symbol.label = [[UILabel alloc] initWithFrame: CGRectInset(symbol.bounds, 4, 4)];
    symbol.label.adjustsFontSizeToFitWidth = YES;
    symbol.label.backgroundColor = [UIColor clearColor];
    [symbol addSubview:symbol.label];
    symbol.backgroundColor = [UIColor clearColor];
    symbol.userInteractionEnabled = false;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = symbol.bounds;
    gradient.cornerRadius = 4;
    gradient.borderColor = [[UIColor grayColor] CGColor];
    gradient.borderWidth = 0;
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.6], [NSNumber numberWithFloat:1.0], nil];		
    [symbol.layer insertSublayer:gradient atIndex:0];        
    symbol.gradient = gradient;
    
    return symbol;
}

- (void) setFood:(Product *)newFood drink: (Product *)newDrink
{
    food = newFood;
    drink = newDrink;
    if(food != nil)
    {
        gradient.borderWidth = 1;
        gradient.borderColor = [[UIColor blackColor] CGColor];
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[food.category.color CGColor],
                           (id)[[food.category.color colorWithAlphaComponent:0.5] CGColor],
                           nil];
    }
    else
    {
        if(drink == nil)
        {
            gradient.borderWidth = 0;
        }
        else
        {
            gradient.borderWidth = 1;
            gradient.borderColor = [[UIColor grayColor] CGColor];
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], nil];
        }
    }
    if(drink != nil)
    {
        label.shadowColor = drink.category.color == [UIColor whiteColor] ? [UIColor blackColor] : [UIColor whiteColor];
        label.textColor  = drink.category.color;
        label.text = [[drink.key substringToIndex:2] uppercaseString];
    }
    else
    {
        label.text = @"";
    }
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [super dealloc];
}

@end
