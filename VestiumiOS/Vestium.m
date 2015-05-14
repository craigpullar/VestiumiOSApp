//
//  Vestium.m
//  Vestium
//
//  Created by Daniel Koehler on 23/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "Vestium.h"



@implementation Vestium

-(id) init {
    
    if (self = [super init])
    {
        
        
        
        self.urlBuilder = [NSURLComponents alloc];
        [self.urlBuilder setScheme:kAPI_SCHEME];
        [self.urlBuilder setHost:kAPI_HOST];
        
    }
    return self;
}

+(NSURL*) urlWithPathComponent:(NSString*) path
{
    NSURLComponents * urlBuilder = [NSURLComponents alloc];
    [urlBuilder setPort:[NSNumber numberWithInt:8000]];
    [urlBuilder setScheme:kAPI_SCHEME];
    [urlBuilder setHost:kAPI_HOST];
    [urlBuilder setPath:path];
    return urlBuilder.URL;
}

//////////////////
//GET AUTH TOKEN//
//////////////////
-(void) authTokenForResourceOwnerUsername:(NSString *) username password:(NSString *) password {
    
    NSDictionary *params = @{
                             @"client_id": kCLIENT_ID,
                             @"client_secret": kCLIENT_SECRET,
                             @"grant_type": @"password",
                             @"username": username,
                             @"password": password,
                             @"scope": @"read write"
                             };
    
    [self.urlBuilder setPath:kAPI_AUTH_PATH];
    
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         @try
         {
             
             self.expires = [NSDate dateWithTimeIntervalSinceNow:[[responseObject objectForKey:@"expires_in"] intValue]];
             self.accessToken = [responseObject objectForKey:@"access_token"];
             self.refreshToken = [responseObject objectForKey:@"refresh_token"];
         } @catch (NSException * e)
         {
             // Handle auth grant fell over
             NSLog(@"Exception: %@", e);
         }
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSLog(@"Error: %@", error);
         
     }];
}

///////////////////////
// GET REFRESH TOKEN //
///////////////////////
-(void) authTokenForRefreshToken:(NSString*) refreshToken {
    
    NSDictionary *params = @{
                             @"client_id": kCLIENT_ID,
                             @"client_secret": kCLIENT_SECRET,
                             };
    
    
    [self.urlBuilder setPath:@"some path"];
    
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            
            self.expires = [NSDate dateWithTimeIntervalSinceNow:[[responseObject objectForKey:@"expires_in"] intValue]];
            self.accessToken = [responseObject objectForKey:@"access_token"];
            self.refreshToken = [responseObject objectForKey:@"refresh_token"];
            
        } @catch (NSException * e) {
            // Handle auth grant fell over
            NSLog(@"Exception: %@", e);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
}

///////////////////
// REGISTER USER //
///////////////////
-(void)registerUserWithFirstName:(NSString*) firstName lastName:(NSString*) lastName email:(NSString*) email username:(NSString*) username password:(NSString*) password image:(UIImage *)image{
    
    if (!image)
    {
        image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"user-placeholder.png"];
    }
    
    NSString *base64PhotoString = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *params = @{
                             @"first_name": firstName,
                             @"last_name": lastName,
                             @"email": email,
                             @"username": username,
                             @"password":password,
                             @"profileImage":base64PhotoString,
                             };
    
    [self.urlBuilder setPath:@"/api/v1/user/"];
    
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* user) {
        self.user = [[User alloc] initWithJSON:user];
        
        [self.delegate didCreateUser:self.user password:password];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
    
}


