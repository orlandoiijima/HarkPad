//
//  CKCalendarViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@protocol CKCalendarDelegate;

@interface CKCalendarViewController : UIViewController

@property(nonatomic, strong) id delegate;

+ (CKCalendarViewController *)controllerWithDate:(NSDate *)date delegate:(id<CKCalendarDelegate>)delegate;

@end
