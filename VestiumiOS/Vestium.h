//
//  Vestium.h
//  Vestium
//
//  Created by Daniel Koehler on 23/07/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "User.h"
#import "Label.h"
#import "Post.h"

typedef NS_ENUM(NSInteger, VestiumNotificationState)
{
    VestiumNotificationStateUnread,
    VestiumNotificationStateRead,
    VestiumNotificationStateSeen,
};

typedef NS_ENUM(NSInteger, VestiumNotificationType) {
    CommentOnPost,
    LikePost,
    NewFollower,
    
};

@protocol VestiumMenuDelegate <NSObject>

-(void) updateMenuWithUser:(User *) user;

@end

@protocol VestiumProfileDelegate <NSObject>
@optional
-(void) didGetProfileUser:(User*)user;
-(void) didGetPostsForUser:(NSArray*)posts;
-(void) didFollowUser:(User*)user;
-(void) didUnfollowUser;
-(void) doesFollowUser;
-(void) doesNotFollowUser;
@end

@protocol VestiumUserDelegate <NSObject>
@optional
-(void) didCreateUser:(User*)user password:(NSString*)password;
-(void) didLoginUser:(User*)user;
-(void) didGetUser:(User*)user;
-(void) didUpdateUser:(User*)user;
-(void) didVerifyUsernameAvailability:(NSString*)username;


-(void) didNotVerfiyUsername:(NSString*)username;
-(void) didNotCreateUser:(User *)user;
-(void) didNotLoginUser:(User *)user;

@end
@protocol VestiumPostDelegate <NSObject>
@optional
-(void) didGetTrendingPosts:(NSArray*)posts;
-(void) didGetFeedPosts:(NSArray*)posts;
-(void) didCreatePost:(Post*)post;
-(void) didGetPostsForUser:(NSArray*)posts;
-(void) didGetPost:(Post*)post;
-(void) didLikePost:(Post*)post;
-(void) didFlagPost:(Post*)post;
-(void) didDeletePost;
-(void) didCommentOnPost:(Post*)post;
-(void) didDeleteComment;
-(void) didUpdatePost:(Post*)post;
@end

@protocol VestiumLabelDelegate <NSObject>
@optional
-(void) didCreateLabel:(Label*)label;
-(void) didGetLabelsForPost:(NSArray*)labels;
-(void) didGetLabel:(Label*)label;
-(void) didDeleteLabel:(Label*)label;
@end

@protocol VestiumNotificationDelegate <NSObject>
@optional
-(void) didGetNotifications:(NSArray*)notifications;
-(void) didSetNotificationState;

@end

@interface Vestium : NSObject

@property NSURLCredential *accessToken;
@property NSURLCredential *refreshToken;
@property NSDate *expires;
@property User* user;
@property NSURLComponents *urlBuilder;

@property (strong, nonatomic) id<VestiumUserDelegate, VestiumPostDelegate, VestiumLabelDelegate, VestiumNotificationDelegate, VestiumProfileDelegate> delegate;

@property (strong, nonatomic) id<VestiumMenuDelegate> menuDelegate;
@property (strong, nonatomic) id<VestiumPostDelegate, VestiumUserDelegate> trendingDelegate;
@property (strong, nonatomic) id<VestiumProfileDelegate> profileDelegate;


//URL contructing methods

+(NSURL*) urlWithPathComponent:(NSString*) path;

// [Register, Login, Update, Verify, Delete]
// User

-(void) registerUserWithFirstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email username:(NSString*)username password:(NSString*)password image:(UIImage*)image;// DONE & TESTED //

-(void) loginUserWithUsername:(NSString*) username password:(NSString*) password;


-(void) updateUserWithFirstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email image:(UIImage*)image;

-(void) verifyUsernameAvalibilty:(NSString *) username;

-(void) getUser:(User*) user;

-(void) getUserForId:(NSInteger) userId;


-(void) getFeedPostArrayForUser:(User*)user;

-(void) createPostWithImage:(UIImage*) postImage description:(NSString*) description tags:(NSArray*) tags pastel:(NSInteger)pastel;
-(void) deletePost:(Post*)post;
-(void) getPostsForUserId:(NSInteger) userId;
-(void) getPostForPostId:(NSInteger) postId;
-(void) updatePostForPost:(Post*)post image:(UIImage*) postImage description:(NSString*) description tags:(NSArray*) tags pastel:(NSInteger)pastel;

-(void) likePostWithId:(NSInteger) postId;

-(void) commentOnPostWithId:(NSInteger) postId comment:(NSString*) comment;
-(void) deleteCommentWithId:(NSInteger)commentId;

-(void) followUserWithId:(NSInteger) userId;
-(void) unfollowUserWithId:(NSInteger) userId;


-(void)createLabelWithPost:(Post*)post positionX:(NSInteger)x positionY:(NSInteger)positionY angle:(NSInteger)angle colour:(NSString*)colour name:(NSString*)name description:(NSString*)description link:(NSString*)link image:(UIImage*)image;
-(void) getLabelsForPost:(Post*)post;
-(void) getLabelForId:(NSInteger)labelId;
-(void) getLabel:(Label*)label;-(void) deleteLabel:(Label*)label;
-(void) getProfileUserForId:(NSInteger) userId;


// Still to implement
-(void) checkIfFollowingUserWithId:(NSInteger) userId;
-(void) getNotifications;
-(void) setStateOfNotificationWithId:(NSInteger) notificationId state:(VestiumNotificationState) state;
-(void) createNotification:(VestiumNotificationType)type;
-(void) getTrendingPostArray;

@end
