//
// Created by wbison on 14-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Edge : NSObject
@property(nonatomic) int left;
@property(nonatomic) int top;
@property(nonatomic) int right;
@property(nonatomic) int bottom;

- (Edge *)initWithString:(NSString *)string;

@end