//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Location : NSObject
@property(nonatomic, strong) id name;
@property(nonatomic) int id;

+ (Location *)locationFromJsonDictionary:(NSDictionary *)jsonDictionary;

@end