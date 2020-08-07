//
//  XGFMDBTool.m
//  TextYtkDB
//
//  Created by KBTC on 15/8/12.
//  Copyright (c) 2015年 KBTC. All rights reserved.
//

#import "XGFMDBTool.h"
#import "KBTCKeyValueStore.h"

//默认数据库名称
static NSString *const DEFAULT_KBTC_DB_NAME = @"kbtc_hbb.sqlite";
/** 默认表格名称 */
static NSString *const DEFAULT_KBTC_TABLE_NAME = @"kbtc_hbb_teacher";

@interface XGFMDBTool ()

@property(nonatomic, strong) KBTCKeyValueStore *storeManger;

@end

@implementation XGFMDBTool

static XGFMDBTool *sharedFMDBManager = nil;
+ (XGFMDBTool *)sharedFMDBManager
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
      sharedFMDBManager = [[XGFMDBTool alloc] init];
    });
    return sharedFMDBManager;
}

- (void)createCustomDBWithName:(NSString *)tableName;
{
    if (tableName.length) {
        _storeManger = [[KBTCKeyValueStore alloc] initDBWithName:[NSString stringWithFormat:@"%@", tableName]];
    } else {
        _storeManger = [[KBTCKeyValueStore alloc] initDBWithName:[NSString stringWithFormat:@"%@", DEFAULT_KBTC_DB_NAME]];
    }
}

- (KBTCKeyValueStore *)storeManger
{
    if (_storeManger == nil)
    {
        _storeManger = [[KBTCKeyValueStore alloc] initDBWithName:@"hbb.sqlite"];
        [_storeManger createCustomTableWithName:DEFAULT_KBTC_TABLE_NAME];
    }
    return _storeManger;
}

- (void)createTableWithName:(NSString *)tableName
{
    [self.storeManger createCustomTableWithName:tableName];
}

//  new
- (void)createTableWithName:(NSString *)tableName
               withobjArray:(NSArray *)objArray
{
    [self.storeManger createCustomTableWithName:tableName];
}

- (NSString *)getReturnTableName:(NSString *)tableName
{
    if (tableName == nil) {
        tableName = DEFAULT_KBTC_TABLE_NAME;
    }
    [self createTableWithName:tableName];
    return tableName;
}

//-----------------------------------------------------------------------增

/**
 *  插入一条数据
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
{
    if (objectId == nil)
        return;
    
    [self.storeManger insertwithId:objectId
                            Object:obj
                              type:type
                          position:position
                         intoTable:[self getReturnTableName:fromTable]
                          maxCount:0];
}

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
{
    if (objectId == nil)
        return;
    [self.storeManger insertwithId:objectId
                            Object:obj
                              type:type
                          position:position
                       createdTime:createdTime
                         intoTable:[self getReturnTableName:fromTable]
                          maxCount:maxCount
                             text1:text1
                             text2:text2
                             text3:text3];
    //
    //    [self.storeManger insertwithId:objectId
    //                            Object:obj
    //                              type:type
    //                          position:position
    //                        createTime:createdTime
    //                         intoTable:[self getReturnTableName:fromTable]
    //                          maxCount:maxCount
    //                             text1:text1
    //                             text2:text2
    //                             text3:text3];
}
/**
 *  插入一条数据
 *
 *  @param objectId  id
 *  @param obj       数据 本身的json
 *  @param fromTable 表格名
 */
- (void)insertDBwithId:(NSString *)objectId
                  type:(NSString *)type
              position:(NSString *)position
            WithObject:(id)obj
              maxCount:(int)maxCount
             fromTable:(NSString *)fromTable;
{
    if (objectId == nil)
        return;

    [self.storeManger insertwithId:objectId
                            Object:obj
                              type:type
                          position:position
                         intoTable:[self getReturnTableName:fromTable]
                          maxCount:maxCount];
}

