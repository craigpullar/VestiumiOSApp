//
//  Label.h
//  Vestium
//
//  Created by Daniel Koehler on 31/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

@interface Label : NSObject

@property (nonatomic) NSInteger identifier;

@property (strong, nonatomic) NSString *imagePath;

@property (nonatomic) NSInteger x;

@property (nonatomic) NSInteger y;

@property (nonatomic) NSInteger angle;

@property (strong, nonatomic) NSString *colour;

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *description;

@property (strong, nonatomic) NSString *link;

@property (strong, nonatomic) NSDate *pubDate;

-(id) initWithJSON:(NSDictionary*)JSON;

@end
