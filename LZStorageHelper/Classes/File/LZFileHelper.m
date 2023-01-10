//
//  LZFileHelper.m
//  Pods
//
//  Created by Dear.Q on 16/7/24.
//
//

#import "LZFileHelper.h"

@implementation LZFileHelper

#pragma mark - -> Initialization
/** 唯一实例 */
+(instancetype)sharedFileHelper {
    
    static LZFileHelper *_instace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[LZFileHelper alloc] init];
    });
    return _instace;
}

#pragma mark - -> Public
/** 判断文件或文件夹是否存在 */
- (BOOL)isExistAtPath:(NSString*)filePath {
    return [self existAtPath:filePath isDirectory:nil];
}

/** 判断是否是文件 */
- (BOOL)isFileAtPath:(NSString *)atPath {
    
    BOOL isDirectory;
    [self existAtPath:atPath isDirectory:&isDirectory];
    return !isDirectory;
}

/** 判断是否是文件夹*/
- (BOOL)isDirectoryAtPath:(NSString *)atPath {
    
    BOOL isDirectory;
    [self existAtPath:atPath isDirectory:&isDirectory];
    return isDirectory;
}

/** 计算指定路径的文件或文件的大小 */
- (unsigned long long)sizeAtPath:(NSString *)atPath {
    
    BOOL isDirectory;
    BOOL isExist = [self existAtPath:atPath isDirectory:&isDirectory];
    if (!isExist) return 0.0;
    if (isDirectory) return [self folderSizeAtPath:atPath];
    else return [self fileSizeAtPath:atPath];
}

/** 获取指定的目录 */
- (NSString *)directoryPath:(NSSearchPathDirectory)searchPathDirectory {
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSUserDomainMask, YES) lastObject];
    return path;
}

/** 创建文件夹到指定的沙盒目录 */
- (BOOL)createDirectory:(NSString *)directory
           toSearchPath:(NSSearchPathDirectory)searchPathDirectory {
    if (nil == directory || 0 == directory.length) {
#if DEBUG
        NSLog(@"目录名称不能为空");
#endif
        return NO;
    }
    NSString *directoryPath = [self directoryPath:searchPathDirectory];
    directoryPath = [directoryPath stringByAppendingPathComponent:directory];
    return [self createFolder:directoryPath];
}

/** 保存文件到指定的目录 */
- (BOOL)saveFileData:(NSData *)fileData
                name:(NSString *)fileName
              toPath:(NSString *)toPath {
    if (nil == fileData || 0 == fileData.length) {
#if DEBUG
        NSLog(@"文件 Data 不能为空");
#endif
        return NO;
    }
    if (nil == fileName || 0 == fileName.length) {
#if DEBUG
        NSLog(@"文件名不能空");
#endif
        return NO;
    }
    if (nil == toPath || 0 == toPath.length) {
#if DEBUG
        NSLog(@"文件路径不能空");
#endif
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![self isExistAtPath:toPath])
        [fileManager createDirectoryAtPath:toPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    NSString *fullPath = [toPath stringByAppendingPathComponent:fileName];
    BOOL flag = [fileData writeToFile:fullPath atomically:YES];
    if (flag) LZStorageLog(@"文件保存成功，路径%@", fullPath);
    return flag;
}

/** 获取指定的文件 NSData类型 */
- (NSData *)takeFile:(NSString *)filePath
               error:(NSError *__autoreleasing *)error {
    
    NSData *data = nil;
    if (nil == filePath || filePath.length == 0) {
        if (nil != error) {
            
            NSMutableDictionary *userInfoDictM = [NSMutableDictionary dictionary];
            [userInfoDictM setObject:@"文件不存在!" forKey:NSLocalizedDescriptionKey];
            [userInfoDictM setObject:@"输入正确的文件路径!" forKey:NSLocalizedFailureReasonErrorKey];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileReadNoSuchFileError
                                     userInfo:[userInfoDictM copy]];
        }
        return data;
    }
    BOOL isDirectory;
    BOOL isExist = [self existAtPath:filePath isDirectory:&isDirectory];
    if (!isExist) {
        if (nil != error) {
            
            NSMutableDictionary *userInfoDictM = [NSMutableDictionary dictionary];
            [userInfoDictM setObject:@"文件不存在!" forKey:NSLocalizedDescriptionKey];
            [userInfoDictM setObject:@"输入的文件路径不存在!" forKey:NSLocalizedFailureReasonErrorKey];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileReadNoSuchFileError
                                     userInfo:[userInfoDictM copy]];
        }
        return data;
    }
    if (isDirectory) {
        if (nil != error) {
            
            NSMutableDictionary *userInfoDictM = [NSMutableDictionary dictionary];
            [userInfoDictM setObject:@"文件不存在!" forKey:NSLocalizedDescriptionKey];
            [userInfoDictM setObject:@"输入路径是文件夹路径!" forKey:NSLocalizedFailureReasonErrorKey];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileReadInvalidFileNameError
                                     userInfo:[userInfoDictM copy]];
        }
        return data;
    }
    data = [NSData dataWithContentsOfFile:filePath
                                  options:NSDataReadingMappedIfSafe
                                    error:error];
    return data;
}

