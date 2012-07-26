//
// Created by wbison on 22-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SalesPdf.h"
#import "PdfCreator.h"
#import "NSDate-Utilities.h"

@implementation SalesPdf {

@private
    NSDate *_from;
    NSDate *_to;
}

@synthesize from = _from;
@synthesize to = _to;

+ (SalesPdf *) salesFrom: (NSDate *)from to: (NSDate *)to {
    SalesPdf *pdf = [[SalesPdf alloc] init];
    pdf.from = from;
    pdf.to = to;
    return pdf;
}

- (NSString *)create
{
    PdfCreator *creator = [PdfCreator pdfCreatorWithTemplateNamed: @"sales" dataSource:self];
    NSString *fileName = [NSString stringWithFormat:@"Sales %@-%@.pdf", [_from flatDateString], [_to flatDateString] ];

    return  [creator createFileNamed: fileName];
}

@end