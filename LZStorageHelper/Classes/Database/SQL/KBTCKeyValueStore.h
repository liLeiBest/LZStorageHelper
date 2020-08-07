//
//  KBTCKeyValueStore.h
//  TextYtkDB
//
//  Created by KBTC on 15/8/13.
//  Copyright (c) 2015年 KBTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBTCKeyValueItem.h"

static NSString *const  updateId = @"id";
static NSString *const  updateObject =  @"json";
static NSString *const  updateDicmodel =  @"dicModel";
static NSString *const  updateCreatedTime = @"createdTime";
static NSString *const  updateType = @"type";
static NSString *const  updatePosition = @"position";
static NSString *const  updateText1  = @"text1";
static NSString *const  updateText2  = @"text2";
static NSString *const  updateText3  = @"text3";




@interface KBTCKeyValueStore : NSObject
- (id)initDBWithName:(NSString *)dbName;

- (id)initWithDBWithPath:(NSString *)dbPath;

- (void)createCustomTableWithName:(NSString *)tableName;// withTableFieldArray:(NSArray *)fieldArray;

- (void)clearTable:(NSString *)tableName;

- (void)close;

///-------------增

/**
 *  增加一条数据  核心代码
 *  id  object pos 不能为空  position 备用主键
 *  maxCount 是限定这个表数据条数
 */
- (void)insertwithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
         createdTime:(NSString *)createdTime
           intoTable:(NSString *)tableName
            maxCount:(int)maxCount
               text1:(NSString *)text1
               text2:(NSString *)text2
               text3:(NSString *)text3;

/**
 *  增加一条数据    id  object pos 不能为空
 */
- (void)insertwithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName
            maxCount:(int)maxCount;
///----------------删

-(void)deleteObjByCondition:(NSString *)condition fromTable:(NSString *)tableName;

- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

/** 删除旧的count条数据 **/
-(void)deleteOldObjByCondition:(NSString *)condition fromTable:(NSString *)tableName delCount:(NSString *)count;

///----------------改
// 如果存储的是模型 如果想用字典替换  这个可能不会支持 默认支持 模型

/**
 *  修改一条数据    id  object pos 不能为空
 */
- (void)updateWithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName;

/**
 *  修改一条数据    id  object pos 不能为空
 */
- (void)updateWithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName
               text1:(NSString *)text1;

/**
 *  修改一条数据的下列数据
 **/
- (void)updateOnceWithId:(NSString *)objectId
                  Object:(id)object
               intoTable:(NSString *)tableName
                   text1:(NSString *)text1;

/**
 *  修改一条数据
 */
- (void)updateWithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName
               text1:(NSString *)text1
               text2:(NSString *)text2
               text3:(NSString *)text3;



/**
 *  根据 id 修改某个字段  传的参数不能为空
 *      核心代码
 *  @param objectId     id 必填
 *  @param condition    需要修改的字段
 *  @param object 修改的新数据
 */
- (void)updateWithId:(NSString *)objectId
     updateCondition:(NSString *)condition
              object:(id)object
           intoTable:(NSString *)tableName;
///----------------查

/**
 *  根据某条id  查询某条数据  (返回的是XGKeyValueItem 模型)
 */
- (id)getobjById:(NSString *)Id fromTable:(NSString *)tableName;

/**
 *  查询某个表中的数据
 */
- (NSArray *)getAllItemsFromTable:(NSString *)tableName;


/**
 *  根据条件筛选
 *
 *  @param Condition 筛选条件 比如 type = 1111 and id > 2
 *
 *  sql条件  交给用户
 *
 *  @param count 如果为空默认是所有的数据
 *  @return 返回 这个表中的满足这个查询条件的 数据  (倒序 先进后出)
 */
- (NSArray *)getObjItemWithSearchCondition:(NSString *)Condition Count:(int)count fromTable:(NSString *)tableName;


/**
 *  从 objId 位置开始 往后 获取一定数目的数据
 *  objId 不能为nil  id 如果为空 就是表中所有的数据
 *  count 如果为空默认是从id之后的所有的数据
 */
- (NSArray *)getObjItemsWithobjId:(NSString *)objId Count:(int)count fromTable:(NSString *)tableName;
/**
 *  从 objId 位置开始 往前 获取一定数目的数据
 *  objId 不能为nil  id 如果为空 就是表中所有的数据
 *  count 如果为空默认是从id之后的所有的数据
 */
- (NSArray *)getNewObjItemsWithobjId:(NSString *)objId Count:(int)count fromTable:(NSString *)tableName;

/**
 *   取出某个表里面的最新的count条数据
 */
- (NSArray *)getAnyCount:(int)count fromTable:(NSString *)tableName;
/**
 *   取出某个表里面的最新的count条数据 并且降序排序
 */
- (NSArray *)getAnyCount:(int)count fromTable:(NSString *)tableName descBy:(NSString *)columnName;

/**
 *  自己写sql (只限)查询数据
 */
- (NSArray *)getItemsWithSQL:(NSString *)sql andTableName:(NSString *)tableName;

/**
 *  获取obj的数量
 *
 *  @return 数量的个数
 */
-(int)getObjCountFromTable:(NSString *)tableName withCondition:(NSString *)condition;


@end
