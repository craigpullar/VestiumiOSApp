//
//  User.m
//  Vestium
//
//  Created by Daniel Koehler on 24/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "User.h"

@implementation User

-(id) initWithJSON:(NSDictionary*)JSON
{
    NSInteger userid = [[JSON objectForKey:@"id"] integerValue];
    self.identifier = userid;
    self.firstName = [JSON objectForKey:@"firstName"];
    self.lastName = [JSON objectForKey:@"lastName"];
    self.email = [JSON objectForKey:@"email"];
    self.username = [JSON objectForKey:@"username"];
    self.dateJoined = [JSON objectForKey:@"dateJoined"];
    self.profileImage = [NSString stringWithFormat:@"%@/%@",kAPI_MEDIA_ROOT,[JSON objectForKey:@"profileImagePath"]];
    self.profileImage = [self.profileImage stringByReplacingOccurrencesOfString:@"mediafiles/" withString:@""];
    self.coverImage = [NSString stringWithFormat:@"%@/%@",kAPI_MEDIA_ROOT,[JSON objectForKey:@"coverImagePath"]];
    self.coverImage = [self.coverImage stringByReplacingOccurrencesOfString:@"mediafiles/" withString:@""];
    self.numFollowers = [[JSON objectForKey:@"numFollowers"] integerValue];
    self.numFollowing = [[JSON objectForKey:@"numFollowing"] integerValue];
    self.numPosts = [[JSON objectForKey:@"numPosts"] integerValue];
    
    return self;
}


@end
