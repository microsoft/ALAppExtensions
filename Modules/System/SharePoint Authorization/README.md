This module provides functionality for authenticating to the SharePoint REST API.
This module does not permanently store any data.

### Create Client Credentials
Creates Codeunit implementing "SharePoint Authorization" interface that can later be used with SharePoint module.
### Example

```
    [NonDebuggable]
    procedure CreateUserCredentials(AadTenantId: Text; ClientId: Text; UserName: Text; Credential: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
```

```
    [NonDebuggable]
    procedure CreateUserCredentials(AadTenantId: Text; ClientId: Text; UserName: Text; Credential: Text; Scope: Text): Interface "SharePoint Authorization";
```


