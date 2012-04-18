//
//  TableViewDashboard.m
//  HarkPad
//
//  Created by Willem Bison on 02/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "TableOverlayDashboard.h"

@implementation TableOverlayDashboard

@synthesize pageControl, reservationsTableView, scrollTableView, delegate, order, guestProperties, actionsView, infoView;

#define PAGECONTROL_HEIGHT 50

- (id)initWithFrame:(CGRect)frame tableView: (TableWithSeatsView *)tableView order:(Order *)anOrder delegate: (id<TablePopupDelegate>) aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = -1;
        self.delegate = aDelegate;
        self.order = anOrder;

        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - PAGECONTROL_HEIGHT, frame.size.width, PAGECONTROL_HEIGHT)];
        pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        pageControl.numberOfPages = 0;
        [pageControl addTarget:self action:@selector(pagerAction) forControlEvents:UIControlEventValueChanged];
        [self addSubview: pageControl];

        scrollTableView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height - PAGECONTROL_HEIGHT)];
        scrollTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollTableView.delegate = self;
        scrollTableView.pagingEnabled = YES;
        scrollTableView.alwaysBounceVertical = NO;
        scrollTableView.directionalLockEnabled = YES;
        [self addSubview: scrollTableView];

        CGRect rectPage = CGRectMake(0, 0, scrollTableView.bounds.size.width, scrollTableView.bounds.size.height);

        actionsView = [[TableActionsView alloc] initWithFrame:rectPage orderInfo:tableView.orderInfo delegate:delegate];
        actionsView.order = order;
        [scrollTableView addSubview: actionsView];
        actionsView.autoresizingMask = -1;
        pageControl.numberOfPages++;
        rectPage = CGRectOffset(rectPage, frame.size.width, 0);

        guestProperties = [GuestProperties viewWithGuest:nil frame:rectPage delegate:delegate];
        [scrollTableView addSubview: guestProperties];
        guestProperties.autoresizingMask = -1;
        pageControl.numberOfPages++;
        rectPage = CGRectOffset(rectPage, frame.size.width, 0);

        reservationsTableView = [[SelectReservationView alloc] initWithFrame:rectPage delegate:delegate];
        [scrollTableView addSubview: reservationsTableView];
        pageControl.numberOfPages++;
        reservationsTableView.autoresizingMask = -1;
        rectPage = CGRectOffset(rectPage, frame.size.width, 0);

        if (tableView.orderInfo != nil) {
            infoView = [[TableOverlayInfo alloc] initWithFrame:rectPage order:order];
            [scrollTableView addSubview: infoView];
            pageControl.numberOfPages++;
            infoView.autoresizingMask = -1;
            rectPage = CGRectOffset(rectPage, frame.size.width, 0);
        }

        scrollTableView.contentSize = CGSizeMake(frame.size.width * pageControl.numberOfPages, frame.size.height);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    scrollTableView.contentSize = CGSizeMake(scrollTableView.bounds.size.width * pageControl.numberOfPages, scrollTableView.bounds.size.height);
}

- (void)pagerAction
{
    [scrollTableView setContentOffset: CGPointMake( pageControl.currentPage * scrollTableView.bounds.size.width, scrollTableView.contentOffset.y) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (pageControl.currentPage == page)
        return;
    pageControl.currentPage = page;
    if([self.delegate respondsToSelector:@selector(didChangeToPageView:)])
        [self.delegate didChangeToPageView: [self viewOnPage:pageControl.currentPage]];
}

- (void) scrollToView: (UIView *)view {
    CGFloat x = 0;
    for (UIView *pageView in scrollTableView.subviews) {
        if (pageView == view) {
            CGPoint contentOffset = CGPointMake(pageView.frame.origin.x, 0);
            [scrollTableView setContentOffset: contentOffset animated:YES];
        }
    }
    x += scrollTableView.bounds.size.width;
}

- (UIView *)viewOnPage: (int)pageControl {
    CGPoint point = CGPointMake( self.pageControl.currentPage * scrollTableView.bounds.size.width, scrollTableView.contentOffset.y);
    for(UIView *view in scrollTableView.subviews) {
        if (CGRectContainsPoint(view.frame, point))
            return view;
    }
    return nil;
}

@end
