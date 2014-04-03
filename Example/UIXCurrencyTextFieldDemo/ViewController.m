//
//  ViewController.m
//  UIXCurrencyTextFieldDemo
//
//  Created by Guy Umbright on 8/23/11.
//  Copyright 2014 Umbright Consulting, Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIXCurrencyTextField* currencyField;
@property (nonatomic, weak) IBOutlet UIXCurrencyTextField* currencyField2;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.currencyField.font = [UIFont systemFontOfSize:36.0];
    self.currencyField.delegate = self;
    
    //accessory for 2nd field
    UIToolbar* v = [[UIToolbar alloc] initWithFrame:CGRectZero];
    v.barTintColor = [UIColor colorWithWhite:.85 alpha:.5];
    
    //!!!To simply use the built in "done" handling
    v.items = @[[[UIBarButtonItem alloc] initWithTitle:@"+99¢" style:UIBarButtonItemStylePlain target:self action:@selector(plus99:)],
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                [[UIBarButtonItem alloc] initWithTitle:@"-99¢" style:UIBarButtonItemStylePlain target:self action:@selector(minus99:)],
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.currencyField2 action:@selector(donePressed:)]];
    [v sizeToFit];
    
    self.currencyField2.inputAccessoryView = v;
    
    self.currencyField2.textColor = [UIColor redColor];
    self.currencyField2.font = [UIFont fontWithName:@"Georgia" size:12.0];
    self.currencyField2.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (IBAction) editTopFieldPressed:(id)sender
{
    [self.currencyField becomeFirstResponder];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (IBAction) endTopFieldEditPressed:(id)sender
{
    [self.currencyField resignFirstResponder];
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) plus99:(id) sender
{
    float val = self.currencyField2.value;
    val += 0.99;
    self.currencyField2.value = val;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) minus99:(id) sender
{
    float val = self.currencyField2.value;
    val -= 0.99;
    self.currencyField2.value = val;
}

#pragma mark UIXCurrencyTextFieldDelegate
/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (BOOL) currencyTextFieldShouldEndEditing:(UIXCurrencyTextField*) currencyField
{
    return YES;
}

/////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////
- (void) currencyTextFieldDidEndEditing:(UIXCurrencyTextField *)currencyTextField
{
    NSLog(@"did end editing");
}
@end
