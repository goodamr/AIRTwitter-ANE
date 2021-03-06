/**
 * Copyright 2015 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

@class AIRTwitterUser;

@interface UserUtils : NSObject

+ (void) dispatchUsers:(NSArray*) users previousCursor:(NSString*) previousCursor nextCursor:(NSString*) nextCursor callbackID:(int) callbackID;

+ (NSMutableDictionary*) getJSON:(AIRTwitterUser*) user;

+ (NSMutableDictionary*) getTrimmedJSON:(NSDictionary*) user;

+ (AIRTwitterUser*) getUser:(NSDictionary*) json;

@end