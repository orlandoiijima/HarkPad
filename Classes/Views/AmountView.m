//
//  AmountView.m
//  HarkPad
//
//  Created by Willem Bison on 21-08-11.
//  Copyright (c) 2011 The Attic. All rights reserved.
//

#import "AmountView.h"
#import "Utils.h"

@implementation AmountView

@synthesize amount, mainView, centsView, pointView, mainFont, centsFont, showCurrency;

- (id)initWithFrame:(CGRect)frame amount: (NSDecimalNumber *)anAmount showCurrency: (BOOL) currency
{
    self = [self initWithFrame:frame];
    if (self) {
        [self createSubViews];
        showCurrency = currency;
        self.amount = anAmount;
        
    }
    return self;
}


- (void)awakeFromNib
{
    [self createSubViews];
}

- (void) createSubViews
{
    mainView = [[UILabel alloc] init];
    mainView.textAlignment = UITextAlignmentRight;
    [self addSubview:mainView];
    
    centsView = [[UILabel alloc] init];
    centsView.adjustsFontSizeToFitWidth = NO;
    [self addSubview: centsView];
    
    pointView = [[UILabel alloc] init];
    pointView.text = @",";
    [self addSubview: pointView];
    
    self.centsFont = [UIFont systemFontOfSize:14];
    self.mainFont = [UIFont systemFontOfSize:22];
}

- (void) layoutSubviews
{
    [mainView sizeToFit];
    [centsView sizeToFit];
//    centsView.frame = CGRectMake(mainView.frame.size.width, centsView.frame.size.width, centsView.frame.size.height);
//    pointView.frame = CGRectMake(self.bounds.size.width - centsSize.width, centsSize.height, centsSize.width, centsSize.height);
//    mainView.frame = CGRectMake(0, 0, self.bounds.size.width - centsSize.width, self.bounds.size.height);
}

- (void) setCentsFont:(UIFont *)font
{
    centsView.font = font;
    [self layoutSubviews];
}

- (void) setMainFont:(UIFont *)font
{
    mainView.font = font;
    [self layoutSubviews];
}

- (void) setAmount:(NSDecimalNumber *)anAmount 
{
    NSString *s = [Utils getAmountString:anAmount withCurrency: showCurrency];
    mainView.text = [s substringToIndex:[s length] - 3];
    centsView.text = [s substringFromIndex: [s length] - 2];
}

@end
