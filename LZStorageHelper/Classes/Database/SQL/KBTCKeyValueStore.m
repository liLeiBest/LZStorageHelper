//
//  KBTCKeyValueStore.m
//  TextKBTCDB
//
//  Created by KBTC on 15/8/13.
//  Copyright (c) 2015年 KBTC. All rights reserved.
//

#import "KBTCKeyValueStore.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "KBTCFMItem.h"

#define PATH_OF_DOCUMENT                                                       \
    [NSSearchPathForDirectoriesInDomains(                                      \
        NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface KBTCKeyValueStore ()

@property(strong, nonatomic) FMDatabaseQueue *dbQueue;

@end
static NSSet *_foundationClasses;

@implementation KBTCKeyValueStore

static NSString *const DEFAULT_DB_NAME = @"kbtc_hbb.sqlite";
static NSString *const CREATE_CUSTOM_TABLE_SQL =
@"CREATE TABLE IF NOT EXISTS %@ ( \
id TEXT NOT NULL, \
json TEXT , \
dicModel TEXT , \
createdTime TEXT NOT NULL, \
type TEXT, \
position TEXT NOT NULL, \
text1 TEXT, \
text2 TEXT, \
text3 TEXT, \
PRIMARY KEY(id)) \
";

// 插入 (直接覆盖)
static NSString *const INSERT_CUSTOM_ITEM_SQL =
    @"REPLACE INTO %@ (id, json, dicModel, "
    @"createdTime,type,position,text1,text2,text3) values (?,?,?,?,?,?,?,?,?)";

// 删
static NSString *const CLEAR_ALL_SQL = @"DELETE from %@";
static NSString *const DELETE_LAST_ITEM_SQL =
    @"DELETE  from %@ where id = (select id from %@ order by createdTime) ";
static NSString *const DELETE_ITEM_SQL = @"DELETE from %@ where id = ?";
static NSString *const DELETE_ITEMS_SQL = @"DELETE from %@ where id in ( %@ )";
static NSString *const DELETE_ITEMS_SQL_WITH_CONDITION = @"DELETE from %@ where %@";
static NSString *const DELETE_OLD_COUNT_ITEM = @"DELETE FROM %@ WHERE %@ and id IN(SELECT id FROM %@ WHERE %@ order by createdTime asc, position  asc LIMIT %@)";

// 更新 数据  插入数据时间永远不变
static NSString *const UPDATE_CUSTOM_ITEM_SQL =
    @"UPDATE %@ set %@ = ? WHERE id = ?";
static NSString *const UPDATE_ONECONDITON_ITEM_SQL =
    @"UPDATE %@ set %@ = ? WHERE id = ?";

//根据条件查询对象的数量
static NSString *const COUNT_OBJ_WITH_CONDITION =
@"select type, count(type) from %@ where %@  group by type";

//根据条件查询
static NSString *const SELECT_CONDITION_ITEM_SQL = @"SELECT * from ";

static NSString *const SELECT_COUNT_SQL = @"SELECT count(id) as count from %@";
//拼接时间的sql
static NSString *const SELECT_MOSAIC_TIME_SQL =
    @"order by createdTime desc, position  desc";

//拼接时间的sql 按照审核时间和发布时间排序text1存放的是审核时间
static NSString *const SELECT_MOMENT_TIME_SQL =
@"SELECT *, IFNULL(text1,createdTime) AS order_time FROM %@ ORDER BY order_time DESC;";

//拼接降序sql
static NSString *const ORDER_BY_DESC = @"order by %@ desc";

//--------------------------------------------------------------------------------------------------------------------------------
+ (void)load
{
    _foundationClasses =
        [NSSet setWithObjects:[NSObject class], [NSURL class], [NSDate class],
                              [NSNumber class], [NSDecimalNumber class],
                              [NSData class], [NSMutableData class],
                              [NSArray class], [NSMutableArray class],
                              [NSDictionary class], [NSMutableDictionary class],
                              [NSString class], [NSMutableString class], nil];
}

+ (BOOL)isClassFromFoundation:(Class)c
{
    return [_foundationClasses containsObject:c];
}

+ (BOOL)checkTableName:(NSString *)tableName
{
    if (tableName == nil || tableName.length == 0 ||
        [tableName rangeOfString:@" "].location != NSNotFound) {
        LZStorageLog(
            @"数据库判断 表名是否合格出错, table name: %@ format "
            @"error.",
            tableName);
        return NO;
    }
    return YES;
}

- (id)initDBWithName:(NSString *)dbName
{
    self = [super init];
    if (self) {
        NSString *dbPath =
            [PATH_OF_DOCUMENT stringByAppendingPathComponent:dbName];
        LZStorageLog(@"数据库保存路径:%@", dbPath);
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (id)initWithDBWithPath:(NSString *)dbPath
{
    self = [super init];
    if (self) {
        LZStorageLog(@"数据库保存路径:%@", dbPath);
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (void)close
{
    [_dbQueue close];
    _dbQueue = nil;
}

///**********************工具类的方法
/**
 *  获取东八区的 当时时间
 */
- (NSDate *)getEastEightDistrictsTime
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    return [date dateByAddingTimeInterval:interval];
}

- (NSString *)getEastEightDistrictsTimeString
{
    NSDate *datenow = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow dateByAddingTimeInterval:interval];
    NSString *timeSp = [NSString
        stringWithFormat:@"%ld", (long)[localeDate timeIntervalSince1970]];
    return timeSp;
}

- (NSString *)returnInsertFiledWithData:(id)obj
{
    if (![KBTCKeyValueStore isClassFromFoundation:[obj class]]) {
        return updateObject;
    } else {
        return updateObject;
    }
}

///**************************************** 新版数据库
///**************************************************

- (void)createCustomTableWithName:
    (NSString *)tableName // withTableFieldArray:(NSArray *)fieldArray;
{
    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *creat_table_sql =
        [NSString stringWithFormat:CREATE_CUSTOM_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {

      result = [db executeUpdate:creat_table_sql];

      if (!result) {
          LZStorageLog(@"ERROR, 创表 出错 create table: %@", tableName);
      }
    }];
}

- (void)insertwithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
         createdTime:(NSString *)createdTime
           intoTable:(NSString *)tableName
            maxCount:(int)maxCount
               text1:(NSString *)text1
               text2:(NSString *)text2
               text3:(NSString *)text3
{
    LZStorageLog(@"Position:%@",position);
    LZStorageLog(@"objectId:%@",objectId);
    LZStorageLog(@"object:%@",object);
    
    if (objectId == nil || object == nil || position == nil) {
        return;
    }

    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }

    if (maxCount && [self getDbObjCountIsMoreThanTheDefaultCount:maxCount
                                                       fromTable:tableName]) {
        //需要 查询数据库最早的数据 删掉
        NSString *deleteLastObjsql = [NSString
            stringWithFormat:DELETE_LAST_ITEM_SQL, tableName, tableName];
        __block BOOL result;
        [_dbQueue inDatabase:^(FMDatabase *db) {
          result = [db executeUpdate:deleteLastObjsql];
        }];
        if (!result) {
            LZStorageLog(@"ERROR, 删除数据库最早的数据时出错 from table: %@",
                     tableName);
        }
    }

    id dicModel;
    NSData *jsonString;

    NSString *textfiled = [self returnInsertFiledWithData:object];
    if ([textfiled isEqualToString:updateDicmodel]) {
        dicModel = object;
    } else {
        jsonString = [NSKeyedArchiver archivedDataWithRootObject:object];
        //        jsonString = object;
    }
    //为扩展 json做处理
    NSError *error;
    //    NSData * data = [NSJSONSerialization dataWithJSONObject:object
    //    options:0 error:&error];
    //    NSString * jsonString = [[NSString alloc] initWithData:data
    //    encoding:(NSUTF8StringEncoding)];
    if (error) {
        LZStorageLog(
            @"ERROR, 获取 json data 出错 竟然能把这个错提出来 你干了什么事? ");
        return;
    }
    if (nil == createdTime) {
        createdTime = [self getEastEightDistrictsTimeString];
    }
    
    NSString *sql;
    sql = [NSString stringWithFormat:INSERT_CUSTOM_ITEM_SQL, tableName];

    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {

      result =
          [db executeUpdate:sql, objectId, jsonString, dicModel, createdTime,
                            type, position, text1, text2, text3];
    }];
    if (!result) {
        LZStorageLog(@"ERROR, 插入数据 出错 into table: %@", tableName);
    }
}

- (void)insertwithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName
            maxCount:(int)maxCount;
{
    [self insertwithId:objectId
                Object:object
                  type:type
              position:position
           createdTime:nil
             intoTable:tableName
              maxCount:maxCount
                 text1:nil
                 text2:nil
                 text3:nil];
}
///--------------删

/**
 *  通过条件删除数据
 *
 *  @param condition 删除调节
 *  @param tableName 表名
 */
-(void)deleteObjByCondition:(NSString *)condition fromTable:(NSString *)tableName{
    if (nil == condition || condition.length == 0) {
        return;
    }
    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_SQL_WITH_CONDITION, tableName,condition];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
        
    }];
    if (!result) {
        LZStorageLog(@"ERROR, 删除数据时出错 table: %@", tableName);
        LZStorageLog(@"%@", [NSString stringWithFormat:@"您已引发bug 出错 : %@", condition]);
    } else {
        LZStorageLog(@"error :删除了数据: %@", sql);
    }

    
}

