//
//  BaseDataMode.m
//  用例测试
//
//  Created by nianfangge on 15/7/25.
//  Copyright (c) 2015年 farben. All rights reserved.
//

#import "BaseDataModel.h"
#import <objc/runtime.h>

//// 获取类的所有Property
//1. objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
//// 获取一个Property的变量名
//2. const char *property_getName(objc_property_t property)
//// 获取一个Property的详细类型表达字符串
//3. const char *property_getAttributes(objc_property_t property)


@interface NSObject(PropertyTypeValue)
+(NSDictionary*)getClassPropertysAndType;
-(NSDictionary *)outPutArray;
-(NSDictionary *)outPutDic;
@end
@implementation NSObject(PropertyTypeValue)
static NSDictionary *primitivesNames = nil;
//获取一个类的属性名和类型
+(NSDictionary*)getClassPropertysAndType
{
    if(primitivesNames== nil){
        primitivesNames = @{@"f":@"float", @"i":@"int", @"d":@"double", @"l":@"long", @"c":@"BOOL", @"s":@"short", @"q":@"long",
                            //and some famos aliases of primitive types
                            // BOOL is now "B" on iOS __LP64 builds
                            @"I":@"NSInteger", @"Q":@"NSUInteger", @"B":@"BOOL",
                            @"@?":@"Block"};
    }
    NSMutableDictionary *properts_info = [[NSMutableDictionary alloc] init];
    Class curClass = [self class];
    NSScanner *scanner = nil;
    NSString* propertyType = nil;
    
    while (curClass && curClass != [NSObject class]) {
        
        objc_property_t  *propItems;
        unsigned int     ncount = 0;
        //        获取类的所有Property
        propItems = class_copyPropertyList(curClass, &ncount);
        
        for(int i = 0; i < ncount; i++){
            objc_property_t prop_item = propItems[i];
            // 获取一个Property的变量名
            const char *properName = property_getName(prop_item);
            // 获取一个Property的详细类型表达字符串
            const char *attribute = property_getAttributes(prop_item);
            
            NSString* propertyAttributes = @(attribute);
            
            // NSLog(@"---------->property attributes:%@",propertyAttributes);
            
            NSString  *proper_Name = @(properName);
            
            NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
            //ignore read-only properties
            if([attributeItems containsObject:@"R"]){
                continue;//to next property
            }
            
            //check for 64b BOOLs
            if ([propertyAttributes hasPrefix:@"Tc,"]) {
                //mask BOOLs as structs so they can have custom convertors
                propertyType = @"BOOL";
            }
            
            scanner = [NSScanner scannerWithString:propertyAttributes];
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                
                //read through the property protocols
                while ([scanner scanString:@"<" intoString:NULL]) {
                    
                    [scanner scanUpToString:@">" intoString:&propertyType];
                    
                    [scanner scanString:@">" intoString:NULL];
                }
            }
            //check if the property is a structure
            else if ([scanner scanString:@"{" intoString: &propertyType]) {
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                                    intoString:&propertyType];
                
            }
            else if([[attributeItems firstObject] isEqualToString:@"T@"]){
                propertyType = @"id";
            }
            else if([[attributeItems firstObject] isEqualToString:@"T@?"]){
                propertyType = @"Block";
            }
            //the property must be a primitive
            else {
                //the property contains a primitive data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                //get the full name of the primitive type
                propertyType = primitivesNames[propertyType];
            }
            
            if(propertyType){
                properts_info[proper_Name] = propertyType;
            }
            
        }
        free(propItems);
        
        curClass = [curClass superclass];
    }
    
    NSDictionary *prop_info = [properts_info copy];
    properts_info = nil;
    
    return prop_info;
}

