//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Run : NSObject <NSCopying>

@property (retain) NSString *text;
@property (retain) NSString *xSpec;
@property (retain) NSString *ySpec;
@property float pointSize;
@property (retain) NSString *fontName;
@property UITextAlignment alignment;
@property float width;

+ (Run *) runFromJson:(NSDictionary *)infoJson;

- (NSString *) evaluateWithProvider:(id) delegate row:(int)row section:(int)section;

@end