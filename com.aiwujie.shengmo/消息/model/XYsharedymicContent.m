//
//  XTsharedymicContent.m
//  ShengmoApp
//
//  Created by 王俊钢 on 2019/7/29.
//  Copyright © 2019 a. All rights reserved.
//

#import "XYsharedymicContent.h"

static NSString *ServiceShare_SinaWeibo = @"ServiceShare_SinaWeibo";

@implementation XYsharedymicContent
/// NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.Newid = [aDecoder decodeObjectForKey:@"Newid"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.icon = [aDecoder decodeObjectForKey:@"icon"];
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
    }
    return self;
}

/// NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.Newid forKey:@"Newid"];
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
}

+ (instancetype)messageWithDict:(NSDictionary *)dict
{
    XYsharedymicContent *msg = [[XYsharedymicContent alloc] init];
    msg.Newid = [dict objectForKey:@"Newid"];
    msg.content = [dict objectForKey:@"content"];
    msg.icon = [dict objectForKey:@"icon"];
    msg.userId = [dict objectForKey:@"userId"];
    return msg;
}

///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}


#pragma mark - RCMessageCoding

/*!
 将消息内容序列化，编码成为可传输的json数据
 
 @discussion
 消息内容通过此方法，将消息中的所有数据，编码成为json数据，返回的json数据将用于网络传输。
 */

///将消息内容编码成json
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];

    [dataDict setObject:self.Newid forKey:@"Newid"];
    [dataDict setObject:self.content forKey:@"content"];
    [dataDict setObject:self.icon forKey:@"icon"];
    [dataDict setObject:self.userId forKey:@"userId"];
    if (self.senderUserInfo) {
        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
        if (self.senderUserInfo.name) {
            [userInfoDic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [userInfoDic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"portrait"];
        }
        if (self.senderUserInfo.userId) {
            [userInfoDic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
        }
        [dataDict setObject:userInfoDic forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

/*!
 将json数据的内容反序列化，解码生成可用的消息内容
 
 @param data    消息中的原始json数据
 
 @discussion
 网络传输的json数据，会通过此方法解码，获取消息内容中的所有数据，生成有效的消息内容。
 */
- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dictionary) {
            self.Newid = [dictionary objectForKey:@"Newid"];
            self.content = [dictionary objectForKey:@"content"];
            self.icon = [dictionary objectForKey:@"icon"];
            self.userId = [dictionary objectForKey:@"userId"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
    }
}
/*!
 返回消息的类型名
 
 @return 消息的类型名
 
 @discussion 您定义的消息类型名，需要在各个平台上保持一致，以保证消息互通。
 
 @warning 请勿使用@"RC:"开头的类型名，以免和SDK默认的消息名称冲突
 */
+ (NSString *)getObjectName
{
    return ServiceShare_SinaWeibo;
}

#pragma mark - RCMessagePersistentCompatible

/*!
 返回在会话列表和本地通知中显示的消息内容摘要
 
 @return 会话列表和本地通知中显示的消息内容摘要
 
 @discussion
 如果您使用IMKit，当会话的最后一条消息为自定义消息时，需要通过此方法获取在会话列表展现的内容摘要；
 当App在后台收到消息时，需要通过此方法获取在本地通知中展现的内容摘要。
 */
- (NSString *)conversationDigest
{
    return @"hi,给你推荐一个动态";
}

@end
