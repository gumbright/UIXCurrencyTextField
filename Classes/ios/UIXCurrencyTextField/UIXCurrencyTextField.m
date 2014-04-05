//
//  UIXCurrencyTextField.m
//  UIXCurrencyTextField
//
//  Created by Guy Umbright on 8/23/11.
//  Copyright 2014 Umbright Consulting, Inc. All rights reserved.
//

#import "UIXCurrencyTextField.h"

const NSUInteger kMaxLengthDefault = 9;

static NSNumberFormatter* gFormatter = nil;
NSString* UIXCurrencyTextFieldDonePressedNotification = @"UIXCurrencyTextFieldDonePressedNotification";

@interface UIXCurrencyTextField ()
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) NSDecimalNumber* currentDecimalValue;

@property (nonatomic, strong) UITextField* entryField;
@property (nonatomic, strong) UILabel* display;
@property (nonatomic, readonly) NSNumberFormatter* formatter;
@property (nonatomic, strong) UIView* blinky;
@property (nonatomic, strong) NSTimer* blinkyTimer;
@property (nonatomic, strong) UIView* currentInputAccessory;
@end

@implementation UIXCurrencyTextField

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) commonInitialization
{
    self.caretWidth = 3;

    self.entryField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.entryField.delegate = self;
    self.entryField.keyboardType =  UIKeyboardTypeNumberPad;
    self.entryField.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editValueChanged:) 
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:self.entryField];
    [self addSubview:self.entryField];
    
    self.display = [[UILabel alloc] initWithFrame:CGRectZero];
    self.display.backgroundColor = [UIColor clearColor];
    self.display.textColor = (self.textColor) ? :[UIColor blackColor];
    self.display.userInteractionEnabled = YES;
    self.display.textAlignment = NSTextAlignmentRight;
    self.display.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:self.display];
    
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    
    gr.numberOfTapsRequired = 1;
    gr.numberOfTouchesRequired = 1;
    [self.display addGestureRecognizer:gr];
    
    self.blinky = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-10, 5, self.caretWidth, self.bounds.size.height-10)];
    self.blinky.backgroundColor = self.display.textColor;
    self.blinky.hidden = 1.0;
    [self addSubview:self.blinky];
    
    self.maxLength = kMaxLengthDefault;
    
    self.display.text = [self.formatter stringFromNumber:[NSNumber numberWithFloat:0.0]];
    [self setNeedsDisplay];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (NSNumberFormatter*) formatter
{
    if (!gFormatter)
    {
        gFormatter = [[NSNumberFormatter alloc] init];
        gFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    
    return gFormatter;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) setupDefaultAccessoryView
{
    UIToolbar* v = [[UIToolbar alloc] initWithFrame:CGRectZero];
    v.barTintColor = [UIColor colorWithWhite:.85 alpha:.5];
    
    v.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)]];
    [v sizeToFit];
    
    self.currentInputAccessory = v;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (UIView*) currentInputAccessory
{
    if (_currentInputAccessory == nil)
    {
        [self setupDefaultAccessoryView];
    }
    
    return _currentInputAccessory;
}


////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self commonInitialization];
    }
    return self;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) awakeFromNib
{
    [self commonInitialization];
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) layoutSubviews
{
    self.entryField.frame = self.bounds;
    CGRect r = self.bounds;
    r.size.width -= (self.caretWidth + 2 + 5);
    self.display.frame = r;
}
#pragma mark UITextFieldDelegate methods

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.blinkyTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(handleBlinky:)
                                                      userInfo:nil
                                                       repeats:YES];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(currencyTextFieldDidEndEditing:)])
    {
        [self.delegate currencyTextFieldDidEndEditing:self];
    }
    
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(currencyTextFieldShouldEndEditing:)])
    {
        result = [self.delegate currencyTextFieldShouldEndEditing:self];
    }
    
    if (result)
    {
        [self handleResignFirstResponder];
    }
    return result;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result = YES;
    
    result = (textField.text.length - range.length + string.length) <= self.maxLength;
    
    if (result)
    {
        NSCharacterSet* goodChars = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSRange resultRange = [string rangeOfCharacterFromSet:goodChars];
        result = (resultRange.location == NSNotFound);
    }
    
    return result;
}

