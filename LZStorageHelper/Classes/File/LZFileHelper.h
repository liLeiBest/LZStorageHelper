//
//  LZFileHelper.h
//  Pods
//
//  Created by Dear.Q on 16/7/24.
//
//

#import <Foundation/Foundation.h>

#define LZFile [LZFileHelper sharedFileHelper]

#define LZSaveFileToPath(data, fileName, toPath) \
[LZFile saveFileData:data name:fileName toPath:toPath]

@interface LZFileHelper : NSObject

/**
 @author Lilei
 
 @brief 唯一实例

 @return LZFileHelper
 */
+ (instancetype)sharedFileHelper;

/**
 @author Lilei
 
 @brief 判断文件是否存在

 @param filePath 文件绝对路径
 @return YES: 存在; NO: 不存在
 */
- (BOOL)isExistAtPath:(NSString*)filePath;

/**
 @author Lilei
 
 @brief 判断是否是文件

 @param atPath 文件绝对路径
 @return YES: 是文件; NO: 不是文件
 */
- (BOOL)isFileAtPath:(NSString *)atPath;

/**
 @author Lilei
 
 @brief 判断是否是文件夹

 @param atPath 文件夹绝对路径
 @return YES: 是文件夹; NO: 不是文件夹
 */
- (BOOL)isDirectoryAtPath:(NSString *)atPath;

/**
 @author Lilei
 
 @brief 计算指定路径的文件或文件的大小
 
 @param atPath 文件或文件夹的绝对路径
 @return 文件或文件夹大小 单位: KB
 */
- (unsigned long long)sizeAtPath:(NSString *)atPath;

/**
 @author Lilei
 
 @brief 获取指定的目录
 
 @param searchPathDirectory NSSearchPathDirectory
 @return NSString
 */
- (NSString *)directoryPath:(NSSearchPathDirectory)searchPathDirectory;

/**
 @author Lilei
 
 @brief 创建文件夹到指定的沙盒目录
 
 @param directory 文件夹名称
 @param searchPathDirectory NSSearchPathDirectory
 @return YES: 创建成功; NO: 创建失败
 @remark directory 包含的中间目录会自动创建。例:@"iOS/temp"
 */
- (BOOL)createDirectory:(NSString *)directory
           toSearchPath:(NSSearchPathDirectory)searchPathDirectory;

/**
 @author Lilei
 
 @brief 保存文件到指定的目录
 
 @param fileData 保存的文件 NSData 类型
 @param toPath 保存的路径
 @param fileName 保存的文件名
 
 @return YES: 保存成功; NO: 保存失败
 */
- (BOOL)saveFileData:(NSData *)fileData
                name:(NSString *)fileName
              toPath:(NSString *)toPath;

/**
 @author Lilei
 
 @brief 获取指定的文件 NSData 类型
 
 @param filePath 文件路径
 @param error 错误信息 NSError
 @return NSData
 */
- (NSData *)takeFile:(NSString *)filePath
               error:(NSError **)error;

/**
 @author Lilei
 
 @biref 删除文件或文件夹

 @param atPath 绝对路径
 @return YES: 删除成功; NO: 删除失败
 */
- (BOOL)deleteAtPath:(NSString *)atPath;

/**
 @author Lilei
 
 @brief 移动文件或文件夹

 @param fromPath 源绝对路径
 @param toPath 目标绝对路径
 @param isCovered 是否需要覆盖已存在的文件
 @return YES: 移动成功; NO: 移动失败
 */
- (BOOL)moveFromPath:(NSString *)fromPath
              toPath:(NSString *)toPath
           isCovered:(BOOL)isCovered;

/**
 @author Lilei
 
 @brief 重命名文件或文件夹

 @param atPath 绝对路径
 @param newName rename
 @return YES: 修改成功; NO: 修改失败
 @remark 文件名不区分大小写
 */
- (BOOL)renameAtPath:(NSString *)atPath
             newName:(NSString *)newName;

/**
 @author Lilei
 
 @brief 获取指定目录下的所有文件

 @param fromDirectory 文件夹
 @return 文件路径数组 NSArray
 @remark 包括子目录下的文件
 */
- (NSArray<NSString *> *)takeAllFilePathFromDirectory:(NSString *)fromDirectory;

/**
 @author Lilei
 
 @brief 获取指定目录下的文件
 
 @param fromDirectory 文件目录
 @return 文件路径数组 NSArray
 @remark 不包括子目录下的文件
 */
- (NSArray<NSString *> *)takeAllFilePathFromCurrentDirectory:(NSString *)fromDirectory;

/**
 @author Lilei
 
 @brief 获取指定的图片文件
 
 @param imagePath 文件路径
 @param error 错误信息 NSError
 @return UIImage
 */
- (UIImage *)takeImage:(NSString *)imagePath
                 error:(NSError **)error;

@end
