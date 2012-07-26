//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol TemplatePrintDataSource

@required
- (NSString *) stringForVariable: (NSString *)variable row: (int)row section: (int)section;
- (NSUInteger) numberOfRowsInSection:(NSInteger)section;
- (NSUInteger) numberOfSections;
- (NSString *) titleForHeaderInSection:(NSInteger)section;
@end