/**
 *  删 单个数据
 */
- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName
{
    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
      result = [db executeUpdate:sql, objectId];

    }];
    if (!result) {
        LZStorageLog(@"ERROR, 删除某一条数据时出错 table: %@", tableName);
        LZStorageLog(@"%@", [NSString stringWithFormat:@"您已引发bug 出错 : %@", objectId]);
    } else {
        LZStorageLog(@"Info :成功删除一条数据 id: %@", objectId);
    }
}
/**
 *  判断数据库数据个数  如果大于一定数目  需要删除 时间最早的一条
 */
- (BOOL)getDbObjCountIsMoreThanTheDefaultCount:(int)defCount
                                     fromTable:(NSString *)tableName
{

    NSString *sql = [NSString stringWithFormat:SELECT_COUNT_SQL, tableName];
    __block int jsonCount = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {

      FMResultSet *rs = [db executeQuery:sql];

      if ([rs next]) {
          jsonCount = [rs intForColumn:@"count"];
      }
      [rs close];
    }];
    if (jsonCount < defCount) {
        return NO;
    } else {
        return YES;
    }
}
// 清表
- (void)clearTable:(NSString *)tableName
{
    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
      result = [db executeUpdate:sql];
    }];
    if (!result) {
        LZStorageLog(@"ERROR,清除表 出错 clear table: %@", tableName);
    }
}

