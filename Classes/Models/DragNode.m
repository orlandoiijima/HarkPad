//
//  DragNode.m
//  HarkPad2
//
//  Created by Willem Bison on 25-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "DragNode.h"
#import "Product.h"
#import "OrderLine.h"

@implementation DragNode

@synthesize treeNode, label, orderLine;

+ (DragNode *) nodeWithNode : (TreeNode *) node frame: (CGRect) frame
{
    DragNode *drag =  [[[DragNode alloc] init] autorelease];
    drag.treeNode = node;
    drag.frame = frame;
    if(node.menu == nil)
    {
        drag.label = node.product.key;
        drag.backgroundColor = node.product.category.color;
    }
    else
    {
        drag.label = node.menu.key;
        drag.backgroundColor = [UIColor redColor];
    }
    return drag;
}

+ (DragNode *) nodeWithOrderLine : (OrderLine *) orderLine frame: (CGRect) frame
{
    DragNode *drag =  [[[DragNode alloc] init] autorelease];
    drag.orderLine = orderLine;
    drag.frame = frame;
    drag.label = orderLine.product.key;
    drag.backgroundColor = orderLine.product.category.color;
    return drag;
}


- (void)drawRect:(CGRect)rect {
    UIFont *font = [UIFont systemFontOfSize:17.0];
    CGSize size = [label sizeWithFont:font forWidth:rect.size.width lineBreakMode:UILineBreakModeClip];
    CGPoint point = CGPointMake(rect.origin.x + (rect.size.width - size.width)/2, rect.origin.y + (rect.size.height - size.height)/2);
    [label drawAtPoint:point withFont:font];
}


- (void)dealloc {
    [treeNode release];
    [orderLine release];
    [label release];
    [super dealloc];
}


@end
