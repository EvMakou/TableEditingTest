//
//  Student.h
//  TableEditingTest
//
//  Created by supermacho on 13.10.16.
//  Copyright © 2016 supermacho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Student : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (assign, nonatomic) CGFloat averageGrade;


+ (Student*) randomStudent;

@end
