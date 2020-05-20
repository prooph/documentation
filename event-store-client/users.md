---
outputFileName: index.html
---

# User Management

The Event Store Client API includes helper methods that use the HTTP API to allow for the management of users. This document describes the methods found in the `\Prooph\EventStore\Async\UserManagement\UsersManager` implementations.

## Methods

### Create a User

Creates a user, the credentials for this operation must be a member of the `$admins` group.

```php
createUserAsync(
    string $login,
    string $fullName,
    list<string> $groups,
    string $password,
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### Disable a User

Disables a user, the credentials for this operation must be a member of the `$admins` group.

```php
disableAsync(
    string $login,
    ?UserCredentials userCredentials = null
): Promise<void>
```

### Enable a User

Enables a user, the credentials for this operation must be a member of the `$admins` group.

```php
enableAsync(
    string $login,
    ?UserCredentials userCredentials = null
): Promise<void>
```

### Delete a User

Deletes (non-recoverable) a user, the credentials for this operation must be a member of the `$admins` group. If you prefer this action to be recoverable, disable the user as opposed to deleting the user.

Throws `\Prooph\EventStoreClient\Exception\UserCommandFailed` when server returns an error. 

```php
deleteUserAsync(
    string $login,
    ?UserCredentials userCredentials = null
): Promise<void>
```

### List all Users

Lists all users.

```php
listAllAsync(
    ?UserCredentials userCredentials = null
): Promise<list<UserDetails>>
```

### Get Details of User

Return the details of the user supplied in user credentials (e.g. the user making the request).

```php
getCurrentUserAsync(
    ?UserCredentials $userCredentials = null
): Promise<UserDetails>
```

### Get Details of Logged in User

```php
getUserAsync(
    string $login,
    ?UserCredentials $userCredentials = null
): Promise<UserDetails>
```

### Update User Details

```php
updateUserAsync(
    string $login,
    string $fullName,
    list<string> $groups,
    ?UserCredentials $userCredentials = null
): Promise<void>
```

### Change User Password

Change the password of the specified user. The credentials doing this operation must be part of the `$admins` group.

```php
changePasswordAsync(
    string $login,
    string $oldPassword,
    string $newPassword,
    ?UserCredentials $userCredentials = null
): Promise<void>
```


### Reset User Password

Resets the password of a user. The credentials doing this operation must be part of the `$admins` group.

```php
resetPasswordAsync(
    string $login,
    string $newPassword,
    ?UserCredentials $userCredentials = null
): Promise<void>
```