/**
 *  删 指定 数组的数据
 */
- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray
                     fromTable:(NSString *)tableName
{
    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSMutableString *stringBuilder = [NSMutableString string];
    for (id objectId in objectIdArray) {
        NSString *item = [NSString stringWithFormat:@" '%@' ", objectId];
        if (stringBuilder.length == 0) {
            [stringBuilder appendString:item];
        } else {
            [stringBuilder appendString:@","];
            [stringBuilder appendString:item];
        }
    }
    NSString *sql =
        [NSString stringWithFormat:DELETE_ITEMS_SQL, tableName, stringBuilder];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
      result = [db executeUpdate:sql];
    }];
    if (!result) {
        LZStorageLog(@"ERROR, 群删 数据时出错 from table: %@", tableName);
    }
}

/**
 *  删除最旧的N条数据
 *
 *  @param condition 删除条件
 *  @param tableName 表名
 *  @param 删除count 条数
 */
-(void)deleteOldObjByCondition:(NSString *)condition fromTable:(NSString *)tableName delCount:(NSString *)count{
    if (nil == condition || condition.length == 0) {
        return;
    }
    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString *sql = [NSString stringWithFormat:DELETE_OLD_COUNT_ITEM, tableName,condition,tableName,condition,count];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
        
    }];
    if (!result) {
        LZStorageLog(@"ERROR, 删除数据时出错 table:%@ condition:%@", tableName, condition);
    } else {
        LZStorageLog(@"error :删除了数据: %@", sql);
    }
}

- (void)updateWithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName
               text1:(NSString *)text1
{
    [self updateWithId:objectId
                Object:object
                  type:type
              position:position
             intoTable:tableName
                 text1:text1
                 text2:nil
                 text3:nil];
}

///----------------改
/**
 *  修改一条数据    id  object pos 不能为空
 */
- (void)updateWithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName
{
    [self updateWithId:objectId
                Object:object
                  type:type
              position:position
             intoTable:tableName
                 text1:nil
                 text2:nil
                 text3:nil];
}

/**
 *  更新一条数据的下面数据
 *  id  object pos 不能为空
 */
