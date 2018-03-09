//
//  SBDBaseMessage.h
//  SendBirdSDK
//
//  Created by Jed Gyeong on 5/30/16.
//  Copyright © 2016 SENDBIRD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBDUser.h"

@class SBDBaseChannel;

/**
 *  The `SBDBaseMessage` class represents the base message which is generated by a user or an admin. The `SBDUserMessage`, the `SBDFileMessage` and the `SBDAdminMessage` are derived from this class.
 */
@interface SBDBaseMessage : NSObject

/**
 *  Unique message ID.
 */
@property (atomic) long long messageId;

/**
 *  Channel URL which has this message.
 */
@property (strong, nonatomic, nullable) NSString *channelUrl;

/**
 *  Channel type of this message.
 */
@property (strong, nonatomic, nullable) NSString *channelType;

/**
 *  The list of users who was mentioned together with the message.
 *
 *  @since 3.0.90
 */
@property (strong, nonatomic, readonly, nullable) NSArray <SBDUser *> *mentionedUsers;

/**
 *  Message created time in millisecond(UTC).
 */
@property (atomic) long long createdAt;

/**
 Message updated time in millisecond(UTC).
 */
@property (atomic) long long updatedAt;

/**
 *  Initializes a message object.
 *
 *  @param dict Dictionary data for a message.
 *
 *  @return SBDBaseMessage object.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Internal use only.
 */
+ (nullable SBDBaseMessage *)buildWithDictionary:(NSDictionary * _Nonnull)dict;

/**
 *  Internal use only.
 */
+ (nullable SBDBaseMessage *)buildWithDictionary:(NSDictionary * _Nonnull)dict channel:(SBDBaseChannel * _Nonnull)channel;

/**
 *  Internal use only.
 */
+ (nullable SBDBaseMessage *)buildWithData:(NSString * _Nonnull)data;

/**
 *  Checks the channel type is open channel or not.
 *
 *  @return Returns YES, when this is open channel.
 */
- (BOOL)isOpenChannel;

/**
 *  Checks the channel type is group channel or not.
 *
 *  @return Returns YES, when this is group channel.
 */
- (BOOL)isGroupChannel;

/**
 Builds a message object from serialized <span>data</span>.
 
 @param data Serialized <span>data</span>.
 @return SBDBaseMessage object.
 */
+ (nullable instancetype)buildFromSerializedData:(NSData * _Nonnull)data;

/**
 Serializes message object.
 
 @return Serialized <span>data</span>.
 */
- (nullable NSData *)serialize;

/**
 *  Internal use only.
 */
- (nullable NSDictionary *)_toDictionary;

@end
