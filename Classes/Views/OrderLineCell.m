#import <CoreGraphics/CoreGraphics.h>
#import "OrderLineCell.h"
#import "Utils.h"
#import "ToggleButton.h"
#import "SeatView.h"
#import "SeatGridView.h"

@implementation OrderLineCell

@synthesize isEditable, nLineIcon, orderLine, price, name, note, props, seat, course, quantity, showSeat, showPrice, showProductProperties, isInEditMode = _isInEditMode, stepperView, notesView, propertyViews, heightInEditMode, delegate, showStepper;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showProductProperties = YES;
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    float right = self.contentView.bounds.size.width - 13;
    float height = self.bounds.size.height;
    self.notesView.frame = CGRectMake(50, self.notesView.frame.origin.y, right - 50, self.notesView.frame.size.height);
    if (self.showStepper) {
        stepperView.frame = CGRectMake(right-94, stepperView.frame.origin.y, 94, height);
        right -= self.stepperView.frame.size.width + 10;
    }
    if (self.showPrice) {
        self.price.frame = CGRectMake(right - 60, 0, 60, self.price.frame.size.height);
        right -= self.price.frame.size.width;
    }
    if (self.showSeat) {
        self.seat.frame = CGRectMake(right - self.seat.frame.size.width, 0, self.seat.frame.size.width, self.seat.frame.size.height);
        right -= self.seat.frame.size.width;
    }
    self.name.frame = CGRectMake(self.name.frame.origin.x, self.name.frame.origin.y, right - self.name.frame.origin.x, self.name.frame.size.height);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line isEditable: (BOOL)isEditable showPrice: (bool)showPrice showProperties: (bool)showProperties showSeat: (bool)showSeat showStepper: (bool)showStepper delegate: (id) delegate rowHeight: (float)rowHeight fontSize: (float)fontSize
{
    OrderLineCell *cell = [[OrderLineCell alloc] init];

    cell.selectionStyle = UITableViewCellSelectionStyleNone; // UITableViewCellEditingStyleNone;
    cell.clipsToBounds = YES;

    cell.delegate = delegate;
    cell.isEditable = isEditable;
    cell.showProductProperties = showProperties;
    cell.showPrice = showPrice;
    cell.showSeat = showSeat;
    cell.showStepper = showStepper;
    float height = rowHeight == 0 ? 44 : rowHeight;
    float width = cell.contentView.bounds.size.width;

    if (line == nil) {
        return cell;
    }

    cell.quantity = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, height)];
    [cell.contentView addSubview:cell.quantity];
    cell.quantity.textAlignment = UITextAlignmentRight;
    cell.quantity.backgroundColor = [UIColor clearColor];
    if (fontSize != 0)
        cell.quantity.font = [UIFont systemFontOfSize:fontSize];
    if (isEditable == false)
        cell.quantity.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    cell.name = [[UILabel alloc] initWithFrame:CGRectMake(cell.quantity.frame.origin.x + cell.quantity.frame.size.width + 3, 0, 200, height)];
    [cell.contentView addSubview:cell.name];
    cell.name.backgroundColor = [UIColor clearColor];
    if (fontSize != 0)
        cell.name.font = [UIFont systemFontOfSize:fontSize];
    cell.name.shadowColor = [UIColor lightGrayColor];
    cell.name.shadowOffset = CGSizeMake(0, 1);

    float right = width;
    if (showStepper) {
        cell.stepperView = [[UIStepper alloc] initWithFrame:CGRectMake(right-94, (height-27)/2, 94, height)];
        [cell.contentView addSubview: cell.stepperView];
        cell.stepperView.minimumValue = 0;
        cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.stepperView addTarget:cell action:@selector(quantityUpdated:) forControlEvents:UIControlEventValueChanged];
        cell.stepperView.value = line.quantity;

        right -= cell.stepperView.frame.size.width - 10;
    }
    
    if (cell.showPrice) {
        cell.price = [[UILabel alloc] initWithFrame:CGRectMake(right-50, 0, 50, height)];
        [cell.contentView addSubview:cell.price];
//        cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        cell.price.textAlignment = UITextAlignmentRight;
        cell.price.backgroundColor = [UIColor clearColor];
        cell.price.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        if (fontSize != 0)
            cell.price.font = [UIFont systemFontOfSize:fontSize];
        if (isEditable == false)
            cell.price.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        right -= cell.price.frame.size.width - 5;
    }

    if (cell.showSeat) {
//        cell.seat = [SeatView viewWithFrame:CGRectMake(right-36, 0, 36, height) offset:line.guest.seat atSide:0 showSeatNumber:YES];
        cell.seat = [SeatGridView viewWithFrame: CGRectMake(right-36, 0, 36, height) countHorizontal:4 countVertical:0 selectedOffset:6];
//        [cell.seat initByGuest: line.guest];
        [cell.contentView addSubview:cell.seat];
        if (isEditable == false)
            cell.seat.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        else
            cell.seat.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        right -= cell.seat.frame.size.width - 5;
    }

    if (isEditable) {
        float x = 50;
        float y = rowHeight;
        float margin = 10;
        float vSpace = 5;
        float controlHeight = 27;
        if ([line.product.properties count] > 0) {
            for(OrderLineProperty *property in line.product.properties) {

                CGSize size = [property.name sizeWithFont: [UIFont boldSystemFontOfSize:18]];
                ToggleButton *sw = [ToggleButton buttonWithTitle: property.name frame: CGRectMake(x, y, size.width + 20, controlHeight)];
                if (sw.frame.origin.x + sw.frame.size.width > width)
                {
                    x = 50;
                    y += controlHeight + vSpace;
                    sw.frame = CGRectMake(x, y, sw.frame.size.width, sw.frame.size.height);
                }
                [cell.contentView addSubview:sw];
                [sw addTarget: cell action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.propertyViews addObject:sw];

                x += sw.frame.size.width + margin;
            }

            y += controlHeight + vSpace;
        }
        x = 50;   
        cell.notesView = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width - 8, controlHeight)];
        [cell.notesView addTarget: cell action:@selector(noteTextUpdated) forControlEvents:UIControlEventEditingChanged];
        cell.notesView.placeholder = NSLocalizedString(@"Notitie", nil);
        cell.notesView.backgroundColor = [UIColor whiteColor];
        cell.notesView.borderStyle = UITextBorderStyleBezel;
        [cell.contentView addSubview: cell.notesView];
        
        cell.heightInEditMode = y + cell.notesView.bounds.size.height + 5;
    }

    cell.orderLine = line;

    return cell;
}

