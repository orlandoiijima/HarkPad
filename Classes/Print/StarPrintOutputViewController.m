//
//  StarPrintOutputViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StarPrintOutputViewController.h"

@interface StarPrintOutputViewController ()

@end

@implementation StarPrintOutputViewController

+(StarPrintOutputViewController *)controllerWithImage:(UIImage *)image layoutTemplate:(NSString *) templateName {
    StarPrintOutputViewController *controller = [[StarPrintOutputViewController alloc] init];
    controller.image = image;
    controller.templateName = templateName;
    return controller;
}

- (void)viewDidLoad {
    self.contentSizeForViewInPopover = self.view.frame.size;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, (_scrollView.frame.size.width / _image.size.width) * _image.size.height);

    _imageView = [[UIImageView alloc] initWithImage:_image];
    [_scrollView addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
    _imageView.layer.borderColor = [UIColor blackColor].CGColor;
    _imageView.layer.borderWidth = 2;
    _imageView.clipsToBounds = NO;
    _caption.text = [NSString stringWithFormat:@"Template: %@", _templateName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
