This module provides functionality for authenticating to the SharePoint REST API.
This module does not permanently store any data.

# Public Objects

## "SharePoint Auth."

### Create Client Credentials

Creates a Codeunit implementing "SharePoint Authorization" interface that can later be used with SharePoint module.

This implementation is using the OAuth 2.0 Authorization Code Flow, which means that the access to SharePoint will be performed with the credentials of the currently logged on user, i.e. the user permissions will apply.

The App Registration specified by the ClientId parameter should be assigned the _Delegated_ API Permissions that is needed for the intended operations in the "SharePoint Client" codeunit.

Examples of delegated API Permissions on the **SharePoint** resource:
| Resource | API Permission | Used for |
| -------- | -------------- | -------- |
| SharePoint | AllSites.Write | Reading and writing files on a regular SharePoint site |
| SharePoint | MyFiles.Write | Reading and writing files on the SharePoint My Site (The Personal OneDrive site) |




### CreateAuthorizationCode

Creates an authorization mechanism with authentication code. 

'00000003-0000-0ff1-ce00-000000000000/.default' can be used as the `Scope` parameter, where the guid is the Application Id for Office 365 SharePoint Online.

#### Syntax

```
    [NonDebuggable]
    procedure CreateAuthorizationCode(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scopes: List of [Text]): Interface "SharePoint Authorization";
```

```
    [NonDebuggable]
    procedure CreateAuthorizationCode(AadTenantId: Text; ClientId: Text; ClientSecret: Text; Scope: Text): Interface "SharePoint Authorization";
```
