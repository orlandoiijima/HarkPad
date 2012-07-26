//
// Created by wbison on 20-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Run.h"
#import "TemplatePrintDataSource.h"


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

- (NSString *) evaluateWithProvider:(id) delegate row:(int)row section:(int)section
{
    NSString *destination = @"";
    int i = 0;
    while (YES) {
        NSString *tail = [_text substringFromIndex:i];
        NSRange startVar = [tail rangeOfString:@"{"];
        if (startVar.length == 0) {
            destination = [destination stringByAppendingString: tail];
            return destination;
        }
        NSRange endVar = [tail rangeOfString:@"}"];
        if (endVar.length == 0 || endVar.location < startVar.location)
            return destination;
        NSString *variable = [tail substringWithRange:NSMakeRange(startVar.location, endVar.location - startVar.location + 1)];
        NSString *outcome = [delegate stringForVariable:variable row:row section:section];
        destination = [destination stringByAppendingString: [tail substringToIndex:startVar.location]];
        destination = [destination stringByAppendingString:outcome];
        i += endVar.location + 1;
    }
}

@end