+ (float) getExtraHeightForEditMode: (OrderLine *)line width: (float)width
{
    if (line == nil || line.product == nil)
        return 0;
    if (line.product.properties == nil || [line.product.properties count] == 0)
        return 33;
    float x = 50;
    float margin = 10;
    int countLines = 1;
    for(OrderLineProperty *property in line.product.properties) {
        CGSize size = [property.name sizeWithFont: [UIFont boldSystemFontOfSize:18]];
        size.width += 20;
        if (x + size.width > width)
        {
            x = 50;
            countLines++;
        }

        x += size.width + margin;
    }
    return 33 * (1 + countLines);
}

- (void) noteTextUpdated {
    orderLine.note = notesView.text;
}

- (void) quantityUpdated: (id)sender {
    orderLine.quantity = stepperView.value;
    quantity.text = [NSString stringWithFormat:@"%d", orderLine.quantity];
    self.orderLine = self.orderLine;
    if ([delegate respondsToSelector:@selector(updatedCell:)])
        [self.delegate updatedCell:self];
}

- (void) switchChanged: (id)sender {
    for(int i=0; i < [self.propertyViews count]; i++) {
        if([self.propertyViews objectAtIndex:i] == sender) {
            int oldValue = [[orderLine getStringValueForProperty: [orderLine.product.properties objectAtIndex:i]] intValue];
            [orderLine setStringValueForProperty: [orderLine.product.properties objectAtIndex:i] value: oldValue == 0 ? @"1" : @"0"];
            return;
        }        
    }
}

- (void) setOrderLine : (OrderLine *) line
{
    orderLine = line;

    propertyViews = [[NSMutableArray alloc] init];

    if (line.guest == nil) {
        seat.hidden = YES;
    }
    else {
//        seat.titleLabel.text = [Utils getSeatChar: line.guest.seat];
        seat.hidden = NO;
    }

    course.titleLabel.text = [Utils getCourseChar:line.course.offset];

    quantity.text = [NSString stringWithFormat:@"%d", line.quantity];
    quantity.hidden = line.quantity == 1;

    if (line.product != nil)
        name.text = line.product.name;
    else {
        name.text = @"Click to select course";
        name.textColor = [UIColor grayColor];
    }

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
    quantity.hidden = !_isInEditMode && orderLine.quantity == 1;
}

@end
