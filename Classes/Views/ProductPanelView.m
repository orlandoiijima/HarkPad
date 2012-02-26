//
//  ProductPanelView.m
//  HarkPad2
//
//  Created by Willem Bison on 24-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "ProductPanelView.h"
#import "TreeNode.h"
#import "NewOrderVC.h"
#import "NewOrderView.h"

@implementation ProductPanelView

@synthesize rootNode, parentNode, menuCardSegment, productInfoLabel;
@synthesize showMenuCard = _showMenuCard;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupMenuCard: frame];
        _showMenuCard  =YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

- (void) setShowMenuCard: (bool)show
{
    _showMenuCard = show;
    if(show)
        [self addSubview:menuCardSegment];
    else
        [menuCardSegment removeFromSuperview];		
}

- (void) handleTapGesture: (UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:self];
    if(tapGestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGRect rect;
    TreeNode *node = [self treeNodeByPoint: point frame:&rect];
    if(node == nil || node.product != nil || node.menu != nil)
        return;
    parentNode = node;
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    menuCardSegment.hidden = self.frame.size.width < 20;
    menuCardSegment.frame = CGRectMake(10, 0, self.frame.size.width - 20, _showMenuCard ? 35 : 0);
    productInfoLabel.frame = menuCardSegment.frame;
}

#define MARGIN 3
#define COUNTCOLUMNS 3

- (TreeNode *) treeNodeByPoint: (CGPoint) point frame: (CGRect *)rect
{
    int index = 0;
    int countColumns = COUNTCOLUMNS;
    for(TreeNode *node in parentNode.nodes)
    {
        int column = index % countColumns;
        int row = index / countColumns;
        *rect = [self getButtonRect: column row: row];
        if(CGRectContainsPoint(*rect, point))
            return node;
        index++;
    }
    if(parentNode.parent != nil)
    {
        if(parentNode.parent.id != rootNode.id)
        {
            int column = index % countColumns;
            int row = index / countColumns;
            *rect = [self getButtonRect: column row: row];
            if(CGRectContainsPoint(*rect, point))
                return parentNode.parent;
            index++;
        }
        int column = index % countColumns;
        int row = index / countColumns;
        *rect = [self getButtonRect: column row: row];
        if(CGRectContainsPoint(*rect, point))
            return rootNode;
    }
    return nil;
}

- (void) drawProductPanel
{
    CGRect rect = self.bounds;
    [[UIColor blackColor] set];
    UIRectFill(rect);
    
    int index = 0;
    int countColumns = COUNTCOLUMNS;
    for(TreeNode *node in parentNode.nodes)
    {
        int column = index % countColumns;
        int row = index / countColumns;
        if(node.product != nil)
            [self drawProductButton: column row:row productNode:node];
        else
        if(node.menu != nil)
            [self drawMenuButton: column row:row menuNode:node];
        else
            [self drawNavigateButton: column row:row label: node.name targetNode:node];
        index++;
    }
    
    if(parentNode.id != rootNode.id)
    {
        TreeNode *grandParent = parentNode.parent;
        if(grandParent.id != rootNode.id)
        {
            int column = index % countColumns;
            int row = index / countColumns;
            [self drawNavigateButton:column row: row label:@"Back" targetNode: grandParent];
            index++;
        }
        int column = index % countColumns;
        int row = index / countColumns;
        [self drawNavigateButton:column row:row label:@"Home" targetNode:rootNode];
    }
}

- (CGRect) getButtonRect : (int) column row : (int) row
{
    int margin = MARGIN;
    int width = self.bounds.size.width / COUNTCOLUMNS - 2*margin;
    int height = 50 - 2*margin;
    int left = column * (width + 2*margin) + margin;
    int top = menuCardSegment.frame.origin.y + menuCardSegment.frame.size.height + 3 + row * (height + 2*margin) + margin;
    return CGRectMake(left, top, width, height);
}