- (void)insterObjArrayWithId:(NSArray *)idArray
             WithObjectArray:(NSArray *)objArray
                   typeArray:(NSArray *)typeArray
               positionArray:(NSArray *)positionArray
                    maxCount:(int)maxCount
                   fromTable:(NSString *)fromTable;
{
    if (idArray.count != objArray.count)
        return;

    for (int i = 0; i < idArray.count; i++) {
        if ([idArray objectAtIndex:i] == nil)
            return;

        [self.storeManger insertwithId:[idArray objectAtIndex:i]
                                Object:[objArray objectAtIndex:i]
                                  type:[typeArray objectAtIndex:i]
                              position:[positionArray objectAtIndex:i]
                             intoTable:[self getReturnTableName:fromTable]
                              maxCount:maxCount];
    }
}
//------------------------------------------------------------------------删
/**
 *  通过某条 id 删除本条数据
 *
 *  @param objectId  objectID
 *  @param tableName 表格名
 */
- (void)deleteObjById:(NSString *)objectId fromTable:(NSString *)tableName;
{
    if (objectId == nil)
        return;

    [self.storeManger deleteObjectById:objectId fromTable:tableName];
}

/** 删除最旧的N条数据 **/
-(void)deleteOldCountObjWithCondition:(NSString *)condition formTable:(NSString *)tableName delCount:(int)count{
    [self.storeManger deleteOldObjByCondition:condition fromTable:tableName delCount: [NSString stringWithFormat:@"%d",count]];
}

/**
 *  通过 id数组 来删除 id相 对应的数据
 *
 *  @param objectIdArray id Array
 *  @param tableName     数据库表格
 */
- (void)deleteObjByIdArray:(NSArray *)objectIdArray
                 fromTable:(NSString *)tableName;
{
    [self.storeManger deleteObjectsByIdArray:objectIdArray fromTable:tableName];
}
/**
 *  删除本表的所有数据  慎用 (清楚缓存时用到)
 *
 *  @param tableName 表名
 */
- (void)deleteAllObjfromTable:(NSString *)tableName;
{
    [self.storeManger clearTable:tableName];
}


/**
 *  通过 自定义条件筛选数据 然后删除
 *
 *  @param condition 类似于 "id＝xx and name=xx"
 *  @param tableName     数据库表格
 */
- (void)deleteObjByCondition:(NSString *)condition fromTable:(NSString *)tableName{
    [self.storeManger deleteObjByCondition:condition fromTable:tableName];
}

/**
 *  删除本数据库
 *
 *  @param diretory 数据库文件路径
 */
- (void)deleteAllDbWithDiretory:(NSString *)diretory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([filename isEqualToString:diretory]) {
            
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    
}
//--------------------------------------------------------------------------改

/**
 *  通过objectID修改这条数据 (覆盖之前的数据)
 *
 *  @param objectId  objectId
 *  @param obj       json数据
 *  @param fromTable 表格名
 */
- (void)updateDbById:(NSString *)objectId
                type:(NSString *)type
            position:(NSString *)position
          WithObject:(id)obj
           fromTable:(NSString *)fromTable
               text1:(NSString *)text1
{
    if (objectId == nil)
        return;
    
    [self.storeManger updateWithId:objectId
                            Object:obj
                              type:type
                          position:position
                         intoTable:fromTable
                             text1:text1];
}

/**
 *  修改一条数据的下列数据
 **/
- (void)updateOnceWithId:(NSString *)objectId
                  Object:(id)object
               intoTable:(NSString *)tableName
                   text1:(NSString *)text1
{
    [self.storeManger updateOnceWithId:objectId Object:object intoTable:tableName text1:text1];
}

- (void)updateDbByIdArray:(NSArray *)objectIdArray
            needUpdateKey:(NSArray *)keys
       andNeedUpdateValue:(NSArray *)values
                fromTable:(NSString *)fromTable {
    if (objectIdArray == nil || objectIdArray.count == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < objectIdArray.count; i++) {
        
        NSString *itemId = objectIdArray[i];
        for (NSInteger j = 0;j < keys.count; j++) {
            
            NSString *key = keys[j];
            id objcect = values[j];
            
            [self.storeManger updateWithId:itemId
                           updateCondition:key
                                    object:objcect
                                 intoTable:fromTable];
        }
    }
}