////////////////
// LOGIN USER //
////////////////
-(void) loginUserWithUsername:(NSString*) username password:(NSString*) password {
    
    
    [self.urlBuilder setPath:@"/api/v1/user/"];
    
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:@{@"username__iexact":username,@"password":password} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *objects = [responseObject objectForKey:@"objects"];
        
        if(objects.count)
        {
            NSDictionary *response = objects[0];
            if([response objectForKey:@"error"])
            {
                NSLog(@"%@",[response objectForKey:@"error"]);
            }
            else{
                NSArray* userList = [responseObject objectForKey:@"objects"];
                NSDictionary *userObject = [userList objectAtIndex:0];
                self.user = [[User alloc] initWithJSON:userObject];
                
                [self authTokenForResourceOwnerUsername:username password:password];
                [self.menuDelegate updateMenuWithUser:self.user];
                [self.delegate didLoginUser:self.user];
                [self getFeedPostArrayForUser:self.user];
            }
        }
        else {
            NSLog(@"Incorrect Username");
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
    
}



/////////////////
// UPDATE USER //
/////////////////
-(void) updateUserWithFirstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email image:(UIImage*)image
{
    NSString *base64PhotoString = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *params = @{
                             @"first_name": firstName,
                             @"last_name": lastName,
                             @"email": email,
                             @"profileImage": base64PhotoString
                             };
    
    
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/user/%ld/",(long)self.user.identifier]];
    
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager PATCH:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            User* user = [[User alloc] initWithJSON:responseObject];
            [self.delegate didUpdateUser:user];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
}



/////////////////////
// VERFIY USERNAME //
/////////////////////
-(void) verifyUsernameAvalibilty:(NSString *) username
{
    NSString *path = [NSString stringWithFormat:@"http://localhost:8000/api/v1/user/?username=%@",username];
    NSURL *url = [NSURL fileURLWithPath:path];
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *users = [responseObject objectForKey:@"objects"];
        if (![users count]) {
            [self.delegate didVerifyUsernameAvailability:username];
        }
        else {
            [self.delegate didNotVerfiyUsername:username];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}



///////////////////////
// GET USER FOR USER //
///////////////////////
-(void) getUser:(User*) user
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/user/%ld/",(long)[user identifier]]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            User* user = [[User alloc] initWithJSON:responseObject];
            [self.delegate didGetUser:user];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //Username is available
        NSLog(@"Error: %@", error);
        
    }];
}

-(void) getProfileUserForId:(NSInteger) userId
{
    
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/user/%ld/",(long)userId]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            
            User* user = [[User alloc] initWithJSON:responseObject];
            [self.profileDelegate didGetProfileUser:user];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //Username is available
        NSLog(@"Error: %@", error);
        
    }];
}

/////////////////////
// GET USER FOR ID //
/////////////////////
-(void) getUserForId:(NSInteger) userId
{
    
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/user/%ld/",(long)userId]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            
            User* user = [[User alloc] initWithJSON:responseObject];
            [self.delegate didGetUser:user];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //Username is available
        NSLog(@"Error: %@", error);
        
    }];
}



//////////////////////////////
// GET TRENDING POST ARRAY //
/////////////////////////////
-(void) getTrendingPostArray
{
    //    [self getFeedPostArray];
}



/////////////////////////
// GET FEED POST ARRAY //
/////////////////////////
-(void) getFeedPostArrayForUser:(User*)user
{
    
    
    [self.urlBuilder setPath:@"/api/v1/relationship/"];
    //    NSString *path = [NSString stringWithFormat:@"http://localhost:8000/api/v1/relationship/?follower__id=%d",2];
    
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:@{@"follower__id": @(user.identifier)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //POSTS WERE RETURNED
        NSArray *relationships = [responseObject objectForKey:@"objects"];
        
        NSMutableArray *userObjects = [[NSMutableArray alloc] init];
        for (NSDictionary *user in relationships){
            [userObjects addObject:[user objectForKey:@"following"]];
        }
        NSMutableArray *postObjects = [[NSMutableArray alloc] init];
        for (NSDictionary *post in userObjects){
            [postObjects addObject:[post objectForKey:@"posts"]];
        }
        NSMutableArray *output = [[NSMutableArray alloc] init];
        for (NSArray *array in postObjects)
        {
            for (NSDictionary *postDic in array)
            {
                Post *post = [[Post alloc] initWithJSON:postDic];
                
                [output addObject:post];
            }
            
        }
        
        if ([output count]) {
            [self.trendingDelegate didGetFeedPosts:output];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POSTS WERE NOT RETURNED
        NSLog(@"Error: %@", error);
        
    }];
}