- (void) drawProductButton: (int)column row: (int)row productNode: (TreeNode *)node
{
//    NewOrderVC *controller = [(NewOrderView*)[[self superview] superview] controller];

//    UIFont *font = [controller.order containsProductId: node.product.id] ? [UIFont boldSystemFontOfSize:17.0] : [UIFont systemFontOfSize:17.0];
    UIFont *font = [UIFont systemFontOfSize:17.0];
    [self drawPanelButton: column row:row label:node.product.key font: font textColor: [UIColor blackColor] backgroundColor: node.product.category.color targetNode:nil];
}

- (void) drawMenuButton: (int)column row: (int)row menuNode: (TreeNode *)node
{
    [self drawPanelButton: column row:row label:node.menu.key font: [UIFont systemFontOfSize:17.0] textColor: [UIColor whiteColor] backgroundColor: [UIColor redColor] targetNode:nil];
}

- (void) drawNavigateButton: (int)column row: (int)row label:(NSString*) label targetNode: (TreeNode *)node
{
    [self drawPanelButton: column row:row label:label font: [UIFont systemFontOfSize:17.0] textColor: [UIColor whiteColor] backgroundColor: [UIColor blueColor] targetNode:nil];
}

- (void) drawPanelButton: (int)column row: (int)row label: (NSString *) label font: (UIFont *) font textColor:(UIColor*)textColor  backgroundColor:(UIColor*)backgroundColor targetNode: (TreeNode *)node
{
    CGRect rect = [self getButtonRect:column row:row];
    [backgroundColor set];
    UIRectFill(rect);
    [textColor set];
    CGSize size = [label sizeWithFont:font forWidth:rect.size.width lineBreakMode:UILineBreakModeClip];
    CGPoint point = CGPointMake(rect.origin.x + (rect.size.width - size.width)/2, rect.origin.y + (rect.size.height - size.height)/2);
    [label drawAtPoint:point withFont:font];
    return;
}

- (void)drawRect:(CGRect)rect {
    [self drawProductPanel];
}


- (void) setupMenuCard: (CGRect) containerFrame
{
    NewOrderVC *controller = [(NewOrderView*)[[self superview] superview] controller];

    rootNode = [[Cache getInstance] tree];
    menuCardSegment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 200, 58)];
    [self addSubview:menuCardSegment];
    [menuCardSegment removeAllSegments];
    int countSegments = 0;
    NSArray *images = [NSArray arrayWithObjects: @"star", @"fork-and-knife", @"food", @"martini", @"wine-glass", @"wine-bottle", nil];
    for(TreeNode *node in rootNode.nodes)
    {
        if(node.menu == nil && node.product == nil)
        {
            NSString *imageName = countSegments < [images count] ? [images objectAtIndex:countSegments] : @"";
            UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
            [menuCardSegment insertSegmentWithImage:image atIndex:countSegments animated:NO];
            countSegments++;
            if(parentNode == nil)
            {
                parentNode = node;
                rootNode = node;        
            }
        }
    }
    [menuCardSegment addTarget:controller action:@selector(gotoMenuCard) forControlEvents:UIControlEventValueChanged];
    menuCardSegment.selectedSegmentIndex = 0;
    
    productInfoLabel = [[UILabel alloc] initWithFrame:menuCardSegment.frame];
    productInfoLabel.backgroundColor = [UIColor clearColor];
    productInfoLabel.font = [UIFont boldSystemFontOfSize:18];
    productInfoLabel.textColor = [UIColor yellowColor];
    productInfoLabel.textAlignment = UITextAlignmentCenter;
    productInfoLabel.adjustsFontSizeToFitWidth = YES;
}

- (void) showInfoLabelWithNode: (TreeNode *) node
{
    [self addSubview: productInfoLabel];
    [menuCardSegment removeFromSuperview];
    NSString *text = @"";
    if(node.product != nil)
        text = [NSString stringWithFormat:@"%@ (€%.2f)", node.product.name, [node.product.price floatValue]]; 
    if(node.menu != nil)
        text = [NSString stringWithFormat:@"%@", node.menu.name]; 
    productInfoLabel.text = text;
}

- (void) hideProductInfoButton
{
    [self addSubview: menuCardSegment];
    [productInfoLabel removeFromSuperview]	;
}



@end