- (void)updateOnceWithId:(NSString *)objectId
              Object:(id)object
           intoTable:(NSString *)tableName
               text1:(NSString *)text1
{
    
    if(text1 == nil){
        NSString *sql;
        sql = [NSString
               stringWithFormat:@"update %@ set json=? where id=?", tableName];
        
        __block BOOL result;
        [_dbQueue inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql, [NSKeyedArchiver archivedDataWithRootObject:object],objectId];
        }];
        if (!result) {
            LZStorageLog(@"ERROR, 没有更新 table: %@ obj :%@ ",
                     tableName, object);
        } else {
            LZStorageLog(@" 更新成功 table: %@ obj :%@ ", tableName, object);
        }
        return;

    }
    
    NSString *sql;
    sql = [NSString
           stringWithFormat:@"update %@ set json=?,text1=? where id=?", tableName];
    
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, [NSKeyedArchiver archivedDataWithRootObject:object],text1,objectId];
    }];
    if (!result) {
        LZStorageLog(@"ERROR, 没有更新 table: %@  status : %@  obj :%@ ",
                 tableName, text1, object);
    } else {
        LZStorageLog(@" 更新成功 table: %@  status : %@  obj :%@ ", tableName,
                 text1, object);
    }

}

/**
 *  修改一条数据
 *  id  object pos 不能为空
 */
- (void)updateWithId:(NSString *)objectId
              Object:(id)object
                type:(NSString *)type
            position:(NSString *)position
           intoTable:(NSString *)tableName
               text1:(NSString *)text1
               text2:(NSString *)text2
               text3:(NSString *)text3
{
    [self updateWithId:objectId
        updateCondition:updateObject
                 object:object
              intoTable:tableName];
    
    [self updateWithId:objectId
        updateCondition:updateDicmodel
                 object:object
              intoTable:tableName];
    
    [self updateWithId:objectId
        updateCondition:updateType
                 object:type
              intoTable:tableName];
    
    if (text1 !=nil) {
        [self updateWithId:objectId
           updateCondition:updateText1
                    object:text1
                 intoTable:tableName];
    }
    if (text2!=nil) {
        [self updateWithId:objectId
           updateCondition:updateText2
                    object:text2
                 intoTable:tableName];
    }
    
    if (text3!=nil) {
        [self updateWithId:objectId
           updateCondition:updateText3
                    object:text3
                 intoTable:tableName];
    }
}

/**
 *  根据 id 修改某个字段
 *
 *  @param objectId     id 必填
 *  @param Condition    需要修改的字段 不能是id 与 position
 *  @param object       修改的新数据
 */
- (void)updateWithId:(NSString *)objectId
     updateCondition:(NSString *)condition
              object:(id)object
           intoTable:(NSString *)tableName;
{
    if (objectId == nil || object == nil || condition == nil ||
        [condition isEqualToString:@"position"] ||
        [condition isEqualToString:@"id"]) {
        return;
    }

    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    id upObject = object;
    if ([condition isEqualToString:updateObject] ||
        [condition isEqualToString:updateDicmodel]) { //如果更改条件是 整条数据
                                                      //需要处理
        //要修改哪个字段
        condition = [self returnInsertFiledWithData:object];
        if ([condition isEqualToString:updateDicmodel]) {
            upObject = object;
            //如果存储的是模型需要把 字典删除
            [self updateOneWithId:objectId
                        Condition:updateObject
                        intoTable:tableName];
        } else {

            @try {
                upObject = [NSKeyedArchiver archivedDataWithRootObject:object];
            } @catch (NSException *exception) {
                LZStorageLog(@"KBTCKeyValueStore.m  420行 修改数据  转data出错 \n "
                      @"exception:%@",
                      exception);
            } @finally {
            }

            //            upObject = object;
            //如果存储的是字典 需要把 模型删除
//            [self updateOneWithId:objectId
//                        Condition:updateDicmodel
//                        intoTable:tableName];
        }
    }

    NSString *sql;
    sql = [NSString
        stringWithFormat:UPDATE_CUSTOM_ITEM_SQL, tableName, condition];

    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
      result = [db executeUpdate:sql, upObject, objectId];
    }];
    if (!result) {
        LZStorageLog(@"ERROR, 没有更新 table: %@  condition : %@  obj :%@ ",
                 tableName, condition, object);
    } else {
        LZStorageLog(@" 更新成功 table: %@  condition : %@  obj :%@ ", tableName,
                 condition, object);
    }
}

// 从哪个表清楚哪条id的哪个字段
- (void)updateOneWithId:(NSString *)objectId
              Condition:(NSString *)condition
              intoTable:(NSString *)tableName;
{
    NSString *sql;
    sql = [NSString
        stringWithFormat:UPDATE_ONECONDITON_ITEM_SQL, tableName, condition];

    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
      result = [db executeUpdate:sql, NULL, objectId];
    }];
    if (!result) {
        LZStorageLog(@"ERROR, failed to insert/replace into table: %@", tableName);
    }
}