/////////////////
// CREATE POST //
/////////////////
-(void) createPostWithImage:(UIImage*) postImage description:(NSString*) description tags:(NSArray*) tags pastel:(NSInteger) pastel
{
    // This is really hacky.
    NSString *base64PhotoString = [UIImagePNGRepresentation(postImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [self.urlBuilder setPath:@"/api/v1/post/"];
    NSURL *url = [self.urlBuilder URL];
    
    NSDictionary *params = @{
                             @"imagePathString": base64PhotoString,
                             //                             @"labels": labels,
                             @"description":description,
                             //                             @"tags": tags
                             @"user": [NSString stringWithFormat:@"/api/v1/user/%@/", [NSNumber numberWithInteger:self.user.identifier]],
                             @"pastel": [NSNumber numberWithInteger:pastel],
                             @"numLikes": @0,
                             @"numComments":@0,
                             };
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *post) {
        
        
        if (post){
            [self.delegate didCreatePost:[[Post alloc] initWithJSON:post]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST FAILED TO CREATE
        NSLog(@"Error: %@", error);
        
    }];
}



/////////////////////
// GET USERS POSTS //
/////////////////////
-(void) getPostsForUserId:(NSInteger) userId
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/user/%ld/",(long) userId]];
    NSURL *url = [self.urlBuilder URL];
    
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //POSTS WERE RETURNED
        NSMutableArray *posts = [[NSMutableArray alloc] init];
        
        for (NSDictionary *post in [responseObject objectForKey:@"posts"]){
            Post *postObject = [[Post alloc] initWithJSON:post];
            [posts addObject:postObject];
            
        }
        [self.profileDelegate didGetPostsForUser:posts];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POSTS WERE NOT RETURNED
        NSLog(@"Error: %@", error);
        
    }];
}



/////////////////////
// GET POST FOR ID //
/////////////////////
-(void) getPostForPostId:(NSInteger) postId
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/post/%ld/",(long)postId]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *post) {
        
        //POST WAS RETURNED
        if ([post count]) {
            
            [self.delegate didGetPost:[[Post alloc] initWithJSON:post]];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST WAS NOT RETURNED
        NSLog(@"Error: %@", error);
        
    }];
}



/////////////////
// DELETE POST //
/////////////////
-(void) deletePost:(Post*)post {
    
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/post/%ld/", (long)post.identifier]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager DELETE:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //POST WAS DELETED
        [self.delegate didDeletePost];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST WAS NOT DELETED
        NSLog(@"Error: %@", error);
        
    }];
}


