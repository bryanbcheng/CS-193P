//
//  GraphViewController.h
//  Assignment3_Graphing_Calculator
//
//  Created by Cheng Bocong on 12/08/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController

@property (nonatomic, strong) NSArray *programStack;

- (void)setProgramDescription:(NSString *)description;

@end
