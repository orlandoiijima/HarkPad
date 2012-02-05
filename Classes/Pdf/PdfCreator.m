//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import "PdfCreator.h"


@implementation PdfCreator {
}

@synthesize delegate = _delegate, template = _template;

+ (PdfCreator *)pdfCreatorWithTemplate: (NSMutableDictionary *) template {
    PdfCreator *creator = [[PdfCreator alloc] init];
    creator.template = template;
    return creator;
}

- (void) createFileAtPath: (NSString *)path delegate: (id)delegate {
    self.delegate = delegate;
    CGSize pageSize = CGSizeMake(612, 792);
    UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);

    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);

    NSArray *texts = [self.template objectForKey:@"texts"];
    int y = 0;
    for(NSDictionary *text in texts) {
        NSString *textToDraw = [text objectForKey:@"text"];
        textToDraw = [self evaluateString:textToDraw];
        int x = [[text objectForKey:@"x"] intValue];
        if([text objectForKey:@"y"] != nil) 
            y = [[text objectForKey:@"y"] intValue];
        int width = [[text objectForKey:@"width"] intValue];

        UIFont *font = [UIFont systemFontOfSize:14.0];
    
        CGSize stringSize = [textToDraw sizeWithFont:font
                                   constrainedToSize:CGSizeMake(width, 100)
                                       lineBreakMode:UILineBreakModeWordWrap];
    
        CGRect renderingRect = CGRectMake(x, y, width, stringSize.height);
    
        UITextAlignment alignment = [[text objectForKey:@"alignment"] intValue];
        [textToDraw drawInRect:renderingRect
                      withFont:font
                 lineBreakMode:UILineBreakModeWordWrap
                     alignment:alignment];
        y += stringSize.height;
    }
    
    int countRows = [self.delegate countOfRows];
    if (countRows > 0) {
        NSDictionary *table = [self.template objectForKey:@"table"];
        NSArray *columns = [table objectForKey:@"columns"];
        int y = [[table objectForKey:@"y"] intValue];
        CGFloat fontSize = [[table objectForKey:@"fontSize"] floatValue];
        UIFont *font = [UIFont systemFontOfSize: fontSize];
        for(int row = 0; row < countRows; row++) {
            int x = [[table objectForKey:@"x"] intValue];
            int height = 0;
            for(NSDictionary *columnDic in columns) {
                NSString *variable = [columnDic objectForKey:@"text"];
                int width = [[columnDic objectForKey:@"width"] intValue];
                if ([variable length] > 0) {
                    NSString *cell = [self.delegate stringForVariable:variable inRow:row];

                    CGSize stringSize = [cell sizeWithFont:font
                                               constrainedToSize:CGSizeMake(width, 100)
                                                   lineBreakMode:UILineBreakModeWordWrap];
                    if (stringSize.height > height)
                        height = stringSize.height;
                    CGRect renderingRect = CGRectMake(x, y, width, stringSize.height);

                    UITextAlignment alignment = [[columnDic objectForKey:@"alignment"] intValue];
                    [cell drawInRect:renderingRect
                                  withFont:font
                             lineBreakMode:UILineBreakModeWordWrap
                           alignment:alignment];
                }
                x += width;
            }        
            y += height;
        }

        //  Tablefooter
        int x = [[table objectForKey:@"x"] intValue];
        int height = 0;
        for(NSDictionary *columnDic in columns) {
            NSString *variable = [columnDic objectForKey:@"footer"];
            int width = [[columnDic objectForKey:@"width"] intValue];
            if ([variable length] > 0) {
                NSString *cell = [self.delegate stringForVariable:variable inRow: countRows];

                CGSize stringSize = [cell sizeWithFont:font
                                           constrainedToSize:CGSizeMake(width, 100)
                                               lineBreakMode:UILineBreakModeWordWrap];
                if (stringSize.height > height)
                    height = stringSize.height;
                CGRect renderingRect = CGRectMake(x, y, width, stringSize.height);

                UITextAlignment alignment = [[columnDic objectForKey:@"alignment"] intValue];
                [cell drawInRect:renderingRect
                              withFont:font
                         lineBreakMode:UILineBreakModeWordWrap
                       alignment:alignment];
            }
            x += width;
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