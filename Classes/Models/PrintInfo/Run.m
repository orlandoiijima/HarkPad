//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Run.h"


@implementation Run {

@private
    NSString *_fontName;
    float _pointSize;
    NSString *_text;
    float _width;
    NSString *_xSpec;
    NSString *_ySpec;
    UITextAlignment _alignment;
}
@synthesize fontName = _fontName;
@synthesize pointSize = _pointSize;
@synthesize text = _text;
@synthesize width = _width;
@synthesize xSpec = _xSpec;
@synthesize ySpec = _ySpec;
@synthesize alignment = _alignment;


+ (Run *) runFromJson:(NSDictionary *)infoJson
{
    Run *run = [[Run alloc] init];
    run.fontName  = [infoJson objectForKey:@"FontName"];
    run.pointSize = [[infoJson objectForKey:@"PointSize"] floatValue];
    run.alignment = (UITextAlignment) [[infoJson objectForKey:@"Alignment"] intValue];
    run.width = [[infoJson objectForKey:@"Width"] floatValue];
    run.xSpec  = [infoJson objectForKey:@"XSpec"];
    run.ySpec  = [infoJson objectForKey:@"YSpec"];
    run.text  = [infoJson objectForKey:@"Text"];
    return run;
}

@end