#pragma mark attributes

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (float) value
{
    return self.currentValue;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setValue:(float)inputValue
{
    NSString* floatString = [NSString stringWithFormat:@"%f",inputValue];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                      scale:[self.formatter maximumFractionDigits]
                                                                                           raiseOnExactness:FALSE
                                                                                            raiseOnOverflow:TRUE
                                                                                           raiseOnUnderflow:TRUE
                                                                                        raiseOnDivideByZero:TRUE];
    
    [self.formatter setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber* n = [self.formatter numberFromString:floatString];
    [self.formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[n decimalValue]];
    
    NSDecimalNumber *roundedDecimalNumber = [decimalNumber decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    NSDecimalNumber* num = [roundedDecimalNumber decimalNumberByMultiplyingBy:scale];
    
    self.entryField.text = [num stringValue];
    [self updateCurrentValue];
    [self updateDisplay];
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setFont:(UIFont *)font
{
    self.display.font = font;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (UIFont*) font
{
    return self.display.font;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) setTextColor:(UIColor *)textColor
{
    self.display.textColor = textColor;
    self.blinky.backgroundColor = textColor;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (UIColor*) textColor
{
    return self.display.textColor;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (UIView*) inputAccessoryView
{
    return self.currentInputAccessory;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) setInputAccessoryView:(UIView *)inputAccessoryView
{
    self.currentInputAccessory = inputAccessoryView;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) setDecimalValue:(NSDecimalNumber *)decValue
{
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    NSDecimalNumber* num = [decValue decimalNumberByMultiplyingBy:scale];
    
    self.entryField.text = [num stringValue];
    [self updateDisplay];
    
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (NSDecimalNumber*) decimalValue
{
    NSDecimalNumber* num = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:[self.entryField.text intValue]] decimalValue]];
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    num = [num decimalNumberByDividingBy:scale];
    
    return num;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) setMaxLength:(NSUInteger)maxLength
{
    _maxLength = (maxLength <= kMaxLengthDefault) ? : kMaxLengthDefault;
}

#pragma mark operational
////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) updateDisplay
{
    if (self.entryField.text.length == 0)
    {
        self.display.text = [self.formatter stringFromNumber:[NSNumber numberWithFloat:0.0]];
    }
    else
    {
        self.display.text = [self.formatter stringFromNumber:self.currentDecimalValue];
    }
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) editValueChanged:(NSNotification*) notification
{
    [self updateCurrentValue];
    [self updateDisplay];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) updateCurrentValue
{
    NSDecimalNumber* num = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:[self.entryField.text intValue]] decimalValue]];
    NSDecimalNumber* scale = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:10] decimalValue]];
    scale = [scale decimalNumberByRaisingToPower:[self.formatter maximumFractionDigits]];
    self.currentDecimalValue = [num decimalNumberByDividingBy:scale];
    double d = [self.currentDecimalValue doubleValue];
    self.currentValue = (float) d;
    
}


////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) handleBlinky:(NSTimer*) timer
{
    if (self.blinky.alpha == 0.0)
    {
        [UIView animateWithDuration:0.15 
                              delay:0.0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^(void) {self.blinky.alpha = 0.8;} 
                         completion:nil];
    }
    else
    {
        [UIView animateWithDuration:0.15 
                              delay:0.0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^(void) {self.blinky.alpha = 0.0;} 
                         completion:nil];
    }
}


////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) handleBecomeFirstResponder
{
    if (!self.entryField.isFirstResponder)
    {
        self.entryField.inputAccessoryView = self.currentInputAccessory;
        [self.entryField becomeFirstResponder];
    }
    self.blinky.alpha = 0.0;
    self.blinky.hidden = NO;
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) handleResignFirstResponder
{
    NSLog(@"%@\n\n%@",self, self.entryField);
    
    if (self.entryField.isFirstResponder)
    {
        [self.blinkyTimer invalidate];
        self.blinky.hidden = YES;
        [self.entryField resignFirstResponder];
    }
    
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (void) tapped: (UIGestureRecognizer*) gr
{
    [self becomeFirstResponder];
}

////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////
- (NSDecimalNumber*) floatToAppropriateNSDecimalNumber:(float) value
{
    NSString* floatString = [NSString stringWithFormat:@"%f",value];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain 
                                                                                                      scale:[self.formatter maximumFractionDigits] 
                                                                                           raiseOnExactness:FALSE 
                                                                                            raiseOnOverflow:TRUE 
                                                                                           raiseOnUnderflow:TRUE 
                                                                                        raiseOnDivideByZero:TRUE]; 
    
    [self.formatter setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber* n = [self.formatter numberFromString:floatString];
    [self.formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[n decimalValue]];
    
    NSDecimalNumber *roundedDecimalNumber = [decimalNumber decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return roundedDecimalNumber;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) donePressed:(id) sender
{
    [self endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIXCurrencyTextFieldDonePressedNotification object:self];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL) becomeFirstResponder
{
    [self handleBecomeFirstResponder];
    return YES;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL) resignFirstResponder
{
    [self handleResignFirstResponder];
    return YES;
}
@end
