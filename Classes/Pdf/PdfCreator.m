//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import "PdfCreator.h"
#import "Run.h"
#import "PrintColumn.h"
#import "Cache.h"
#import "PrintInfo.h"


@implementation PdfCreator {
}

@synthesize delegate = _delegate, template = _template;

+ (PdfCreator *)pdfCreatorWithTemplateNamed: (NSString *) template {
    PdfCreator *creator = [[PdfCreator alloc] init];
    creator.template  = [[[Cache getInstance] printInfo] getTemplateNamed:template];
    return creator;
}

- (void) createFileAtPath: (NSString *)path delegate: (id)delegate {
    self.delegate = delegate;
    CGSize pageSize = CGSizeMake(612, 792);
    UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);

    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);

    float y = 0;
    for(Run *run in self.template.preRuns) {
        NSString *textToDraw = [self evaluateString: run.text];
        float x = [run.xSpec floatValue];
        y = run.ySpec == nil ? y : [run.ySpec floatValue];
        float width = run.width;

        UIFont *font = [UIFont systemFontOfSize:14.0];
    
        CGSize stringSize = [textToDraw sizeWithFont:font
                                   constrainedToSize:CGSizeMake(run.width, 100)
                                       lineBreakMode:UILineBreakModeWordWrap];
    
        CGRect renderingRect = CGRectMake(x, y, width, stringSize.height);
    
        UITextAlignment alignment = run.alignment;
        [textToDraw drawInRect:renderingRect
                      withFont:font
                 lineBreakMode:UILineBreakModeWordWrap
                     alignment:alignment];
        y += stringSize.height;
    }
    
    int countRows = [self.delegate countOfRows];
    if (countRows > 0) {
        y = [self.template.table.ySpec floatValue];
        UIFont *font = [UIFont systemFontOfSize: self.template.table.pointSize];
        for(NSUInteger row = 0; row < countRows; row++) {
            float x = [self.template.table.xSpec floatValue];
            float height = 0;
            for(PrintColumn *column in self.template.table.columns) {
                NSString *variable = column.text;
                float width = column.width;
                if ([variable length] > 0) {
                    NSString *cell = [self.delegate stringForVariable:variable inRow:row];

                    CGSize stringSize = [cell sizeWithFont:font
                                               constrainedToSize:CGSizeMake(width, 100)
                                                   lineBreakMode:UILineBreakModeWordWrap];
                    if (stringSize.height > height)
                        height = stringSize.height;
                    CGRect renderingRect = CGRectMake(x, y, width, stringSize.height);

                    [cell drawInRect:renderingRect
                                  withFont:font
                             lineBreakMode:UILineBreakModeWordWrap
                           alignment:column.alignment];
                }
                x += width;
            }        
            y += height;
        }
    }
    
    UIGraphicsEndPDFContext();
}

- (NSString *) evaluateString: (NSString *)string
{
    NSString *destination = @"";
    int i = 0;
    while (YES) {
        NSString *tail = [string substringFromIndex:i];
        NSRange startVar = [tail rangeOfString:@"{"];
        if (startVar.length == 0) {
            destination = [destination stringByAppendingString: tail];
            return destination;
        }
        NSRange endVar = [tail rangeOfString:@"}"];
        if (endVar.length == 0 || endVar.location < startVar.location)
            return destination;
        NSString *variable = [tail substringWithRange:NSMakeRange(startVar.location, endVar.location - startVar.location + 1)];
        NSString *outcome = [self.delegate stringForVariable:variable];
        destination = [destination stringByAppendingString: [tail substringToIndex:startVar.location]];
        destination = [destination stringByAppendingString:outcome];
        i += endVar.location + 1;
    }
}

@end