/**
 *  通过objectID修改这条数据 (覆盖之前的数据)
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
{
    if (objectId == nil)
        return;

    [self.storeManger updateWithId:objectId
                            Object:obj
                              type:type
                          position:position
                         intoTable:fromTable];
}

- (void)updateDbByIdArray:(NSArray *)IdArray
          WithObjectArray:(NSArray *)objArray
                fromTable:(NSString *)fromTable;
{
    if (IdArray.count != objArray.count)
        return;

    for (int i = 0; i < IdArray.count; i++) {
        if ([IdArray objectAtIndex:i] == nil)
            return;
        //        if ([objArray objectAtIndex:i] == nil) return;

        //        [self updateDbById:[IdArray objectAtIndex:i]
        //        WithObject:[objArray objectAtIndex:i] fromTable:fromTable];
    }
}

//--------------------------------------------------------------------------查
/**
 *  通过 objectID 查询 获取这条数据
 *
 *  @param objectId  objectID
 *  @param ClassName 需要转换成什么模型   如果这个参数是nil 返回的是 存的字典
 *  @param tableName 表格名
 *  如果单条数据就用ClassName 接收模型
 *
 *  @return 返回 模型
 */
- (id)getDBObjectById:(NSString *)objectId fromTable:(NSString *)tableName;
{
    if (objectId == nil)
        return nil;

    id item = [self.storeManger getobjById:objectId fromTable:tableName];
    if (item) {
        return item;
    }
    return nil;
}

- (NSArray *)getObjectByType:(NSString *)type fromTable:(NSString *)tableName;
{
    if (type == nil)
        return nil;
    return [self.storeManger getObjItemWithSearchCondition:updateType
                                                     Count:0
                                                 fromTable:tableName];
}

/** 判断 URL 是否已经存在表中 */
- (void)isExistByURL:(NSString *)URL
           fromTable:(NSString *)tableName
   completionHandler:(void (^)(BOOL, NSArray<NSDictionary *> *))handler
{
    if (nil == URL || !URL.length) handler(NO, nil);
    
    NSArray *array = [self.storeManger
                      getObjItemWithSearchCondition:
                      [NSString stringWithFormat:@"%@ = '%@'", updateText1, URL]
                      Count:0
                      fromTable:tableName];
    if (array.count)
    {
        NSMutableArray *tempArrM = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(KBTCKeyValueItem *obj,
                                            NSUInteger idx,
                                            BOOL *stop)
         {
             [tempArrM addObject:obj.itemResult];
         }];
        if (handler) handler(YES, tempArrM.copy);
    }
    else handler(NO, nil);
}

/**
 *  通过url 查询  (仅限收藏 与 教学)
 *  @return 查询这个url是否存在
 */
- (BOOL)getObjectByUrl:(NSString *)url fromTable:(NSString *)tableName;
{
    if ([url isEqualToString:@""])
        return NO;

    NSArray *array = [self.storeManger
        getObjItemWithSearchCondition:
            [NSString stringWithFormat:@"%@ = '%@'", updateText1, url]
                                Count:0
                            fromTable:tableName];
    if (array.count) {
        return YES;
    } else {
        return NO;
    }

    return NO;
}

/**
 *  根据某条数据id 获取之前10条的数据 (用于上拉刷新)(倒序 时间早的在后面)
 *
 *  @param objectId  上拉刷新最后一条id
 *  @param tableName 表格名
 *
 *  @return 返回数组 (后10条数据 数组)
 */
