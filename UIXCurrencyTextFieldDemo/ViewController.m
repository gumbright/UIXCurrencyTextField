//
//  ViewController.m
//  UIXCurrencyTextFieldDemo
//
//  Created by Guy Umbright on 5/20/13.
//  Copyright (c) 2013 Umbright Consulting, Inc. All rights reserved.
//

#import "ViewController.h"
#import "UIXCurrencyTextField.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIXCurrencyTextField* currencyField;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.currencyField.font = [UIFont systemFontOfSize:36.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
