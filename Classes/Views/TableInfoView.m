//
//  TableInfoView.m
//  HarkPad2
//
//  Created by Willem Bison on 30-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "TableInfoView.h"


@implementation TableInfoView


+ (TableInfoView *) viewWithOrder: (Order *) order
{
    TableInfoView *view = [[[NSBundle mainBundle] loadNibNamed:@"TableInfoView" owner:self options:nil] lastObject];
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
