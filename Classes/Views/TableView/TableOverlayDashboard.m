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

@synthesize pageControl, reservationsTableView, scrollTableView, delegate, order, guestProperties, courseInfo, actionsView, infoView;

#define PAGECONTROL_HEIGHT 50

- (id)initWithFrame:(CGRect)frame tableView: (TableView *)tableView delegate: (id<TablePopupDelegate>) aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {

        self.delegate = aDelegate;

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
        [scrollTableView addSubview: actionsView];
        pageControl.numberOfPages++;
        rectPage = CGRectOffset(rectPage, frame.size.width, 0);

        guestProperties = [GuestProperties viewWithGuest:nil frame:rectPage delegate:delegate];
        [scrollTableView addSubview: guestProperties];
        pageControl.numberOfPages++;
        rectPage = CGRectOffset(rectPage, frame.size.width, 0);

        if (tableView.orderInfo != nil) {
            courseInfo = [CourseGuestTableView viewWithTableView: tableView];
            courseInfo.frame = rectPage;
            [scrollTableView addSubview: courseInfo];
            pageControl.numberOfPages++;
            rectPage = CGRectOffset(rectPage, frame.size.width, 0);
        }

        reservationsTableView = [[SelectReservationView alloc] initWithFrame:rectPage delegate:delegate];
        [scrollTableView addSubview: reservationsTableView];
        pageControl.numberOfPages++;
        rectPage = CGRectOffset(rectPage, frame.size.width, 0);

        if (tableView.orderInfo != nil) {
            infoView = [[TableOverlayInfo alloc] initWithFrame:rectPage order:nil];
            [scrollTableView addSubview: infoView];
            pageControl.numberOfPages++;
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
    return [scrollTableView hitTest:point withEvent: nil];
}

@end
