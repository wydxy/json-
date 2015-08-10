//
//  UserModel.h
//  TestEamp
//
//  Created by kmgao on 14/12/23.
//  Copyright (c) 2014年 kmgao. All rights reserved.
//

#import "BaseDataModel.h"

@interface UserModel : BaseDataModel

@property(nonatomic,strong)  NSString  *status;
@property(nonatomic,strong)  NSString  *server_time;

@property(nonatomic,strong)  NSString  *uuid;
@property(nonatomic,strong)  NSString  *name;
@property(nonatomic,strong)  NSString  *password;
@property(nonatomic,strong)  NSString  *create_time;
@property(nonatomic,strong)  NSString  *register_time;

@property(nonatomic,strong)  NSString  *crm_uuid;



@end