-(NSMutableArray *)outPutArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *selfArray = (NSArray *)self;
    for (int itemIndex = 0; itemIndex < selfArray.count; itemIndex++) {
        id value = [selfArray objectAtIndex:itemIndex];
        
        unsigned int outCount;
        //        获取类的 Property
        objc_property_t *properties = class_copyPropertyList([value class], &outCount);
        
        if(outCount > 0)
        {
            [array addObject:[value outPutDic]];
        }
        else {
            [array addObject:value];
            
        }
        
        free(properties);
    }
    
    return array;
}
-(NSMutableDictionary *)outPutDic
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSDictionary *propertiesInfo = [[self class] getClassPropertysAndType];
    
    [propertiesInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *propertyName = (NSString*)key;
        NSString *propertyType = (NSString*)obj;
        if(propertyName){
            if([NSClassFromString(propertyType) isSubclassOfClass:NSClassFromString(@"NSString")])
            {
                if([self valueForKey:propertyName] == nil){
                    [dict setObject:@"" forKey:propertyName];
                }
                else{
                    [dict setObject:[self valueForKey:propertyName] forKey:propertyName];
                }
            }
            else if ([NSClassFromString(propertyType) isSubclassOfClass:NSClassFromString(@"NSNumber")])
            {
                if([self valueForKey:propertyName] == nil){
                    [dict setObject:[NSNull null] forKey:propertyName];
                }
                else{
                    [dict setObject:[self valueForKey:propertyName] forKey:propertyName];
                }
            }
            else if ([NSClassFromString(propertyType) isSubclassOfClass:NSClassFromString(@"NSArray")])
            {
                if([self valueForKey:propertyName] == nil){
                    [dict setObject:[NSArray array] forKey:propertyName];
                }
                else{
                    NSArray *value = [self valueForKey:propertyName];
                    NSArray *arrayOfValue = [value outPutArray];
                    [dict setObject:arrayOfValue forKey:propertyName];
                }
            }
            else if ([NSClassFromString(propertyType) isSubclassOfClass:NSClassFromString(@"NSDictionary")])
            {
                if([self valueForKey:propertyName] == nil){
                    [dict setObject:[NSDictionary dictionary] forKey:propertyName];
                }
                else{
                    NSDictionary *value = [self valueForKey:propertyName];
                    NSDictionary *dictOfValue = [value outPutDic];
                    [dict setObject:dictOfValue forKey:propertyName];
                }
            }
            else if ([NSClassFromString(propertyType) isSubclassOfClass:NSClassFromString(@"NSData")])
            {
                if([self valueForKey:propertyName] == nil){
                    [dict setObject:[NSNull null] forKey:propertyName];
                }
                else{
                    NSDictionary *value = [self valueForKey:propertyName];
                    [dict setObject:value forKey:propertyName];
                }
            }
            else if([propertyType isEqualToString:primitivesNames[@"i"]])
            {
                [dict setObject:[NSNumber numberWithInt:[[self valueForKey:propertyName] intValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:primitivesNames[@"I"]])
            {
                [dict setObject:[NSNumber numberWithInteger:[[self valueForKey:propertyName] integerValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:primitivesNames[@"Q"]])
            {
                [dict setObject:[NSNumber numberWithUnsignedInteger:[[self valueForKey:propertyName] unsignedIntegerValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:primitivesNames[@"B"]] || [propertyType isEqualToString:primitivesNames[@"c"]])
            {
                [dict setObject:[NSNumber numberWithInt:[[self valueForKey:propertyName] boolValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:primitivesNames[@"d"]]){
                [dict setObject:[NSNumber numberWithDouble:[[self valueForKey:propertyName] doubleValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:primitivesNames[@"f"]])
            {
                [dict setObject:[NSNumber numberWithFloat:[[self valueForKey:propertyName] floatValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:primitivesNames[@"l"]] || [propertyType isEqualToString:primitivesNames[@"q"]])
            {
                [dict setObject:[NSNumber numberWithLong:[[self valueForKey:propertyName] longValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:primitivesNames[@"s"]])
            {
                [dict setObject:[NSNumber numberWithShort:[[self valueForKey:propertyName] shortValue]] forKey:propertyName];
            }
            else if([propertyType isEqualToString:@"id"])
            {
                //can't convert.
                id value = [self valueForKey:propertyName];
                if (value) {
                    NSDictionary *dictOfValue = [value outPutDic];
                    [dict setObject:dictOfValue forKey:propertyName];
                }
                else{
                    [dict setObject:[NSNull null] forKey:propertyName];
                }
            }
            else if([propertyType isEqualToString:@""])
            {
                //can't convert.
            }
            else {
                id value = [self valueForKey:propertyName];
                if (value) {
                    NSDictionary *dictOfValue = [value outPutDic];
                    [dict setObject:dictOfValue forKey:propertyName];
                }
                else{
                    [dict setObject:[NSNull null] forKey:propertyName];
                }
            }
        }
    }];
    propertiesInfo = nil;
    return dict;
}

@end

@interface BaseDataModel()

@end
@implementation BaseDataModel
+(id)makeDataModelByJson:(NSString*)jsonString
{
    if (jsonString != nil) {
        
        id dicInfo = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        return [self makeDataModel:dicInfo];
    }
    
    return nil;
}


+(id)makeDataModel:(id)properties
{
    if([properties isKindOfClass:[NSDictionary class]]){
        id obj = [[self alloc] init];
        [obj setValuesForKeysWithDictionary:properties];
        return obj;
    }
    else if([properties isKindOfClass:[self class]]){
        return properties;
    }
    return nil;
}

-(id)initWithDictionary:(NSDictionary*)properties
{
    self = [super init];
    if(self){
        [self setValuesForKeysWithDictionary:properties];
    }
    return self;
}

-(void)setValuesForKeysWithDictionary:(NSDictionary *)dic
{
    NSMutableDictionary *dicTmp = [self outPutDic];
    for (id key in [dicTmp allKeys]) {
        id value = [dic objectForKey:key];
        if (value) {
            [self setValue:value forKey:key];
        }
    }
    [dicTmp removeAllObjects];
    dicTmp = nil;
}

-(void)makeClassWithProperties:(NSMutableArray*)properties customClassName:(NSString*)className
{
    if(!properties) return;
    
    for (int i = 0; i < properties.count ;i++) {
        Class cls = NSClassFromString(className);
        id sub = properties[i];
        
        if([cls isSubclassOfClass:[BaseDataModel class]]){
            id obj = [cls makeDataModel:sub];
            if(obj){
                [properties replaceObjectAtIndex:i withObject:obj];
            }
        }
    }
}

-(NSMutableDictionary*)toDictionary
{
    return [self outPutDic];
#if 0
    NSDictionary *propertyInfo = [[self class] getClassPropertysAndType];
    if(propertyInfo && propertyInfo.count > 0){
        NSMutableDictionary *outDic = [[NSMutableDictionary alloc] initWithCapacity:propertyInfo.count];
        
        for (NSString *key in [propertyInfo allKeys]) {
            id value = [self valueForKey:key];
            if(value && [value isKindOfClass:[BaseDataModel class]]){
                [outDic setObject:[value toDictionary] forKey:key];
            }
            else if(value && [value isKindOfClass:[NSArray class]] && [(NSArray*)value count] > 0){
                id subValue = [value objectAtIndex:0];
                if(subValue && [subValue isKindOfClass:[BaseDataModel class]]){
                    NSMutableArray *subItems = [NSMutableArray array];
                    for (id item in value) {
                        [subItems addObject:[item toDictionary]];
                    }
                    [outDic setObject:subItems forKey:key];
                }
                else{
                    [outDic setObject:value forKey:key];
                }
            }
            else if(value != nil){
                outDic[key] = value;
            }else{
                
                //                if([propertyInfo[key] isKindOfClass:[NSString class]]){
                //                    outDic[key] = @"";
                //                }
                //                else{
                //                    outDic[key] = [NSNull null];
                //                }
                
                //value is nil
                NSString *valueType = [propertyInfo objectForKey:key];
                //                outDic[key] = [[NSClassFromString(valueType) alloc] init];
                
                if ([valueType isEqualToString:NSStringFromClass([NSMutableArray class])] || [valueType isEqualToString:NSStringFromClass([NSArray class])]) {
                    outDic[key] = [NSMutableArray array];
                } else if ([valueType isEqualToString:NSStringFromClass([NSMutableDictionary class])] || [valueType isEqualToString:NSStringFromClass([NSDictionary class])]) {
                    outDic[key] = [NSMutableDictionary dictionary];
                } else {
                    outDic[key] = [NSNull null];
                }
                //mdy by neil.libo 2015.1.6
                
                //                if([propertyInfo[key] isKindOfClass:[NSString class]]){
                //                    outDic[key] = @"";
                //                }
                //                else{
                //                    outDic[key] = [NSNull null];
                //                }
                
            }
        }
        propertyInfo = nil;
        return outDic;
    }  
    propertyInfo = nil;
    return nil;
#endif
}

@end