/** 删除文件或文件夹 */
- (BOOL)deleteAtPath:(NSString *)filePath {
    // 文件或文件夹路径为空
    if (nil == filePath || 0 == filePath.length) {
        return YES;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [self isExistAtPath:filePath];
    // 文件或文件夹不存在
    if (NO == exist) {
        return YES;
    }
    NSError *error;
    BOOL isSuccess = [fileManager removeItemAtPath:filePath error:&error];
    if (NO == isSuccess) {
        LZStorageLog(@"删除文件或文件夹失败:%@", error.localizedDescription);
    }
    return isSuccess;
}

/** 移动文件或文件夹 */
- (BOOL)moveFromPath:(NSString *)fromPath
              toPath:(NSString *)toPath
           isCovered:(BOOL)isCovered {
    
    BOOL isDirectory;
    BOOL isExist = [self existAtPath:fromPath isDirectory:&isDirectory];
    if (!isExist) return NO;
    if (isDirectory) return [self moveFolderFromPath:fromPath
                                              toPath:toPath
                                           isCovered:isCovered];
    else return [self moveFileFromPath:fromPath
                                toPath:toPath
                             isCovered:isCovered];
}

/** 重命名文件或文件夹 */
- (BOOL)renameAtPath:(NSString *)atPath
             newName:(NSString *)newName {
    // 构造新的目标路径
    NSString *oldPath = [atPath stringByDeletingLastPathComponent];
    NSString *newPath = [oldPath stringByAppendingPathComponent:newName];
    
    // 移动文件到新文件夹，并删除旧文件夹
    BOOL mSuccess = [self moveFromPath:atPath toPath:newPath isCovered:YES];
    BOOL dSuccess = [self deleteAtPath:atPath];
    return mSuccess && dSuccess;
}

/** 获取指定目录下的所有文件，包括子目录下的文件 */
- (NSArray<NSString *> *)takeAllFilePathFromDirectory:(NSString *)fromDirectory {
    
    NSMutableArray *fileArrM = [NSMutableArray new];
    [self takeFileFromPath:fromDirectory
               storeToArrM:&fileArrM
       includeSubDirectory:YES];
    return [fileArrM copy];
}

/** 获取指定目录下的文件，不包括子目录下的文件 */
- (NSArray<NSString *> *)takeAllFilePathFromCurrentDirectory:(NSString *)fromDirectory {
    
    NSMutableArray *fileArrM = [NSMutableArray array];
    [self takeFileFromPath:fromDirectory
               storeToArrM:&fileArrM
       includeSubDirectory:NO];
    return [fileArrM copy];
}

/** 获取指定的图片文件 */
- (UIImage *)takeImage:(NSString *)imagePath
                 error:(NSError *__autoreleasing *)error {
    
    UIImage *image = nil;
    NSData *imageData = [self takeFile:imagePath error:error];
    if (nil != imageData) image = [UIImage imageWithData:imageData];
    return image;
}

#pragma mark - -> Private
/**
 @author Lilei
 
 @brief 创建文件夹

 @param directoryPath 目录路径
 @return YES: 创建成功; NO: 创建失败
 */
- (BOOL)createFolder:(NSString *)directoryPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isSuccess=[fileManager createDirectoryAtPath:directoryPath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    if (!isSuccess) {
        LZStorageLog(@"创建文件目录失败:%@", error.localizedDescription);
    }
    return isSuccess;
}

/**
 @author Lilei
 
 @biref 获取文件的大小
 
 @param atPath 文件绝对路径
 @return 文件大小 单位: KB
 */
- (unsigned long long)fileSizeAtPath:(NSString *)atPath {
    if ([self isExistAtPath:atPath]) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        unsigned long long fileSize = [[fileManager attributesOfItemAtPath:atPath error:NULL]  fileSize];
        return fileSize;
    } else {
        LZStorageLog(@"文件不存在:%@", atPath);
        return 0.0;
    }
}

/**
 @author Lilei
 
 @brief 获取文件夹中所有文件的总大小
 
 @param atPath 文件夹绝对路径
 @return 文件夹大小 单位: KB
 */
