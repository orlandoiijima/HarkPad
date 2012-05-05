//
//  TableViewDashboard.m
//  HarkPad
//
//  Created by Willem Bison on 02/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableOverlayDashboard.h"
#import "UIImage+TBKMasking.h"

@implementation TableOverlayDashboard

@synthesize pageControl, reservationsTableView, contentView, delegate, order, guestProperties, actionsView, infoView, buttonViews;

#define PAGECONTROL_HEIGHT 50

- (id)initWithFrame:(CGRect)frame tableView: (TableWithSeatsView *)tableView order:(Order *)anOrder delegate: (id<TablePopupDelegate>) aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = -1;
        self.delegate = aDelegate;
        self.order = anOrder;

        pageControl = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - PAGECONTROL_HEIGHT, frame.size.width, PAGECONTROL_HEIGHT)];
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview: pageControl];

        contentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height - PAGECONTROL_HEIGHT)];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:contentView];

        CGRect rectPage = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);

        int numberOfPages = tableView.orderInfo == nil ? 3 : 4;
        float buttonWidth = frame.size.width / numberOfPages;
        float x = 0;
        float y = 0;

        int tag = 0;

        buttonViews = [[NSMutableArray alloc] init];

        actionsView = [[TableActionsView alloc] initWithFrame:rectPage orderInfo:tableView.orderInfo delegate:delegate];
        actionsView.order = order;
        [contentView addSubview: actionsView];
        actionsView.autoresizingMask = -1;
        [buttonViews addObject: actionsView];

        UIButton *button = [self createBarButtonWithFrame:CGRectMake(x, y, buttonWidth, PAGECONTROL_HEIGHT) image: [UIImage imageNamed:@"action.png"] tag:tag++];
        [pageControl addSubview:button];
        x += buttonWidth;
        button.selected = true;

        guestProperties = [GuestProperties viewWithGuest:nil frame:rectPage delegate:delegate];
        guestProperties.autoresizingMask = -1;
        [buttonViews addObject: guestProperties];
        button = [self createBarButtonWithFrame:CGRectMake(x, y, buttonWidth, PAGECONTROL_HEIGHT) image: [UIImage imageNamed:@"usersmall.png"] tag:tag++];
        [pageControl addSubview:button];
        x += buttonWidth;

        reservationsTableView = [[SelectReservationView alloc] initWithFrame:rectPage delegate:delegate];
        reservationsTableView.autoresizingMask = -1;
        [buttonViews addObject: reservationsTableView];
        button = [self createBarButtonWithFrame:CGRectMake(x, y, buttonWidth, PAGECONTROL_HEIGHT) image: [UIImage imageNamed:@"calendar.png"] tag:tag++];
        [pageControl addSubview:button];
        x += buttonWidth;


        if (tableView.orderInfo != nil) {
            infoView = [[TableOverlayInfo alloc] initWithFrame:rectPage order:order];
            infoView.autoresizingMask = -1;
            [buttonViews addObject: infoView];
            button = [self createBarButtonWithFrame:CGRectMake(x, y, buttonWidth, PAGECONTROL_HEIGHT) image: [UIImage imageNamed:@"info.png"] tag:tag];
            [pageControl addSubview:button];
        }
    }
    return self;
}

- (UIButton *)createBarButtonWithFrame: (CGRect) frame image:(UIImage *)image tag: (int)tag
{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.autoresizingMask = -1;
    [pageControl addSubview:button];
    [button setImage: [image tabBarImage] forState:UIControlStateNormal];
    [button setImage: [image selectedTabBarImage] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(gotoViewForButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    return button;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    reservationsTableView.frame = contentView.bounds;
    guestProperties.frame = contentView.bounds;
    if (infoView != nil)
        infoView.frame = contentView.bounds;
}

-(void) gotoView: (UIView *)view {
    NSUInteger i = [buttonViews indexOfObject:view];
    if(i == NSNotFound)
        return;
    [self gotoViewForButton: [pageControl viewWithTag:i]];
}

-(void) gotoViewForButton: (UIButton *)button {
    UIView *currentView = [[contentView subviews] objectAtIndex:0];
    UIView *newView = [buttonViews objectAtIndex:button.tag];
    if (currentView == newView) return;
    for(UIButton *button in [pageControl subviews])
    {
        button.selected = NO;
    }
    button.selected = YES;
    [UIView transitionFromView:currentView
                        toView:newView
                      duration: 0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL x) {
        [currentView removeFromSuperview];
        [contentView addSubview:newView];
    }];
}

@end
