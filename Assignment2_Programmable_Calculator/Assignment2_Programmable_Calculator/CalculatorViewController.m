//
//  CalculatorViewController.m
//  Assignment2_Programmable_Calculator
//
//  Created by Cheng Bocong on 12/07/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddeOfEnteringANumber;
@property (nonatomic) BOOL decimalPlaced;
@property (nonatomic, strong) CalculatorBrain *brain;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize description = _description;
@synthesize userIsInTheMiddeOfEnteringANumber = _userIsInTheMiddeOfEnteringANumber;
@synthesize decimalPlaced = _decimalPlaced;
@synthesize brain = _brain;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    
    if (self.userIsInTheMiddeOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        
        // Prevent multiple leading 0 fix
        if (![digit isEqualToString:@"0"]) {
            self.userIsInTheMiddeOfEnteringANumber = YES;
        }
    }
}

- (IBAction)decimalPressed {
    if (!self.decimalPlaced) {
        if (self.userIsInTheMiddeOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:@"."];
        } else {
            // Start new number with decimal
            self.display.text = @"0.";
        }
        
        self.userIsInTheMiddeOfEnteringANumber = YES;
        self.decimalPlaced = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.description.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
    self.userIsInTheMiddeOfEnteringANumber = NO;
    self.decimalPlaced = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = [sender currentTitle];
    
    if (self.userIsInTheMiddeOfEnteringANumber) {
        if ([operation isEqualToString:@"+/-"]) {
            self.display.text = [NSString stringWithFormat:@"%g", -[self.display.text doubleValue]];
            return;
        }
        [self enterPressed];
    }
    
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.description.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
}

- (IBAction)clearPressed {
    [self.brain clear];
    self.display.text = @"0";
    self.description.text = @"";
    self.userIsInTheMiddeOfEnteringANumber = NO;
    self.decimalPlaced = NO;
}
- (IBAction)backspacePressed {
    if (self.userIsInTheMiddeOfEnteringANumber) {
        if ([self.display.text length] == 1) {
            self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:[self.brain program]]];
            self.userIsInTheMiddeOfEnteringANumber = NO;
        } else {
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        }
    } else {
        // Remove top item from stack
        [self.brain undoProgram];
        self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:[self.brain program]]];
        self.description.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = [sender currentTitle];
    
    if (self.userIsInTheMiddeOfEnteringANumber) {
        [self enterPressed];
    }
    
    [self.brain pushVariable:variable];
    self.display.text = variable;
    self.description.text = [CalculatorBrain descriptionOfProgram:[self.brain program]];
}

@end