- (unsigned long long)folderSizeAtPath:(NSString *)atPath {
    
    __block unsigned long long totalSize = 0.0;
    if (nil == atPath || 0 == atPath.length) {
#if DEBUG
        NSLog(@"文件夹不能为空");
#endif
        return totalSize;
    }
    NSArray *filePathArray = [self takeAllFilePathFromDirectory:atPath];
    [filePathArray enumerateObjectsUsingBlock:^(NSString *fullPath, NSUInteger idx, BOOL * _Nonnull stop) {
         totalSize += [self fileSizeAtPath:fullPath];
    }];
    return totalSize;
}

/**
 @author Lilei
 
 @brief 移动文件
 
 @param fromPath 要移动的文件绝对路径
 @param toPath 移动到的文件绝对路径
 @param isCovered 是否需要覆盖已存在的文件
 @return YES: 移动成功; NO: 移动失败
 @remark 以下情况会移动失败:1.目标路径包含不存在的目录;2.目标路径已经存在;3.目标文件已经存在。
 */
- (BOOL)moveFileFromPath:(NSString *)fromPath
                  toPath:(NSString *)toPath
               isCovered:(BOOL)isCovered {
    if (nil == fromPath || 0 == fromPath.length) {
#if DEBUG
        NSLog(@"要移动的文件不能为空");
#endif
        return NO;
    }
    if (nil == toPath || 0 == toPath.length) {
#if DEBUG
        NSLog(@"移动到的路径不能为空");
#endif
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (isCovered) [fileManager removeItemAtPath:toPath error:NULL];
    NSError *error;
    BOOL isSuccess = [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];
    if (!isSuccess) LZStorageLog(@"移动文件失败:%@", error.localizedDescription);
    return isSuccess;
}

/**
 @author Lilei
 
 @brief 移动文件夹
 
 @param fromPath 要移动的文件夹绝对路径
 @param toPath 移动到的文件夹绝对路径
 @param isCovered 是否需要覆盖已存在的文件
 @return YES: 移动成功; NO: 移动失败
 */
- (BOOL)moveFolderFromPath:(NSString *)fromPath
                    toPath:(NSString *)toPath
                 isCovered:(BOOL)isCovered {
    // 防止有未创建的多级目录
    [self createFolder:toPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:fromPath];
    NSString *path;
    BOOL isSuccess = YES;
    while ((path = [dirEnum nextObject]) != nil) {
        
        NSString *fromFullPath = [fromPath stringByAppendingPathComponent:path];
        if (![self isNeedFile:fromFullPath]) continue;
        NSString *toFullPath = [toPath stringByAppendingPathComponent:path];
        if (![self moveFileFromPath:fromFullPath toPath:toFullPath isCovered:isCovered]) {
            isSuccess = NO;
            break;
        }
    }
    return isSuccess;
}

/**
 @author Lilei
 
 @brief 获取指定目录下的文件路径，并保存到指定的容器内
 
 @param fromPath 文件目录
 @param fileArrM 容器 NSMutableArray
 */
- (void)takeFileFromPath:(NSString*)fromPath
             storeToArrM:(NSMutableArray * __autoreleasing *)fileArrM
     includeSubDirectory:(BOOL)include {
    
    __block BOOL isDirectory;
    BOOL isExist = [self existAtPath:fromPath isDirectory:&isDirectory];
    if (isExist && isDirectory) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *tempArrI = [fileManager contentsOfDirectoryAtPath:fromPath error:NULL];
        [tempArrI enumerateObjectsUsingBlock:^(NSString *directory, NSUInteger idx, BOOL *stop) {
            
            NSString *filePath = [fromPath stringByAppendingPathComponent:directory];
            if (!include) {
                
                [self existAtPath:filePath isDirectory:&isDirectory];
                if (isDirectory) return ;
            }
            [self takeFileFromPath:filePath storeToArrM:fileArrM includeSubDirectory:include];
        }];
    } else if (isExist && !isDirectory) {
        if ([self isNeedFile:fromPath]) [*fileArrM addObject:fromPath];
    }
}

/**
 @author Lilei
 
 @brief 判断是否是需要的文件
 
 @param filePath 文件路径
 @return BOOL
 @remark 排除隐藏文件，以.开头。
 */
- (BOOL)isNeedFile:(NSString *)filePath {
    
    NSString *fileName = filePath.lastPathComponent;
    return [fileName hasPrefix:@"."] ? NO : YES;
}

/**
 @author Lilei
 
 @brief 判断文件或文件夹是否存在

 @param atPath 绝对路径
 @param isDirectory 是文件还是文件夹
 @return YES: 存在; NO: 不存在
 */
- (BOOL)existAtPath:(NSString *)atPath
        isDirectory:(BOOL *)isDirectory {
    if (nil == atPath || 0 == atPath.length) {
#if DEBUG
        NSLog(@"文件或文件夹不能为空");
#endif
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:atPath
                                     isDirectory:isDirectory];
    return isExist;
}

@end
