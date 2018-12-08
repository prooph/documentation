---
outputFileName: index.html
---

# User Management

The Event Store Client API includes helper methods that use the HTTP API to allow for the management of users. This document describes the methods found in the `UsersManager` class.

## Methods

### Create a User

Creates a user, the credentials for this operation must be a member of the `$admins` group.

```php
createUserAsync(
    string $login,
    string $fullName,
    string[] $groups,
    string $password,
    ?UserCredentials $userCredentials = null
): Promise
```

### Disable a User

Disables a user, the credentials for this operation must be a member of the `$admins` group.

```php
disableAsync(
    string $login,
    ?UserCredentials userCredentials = null
): Promise
```

### Enable a User

Enables a user, the credentials for this operation must be a member of the `$admins` group.

```php
enableAsync(
    string $login,
    ?UserCredentials userCredentials = null
): Promise
```

### Delete a User

Deletes (non-recoverable) a user, the credentials for this operation must be a member of the `$admins` group. If you prefer this action to be recoverable, disable the user as opposed to deleting the user.

```php
deleteUserAsync(
    string $login,
    ?UserCredentials userCredentials = null
): Promise
```

### List all Users

Lists all users.

```php
listAllAsync(
    ?UserCredentials userCredentials = null
): Promise<UserDetails[]>
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
    string[] $groups,
    ?UserCredentials $userCredentials = null
): Promise
```

### Reset User Password

Resets the password of a user. The credentials doing this operation must be part of the `$admins` group.

```php
resetPasswordAsync(
    string $login,
    string $newPassword,
    ?UserCredentials $userCredentials = null
): Promise
```
