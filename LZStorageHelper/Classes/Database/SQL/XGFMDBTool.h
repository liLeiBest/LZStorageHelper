//
//  XGFMDBTool.h
//  TextYtkDB
//
//  Created by KBTC on 15/8/12.
//  Copyright (c) 2015年 KBTC. All rights reserved.
//

#import <Foundation/Foundation.h>

// 默认 存储个数
static int KBTC_DEFAUL_INSERT_COUNT = 20;

@interface XGFMDBTool : NSObject

+ (XGFMDBTool *)sharedFMDBManager;

- (void)createCustomDBWithName:(NSString *)tableName;
- (void)createTableWithName:(NSString *)tableName;

//-----------------------------------------------------------------------增
/**
 *  插入一条数据  默认不限制
 *
 *  @param objectId  id
 *  @param obj       数据 本身的json
 *  @param fromTable 表格名
 */
- (void)insertDBwithId:(NSString *)objectId
                  type:(NSString *)type
              position:(NSString *)position
            WithObject:(id)obj
             fromTable:(NSString *)fromTable;
/**
 *  插入一条数据  可以限定数据个数
 *
 *  @param objectId  id
 *  @param obj       数据 本身的json
 *  @param maxCount  最多存入多少条数据
 *  @param fromTable 表格名
 */
- (void)insertDBwithId:(NSString *)objectId
                  type:(NSString *)type
              position:(NSString *)position
            WithObject:(id)obj
              maxCount:(int)maxCount
             fromTable:(NSString *)fromTable;

- (void)insertDBwithId:(NSString *)objectId
                  type:(NSString *)type
              position:(NSString *)position
           createdTime:(NSString *)createdTime
            WithObject:(id)obj
             fromTable:(NSString *)fromTable
              maxCount:(int)maxCount
                 text1:(NSString *)text1
                 text2:(NSString *)text2
                 text3:(NSString *)text3;

/**
 *  批量插入 一组数据
 *
 *  @param idArray    id 数组
 *  @param objArray   与id 数组相对应的 obj数组
 *  @param fromTable 表格名
 */
- (void)insterObjArrayWithId:(NSArray *)idArray
             WithObjectArray:(NSArray *)objArray
                   typeArray:(NSArray *)typeArray
               positionArray:(NSArray *)positionArray
                    maxCount:(int)maxCount
                   fromTable:(NSString *)fromTable;

//------------------------------------------------------------------------删
/**
 *  通过某条 id 删除本条数据
 *
 *  @param objectId  objectID
 *  @param tableName 表格名
 */
- (void)deleteObjById:(NSString *)objectId fromTable:(NSString *)tableName;

/** 删除旧的count条数据 **/
-(void)deleteOldCountObjWithCondition:(NSString *)condition formTable:(NSString *)tableName delCount:(int)count;

/**
 *  通过 id数组 来删除 id相 对应的数据
 *
 *  @param objectIdArray id Array 只是id数组就ok  不需要转NSString
 *数据库本身已经处理
 *  @param tableName     数据库表格
 */
- (void)deleteObjByIdArray:(NSArray *)objectIdArray
                 fromTable:(NSString *)tableName;

/**
 *  自定义条件删除数据
 *
 *  @param condition 自定义条件
 *  @param tableName 从那个表删除
 */
- (void)deleteObjByCondition:(NSString *)condition
                   fromTable:(NSString *)tableName;

/**
 *  删除本表的所有数据  慎用 (清楚缓存时用到)
 *
 *  @param tableName 表名
 */
- (void)deleteAllObjfromTable:(NSString *)tableName;

/**
 *  删除本数据库
 *
 *  @param diretory 数据库文件路径
 */
- (void)deleteAllDbWithDiretory:(NSString *)diretory;
//--------------------------------------------------------------------------改

/**
 *  通过objectID修改这条数据
 *
 *  @param objectId  objectId
 *  @param obj       json数据
 *  @param fromTable 表格名
 */
- (void)updateDbById:(NSString *)objectId
                type:(NSString *)type
            position:(NSString *)position
          WithObject:(id)obj
           fromTable:(NSString *)fromTable;
/**
 *  通过objectID修改这条数据
 *
 *  @param objectId  objectId
 *  @param obj       json数据
 *  @param fromTable 表格名
 *  @param text1      text1的内容
 */
- (void)updateDbById:(NSString *)objectId
                type:(NSString *)type
            position:(NSString *)position
          WithObject:(id)obj
           fromTable:(NSString *)fromTable
               text1:(NSString *)text1;


/**
 *  修改一条数据的下列数据
 **/
- (void)updateOnceWithId:(NSString *)objectId
                  Object:(id)object
               intoTable:(NSString *)tableName
                   text1:(NSString *)text1;


/**
 根据一组 主键id 修改每一项的 某key对应的值value

 @param objectIdArray 主键数组
 @param keys 字段
 @param values 字段对应的值（需要跟字段一一对应）
 @param fromTable 名称
 */
