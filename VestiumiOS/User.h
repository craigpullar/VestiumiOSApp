//
//  User.h
//  Vestium
//
//  Created by Daniel Koehler on 24/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) NSInteger identifier;

@property (strong, nonatomic) NSString *firstName;

@property (strong, nonatomic) NSString *lastName;

@property (strong, nonatomic) NSString *profileImage;

@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSString *username;

@property (strong, nonatomic) NSDate *dateJoined;

@property (nonatomic) NSInteger numFollowers;

@property (nonatomic) NSInteger numFollowing;

@property (nonatomic) NSInteger numPosts;

@property (nonatomic, strong) NSString *coverImage;

-(id) initWithJSON:(NSDictionary*)JSON;

@end
