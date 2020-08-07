//
//  LZDefaultsHelper.h
//  Pods
//
//  Created by Dear.Q on 16/7/24.
//
//

#import <Foundation/Foundation.h>

#define LZDefaults [LZDefaultsHelper sharedDefaultsHelper]

#define LZDefaultsSetValueForKey(value, defaultsName) \
[LZDefaults setObject:value forKey:defaultsName]

#define LZDefaultsValueForKey(defaultsName) \
[LZDefaults objectForKey:defaultsName]

#define LZDefaultsRemoveValueForKey(defaultsName) \
[LZDefaults removeValueForKey:defaultsName];

NS_ASSUME_NONNULL_BEGIN

/** 监听回调 */
typedef void(^LZDefaultsKVOHandler)(id oldValue, id newValue);

@interface LZDefaultsHelper : NSObject

/**
 实例

 @return LZDefaultsHelper
 */
+ (instancetype)sharedDefaultsHelper;

/**
@author Lilei

@brief 保存用户偏好设置

@param object      NSString, NSData, NSNumber, NSDate, NSArray, and NSDictionary
@param defaultName identifie
*/
- (void)setObject:(id)object forKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将 NSInteger 转换成 NSNumber，保存到用户偏好设置
 
 @param value       BOOL
 @param defaultName identifie
 */
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将 float 转换成 NSNumber，保存到用户偏好设置
 
 @param value       BOOL
 @param defaultName identifie
 */
- (void)setFloat:(float)value forKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将 double 转换成 NSNumber，保存到用户偏好设置
 
 @param value       BOOL
 @param defaultName identifie
 */
- (void)setDouble:(double)value forKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将 BOOL 转换成 NSString，保存到用户偏好设置
 
 @param value       BOOL
 @param defaultName identifie
 @remark            @"1" : YES; @"0" : NO.
 */
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将 NSUR 归档成 NSData，保存到用户偏好设置
 
 @param url         NSURL
 @param defaultName identifie
 */
- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 获取用户偏好设置中 defaultName 对应的值
 
 @param defaultName identifie
 
 @return NSString, NSData, NSNumber, NSDate, NSArray, and NSDictionary
 */
- (id)objectForKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将用户偏好号 defaultName 对应的值转为 NSInteger 类型
 
 @param defaultName identifie
 
 @return NSInteger
 */
- (NSInteger)integerForKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将用户偏好号 defaultName 对应的值转为 float 类型
 
 @param defaultName identifie
 
 @return float
 */
- (float)floatForKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将用户偏好号 defaultName 对应的值转为 double 类型
 
 @param defaultName identifie
 
 @return double
 */
- (double)doubleForKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 将用户偏好号 defaultName 对应的值转为 BOOL 类型
 
 @param defaultName identifie
 
 @return BOOL
 */
- (BOOL)boolForKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 获取 setURL:forKey 保存的 URL
 
 @param defaultName identifie
 
 @return NSURL
 */
- (NSURL *)URLForKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 移除用户设置中 defaultName 项
 
 @param defaultName identifie
 */
- (void)removeValueForKey:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 批量移除用户设置中 defaultName 项
 
 @param defaultNames defaultName 数组
 */
- (void)removeValuesForKeys:(NSArray *)defaultNames;

/**
 @author Lilei
 
 @brief 设置 UserDefautls 的默认值
 @remark 默认的数据是不会被保存到 plist 文件中的，我们需要手动变更这些数据然后保存。
 
 @param registrationDictionary 默认值为字典类型
 */
- (void)registerDefaults:(NSDictionary<NSString *, id> *)registrationDictionary;


/**
 @author Lilei
 
 @brief 添加键值变化的监听

 @param defaultName identifie
 @remark 不需要监听时，必须手动调用 removeObserver:forDefaultName: 移除
 */
- (void)addObserver:(NSObject *)observer forDefaultName:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 移除键值变化的监听

 @param observer 监听者
 @param defaultName identifie
 */
- (void)removeObserver:(NSObject *)observer forDefaultName:(NSString *)defaultName;

/**
 @author Lilei
 
 @brief 监听键值的变化

 @param defaultName identifie
 @param completionHandler 监听回调
 */
- (void)observeValueForDefaultName:(NSString *)defaultName
				 completionHandler:(LZDefaultsKVOHandler)completionHandler;

/**
 @author Lilei
 
 @brief 移除监听的回调

 @param defaultName identifie
 */
- (void)removeObserverHandlerForDefaultName:(NSString *)defaultName;

@end

NS_ASSUME_NONNULL_END
