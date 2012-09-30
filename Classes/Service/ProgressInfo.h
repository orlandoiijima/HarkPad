//
// Created by wbison on 30-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface ProgressInfo : NSObject
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic, strong) UILabel *label;

+ (ProgressInfo *)progressWithHudText:(NSString *)text parentView:(UIView *)parentView;

+ (ProgressInfo *)progressWithActivityText:(NSString *)text label:(UILabel *)label activityIndicatorView:(UIActivityIndicatorView *)indicatorView;

- (void)start;

- (void)stop;

@end