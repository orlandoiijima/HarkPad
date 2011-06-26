//
//  GridViewCellLine.m
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "GridViewCellLine.h"


@implementation GridViewCellLine

@synthesize textLabel, middleLabel, bottomLabel, isSelected = _isSelected, isDropTarget, path, deleteButton;

- (id)initWithTitle: (NSString *) title middleLabel: (NSString *)label2 bottomLabel: (NSString *)label3 path: (CellPath *)aPath {
    if ((self = [super init])) {
        self.path = [CellPath pathForColumn:aPath.column row:aPath.row line:aPath.line];
        // Initialization code
        self.layer.cornerRadius = 10;
        // Drop shadow.
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(0, 2);        
	        self.autoresizesSubviews = YES;
 //       self.autoresizingMask = UIViewAutoresizingFlexibleWidth; // | UIViewAutoresizingFlexibleHeight; 
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin; 
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.shadowColor = [UIColor lightGrayColor];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.text = title;
        [self addSubview: self.textLabel];
        
        self.middleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.middleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin; 
        self.middleLabel.backgroundColor = [UIColor clearColor];
        self.middleLabel.shadowColor = [UIColor lightGrayColor];
        self.middleLabel.textAlignment = UITextAlignmentCenter;
        self.middleLabel.adjustsFontSizeToFitWidth = NO;
        self.middleLabel.font = [UIFont systemFontOfSize:12];
        self.middleLabel.text = label2;
        self.middleLabel.hidden = YES;
        [self addSubview: self.middleLabel];
        
        self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bottomLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin; 
        self.bottomLabel.backgroundColor = [UIColor clearColor];
        self.bottomLabel.shadowColor = [UIColor lightGrayColor];
        self.bottomLabel.textAlignment = UITextAlignmentCenter;
        self.bottomLabel.font = [UIFont systemFontOfSize:12];
        self.bottomLabel.text = label3;
        self.bottomLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:1];
        self.bottomLabel.hidden = YES;
        [self addSubview: self.bottomLabel];
        
        self.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:1 alpha:1];
    }
    return self;
}

- (void)layoutSubviews
{
    if(_isSelected) {
        self.textLabel.frame = CGRectMake(10, 6, self.bounds.size.width - 20, 20);    
        self.middleLabel.frame = CGRectMake(10, 25, self.bounds.size.width - 20, 16);    
        self.bottomLabel.frame = CGRectMake(10, 40, self.bounds.size.width - 20, 20);    
    }
    else {
        self.textLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);    
        self.middleLabel.frame = CGRectMake(0, 20, self.bounds.size.width, 20);    
    }
}

- (void) setIsSelected:(bool)selected
{
    _isSelected = selected;
    middleLabel.hidden = selected == NO;
    bottomLabel.hidden = selected == NO;
    self.backgroundColor = selected ? [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1] : [UIColor colorWithRed:0.7 green:0.7 blue:1 alpha:1];
}

- (void) setIsDropTarget:(bool)isDropTarget
{
    //    self.layer.borderColor = [[UIColor blackColor] CGColor]	;
    //   self.layer.borderWidth = isSelected ? 1 : 0;
}

- (void) addDeleteButtonWithTarget: (id)target action: (SEL) action
{
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton addTarget: target action: action forControlEvents:UIControlEventTouchDown];
    UIImage *image = [UIImage imageNamed:@"closebox.png"];
    [self.deleteButton setImage:image forState:UIControlStateNormal];
    self.deleteButton.frame = CGRectMake(self.frame.size.width - 20, -10, 30, 30);
    self.deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin; 

    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self.deleteButton.frame = [window convertRect: self.deleteButton.frame fromView:self];
    [window addSubview: deleteButton];
}

- (void) removeDeleteButton
{
    [deleteButton removeFromSuperview];
//    [deleteButton release];
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