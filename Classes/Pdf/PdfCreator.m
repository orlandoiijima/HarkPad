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

@synthesize dataSource = _dataSource, template = _template;

+ (PdfCreator *)pdfCreatorWithTemplate: (PrintTemplate *) template dataSource: (id)dataSource {
    PdfCreator *creator = [[PdfCreator alloc] init];
    creator.template  = template;
    creator.dataSource = dataSource;
    return creator;
}

- (NSString *) createFileNamed: (NSString *)fileName {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];

    CGSize pageSize = CGSizeMake(612, 792);
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);

    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);

    float pointSize = self.template.pointSize == 0.0 ? 14.0 : self.template.pointSize;

    float y = 0;
    for(Run *run in self.template.preRuns) {
        NSString *textToDraw = [run evaluateWithProvider: _delegate row:-1 section:-1];
        float x = [run.xSpec floatValue];
        y = run.ySpec == nil ? y : [run.ySpec floatValue];
        float width = run.width;

        UIFont *font = [UIFont systemFontOfSize: run.pointSize == 0.0 ? pointSize : run.pointSize];
    
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

    int countSections = [_dataSource numberOfSections];
    for (NSUInteger section=0; section < countSections; section++) {
        int countRows = [_dataSource numberOfRowsInSection:section];
        if (countRows == 0)
            continue;

        Run *sectionRun = self.template.table.section;
        NSString *sectionHeader = [sectionRun evaluateWithProvider: _dataSource row: -1 section: section];
        if ([sectionHeader length] > 0) {
            UIFont *font = [UIFont systemFontOfSize: sectionRun.pointSize == 0.0 ? pointSize : sectionRun.pointSize];
            float x = [sectionRun.xSpec floatValue];
            CGSize stringSize = [sectionHeader sizeWithFont:font
                                       constrainedToSize:CGSizeMake(pageSize.width - x, 100)
                                           lineBreakMode:UILineBreakModeWordWrap];
            CGRect renderingRect = CGRectMake(x, y, sectionRun.width, stringSize.height);

            [sectionHeader drawInRect:renderingRect
                          withFont:font
                     lineBreakMode:UILineBreakModeWordWrap
                   alignment: sectionRun.alignment];
        }
        y = [self.template.table.ySpec floatValue];
        UIFont *font = [UIFont systemFontOfSize: self.template.table.pointSize == 0.0 ? pointSize : self.template.table.pointSize];
        for(NSUInteger row = 0; row < countRows; row++) {
            float height = 0;
            for(PrintColumn *column in self.template.table.columns) {
                float x = [column.cell.xSpec floatValue];
                NSString *cell = [column.cell evaluateWithProvider: _dataSource row:row section: section];
                if ([cell length] > 0) {

                    CGSize stringSize = [cell sizeWithFont:font
                                               constrainedToSize:CGSizeMake(column.cell.width, 100)
                                                   lineBreakMode:UILineBreakModeWordWrap];
                    if (stringSize.height > height)
                        height = stringSize.height;
                    CGRect renderingRect = CGRectMake(x, y, column.cell.width, stringSize.height);

                    [cell drawInRect:renderingRect
                                  withFont:font
                             lineBreakMode:UILineBreakModeWordWrap
                           alignment:column.cell.alignment];
                }
                x += column.cell.width;
            }
            y += height;
        }
    }

    UIGraphicsEndPDFContext();

    return pdfFileName;
}

@end