- (void)updateDbByIdArray:(NSArray *)objectIdArray
            needUpdateKey:(NSArray *)keys
       andNeedUpdateValue:(NSArray *)values
                fromTable:(NSString *)fromTable;

/**
 *   通过objectID数组修改 这些数据        暂时不对外
 *   id 数组里面的顺序  必须和 obj数组里面的数据 一一对应
 */
//- (void)updateDbByIdArray:(NSArray *)objectIdArray WithObjectArray:(NSArray
//*)objArray fromTable:(NSString *)fromTable;

//--------------------------------------------------------------------------查
/**
 *  通过 objectID 查询 获取这条数据
 *
 *  @param objectId  objectID
 *  @param tableName 表格名
 *
 *  @return 返回数据是json
 */
- (id)getDBObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

/**
 *  通过type 筛选
 *  @return 筛选后排列 的数组
 */
- (NSArray *)getObjectByType:(NSString *)type fromTable:(NSString *)tableName;

/**
 *  通过url 查询  (仅限收藏 与 教学)
 *  @return 查询这个url是否存在
 */
- (BOOL)getObjectByUrl:(NSString *)url fromTable:(NSString *)tableName;

/**
 @author Lilei
 
 @brief 判断 URL 是否已经存在表中
 
 @param URL URL
 @param tableName 表名
 @param handler 回调
 */
- (void)isExistByURL:(NSString *)URL
           fromTable:(NSString *)tableName
   completionHandler:(void (^)(BOOL exist, NSArray<NSDictionary *> *items))handler;

/**
 *  根据某条数据id 获取之前10条的旧数据 (用于上拉刷新)(倒序 时间早的在后面)
 *
 *  @param objectId  上拉刷新最后一条id
 *  @param tableName 表格名
 *
 *  @return 返回数组 (后10条数据 数组)数组 里面全是 XGKeyValueItem 模型
 */
- (NSArray *)getLastTenDBObjectById:(NSString *)objectId
                          fromTable:(NSString *)tableName;

/**
 *  根据某条数据id 获取之后10条的新数据 (用于下拉刷新)(倒序 时间早的在后面)
 *
 *  @param objectId  上拉刷新最后一条id
 *  @param tableName 表格名
 *
 *  @return 返回数组 (后10条数据 数组)数组 里面全是 XGKeyValueItem 模型
 */
- (NSArray *)getNewTenObjectById:(NSString *)objectId
                       fromTable:(NSString *)tableName;

/**
 *  根据条件获取表中满足条件对象有多少条
 *
 *  @param tableName tableName
 *  @param condition condition
 *
 *  @return int
 */
- (int)getObjCountFromTable:(NSString *)tableName withCondition:(NSString *)condition;

/**
 *  根据条件获取数据列表
 *
 *  @param condition 条件
 *  @param tableName 表名
 *
 *  @return NSArrayList
 */
- (NSArray *)getNewTenObjectByCondition:(NSString *)condition
                              fromTable:(NSString *)tableName;

- (NSArray *)getNewMoreObjectByCondition:(NSString *)condition
                               fromTable:(NSString *)tableName;

/**
 *  获取这个表格的所有数据 (数组里面包含着 XGKeyValueItem 模型)
 *
 *  @param fromTable  数据表
 *
 *  @return 所有数据
 */

- (NSArray *)getAllObjsFromTable:(NSString *)fromTable;

/**
 *  获取这个表格的所有数据 (不是模型 直接可以获取 存入时的数据)
 *
 *  @param fromTable  数据表
 *
 *  @return 所有数据
 */
- (NSMutableArray *)getAllObjsOnlyResultFromTable:(NSString *)fromTable;

/**
 *  返回数据库中的最后一条数据
 */
- (id)getLastObjFromTable:(NSString *)fromeTable;

/**
 *  获取 给表里最新的count条数据(数组里面包含的数据是 XGKeyValueItem 模型)
 */
- (NSArray *)getObjWithCount:(int)count fromTable:(NSString *)fromTable;

/**
 *  获取 给表里最新的count条数据  (数组里面包含的 不是模型 直接可以获取
 * 存入时的数据)
 */
- (NSMutableArray *)getObjOnlyResultWithCount:(int)count
                                    fromTable:(NSString *)fromTable;
/**
 *  获取 给表里最新的count条数据  (数组里面包含的 不是模型 直接可以获取
 * 存入时的数据) 并降序
 */
- (NSArray *)getObjWithCount:(int)count
                   fromTable:(NSString *)fromTable
                      descBy:(NSString *)columnName;
/**
 *  返回某个表格 一共多少条数据
 */
- (NSUInteger)getObjCountFromTable:(NSString *)fromTable;

- (NSArray *)getObjsBySql:(NSString *)sql;

@end
