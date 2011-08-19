//
//  Splitter.m
//  HarkPad2
//
//  Created by Willem Bison on 11-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Splitter.h"


@implementation Splitter

@synthesize startDrag, firstView, secondView, position, isDrag, controller, width;

- (id)initWithView: (UIView *) first secondView : (UIView *)second controller: (UIViewController *) topController position: (int) pos width: (int) w
{
    second.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    first.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.firstView = first;
    self.secondView = second;
    self.position = pos;
    self.width = w;
    self.controller = topController;
    [self addSubview:first];
    [self addSubview:second];
    firstView.frame = CGRectMake(0, 0, pos - width/2, self.frame.size.height);
    secondView.frame = CGRectMake(pos + width/2, 0, self.frame.size.width - (pos + width/2), self.frame.size.height);
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void) collapseFirst
{
    firstView.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    secondView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);    
    [firstView setNeedsDisplay];    
//    [secondView redraw];
}

- (void) expandFirst
{
    firstView.frame = CGRectMake(0, 0, position - width/2, self.frame.size.height);
    secondView.frame = CGRectMake(position + width/2, 0, self.frame.size.width - (position + width/2), self.frame.size.height);
    [firstView setNeedsDisplay];    
//    [secondView redraw];
}
//
//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint point = [[touches anyObject] locationInView:self];
//    if(CGRectContainsPoint(firstView.frame, point))
//    {
//        return;
//    }
//    if(CGRectContainsPoint(secondView.frame, point))
//        return;
//    isDrag = YES;
//    startDrag = point;
//}
//
//- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{    
//    CGPoint point  = [[touches anyObject] locationInView:self];
//    if(isDrag == NO)
//    {
//        if(CGRectContainsPoint(firstView.frame, point) || CGRectContainsPoint(secondView.frame, point))
//        {
//            [controller touchesMoved:touches withEvent:event];
//        }
//        
//        return;
//    }
//    int delta = point.x - startDrag.x;
//    firstView.frame = CGRectMake(firstView.frame.origin.x, firstView.frame.origin.y, firstView.frame.size.width + delta, firstView.frame.size.height);
//    secondView.frame = CGRectMake(secondView.frame.origin.x + delta, secondView.frame.origin.y, secondView.frame.size.width - delta, secondView.frame.size.height);
//    startDrag = point;
//}
//
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if(isDrag == NO)
//    {
//        [controller touchesEnded:touches withEvent:event];
//        return;
//    }
//    [firstView setNeedsDisplay];    
//    [secondView redraw];
//    isDrag = NO;
//}
//
@end
