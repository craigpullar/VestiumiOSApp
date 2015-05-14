//
//  Post.h
//  Vestium
//
//  Created by Daniel Koehler on 24/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "User.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PostType) {
    PostTypePortrait,
    PostTypeLandscape,
};

@interface Post : NSObject

@property (nonatomic) NSInteger identifier;

@property (strong, nonatomic) NSString *imagePath;

@property (nonatomic) PostType type;

@property (strong, nonatomic) UIColor *pastel;

@property (strong, nonatomic) NSString *descriptionText;

@property (strong, nonatomic) User *user;

@property (nonatomic) NSInteger numLikes;

@property (nonatomic) NSInteger numShares;

@property (nonatomic) NSInteger numComments;

@property (nonatomic, strong) NSDate *pubDate;

// Commments relationship

-(id) initWithJSON:(NSDictionary*)json;

@end
