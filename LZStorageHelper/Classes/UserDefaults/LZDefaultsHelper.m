//
//  LZDefaultsHelper.m
//  Pods
//
//  Created by Dear.Q on 16/7/24.
//
//

#import "LZDefaultsHelper.h"

@interface _LZDefaultsKVOWeakObserver : NSObject

/** 记录监听回调 */
@property (nonatomic, copy) LZDefaultsKVOHandler KVOHandler;


/**
 实例
 
 @param KVOHandler LZDefaultsKVOHandler
 @return _LZDefaultsKVOWeakObserver
 */
- (id)initWithBlock:(LZDefaultsKVOHandler)KVOHandler;

@end

@implementation _LZDefaultsKVOWeakObserver

/** 实例 */
- (id)initWithBlock:(LZDefaultsKVOHandler)KVOHandler {
	
	self = [super init];
	if (self) {
		self.KVOHandler = KVOHandler;
	}
	return self;
}

// MARK - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if (!self.KVOHandler) return;

	BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
	if (isPrior) return;
	
	NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
	if (changeKind != NSKeyValueChangeSetting) return;
	
	id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
	if (oldVal == [NSNull null]) oldVal = nil;
	
	id newVal = [change objectForKey:NSKeyValueChangeNewKey];
	if (newVal == [NSNull null]) newVal = nil;
	
	self.KVOHandler(oldVal, newVal);
}

@end

@interface LZDefaultsHelper()

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableDictionary *userDefaultsObserverHandlers;

@end

@implementation LZDefaultsHelper

#pragma mark - -> LazyLoading
- (NSUserDefaults *)userDefaults {
    if (nil == _userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}

- (NSMutableDictionary *)userDefaultsObserverHandlers {
	if (nil == _userDefaultsObserverHandlers) {
		_userDefaultsObserverHandlers = [NSMutableDictionary dictionary];
	}
	return _userDefaultsObserverHandlers;
}

#pragma mark - -> Public
/** 实例 */
+ (instancetype)sharedDefaultsHelper {
	
	static LZDefaultsHelper *_instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[LZDefaultsHelper alloc] init];
	});
	return _instance;
}

/** 保存用户偏好设置 */
- (void)setObject:(id)object forKey:(NSString *)defaultName {
	
    [self.userDefaults setObject:object forKey:defaultName];
    [self.userDefaults synchronize];
}

/** 将 NSInteger 转换成 NSNumber，保存到用户偏好设置 */
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
	
    [self.userDefaults setInteger:value forKey:defaultName];
    [self.userDefaults synchronize];
}

/** 将 float 转换成 NSNumber，保存到用户偏好设置 */
- (void)setFloat:(float)value forKey:(NSString *)defaultName {
	
    [self.userDefaults setFloat:value forKey:defaultName];
    [self.userDefaults synchronize];
}

/** 将 double 转换成 NSNumber，保存到用户偏好设置 */
- (void)setDouble:(double)value forKey:(NSString *)defaultName {
	
    [self.userDefaults setDouble:value forKey:defaultName];
    [self.userDefaults synchronize];
}

/** 将 BOOL 转换成 NSString，保存到用户偏好设置 */
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    [self.userDefaults setObject:value ? @"1" : @"0" forKey:defaultName];
}

/** 将 NSUR 归档成 NSData，保存到用户偏好设置 */
- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName {
	
    [self.userDefaults setURL:url forKey:defaultName];
    [self.userDefaults synchronize];
}

/** 获取用户偏好设置 */
- (id)objectForKey:(NSString *)defaultName {
	
    id  object = [self.userDefaults objectForKey:defaultName];
    return object;
}

/** 将用户偏好号 defaultName 对应的值转为 NSInteger 类型 */
- (NSInteger)integerForKey:(NSString *)defaultName {
    return [self.userDefaults integerForKey:defaultName];
}

/** 将用户偏好号 defaultName 对应的值转为 float 类型 */
- (float)floatForKey:(NSString *)defaultName {
    return [self.userDefaults floatForKey:defaultName];
}

/** 将用户偏好号 defaultName 对应的值转为 double 类型 */
- (double)doubleForKey:(NSString *)defaultName {
    return [self.userDefaults doubleForKey:defaultName];
}

/** 将用户偏好号 defaultName 对应的值转为 BOOL 类型 */
- (BOOL)boolForKey:(NSString *)defaultName {

    id value = [self.userDefaults objectForKey:defaultName];
    if ([value isKindOfClass:[NSString class]]) {
        return [value isEqualToString:@"1"] ? YES : NO;
    } else {
        return value ? YES : NO;
    }
}

/**  获取 setURL:forKey 保存的 URL */
- (NSURL *)URLForKey:(NSString *)defaultName {
    return [self.userDefaults URLForKey:defaultName];
}

/** 移除用户设置中 defaultName 项 */
- (void)removeValueForKey:(NSString *)defaultName {
    [self.userDefaults removeObjectForKey:defaultName];
}

/** 移除用户设置中 defaultName 项 */
- (void)removeValuesForKeys:(NSArray *)defaultNames {
	
    __weak typeof(self) weakSelf = self;
    [defaultNames enumerateObjectsUsingBlock:
	 ^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf removeValueForKey:key];
    }];
}

/** 设置UserDefautls的默认值 */
- (void)registerDefaults:(NSDictionary<NSString *,id> *)registrationDictionary {
    NSAssert(registrationDictionary && [registrationDictionary isKindOfClass:[NSDictionary class]], @"registrationDictionary 不能为nil或非字典类型");
    [self.userDefaults registerDefaults:registrationDictionary];
}

/** 添加键值变化的监听 */
- (void)addObserver:(NSObject *)observer forDefaultName:(NSString *)defaultName {
	[self.userDefaults addObserver:observer
						forKeyPath:defaultName
						   options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
						   context:NULL];
}

/** 移除键值变化的监听 */
- (void)removeObserver:(NSObject *)observer forDefaultName:(NSString *)defaultName {
	[self.userDefaults removeObserver:observer forKeyPath:defaultName];
}

/** 监听键值的变化 */
- (void)observeValueForDefaultName:(NSString *)defaultName
				 completionHandler:(LZDefaultsKVOHandler)completionHandler {
	if (!defaultName || !completionHandler) return;
	_LZDefaultsKVOWeakObserver *target = [[_LZDefaultsKVOWeakObserver alloc] initWithBlock:completionHandler];
	
	NSMutableArray *arrM = self.userDefaultsObserverHandlers[defaultName];
	if (nil == arrM) {
		
		arrM = [NSMutableArray new];
		self.userDefaultsObserverHandlers[defaultName] = arrM;
	}
	[arrM addObject:target];
	[self.userDefaults addObserver:target
						forKeyPath:defaultName
						   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
						   context:NULL];
}

/** 移除监听的回调 */
- (void)removeObserverHandlerForDefaultName:(NSString *)defaultName {
	if (nil == defaultName) return;
	NSMutableArray *arrM = self.userDefaultsObserverHandlers[defaultName];;
	[arrM enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
		[self.userDefaults removeObserver:obj forKeyPath:defaultName];
	}];
	
	[self.userDefaultsObserverHandlers removeObjectForKey:defaultName];
}

/** 移除所有监听的回调 */
- (void)dealloc {
	[self.userDefaultsObserverHandlers enumerateKeysAndObjectsUsingBlock:
	 ^(NSString *key, NSMutableArray *arrM, BOOL *stop) {
		[arrM enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
			[self.userDefaults removeObserver:obj forKeyPath:key];
		}];
	}];

	[self.userDefaultsObserverHandlers removeAllObjects];
}

@end
