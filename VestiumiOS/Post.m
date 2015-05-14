//
//  Post.m
//  Vestium
//
//  Created by Daniel Koehler on 24/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "Post.h"

@implementation UIColor(Vestium)

+ (UIColor*) colorWithInt:(NSInteger) rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end

@implementation NSNumber(Vestium)

- (NSNumber*) numberWithColor:(UIColor*) colorValue {
    
    double red, green, blue;
    
    if ([colorValue getRed:&red green:&green blue:&blue alpha:NULL])
    {
        return [NSNumber numberWithInteger:((NSUInteger)(red * 255 + 0.5) << 16) | ((NSUInteger)(green * 255 + 0.5) << 8) | (NSUInteger)(blue * 255 + 0.5)];
    }
    
    return 0;
}

@end

@implementation Post

-(id) initWithJSON:(NSDictionary*) JSON;
{
    
    self.identifier = [[JSON objectForKey:@"id"] integerValue];
    self.descriptionText = [JSON objectForKey:@"description"];
    self.pastel = [UIColor colorWithInt:[[JSON objectForKey:@"pastel"] integerValue]];
    
    self.user = [[User alloc] initWithJSON:[JSON objectForKey:@"user"]];
    self.numLikes = [[JSON objectForKey:@"numLikes"] integerValue];
    self.numShares = [[JSON objectForKey:@"numLikes"] integerValue];
    self.numComments = [[JSON objectForKey:@"numComments"] integerValue];
    self.numShares = [[JSON objectForKey:@"numShares"] integerValue];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.S"];
    
    self.pubDate = [df dateFromString:[JSON objectForKey:@"pubDate"]];
    NSString *link = [JSON objectForKey:@"imagePath"];
    link = [link stringByReplacingOccurrencesOfString:@"media/" withString:@""];
    self.imagePath = [NSString stringWithFormat:@"%@%@",kAPI_MEDIA_ROOT,link];
    
    
    return self;
}

@end
