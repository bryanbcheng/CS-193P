//
//  CalculatorBrain.m
//  Assignment3_Graphing_Calculator
//
//  Created by Cheng Bocong on 12/07/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSSet *twoOperandOperations;
@property (nonatomic, strong) NSSet *oneOperandOperations;
@property (nonatomic, strong) NSSet *noOperandOperations;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize twoOperandOperations = _twoOperandOperations;
@synthesize oneOperandOperations = _oneOperandOperations;
@synthesize noOperandOperations = _noOperandOperations;

- (NSMutableArray *)programStack {
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program {
    return [self.programStack copy];
}

+ (NSSet *)twoOperandOperations {
    static NSSet *_twoOperandOperations = nil;
    if (_twoOperandOperations == nil) {
        _twoOperandOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    }
    return _twoOperandOperations;
}

+ (NSSet *)oneOperandOperations {
    static NSSet *_oneOperandOperations = nil;
    if (_oneOperandOperations == nil) {
        _oneOperandOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"sqrt", @"log", @"+/-", nil];
    }
    return _oneOperandOperations;
}

+ (NSSet *)noOperandOperations {
    static NSSet *_noOperandOperations = nil;
    if (_noOperandOperations == nil) {
        _noOperandOperations = [[NSSet alloc] initWithObjects:@"π", @"e", nil];
    }
    return _noOperandOperations;
}

+ (BOOL)isOperation:(NSString *)operation {
    return [[self twoOperandOperations] containsObject:operation] ||
           [[self oneOperandOperations] containsObject:operation] ||
           [[self noOperandOperations] containsObject:operation];
}

+ (NSString *)suppressParentheses:(NSString *)string {
    if ([string hasPrefix:@"("] && [string hasSuffix:@")"]) {
        return [string substringWithRange:NSMakeRange(1, [string length] - 2)];
    }
    return string;
}
/*
+ (NSString *)findMostRecentOperation:(NSString *)string {
    NSString *searchString = [self suppressParentheses:string];
    
    int i = 0;
    int openParentheses = 0;
    while (i < [searchString length]) {
        NSString *letter = [searchString substringWithRange:NSMakeRange(i, 1)];
        if ([letter isEqualToString:@"("]) {
            openParentheses++;
        } else if ([letter isEqualToString:@")"]) {
            openParentheses--;
        }
        if (openParentheses > 0) continue;
        
        if ([letter isEqualToString:@"+"] || [letter isEqualToString:@"-"] ||
            [letter isEqualToString:@"*"] || [letter isEqualToString:@"/"])
            return letter;
    }
    
    return nil;
}
*/
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack {
    NSString *description = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *symbol = topOfStack;
        
        // Need to remove extra parentheses
        if ([[self twoOperandOperations] containsObject:symbol]) {
            NSString *secondNumber = [self descriptionOfTopOfStack:stack];
            NSString *firstNumber = [self descriptionOfTopOfStack:stack];
            description = [NSString stringWithFormat:@"(%@ %@ %@)", firstNumber, symbol, secondNumber];
        } else if ([[self oneOperandOperations] containsObject:symbol]) {
            NSString *number = [self suppressParentheses:[self descriptionOfTopOfStack:stack]];
            if ([symbol isEqualToString:@"+/-"]) {
                description = [NSString stringWithFormat:@"-(%@)", number];
            } else {
                description = [NSString stringWithFormat:@"%@(%@)", symbol, number];
            }
        } else {
            // For variables, pi, e
            description = symbol;
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // To list everything in stack
    NSString *description = @"";
    while ([stack count] != 0) {
        if ([description isEqualToString:@""]) {
            description = [self suppressParentheses:[self descriptionOfTopOfStack:stack]];
        } else {
            description = [NSString stringWithFormat:@"%@, %@", description, [self suppressParentheses:[self descriptionOfTopOfStack:stack]]];
        }
    }
    return description;
}

- (void)pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable {
    [self.programStack addObject:variable];
}

- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"e"]) {
            result = M_E;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            double operand = [self popOperandOffProgramStack:stack];
            // No imaginary numbers
            if (operand >= 0) result = sqrt(operand);
        } else if ([operation isEqualToString:@"log"]) {
            double operand = [self popOperandOffProgramStack:stack];
            // Log cannot take negative numbers and log(0) = -inf
            if (operand > 0) result = sqrt(operand); 
        } else if ([operation isEqualToString:@"+/-"]) {
            result = -[self popOperandOffProgramStack:stack];
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program {
    return [self runProgram:program
        usingVariableValues:nil];
}

+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        NSSet *variables = [CalculatorBrain variablesUsedInProgram:program];
        
        for (NSUInteger i = 0; i < [stack count]; i++) {
            id item = [stack objectAtIndex:i];
            if ([variables containsObject:item]) {
                NSNumber *value = [variableValues objectForKey:item];
                if (value) {
                    [stack replaceObjectAtIndex:i withObject:value];
                }
            }
        }
    }
    return [self popOperandOffProgramStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    NSSet *variables = [NSSet set];
    if ([program isKindOfClass:[NSArray class]]) {
        for (id item in program) {
            if ([item isKindOfClass:[NSString class]] && ![self isOperation:item]) {
                variables = [variables setByAddingObject:item];
            }
        }
    }
    return [variables count] > 0 ? variables : nil;
}

- (void)undoProgram {
    if ([self.programStack count] != 0) [self.programStack removeLastObject];
}

- (void)clear {
    [self.programStack removeAllObjects];
}

@end
