This module provides functionality for authenticating to the SharePoint REST API.
This module does not permanently store any data.

# Public Objects

## "SharePoint Auth."

### Example

This example shows how to use the `CreateAuthorizationCode()` function when saving a file to a SharePoint Online library.

```
    internal procedure SaveFile(BaseUrl: Text; LibraryAndFolderPath: Text; Filename: Text; var TempBlob: Codeunit "Temp Blob")
    var
        SharePointFile: Record "SharePoint File";
        SharePointClient: Codeunit "SharePoint Client";
        SaveFailedErr: Label 'Save to SharePoint failed.\ErrorMessage: %1\HttpRetryAfter: %2\HttpStatusCode: %3\ResponseReasonPhrase: %4', Comment = '%1=GetErrorMessage; %2=GetHttpRetryAfter; %3=GetHttpStatusCode; %4=GetResponseReasonPhrase';
        AadTenantId: Text;
        InStream: InStream;
        HttpDiagnostics: Interface "HTTP Diagnostics";
    begin
        AadTenantId := GetAadTenantNameFromBaseUrl(BaseUrl);
        SharePointClient.Initialize(BaseUrl, GetSharePointAuthorization(AadTenantId));
        InStream := TempBlob.CreateInStream();
        if not SharePointClient.AddFileToFolder(LibraryAndFolderPath, Filename, InStream, SharePointFile) then begin
            HttpDiagnostics:= SharePointClient.GetDiagnostics();
            Error(SaveFailedErr, HttpDiagnostics.GetErrorMessage(), HttpDiagnostics.GetHttpRetryAfter(), HttpDiagnostics.GetHttpStatusCode(), HttpDiagnostics.GetResponseReasonPhrase());
        end;
    end;

    local procedure GetSharePointAuthorization(AadTenantId: Text): Interface "SharePoint Authorization"
    var
        SharePointAuth: Codeunit "SharePoint Auth.";
        Scopes: List of [Text];
        ClientId: Text;
        [NonDebuggable]
        ClientSecret: Text;
    begin
        GetAppRegistration(ClientId, ClientSecret);
        Scopes.Add('00000003-0000-0ff1-ce00-000000000000/.default');
        exit(SharePointAuth.CreateAuthorizationCode(AadTenantId, ClientId, ClientSecret, Scopes));
    end;

    local procedure GetAadTenantNameFromBaseUrl(BaseUrl: Text): Text
    var
        Uri: Codeunit Uri;
        MySiteHostSuffixTxt: Label '-my.sharepoint.com', Locked = true;
        SharePointHostSuffixTxt: Label '.sharepoint.com', Locked = true;
        OnMicrosoftTxt: Label '.onmicrosoft.com', Locked = true;
        UrlInvalidErr: Label 'The Base Url %1 does not seem to be a valid SharePoint Online Url.', Comment = '%1=BaseUrl';
        Host: Text;
    begin
        // SharePoint Online format:  https://tenantname.sharepoint.com/SiteName/LibraryName/
        // SharePoint My Site format: https://tenantname-my.sharepoint.com/personal/user_name/
        Uri.Init(BaseUrl);
        Host := Uri.GetHost();
        if not Host.EndsWith(SharePointHostSuffixTxt) then
            Error(UrlInvalidErr, BaseUrl);
        if Host.EndsWith(MySiteHostSuffixTxt) then
            exit(CopyStr(Host, 1, StrPos(Host, MySiteHostSuffixTxt) - 1) + OnMicrosoftTxt);
        exit(CopyStr(Host, 1, StrPos(Host, SharePointHostSuffixTxt) - 1) + OnMicrosoftTxt);
    end;
```

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