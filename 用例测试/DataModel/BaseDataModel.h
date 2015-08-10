//
//  BaseDataMode.h
//  用例测试
//
//  Created by nianfangge on 15/7/25.
//  Copyright (c) 2015年 farben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDataModel : NSObject

/*!
 @brief  把json串转成数据结构
 
 @param jsonString 把json字符串转化成类结构对象
 
 @return 返回对应的数据模型
 */

+(id)makeDataModelByJson:(NSString*)jsonString;

/*!
 @brief  子类可以覆盖定义自己的实现,基类只实现自己本身的属性值
 
 @param properties 转成对象数据模型的字典
 
 @return 返回对应的数据模型
 */
+(id)makeDataModel:(id)properties;

/*!
 @brief  使用指定的字典给对象属性赋值
 
 @param properties 字段属性字典
 
 @return 返回对应的数据模型
 */
-(id)initWithDictionary:(NSDictionary*)properties;

/*!
 @brief  获取这个类里所有非只读的属性列表,字典里key为属性名,值value为数据类型
 
 @return 返回这个类里所有的属性列表,包括基类
 */
+(NSDictionary*)getClassProperties;

/*!
 @brief  如果类里自定义的类对象数组,则通过这个方法把字典里的字段付给的自定义类对象字段
 
 @param properties 类对象里的自定义类数组
 @param className  自定义类的名字
 */

-(void)makeClassWithProperties:(NSMutableArray*)properties customClassName:(NSString*)className;

/*!
 @brief  通过字典给对象字段付值
 
 @param dic 付值的字典内容
 */
-(void)setValuesForKeysWithDictionary:(NSDictionary *)dic;
@end