/////////////////
// UPDATE POST //
/////////////////
-(void) updatePostForPost:(Post*)post image:(UIImage*) postImage description:(NSString*) description tags:(NSArray*) tags pastel:(NSInteger)pastel
{
    NSString *base64PhotoString = [UIImagePNGRepresentation(postImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/post/%ld/", (long)post.identifier]];
    NSURL *url = [self.urlBuilder URL];
    
    NSDictionary *params = @{
                             @"imagePathString": base64PhotoString,
                             //                             @"labels": labels,
                             @"description":description,
                             //                             @"tags": tags
                             @"user": [NSString stringWithFormat:@"/api/v1/user/%@/", [NSNumber numberWithInteger:self.user.identifier]],
                             @"pastel": [NSNumber numberWithInteger:pastel],
                             };
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager PATCH:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *post) {
        
        if(post)
        {
            [self.delegate didUpdatePost:[[Post alloc] initWithJSON:post]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST WAS NOT DELETED
        NSLog(@"Error: %@", error);
        
    }];
}



/////////////////
// LIKE A POST //
/////////////////
-(void) likePostWithId:(NSInteger)postId{
    
    [self.urlBuilder setPath:@"/api/v1/like/"];
    
    NSURL *url = [self.urlBuilder URL];
    
    NSDictionary *params = @{
                             @"user": [NSString stringWithFormat:@"/api/v1/user/%d/",self.user.identifier],
                             @"post": [NSString stringWithFormat:@"/api/v1/post/%@/",[NSNumber numberWithInteger:postId]],
                             @"postId": [NSNumber numberWithInteger:postId],
                             };
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* response) {
        
        //POST WAS LIKED
        NSDictionary *post = [response objectForKey:@"post"];
        if([post count]){
            [self.delegate didLikePost:[[Post alloc] initWithJSON:post]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST WAS NOT LIKED
        NSLog(@"Error: %@", error);
        
    }];
}



/////////////////////
// COMMENT ON POST //
/////////////////////
-(void) commentOnPostWithId:(NSInteger) postId comment:(NSString*) comment
{
    [self.urlBuilder setPath:@"/api/v1/comment/"];
    NSURL *url = [self.urlBuilder URL];
    
    NSDictionary *params = @{
                             @"user": [NSString stringWithFormat:@"/api/v1/user/%d/",self.user.identifier],
                             @"content":comment,
                             @"post":[NSString stringWithFormat:@"/api/v1/post/%@/",[NSNumber numberWithInteger:postId]],
                             @"postId": [NSNumber numberWithInteger:postId],
                             };
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* response) {
        
        NSDictionary *post = [response objectForKey:@"post"];
        if([post count]){
            
            [self.delegate didCommentOnPost:[[Post alloc] initWithJSON:post]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}


////////////////////
// DELETE COMMENT //
////////////////////
-(void) deleteCommentWithId:(NSInteger)commentId;
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/comment/%ld/", (long)commentId]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager DELETE:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //COMMENT WAS DELETED
        [self.delegate didDeleteComment];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //COMMENT WAS NOT DELETED
        NSLog(@"Error: %@", error);
        
    }];
}


/////////////////
// FOLLOW USER //
/////////////////
-(void) followUserWithId:(NSInteger) userId
{
    [self.urlBuilder setPath:@"/api/v1/relationship/"];
    NSURL *url = [self.urlBuilder URL];
    NSNumber *follower = [NSNumber numberWithInteger:self.user.identifier];
    NSNumber *following = [NSNumber numberWithInteger:userId];
    NSDictionary *params = @{
                             @"follower": [NSString stringWithFormat:@"api/v1/user/%@/",follower],
                             @"following": [NSString stringWithFormat:@"api/v1/user/%ld/",(long)userId],
                             @"followingId": following,
                             @"follow_date": @"pie",
                             };
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        User *user = [[User alloc] initWithJSON:[responseObject objectForKey:@"following"]];
        [self.profileDelegate didFollowUser:user];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //USER WAS UNFOLLOWED
        NSLog(@"Error: %@", error);
        
    }];
}



///////////////////
// UNFOLLOW USER //
///////////////////
-(void) unfollowUserWithId:(NSInteger) userId
{
    [self.urlBuilder setPath:@"/api/v1/relationship/"];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSNumber *following = [NSNumber numberWithInteger:userId];

    [manager DELETE:[url absoluteString] parameters:@{@"following_id":@(userId), @"follower_id":@(self.user.identifier),@"followingId":following} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self.profileDelegate didUnfollowUser];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //USER WAS UNFOLLOWED
        NSLog(@"Error: %@", error);
        
    }];
}


////////////////////////
// CHECK IF FOLLOWING //
////////////////////////
-(void) checkIfFollowingUserWithId:(NSInteger) userId
{
    [self.urlBuilder setPath:@"/api/v1/relationship/"];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:@{@"following_id":@(userId), @"follower_id":@(self.user.identifier)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *relationships = [responseObject objectForKey:@"objects"];
        if (relationships.count)
        {
            [self.profileDelegate doesFollowUser];
        }
        else
        {
            [self.profileDelegate doesNotFollowUser];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //USER WAS UNFOLLOWED
        NSLog(@"Error: %@", error);
        
    }];
}

//////////////////
// CREATE LABEL //
//////////////////
-(void)createLabelWithPost:(Post*)post positionX:(NSInteger)positionX positionY:(NSInteger)positionY angle:(NSInteger)angle colour:(NSString*)colour name:(NSString*)name description:(NSString*)description link:(NSString*)link image:(UIImage*)image
{
    // This is really hacky.
    NSString *base64PhotoString = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [self.urlBuilder setPath:@"/api/v1/label/"];
    NSURL *url = [self.urlBuilder URL];
    
    NSDictionary *params = @{
                             @"imagePathString": base64PhotoString,
                             @"description":description,
                             @"post": [NSString stringWithFormat:@"/api/v1/post/%@/", [NSNumber numberWithInteger:post.identifier]],
                             @"x": [NSNumber numberWithInt:positionX],
                             @"y": [NSNumber numberWithInt:positionY],
                             @"angle": [NSNumber numberWithInt:angle],
                             @"colour": colour,
                             @"name": name,
                             @"description": description,
                             @"link": link
                             };
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *label) {
        
        
        if(label)
        {
            [self.delegate didCreateLabel:[[Label alloc] initWithJSON:label]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST FAILED TO CREATE
        NSLog(@"Error: %@", error);
        
    }];
}


