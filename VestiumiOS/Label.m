//
//  Label.m
//  Vestium
//
//  Created by Daniel Koehler on 31/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "Label.h"

@implementation Label

-(id) initWithJSON:(NSDictionary*)JSON
{
    self.identifier = [[JSON objectForKey:@"id"] integerValue];
    self.imagePath = [JSON objectForKey:@"imagePath"];
    self.x = [[JSON objectForKey:@"x"] integerValue];
    self.y = [[JSON objectForKey:@"y"] integerValue];
    self.angle = [[JSON objectForKey:@"angle"] integerValue];
    self.colour = [JSON objectForKey:@"colour"];
    self.name = [JSON objectForKey:@"name"];
    self.description = [JSON objectForKey:@"description"];
    self.link = [JSON objectForKey:@"link"];
    self.pubDate = [NSDate dateWithTimeIntervalSince1970:[[JSON objectForKey:@"pubDate"] integerValue]];
    
    return self;
}

@end