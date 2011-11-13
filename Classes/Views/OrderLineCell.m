
#import "OrderLineCell.h"
#import "OrderLine.h"
#import "OrderLinePropertyValue.h"
//#import "OrderViewDetailController.h"
#import "OrderTableView.h"
#import "Utils.h"
#import "OrderGridHitInfo.h"
#import "ToggleButton.h"
#import "CrystalButton.h"

@implementation OrderLineCell

@synthesize nLineIcon, orderLine, price, name, note, props, seat, course, quantity, showProductProperties, isInEditMode = _isInEditMode, stepperView, notesView, propertyViews, heightInEditMode, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showProductProperties = YES;
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line isEditable: (BOOL)isEditable delegate: (id) delegate rowHeight: (float)rowHeight
{
    OrderLineCell *cell = [[OrderLineCell alloc] init];

    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.clipsToBounds = YES;

    cell.delegate = delegate;

    float height = rowHeight == 0 ? 44 : rowHeight;
    float width = cell.contentView.bounds.size.width - 10;
    
    cell.quantity = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, height)];
    [cell.contentView addSubview:cell.quantity];
    cell.quantity.textAlignment = UITextAlignmentRight;
    cell.quantity.backgroundColor = [UIColor clearColor];
    if (isEditable == false)
        cell.quantity.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    cell.name = [[UILabel alloc] initWithFrame:CGRectMake(cell.quantity.frame.origin.x + cell.quantity.frame.size.width + 3, 0, 200, height)];
    [cell.contentView addSubview:cell.name];
    cell.name.backgroundColor = [UIColor clearColor];
    if (isEditable == false)
        cell.name.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    cell.price = [[UILabel alloc] initWithFrame:CGRectMake(width-50, 0, 50, height)];
    [cell.contentView addSubview:cell.price];
    cell.price.textAlignment = UITextAlignmentRight;
    cell.price.backgroundColor = [UIColor clearColor];
    cell.price.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    if (isEditable == false)
        cell.price.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    cell.orderLine = line;

    if (isEditable) {
        float x = 50;
        float y = rowHeight;
        float margin = 10;
        float vSpace = 5;
        float controlHeight = 27;
        cell.stepperView = [[UIStepper alloc] initWithFrame:CGRectMake(x, y, 40, controlHeight)];
        [cell.contentView addSubview: cell.stepperView];
        [cell.stepperView addTarget:cell action:@selector(quantityUpdated) forControlEvents:UIControlEventValueChanged];
        cell.stepperView.value = line.quantity;

        x += cell.stepperView.frame.size.width + margin;
        for(OrderLineProperty *property in line.product.properties) {

            CGSize size = [property.name sizeWithFont: [UIFont boldSystemFontOfSize:18]];
            ToggleButton *sw = [ToggleButton buttonWithTitle: property.name frame: CGRectMake(x, y, size.width + 20, controlHeight)];
            if (sw.frame.origin.x + sw.frame.size.width > width)
            {
                x = 50;
                y += controlHeight + vSpace;
                sw.frame = CGRectMake(x, y, sw.frame.size.width, sw.frame.size.height);
            }
//            [sw setTitle:property.name forState:UIControlStateNormal];
//            sw.tintColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:sw];
            [sw addTarget: cell action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.propertyViews addObject:sw];

            x += sw.frame.size.width + margin;
        }

        y += controlHeight + vSpace;
        x = 50;   
        cell.notesView = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width - 8, controlHeight)];
        [cell.notesView addTarget: cell action:@selector(noteTextUpdated) forControlEvents:UIControlEventEditingChanged];
        cell.notesView.placeholder = NSLocalizedString(@"Notitie", nil);
        cell.notesView.backgroundColor = [UIColor whiteColor];
        cell.notesView.borderStyle = UITextBorderStyleBezel;
        [cell.contentView addSubview: cell.notesView];
        
        cell.heightInEditMode = y + cell.notesView.bounds.size.height + 5;
    }
    return cell;
}

+ (float) getExtraHeightForEditMode: (OrderLine *)line
{
    return 33*3; // * (2 + [line.product.properties count]);
}

- (void) noteTextUpdated {
    orderLine.note = notesView.text;
}

- (void) quantityUpdated {
    orderLine.quantity = stepperView.value;
    quantity.text = [NSString stringWithFormat:@"%d", orderLine.quantity];
    self.orderLine = self.orderLine;
    if ([delegate respondsToSelector:@selector(updatedCell:)])
        [self.delegate updatedCell:self];
}

- (void) switchChanged: (id)sender {
//   UIButton *button = (UIButton *)sender;
    for(int i=0; i < [self.propertyViews count]; i++) {
        if([self.propertyViews objectAtIndex:i] == sender) {
            int oldValue = [[orderLine getStringValueForProperty: [orderLine.product.properties objectAtIndex:i]] intValue];
            [orderLine setStringValueForProperty: [orderLine.product.properties objectAtIndex:i] value: oldValue == 0 ? @"1" : @"0"];
//            button.tintColor = button.tintColor == [UIColor blueColor] ? [UIColor lightGrayColor] : [UIColor blueColor];
            return;
        }        
    }
}

- (void) setOrderLine : (OrderLine *) line
{
    orderLine = line;
    
    propertyViews = [[NSMutableArray alloc] init];

    seat.titleLabel.text = [Utils getSeatChar: line.guest.seat];
    course.titleLabel.text = [Utils getCourseChar:line.course.offset];
    quantity.text = [NSString stringWithFormat:@"%d", line.quantity];
    quantity.hidden = line.quantity == 1;
    name.text = line.product.name;

//    if(line.entityState == New)
//    {
//        name.font = [UIFont boldSystemFontOfSize:18];
//        price.font = [UIFont boldSystemFontOfSize:18];
//    }
//    else
//    {
//        nLineIcon.hidden = YES;
//    }
    
    if (showProductProperties) {
        if(line.note.length > 0) {
            note.text = line.note;
            name.frame = CGRectOffset(name.frame, 0, -5);
            quantity.frame = CGRectOffset(quantity.frame, 0, -5);
        }
        else
            note.text = @"";

        props.text = @"";
        for(OrderLinePropertyValue *propertyValue in line.propertyValues)
        {
            props.text = [NSString stringWithFormat:@"%@ %@", props.text, propertyValue.displayValue];
        }
    }
    else {
        note.text = @"";
        props.text = @"";
    }

    NSDecimalNumber *q = [NSDecimalNumber decimalNumberWithDecimal: [[NSNumber numberWithInt:line.quantity] decimalValue]];
    NSDecimalNumber *amount = [line.product.price decimalNumberByMultiplyingBy:q]; 
    price.text = [Utils getAmountString: amount withCurrency:NO];

    self.backgroundColor = [orderLine.product.category.color colorWithAlphaComponent:0.8];			
    self.opaque = NO;

    self.isInEditMode = self.isSelected;
}

- (void) setIsInEditMode: (BOOL)value {
//    _isInEditMode = value;
//    notesView.hidden = !_isInEditMode;
//    stepperView.hidden = !_isInEditMode;
//    for(UISwitch *sw in propertyViews) {
//        sw.hidden = !_isInEditMode;
//    }
    quantity.hidden = !_isInEditMode && orderLine.quantity == 1;
}

@end