////////////////////////
// GET LABEL FOR POST //
////////////////////////
-(void) getLabelsForPost:(Post*)post
{
    
    
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/post/%d/",post.identifier]];
    NSURL *url = [self.urlBuilder URL];
    
    
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *post) {
        
        
        NSArray *labels = [[NSArray alloc] init];
        labels = [post objectForKey:@"labels"];
        if(labels.count)
        {
            [self.delegate didGetLabelsForPost:labels];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST FAILED TO CREATE
        NSLog(@"Error: %@", error);
        
    }];
}

//////////////////////
// GET LABEL FOR ID //
//////////////////////
-(void) getLabelForId:(NSInteger)labelId
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/label/%d/",labelId]];
    NSURL *url = [self.urlBuilder URL];
    
    
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *label) {
        
        
        if(label)
        {
            [self.delegate didGetLabel:[[Label alloc] initWithJSON:label]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST FAILED TO CREATE
        NSLog(@"Error: %@", error);
        
    }];
}


/////////////////////////
// GET LABEL FOR LABEL //
/////////////////////////
-(void) getLabel:(Label*)label
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/label/%ld/",(long)label.identifier]];
    NSURL *url = [self.urlBuilder URL];
    
    
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *label) {
        
        
        if(label)
        {
            [self.delegate didGetLabel:[[Label alloc] initWithJSON:label]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //POST FAILED TO CREATE
        NSLog(@"Error: %@", error);
        
    }];
}

//////////////////
// DELETE LABEL //
//////////////////
-(void) deleteLabel:(Label*)label
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/label/%ld/", (long)label.identifier]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager DELETE:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //COMMENT WAS DELETED
        [self.delegate didDeleteComment];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //COMMENT WAS NOT DELETED
        NSLog(@"Error: %@", error);
        
    }];
}

///////////////////////
// GET NOTIFICATIONS //
///////////////////////
-(void) getNotifications
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/notification/?user__id=%ld",(long)[[self user] identifier]]];
    NSURL *url = [self.urlBuilder URL];
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NOTIFICATIONS WERE RECEIVED
        NSLog(@"Success");
        NSArray *notifications = responseObject;
        [self.delegate didGetNotifications:notifications];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NOTIFICATIONS WERE NOT RECEIVED
        NSLog(@"Error: %@", error);
        
    }];
}



////////////////////////////
// SET NOTIFICATION STATE //
////////////////////////////
-(void) setStateOfNotificationWithId:(NSInteger) notificationId state:(VestiumNotificationState) state
{
    [self.urlBuilder setPath:[NSString stringWithFormat:@"/api/v1/notification/%ld/",(long)notificationId]];
    NSURL *url = [self.urlBuilder URL];
    
    NSDictionary *params = @{@"state": [NSString stringWithFormat:@"%d",state]};
    
    AFHTTPRequestOperationManager *manager = [[ AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager PATCH:[url absoluteString] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NOTIFICATIONS WERE RECEIVED
        NSLog(@"Success");
        [self.delegate didSetNotificationState];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NOTIFICATIONS WERE NOT RECEIVED
        NSLog(@"Error: %@", error);
        
    }];
}
-(void) createNotification:(VestiumNotificationType)type
{
    
}

//////////////////////////////
// SINGLETON DESIGN PATTERN //
//////////////////////////////
+ (instancetype) singleton {
    static id singletonInstance = nil;
    if (!singletonInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singletonInstance = [[super allocWithZone:NULL] init];
        });
    }
    return singletonInstance;
}

+ (id) allocWithZone:(NSZone *)zone {
    return [self singleton];
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

@end
