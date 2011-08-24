//
//  AmountView.h
//  HarkPad
//
//  Created by Willem Bison on 21-08-11.
//  Copyright (c) 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmountView : UIView {
    UILabel *main;
    UILabel *cents;
    UIFont *mainFont;
    UIFont *centsFont;
    NSDecimalNumber *amount;
}
@property bool showCurrency;
@property (retain) UILabel *mainView;
@property (retain) UILabel *centsView;
@property (retain) UILabel *pointView;
@property (retain, nonatomic) UIFont *mainFont;
@property (retain, nonatomic) UIFont *centsFont;
@property (retain, nonatomic) NSDecimalNumber *amount;

- (void) createSubViews;

@end
