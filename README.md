# nestjs-grpc

## requirement

```shell
pnpm i -S @grpc/grpc-js @grpc/proto-loader @nestjs/microservices ts-proto
```

## create proto

```proto
syntax = "proto3";

package auth;

service UsersService {
  rpc CreateUser (CreateUserDto) returns (User) {}
  rpc FindAllUsers (Empty) returns (Users) {}
  rpc FindOneUser (FindOneUserDto) returns (User) {}
  rpc UpdateUser (UpdateUserDto) returns (User) {}
  rpc RemoveUser (FindOneUserDto) returns (User) {}
  rpc QueryUsers (stream PaginationDto) returns (stream Users) {}
}
message PaginationDto {
  int32 page = 1;
  int32 skip = 2;
}
message UpdateUserDto {
  string id = 1;
  SocialMedia socialMedia = 2;
}
message FindOneUserDto {
  string id = 1;
}
message Empty {};
message Users {
  repeated User users = 1;
}
message CreateUserDto {
  string username = 1;
  string password = 2;
  int32 age = 3;
}
message User {
  string id = 1;
  string username = 2;
  string password = 3;
  int32 age = 4;
  bool subscribed = 5;
  SocialMedia socialMedia = 6;
}

message SocialMedia {
  optional string twitterUri = 1;
  optional string fbUri = 2;
}
```

## create auth service

```shell
nest g app auth
nest g lib common
```

## register service from proto

```typescript
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { AUTH_SERVICE } from './constants';
import { AUTH_PACKAGE_NAME } from '@app/common';
import { join } from 'path';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: AUTH_SERVICE,
        transport: Transport.GRPC,
        options: {
          package: AUTH_PACKAGE_NAME,
          protoPath: join(__dirname, '../auth.proto'),
        },
      },
    ]),
  ],
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
```

## create microservice

```typescript
import { NestFactory } from '@nestjs/core';
import { AuthModule } from './auth.module';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { join } from 'path';
import { AUTH_PACKAGE_NAME } from '@app/common';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AuthModule,
    {
      transport: Transport.GRPC,
      options: {
        protoPath: join(__dirname, '../auth.proto'),
        package: AUTH_PACKAGE_NAME,
      },
    },
  );
  await app.listen();
}
bootstrap();

```

## create lib shared module
```makefile
.PHONY: proto
TARGET=./libs/common/src/types
gen-proto:
	@protoc --plugin=node_modules/ts-proto/protoc-gen-ts_proto \
		-I=./proto \
		--ts_proto_out=${TARGET} \
		--ts_proto_opt=nestJs=true \
		--ts_proto_opt=fileSuffix=.pb \
		./proto/auth.proto --experimental_allow_proto3_optional
```
```typescript
/* eslint-disable */
import { GrpcMethod, GrpcStreamMethod } from "@nestjs/microservices";
import { Observable } from "rxjs";

export const protobufPackage = "auth";

export interface PaginationDto {
  page: number;
  skip: number;
}

export interface UpdateUserDto {
  id: string;
  socialMedia: SocialMedia | undefined;
}

export interface FindOneUserDto {
  id: string;
}

export interface Empty {
}

export interface Users {
  users: User[];
}

export interface CreateUserDto {
  username: string;
  password: string;
  age: number;
}

export interface User {
  id: string;
  username: string;
  password: string;
  age: number;
  subscribed: boolean;
  socialMedia: SocialMedia | undefined;
}

export interface SocialMedia {
  twitterUri?: string | undefined;
  fbUri?: string | undefined;
}

export const AUTH_PACKAGE_NAME = "auth";

export interface UsersServiceClient {
  createUser(request: CreateUserDto): Observable<User>;

  findAllUsers(request: Empty): Observable<Users>;

  findOneUser(request: FindOneUserDto): Observable<User>;

  updateUser(request: UpdateUserDto): Observable<User>;

  removeUser(request: FindOneUserDto): Observable<User>;

  queryUsers(request: Observable<PaginationDto>): Observable<Users>;
}

export interface UsersServiceController {
  createUser(request: CreateUserDto): Promise<User> | Observable<User> | User;

  findAllUsers(request: Empty): Promise<Users> | Observable<Users> | Users;

  findOneUser(request: FindOneUserDto): Promise<User> | Observable<User> | User;

  updateUser(request: UpdateUserDto): Promise<User> | Observable<User> | User;

  removeUser(request: FindOneUserDto): Promise<User> | Observable<User> | User;

  queryUsers(request: Observable<PaginationDto>): Observable<Users>;
}

export function UsersServiceControllerMethods() {
  return function (constructor: Function) {
    const grpcMethods: string[] = ["createUser", "findAllUsers", "findOneUser", "updateUser", "removeUser"];
    for (const method of grpcMethods) {
      const descriptor: any = Reflect.getOwnPropertyDescriptor(constructor.prototype, method);
      GrpcMethod("UsersService", method)(constructor.prototype[method], method, descriptor);
    }
    const grpcStreamMethods: string[] = ["queryUsers"];
    for (const method of grpcStreamMethods) {
      const descriptor: any = Reflect.getOwnPropertyDescriptor(constructor.prototype, method);
      GrpcStreamMethod("UsersService", method)(constructor.prototype[method], method, descriptor);
    }
  };
}

export const USERS_SERVICE_NAME = "UsersService";

```