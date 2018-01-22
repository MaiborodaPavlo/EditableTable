//
//  PMEmployee.h
//  EditableTable
//
//  Created by Pavel on 22.01.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PMEmployee : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) CGFloat experience;

+ (PMEmployee *) randomEmployee;

@end