///----------------查

/**
 *  根据某条id  查询某条数据
 */
- (id)getobjById:(NSString *)Id fromTable:(NSString *)tableName;
{
    [self createCustomTableWithName:tableName];

    NSArray *array = [self
        getObjItemWithSearchCondition:[NSString
                                          stringWithFormat:@"id = '%@'", Id]
                                Count:1
                            fromTable:tableName];
    if (array) {
        return [array lastObject];
    }
    return nil;
}

/**
 *  根据条件筛选
 *
 *  @param Condition 筛选条件 比如 type = 1111 and id > 2 sql条件交给用户
 *
 *  @param count 如果为空默认是所有的数据
 *  @return 返回 这个表中的满足这个查询条件的 数据
 */
- (NSArray *)getObjItemWithSearchCondition:(NSString *)Condition
                                     Count:(int)count
                                 fromTable:(NSString *)tableName;
{
    [self createCustomTableWithName:tableName];

    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString *sql;
    if (Condition) {
        sql = [NSString stringWithFormat:@"%@ %@ where %@ %@",
                                         SELECT_CONDITION_ITEM_SQL, tableName,
                                         Condition, SELECT_MOSAIC_TIME_SQL];
    } else {
        sql = [NSString stringWithFormat:@"%@ %@ %@", SELECT_CONDITION_ITEM_SQL,
                                         tableName, SELECT_MOSAIC_TIME_SQL];
    }
    if (count) {
        sql = [NSString stringWithFormat:@"%@ Limit %d", sql, count];
    }
    return [self getItemsWithSQL:sql andTableName:tableName];

    return nil;
}

/**
 *  从某条数据开始 取几条数据
 *
 *
 *  (倒序 先进后出)
 *  1 >   objId id 如果为空 就是表中倒数的count条数据
 *  2 >   count 如果为空默认是从id之后的所有的数据
 *  3 >   如果 id 与 count 都为空 会是这个表中所有数据
 */
- (NSArray *)getObjItemsWithobjId:(NSString *)objId
                            Count:(int)count
                        fromTable:(NSString *)tableName;
{
    return [self getCustomObjItemsWithobjId:objId
                               isNeedNewObj:NO
                                      Count:count
                                  fromTable:tableName
                                     descBy:nil];
    return nil;
}

- (NSArray *)getNewObjItemsWithobjId:(NSString *)objId
                               Count:(int)count
                           fromTable:(NSString *)tableName;
{

    return [self getCustomObjItemsWithobjId:objId
                               isNeedNewObj:YES
                                      Count:count
                                  fromTable:tableName
                                     descBy:nil];

    return nil;
}

- (NSArray *)getObjItemsWithCount:(int)count
                        fromTable:(NSString *)tableName
                           descBy:(NSString *)columnName;
{

    return [self getCustomObjItemsWithobjId:nil
                               isNeedNewObj:NO
                                      Count:count
                                  fromTable:tableName
                                     descBy:columnName];

    return nil;
}

