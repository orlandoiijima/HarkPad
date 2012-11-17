//
//  StarPrintOutputViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface StarPrintOutputViewController : UIViewController
@property(nonatomic, strong) UIImage *image;
@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain) IBOutlet UIImageView *imageView;
@property (retain) IBOutlet UILabel *caption;

@property(nonatomic, copy) NSString *templateName;

+ (StarPrintOutputViewController *)controllerWithImage:(UIImage *)image layoutTemplate:(NSString *)templateName;


@end
