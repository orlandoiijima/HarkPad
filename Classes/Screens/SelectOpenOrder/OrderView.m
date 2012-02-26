//
//  OrderView.m
//  HarkPad
//
//  Created by Willem Bison on 11/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OrderView.h"
#import "Utils.h"
#import "SelectOpenOrder.h"
#import "NSDate-Utilities.h"

@implementation OrderView

@synthesize order = _order, dataSource, tableView, label, isSelected = _isSelected, infoLabel, amountLabel;

- (id)initWithFrame:(CGRect)frame order: (Order *)anOrder delegate: (id<OrderViewDelegate>) delegate
{
    self = [super initWithFrame:frame];
    if (self) {

        if ([anOrder.lines count] > 0) {
            self.label = [OrderTag tagWithFrame:CGRectMake(0, 2, frame.size.width, 45) andOrder: anOrder delegate: delegate];
            [self addSubview:self.label];
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.label.frame.size.height + 6, frame.size.width, frame.size.height - self.label.frame.size.height - 10 - 25) style:UITableViewStyleGrouped];
            self.tableView.backgroundColor = [UIColor clearColor];
            self.tableView.backgroundView = nil;
            self.tableView.sectionHeaderHeight = 1;
            [self addSubview:self.tableView];
            self.tableView.delegate = self;

            self.amountLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.bounds.size.width - 100, self.bounds.size.height - 25, 87, 20)];
            [self addSubview:self.amountLabel];
            self.amountLabel.textAlignment = UITextAlignmentRight;
            self.amountLabel.backgroundColor = [UIColor clearColor];
            self.amountLabel.text = [Utils getAmountString:[anOrder getAmount] withCurrency:YES];
        }
        else {
            infoLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, self.bounds.size.height/3, self.bounds.size.width - 40, 40)];
            infoLabel.backgroundColor = [UIColor clearColor];
            infoLabel.textColor = [UIColor grayColor];
            infoLabel.numberOfLines = 0;
            infoLabel.lineBreakMode = UILineBreakModeWordWrap;
            [self addSubview:infoLabel];
            if (anOrder.id == byNothing) {
                UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(infoLabel.frame.origin.x, infoLabel.frame.origin.y - 30, infoLabel.frame.size.width, 30)];
                [nameField addTarget:self action:@selector(updateOrderName:) forControlEvents:UIControlEventEditingChanged];
                [self addSubview:nameField];
                nameField.placeholder = @"Naam";
                nameField.backgroundColor = [UIColor whiteColor];
                nameField.borderStyle = UITextBorderStyleBezel;
                infoLabel.text = NSLocalizedString(@"New bill", nil);
            }
            else
            if (anOrder.id == byReservation)
                infoLabel.text = NSLocalizedString(@"Tap to select reservation", nil);
            else
            if (anOrder.id == byEmployee)
                infoLabel.text = NSLocalizedString(@"Tap to select coworker", nil);
            infoLabel.textAlignment = UITextAlignmentCenter;
        }
        self.order = anOrder;
    }

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.cornerRadius = 6;
    gradientLayer.frame = self.bounds;
    gradientLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    gradientLayer.borderWidth = 4;
    gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.7], [NSNumber numberWithFloat:1.0], nil];
    [self.layer insertSublayer:gradientLayer atIndex:0];

    return self;
}

- (void)setOrder: (Order *)newOrder {
    _order = newOrder;
    dataSource = [OrderDataSource dataSourceForOrder:newOrder grouping: noGrouping totalizeProducts:YES showFreeProducts:NO showProductProperties:NO isEditable:NO showPrice:NO showEmptySections:NO fontSize:14];
    self.tableView.dataSource = dataSource;
}

- (void)updateOrderName: (id)sender
{
    UITextField *nameField = (UITextField *)sender;
    _order.name = nameField.text;
}

- (void)setIsSelected: (BOOL)selected {
    CAGradientLayer *layer = [self.layer.sublayers objectAtIndex:0];
    layer.borderColor = selected ? [[UIColor blueColor] CGColor] :  [[UIColor lightGrayColor] CGColor];
    layer.colors = selected ?
            [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:0.7 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.5 alpha:1] CGColor], nil] :
            [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor], (__bridge id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
    _isSelected = selected;
}

- (NSIndexPath *)tableView:(UITableView *)view willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)view heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 26;
}

@end