- (NSArray *)getCustomObjItemsWithobjId:(NSString *)objId
                           isNeedNewObj:(BOOL)needNewObj
                                  Count:(int)count
                              fromTable:(NSString *)tableName
                                 descBy:(NSString *)columnName;
{
    [self createCustomTableWithName:tableName];

    if ([KBTCKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    NSString *sql;

    if (objId) {
        NSString *needNewStr = needNewObj ? @">" : @"<";

        sql = [NSString
            stringWithFormat:@"%@ %@ where createdTime %@ (select createdTime "
                             @"from %@ where id= '%@') %@",
                             SELECT_CONDITION_ITEM_SQL, tableName, needNewStr,
                             tableName, objId, SELECT_MOSAIC_TIME_SQL];
    } else if([tableName rangeOfString:@"table_classNewsList"].location != NSNotFound){
        sql = [NSString stringWithFormat:SELECT_MOMENT_TIME_SQL, tableName];
    } else {
        sql = [NSString stringWithFormat:@"%@ %@ %@", SELECT_CONDITION_ITEM_SQL,
                                         tableName, SELECT_MOSAIC_TIME_SQL];
    }
    if (count) {
        sql = [NSString stringWithFormat:@"%@ Limit %d", sql, count];
    }
    if (columnName) {
        //        sql = [NSString stringWithFormat:@"%@ order by %@
        //        desc",sql,columnName];
    }
    return [self getItemsWithSQL:sql andTableName:tableName];

    return nil;
}

/**
 *  读取某个表中所有的数据
 */
- (NSArray *)getAllItemsFromTable:(NSString *)tableName
{

    NSArray *result =
        [self getObjItemsWithobjId:nil Count:0 fromTable:tableName];
    if (result) {
        return result;
    }

    return nil;
}

/**
 *   取出某个表里面的最新的count条数据
 */
- (NSArray *)getAnyCount:(int)count fromTable:(NSString *)tableName;
{
    NSArray *result =
        [self getObjItemsWithobjId:nil Count:count fromTable:tableName];
    if (result) {
        return result;
    }
    return nil;
}

/**
 *   取出某个表里面的最新的count条数据并按照某个字段降序排序
 */
- (NSArray *)getAnyCount:(int)count
               fromTable:(NSString *)tableName
                  descBy:(NSString *)columnName;
{
    NSArray *result =
        [self getObjItemsWithCount:count fromTable:tableName descBy:columnName];
    if (result) {
        return result;
    }
    return nil;
}

- (NSArray *)getItemsWithSQL:(NSString *)sql andTableName:(NSString *)tableName
{
    LZStorageLog(@"查询 语句 的sql : %@", sql);

    //    NSString * str = [sql substringToIndex:5];
    //    if ([str isEqualToString:@"SELECT"] || [str
    //    isEqualToString:@"select"]) {
    //        这里需要判断是不是 查询语句
    //    }
    __block NSMutableArray *result = [NSMutableArray array];

    [_dbQueue inDatabase:^(FMDatabase *db) {
      FMResultSet *rs = [db executeQuery:sql];
      while ([rs next]) {
          KBTCFMItem *item = [[KBTCFMItem alloc] init];
          item.itemId = [rs stringForColumn:@"id"];
          item.itemObject = [rs dataForColumn:@"json"];
          item.dicModel = [rs stringForColumn:@"dicModel"];
          item.createdTime = [rs dateForColumn:@"createdTime"];
          item.type = [rs stringForColumn:@"type"];
          item.position = [rs stringForColumn:@"position"];
          item.text1 = [rs stringForColumn:@"text1"];
          item.text2 = [rs stringForColumn:@"text2"];
          item.text3 = [rs stringForColumn:@"text3"];
          [result addObject:item];
      }

      [rs close];
    }];
    // parse json string to object
    //    NSError * error;
    NSMutableArray *heehh = [NSMutableArray array];
    for (KBTCFMItem *item in result) {
        KBTCKeyValueItem *keyValueItem = [[KBTCKeyValueItem alloc] init];

        @try {
            if (item.itemObject) {
                item.itemResult = [NSKeyedUnarchiver unarchiveObjectWithData:item.itemObject];
            }
            if (item.dicModel) {
                item.itemResult = item.dicModel;
            }
        }
        @catch (NSException *exception) {
            NSString *itemID = item.itemId;
            [self deleteObjectById:itemID fromTable:tableName];
            continue;
        }
        @finally {
    
        }
        keyValueItem.itemId = item.itemId;
        keyValueItem.itemResult = item.itemResult;
        keyValueItem.createdTime = item.createdTime;
        keyValueItem.type = item.type;
        keyValueItem.position = item.position;
        keyValueItem.text1 = item.text1;
        keyValueItem.text2 = item.text2;
        keyValueItem.text3 = item.text3;
        [heehh addObject:keyValueItem];
        /*
         error = nil;
         id object = [NSJSONSerialization JSONObjectWithData:[item.itemObject
         dataUsingEncoding:NSUTF8StringEncoding]
         options:(NSJSONReadingAllowFragments) error:&error];
         if (error) {
         LZStorageLog(@"ERROR, 读取所有数据时 解析json出错");
         } else {
         }
         */
    }
    return heehh;

    return nil;
}

/**
 *  根据条件获取对象个数
 *  @return
 */
-(int)getObjCountFromTable:(NSString *)tableName withCondition:(NSString *)condition{
    NSString *sql;
    sql = [NSString
           stringWithFormat:COUNT_OBJ_WITH_CONDITION, tableName, condition];
    
    __block FMResultSet *result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeQuery:sql];
    }];
    if ([result next]) {
        int totalCount = [result intForColumnIndex:0];
        return totalCount;
    }
    return 0;
    
}

@end
