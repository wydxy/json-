//
//  UserModel.m
//  TestEamp
//
//  Created by kmgao on 14/12/23.
//  Copyright (c) 2014年 kmgao. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel


- (NSString *)description
{
    return [NSString stringWithFormat:@"user:{\n status=%@,\n server_time=%@,\n uuid=%@,\n name=%@,\n password=%@,\n create_time=%@,\n register_time=%@,\n crm_uuid=%@\n}",
            self.status,
            self.server_time,
            self.uuid,
            self.name,
            self.password,
            self.create_time,
            self.register_time,
            self.crm_uuid
            ];
}

@end