- (NSArray *)getLastTenDBObjectById:(NSString *)objectId
                          fromTable:(NSString *)tableName;
{
    if (objectId == nil || [objectId isEqualToString:@"(null)"]) {
        return [self.storeManger getAllItemsFromTable:tableName];
    } else {
        return [self.storeManger getObjItemsWithobjId:objectId
                                                Count:10
                                            fromTable:tableName];
    }

    return nil;
}
- (NSArray *)getNewTenObjectById:(NSString *)objectId
                       fromTable:(NSString *)tableName;
{

    if (objectId == nil || [objectId isEqualToString:@"(null)"]) {
        return nil;
    } else {
        return [self.storeManger getNewObjItemsWithobjId:objectId
                                                   Count:10
                                               fromTable:tableName];
    }

    return nil;
}

- (int)getObjCountFromTable:(NSString *)tableName withCondition:(NSString *)condition;
{
    return [self.storeManger getObjCountFromTable:tableName withCondition:condition];
}

- (NSArray *)getNewTenObjectByCondition:(NSString *)condition fromTable:(NSString *)tableName{
    return [self.storeManger getObjItemWithSearchCondition:condition Count:100 fromTable:tableName];
}

- (NSArray *)getNewMoreObjectByCondition:(NSString *)condition fromTable:(NSString *)tableName{
    return [self.storeManger getObjItemWithSearchCondition:condition Count:1000 fromTable:tableName];
}

/**
 *  获取这个表格的所有数据
 *
 *  @param fromTable  数据表
 *
 *  @return 所有数据
 */
- (NSArray *)getAllObjsFromTable:(NSString *)fromTable;
{
    return [self.storeManger getAllItemsFromTable:fromTable];
}

- (NSMutableArray *)getAllObjsOnlyResultFromTable:(NSString *)fromTable
{
    NSArray *allObjArray = [self getAllObjsFromTable:fromTable];
    NSMutableArray *relustArray = [NSMutableArray array];
    for (KBTCKeyValueItem *item in allObjArray) {
        [relustArray addObject:item.itemResult];
    }
    if (relustArray) {
        return relustArray;
    } else {
        return nil;
    }
}


- (id)getLastObjFromTable:(NSString *)fromTable;
{
    NSArray *myArray = [self getObjWithCount:1 fromTable:fromTable];

    if (myArray.count) {
        return [myArray objectAtIndex:0];
    } else {
        return nil;
    }
    return nil;
}

- (NSArray *)getObjWithCount:(int)count fromTable:(NSString *)fromTable
{
    NSArray *array = [self.storeManger getAnyCount:count fromTable:fromTable];
    if (array.count) {
        return array;
    } else {
        return nil;
    }
}

- (NSArray *)getObjWithCount:(int)count
                   fromTable:(NSString *)fromTable
                      descBy:(NSString *)columnName
{
    NSArray *array = [self.storeManger getAnyCount:count
                                         fromTable:fromTable
                                            descBy:columnName];
    if (array.count) {
        return array;
    } else {
        return nil;
    }
}

- (NSArray *)getObjWithCount:(int)count
                      descBy:(NSString *)columName
                   fromTable:(NSString *)fromTable
{
    NSArray *array = [self.storeManger getAnyCount:count fromTable:fromTable];
    if (array.count) {
        return array;
    } else {
        return nil;
    }
}

- (NSMutableArray *)getObjOnlyResultWithCount:(int)count
                                    fromTable:(NSString *)fromTable;
{
    NSMutableArray *muArray = [NSMutableArray array];
    NSArray *array = [self getObjWithCount:count fromTable:fromTable];
    for (KBTCKeyValueItem *item in array) {
        [muArray addObject:item.itemResult];
    }
    if (array.count) {
        return muArray;
    } else {
        return nil;
    }
}

- (NSUInteger)getObjCountFromTable:(NSString *)fromTable;
{
    NSArray *array = [self getAllObjsFromTable:fromTable];
    return array.count;
}

- (NSArray *)getObjsBySql:(NSString *)sql
{
    return [self.storeManger getItemsWithSQL:sql
                                andTableName:@""];
}
@end
