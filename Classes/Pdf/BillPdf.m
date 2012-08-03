//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BillPdf.h"
#import "PdfCreator.h"
#import "Utils.h"
#import "InvoicePrintDataSource.h"
#import "StarPrintJob.h"


@implementation BillPdf {
}

@synthesize order = _order, orderDataSource = _orderDataSource;

+ (BillPdf *)billByOrder: (Order *)order {
    BillPdf *pdf = [[BillPdf alloc] init];
    pdf.order = order;
    return pdf;
}

- (NSString *)create
{
    InvoicePrintDataSource *printDataSource = [InvoicePrintDataSource dataSourceForOrder:_order];

    StarPrintJob *printJob = [StarPrintJob jobWithTemplateNamed:@"invoice" dataSource:printDataSource ip: @"192.168.1.106"];
    [printJob print];
    return nil;
//    PdfCreator *creator = [PdfCreator pdfCreatorWithTemplateNamed: @"invoice" dataSource:printDataSource];
//    NSString *fileName = [NSString stringWithFormat:@"Invoice%d.pdf", _order.id];
//
//    return  [creator createFileNamed: fileName];
}

@end