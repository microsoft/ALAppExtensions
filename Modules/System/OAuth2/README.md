This module contains tools that support authentication through Azure Active Directory (Azure AD) using OAuth 2.0 authorization protocols.

To learn more about the Microsoft Identity Platform, see [Microsoft Identity Platform documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/).

Use this module to do the following:
- Acquire a token by using the authorization code grant flow. For more information, see [Authorize access to Azure Active Directory web applications using the OAuth 2.0 code grant flow](https://docs.microsoft.com/en-us/azure/active-directory/azuread-dev/v1-protocols-oauth-code/) for v1.0 or [Microsoft identity platform and OAuth 2.0 authorization code flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow/) for v2.0.<br />
- Acquire a token by using the On-Behalf-Of (OBO) flow. For more information, see [Service-to-service calls that use delegated user identity in the On-Behalf-Of flow](https://docs.microsoft.com/en-us/azure/active-directory/azuread-dev/v1-oauth2-on-behalf-of-flow/) for v1.0 or [Microsoft identity platform and OAuth 2.0 On-Behalf-Of flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow) for v2.0.<br />
- Ask for directory admin consent for all the defined application permissions, see [Admin consent on the Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-admin-consent)
- Acquire a token by using the client credentials grant flow. This requires that the administrator user has already consented the required application permissions. For more information, see [Service to service calls using client credentials](https://docs.microsoft.com/en-us/azure/active-directory/azuread-dev/v1-oauth2-client-creds-grant-flow/) for v1.0 or [Microsoft identity platform and the OAuth 2.0 client credentials flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow) for v2.0. To learn more about admin-restricted permissions, see [Admin-restricted permissions](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-permissions-and-consent#admin-restricted-permissions/).<br />
- Acquire the authorization code token from cache or a new refreshed token if the existing one has expired. This requires that the token was obtained earlier through the authorization code flow. This returns either the current token from cache or will try to refresh it in the background and return a new access token.<br />
- Acquire the access and refresh tokens by using the OBO flow. For more information, see [Service-to-service calls that use delegated user identity in the On-Behalf-Of flow](https://docs.microsoft.com/en-us/azure/active-directory/azuread-dev/v1-oauth2-on-behalf-of-flow/) for v1.0 or [Microsoft identity platform and OAuth 2.0 On-Behalf-Of flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow) for v2.0.<br />.<br />
- Acquire the OBO token from cache or a new refreshed token if the existing one has expired. This requires that the token was obtained earlier through the OBO flow. This returns either the current token from cache or will try to refresh it in the background and return a new access token.<br />
- Retrieve Business Central default Redirect URL.<br />



# Public Objects
## OAuth2 (Codeunit 501)

 Contains methods supporting authentication via OAuth 2.0 protocol.
 

### AcquireTokenByAuthorizationCode (Method) <a name="AcquireTokenByAuthorizationCode"></a> 

 Gets the authorization token based on the authorization code via the OAuth2 v1.0 code grant flow.
 

#### Syntax
```
[NonDebuggable]
[Obsolete('Replaced with AcquireTokenByAuthorizationCode with Scopes parameter', '18.0')]
[TryFunction]
procedure AcquireTokenByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.

*AuthCodeErr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokenByAuthorizationCodeWithCertificate (Method) <a name="AcquireTokenByAuthorizationCodeWithCertificate"></a> 

 Gets the authorization token based on the authorization code via the OAuth2 v1.0 code grant flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokenByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the Application (client) configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.

*AuthCodeErr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokenByAuthorizationCode (Method) <a name="AcquireTokenByAuthorizationCode"></a> 

 Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokenByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.

*AuthCodeErr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokenByAuthorizationCodeWithCertificate (Method) <a name="AcquireTokenByAuthorizationCodeWithCertificate"></a> 

 Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokenByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var AuthCodeErr: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.

*AuthCodeErr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokensByAuthorizationCode (Method) <a name="AcquireTokensByAuthorizationCode"></a> 

 Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokensByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var AuthCodeErr: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

*AuthCodeErr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokensByAuthorizationCodeWithCertificate (Method) <a name="AcquireTokensByAuthorizationCodeWithCertificate"></a> 

 Gets the authorization token based on the authorization code via the OAuth2 v2.0 code grant flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokensByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var AuthCodeErr: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the AuthCodeErr for a description of the error.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

*AuthCodeErr ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokenAndTokenCacheByAuthorizationCode (Method) <a name="AcquireTokenAndTokenCacheByAuthorizationCode"></a> 

 Gets the access token and token cache state with authorization code flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokenAndTokenCacheByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var TokenCache: Text; var Error: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the Error for a description of the error.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the token cache acquired when the access token was requested.

*Error ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokenAndTokenCacheByAuthorizationCodeWithCertificate (Method) <a name="AcquireTokenAndTokenCacheByAuthorizationCodeWithCertificate"></a> 

 Gets the access token and token cache state with authorization code flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokenAndTokenCacheByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var TokenCache: Text; var Error: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the Error for a description of the error.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the token cache acquired when the access token was requested.

*Error ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokensAndTokenCacheByAuthorizationCode (Method) <a name="AcquireTokensAndTokenCacheByAuthorizationCode"></a> 

 Gets the access token and token cache state with authorization code flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokensAndTokenCacheByAuthorizationCode(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var TokenCache: Text; var Error: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the Error for a description of the error.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the token cache acquired when the access token was requested.

*Error ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireTokensAndTokenCacheByAuthorizationCodeWithCertificate (Method) <a name="AcquireTokensAndTokenCacheByAuthorizationCodeWithCertificate"></a> 

 Gets the access token and token cache state with authorization code flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokensAndTokenCacheByAuthorizationCodeWithCertificate(ClientId: Text; Certificate: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text; var IdToken: Text; var TokenCache: Text; var Error: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the "Azure portal – App registrations" experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the application (client) configured in the "Azure Portal - Certificates & Secrets".

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*PromptInteraction ([Enum "Prompt Interaction"]())* 

Indicates the type of user interaction that is required.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token. When this parameter is empty, check the Error for a description of the error.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the token cache acquired when the access token was requested.

*Error ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the authorization code grant flow. This parameter will be empty in case the token is aquired successfuly.

### AcquireOnBehalfOfToken (Method) <a name="AcquireOnBehalfOfToken"></a> 

 Gets the authentication token via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[Obsolete('Replaced with AcquireOnBehalfOfToken with Scopes parameter', '18.0')]
[TryFunction]
procedure AcquireOnBehalfOfToken(RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
```
#### Parameters
*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireOnBehalfOfToken (Method) <a name="AcquireOnBehalfOfToken"></a> 

 Gets the authentication token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[TryFunction]
procedure AcquireOnBehalfOfToken(RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text)
```
#### Parameters
*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireOnBehalfOfTokens (Method) <a name="AcquireOnBehalfOfTokens"></a> 

 Gets the authentication token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[TryFunction]
procedure AcquireOnBehalfOfTokens(RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text)
```
#### Parameters
*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

### RequestClientCredentialsAdminPermissions (Method) <a name="RequestClientCredentialsAdminPermissions"></a> 

 Request the permissions from a directory admin.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure RequestClientCredentialsAdminPermissions(ClientId: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; var HasGrantConsentSucceeded: Boolean; var PermissionGrantError: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*HasGrantConsentSucceeded ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Exit parameter indicating the success of granting application permissions.

*PermissionGrantError ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the encountered error in the application permissions grant. This parameter will be empty in case the flow is completed successfuly.

### AcquireTokenWithClientCredentials (Method) <a name="AcquireTokenWithClientCredentials"></a> 

 Gets the access token via the Client Credentials OAuth2 v1.0 grant flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokenWithClientCredentials(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireTokenWithClientCredentials (Method) <a name="AcquireTokenWithClientCredentials"></a> 

 Gets the access token via the Client Credentials OAuth2 v2.0 grant flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokenWithClientCredentials(ClientId: Text; ClientSecret: Text; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireAuthorizationCodeTokenFromCache (Method) <a name="AcquireAuthorizationCodeTokenFromCache"></a> 

 Gets the access token from cache or a refreshed token via OAuth2 v1.0 protocol.
 

#### Syntax
```
[NonDebuggable]
[Obsolete('Added OAuthority parameter', '17.0')]
[TryFunction]
procedure AcquireAuthorizationCodeTokenFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireAuthorizationCodeTokenFromCache (Method) <a name="AcquireAuthorizationCodeTokenFromCache"></a> 

 Gets the access token from cache or a refreshed token via OAuth2 v1.0 protocol.
 

#### Syntax
```
[NonDebuggable]
[Obsolete('Replaced with AcquireAuthorizationCodeTokenFromCache with Scopes parameter', '18.0')]
[TryFunction]
procedure AcquireAuthorizationCodeTokenFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; ResourceURL: Text; var AccessToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireAuthorizationCodeTokenFromCacheWithCertificate (Method) <a name="AcquireAuthorizationCodeTokenFromCacheWithCertificate"></a> 

 Gets the access token from cache or a refreshed token via OAuth2 v1.0 protocol.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireAuthorizationCodeTokenFromCacheWithCertificate(ClientId: Text; Certificate: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; ResourceURL: Text; var AccessToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the Application (client) configured in the Azure Portal - Certificates & Secrets.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireAuthorizationCodeTokenFromCache (Method) <a name="AcquireAuthorizationCodeTokenFromCache"></a> 

 Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireAuthorizationCodeTokenFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireTokensFromCache (Method) <a name="AcquireTokensFromCache"></a> 

 Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokensFromCache(ClientId: Text; ClientSecret: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

### AcquireAuthorizationCodeTokenFromCacheWithCertificate (Method) <a name="AcquireAuthorizationCodeTokenFromCacheWithCertificate"></a> 

 Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireAuthorizationCodeTokenFromCacheWithCertificate(ClientId: Text; Certificate: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the Application (client) configured in the Azure Portal - Certificates & Secrets.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

### AcquireTokensFromCacheWithCertificate (Method) <a name="AcquireTokensFromCacheWithCertificate"></a> 

 Gets the access token from cache or a refreshed token via OAuth2 v2.0 protocol.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokensFromCacheWithCertificate(ClientId: Text; Certificate: Text; RedirectURL: Text; OAuthAuthorityUrl: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Base64-encoded certificate for the Application (client) configured in the Azure Portal - Certificates & Secrets.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

### AcquireOnBehalfAccessTokenAndRefreshToken (Method) <a name="AcquireOnBehalfAccessTokenAndRefreshToken"></a> 

 Gets the access and refresh token via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[Obsolete('Renaming to AcquireOnBehalfAccessTokenAndTokenCache', '18.0')]
[TryFunction]
procedure AcquireOnBehalfAccessTokenAndRefreshToken(OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text; var RefreshToken: Text)
```
#### Parameters
*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*RefreshToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the refresh_token that you acquired when you requested an access token.

### AcquireOnBehalfAccessTokenAndTokenCache (Method) <a name="AcquireOnBehalfAccessTokenAndTokenCache"></a> 

 Gets the access token and token cache  via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[Obsolete('Replaced with AcquireOnBehalfAccessTokenAndTokenCache with Scopes parameter', '18.0')]
[TryFunction]
procedure AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl: Text; RedirectURL: Text; ResourceURL: Text; var AccessToken: Text; var TokenCache: Text)
```
#### Parameters
*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the token cache acquired when the access token was requested .

### AcquireOnBehalfAccessTokenAndRefreshToken (Method) <a name="AcquireOnBehalfAccessTokenAndRefreshToken"></a> 

 Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[Obsolete('Renaming to AcquireOnBehalfAccessTokenAndTokenCache ', '18.0')]
[TryFunction]
procedure AcquireOnBehalfAccessTokenAndRefreshToken(OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var RefreshToken: Text)
```
#### Parameters
*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*RefreshToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the refresh_token that you acquired when you requested an access token.

### AcquireOnBehalfAccessTokenAndTokenCache (Method) <a name="AcquireOnBehalfAccessTokenAndTokenCache"></a> 

 Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[TryFunction]
procedure AcquireOnBehalfAccessTokenAndTokenCache(OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var TokenCache: Text)
```
#### Parameters
*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the token cache acquired when the access token was requested .

### AcquireOnBehalfTokensAndTokenCache (Method) <a name="AcquireOnBehalfTokensAndTokenCache"></a> 

 Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[TryFunction]
procedure AcquireOnBehalfTokensAndTokenCache(OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [Text]; var AccessToken: Text; var IdToken: Text; var TokenCache: Text)
```
#### Parameters
*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the token cache acquired when the access token was requested .

### AcquireOnBehalfOfTokenByRefreshToken (Method) <a name="AcquireOnBehalfOfTokenByRefreshToken"></a> 

 Gets the access and refresh token via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[Obsolete('Renaming to AcquireOnBehalfOfTokenByTokenCache ', '18.0')]
[TryFunction]
procedure AcquireOnBehalfOfTokenByRefreshToken(ClientId: Text; RedirectURL: Text; ResourceURL: Text; RefreshToken: Text; var AccessToken: Text; var NewRefreshToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*RefreshToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The refresh_token that you acquired when you requested an access token.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*NewRefreshToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the new refresh token.

### AcquireOnBehalfOfTokenByTokenCache (Method) <a name="AcquireOnBehalfOfTokenByTokenCache"></a> 

 Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[Obsolete('Replaced with AcquireOnBehalfOfTokenByTokenCache with Scopes parameter', '18.0')]
[TryFunction]
procedure AcquireOnBehalfOfTokenByTokenCache(LoginHint: Text; RedirectURL: Text; ResourceURL: Text; TokenCache: Text; var AccessToken: Text; var NewTokenCache: Text)
```
#### Parameters
*LoginHint ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user login hint, i.e. authentication email.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*ResourceURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application ID of the resource the application is requesting access to. This parameter can be empty.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The token cache acquired when the access token was requested .

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*NewTokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the new token cache.

### AcquireOnBehalfOfTokenByRefreshToken (Method) <a name="AcquireOnBehalfOfTokenByRefreshToken"></a> 

 Gets the access and refresh token via the On-Behalf-Of OAuth2 v2.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[Obsolete('Renaming to AcquireOnBehalfOfTokenByTokenCache ', '18.0')]
[TryFunction]
procedure AcquireOnBehalfOfTokenByRefreshToken(ClientId: Text; RedirectURL: Text; Scopes: List of [Text]; RefreshToken: Text; var AccessToken: Text; var NewRefreshToken: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal – App registrations experience assigned to your app.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*RefreshToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The refresh_token that you acquired when you requested an access token.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*NewRefreshToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the new refresh token.

### AcquireOnBehalfOfTokenByTokenCache (Method) <a name="AcquireOnBehalfOfTokenByTokenCache"></a> 

 Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[TryFunction]
procedure AcquireOnBehalfOfTokenByTokenCache(LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var NewTokenCache: Text)
```
#### Parameters
*LoginHint ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user login hint, i.e. authentication email.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The token cache acquired when the access token was requested .

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*NewTokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the new token cache.

### AcquireOnBehalfOfTokensByTokenCache (Method) <a name="AcquireOnBehalfOfTokensByTokenCache"></a> 

 Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[TryFunction]
procedure AcquireOnBehalfOfTokensByTokenCache(LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var IdToken: Text; var NewTokenCache: Text)
```
#### Parameters
*LoginHint ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user login hint, i.e. authentication email.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The token cache acquired when the access token was requested .

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

*NewTokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the new token cache.

### AcquireOnBehalfOfTokenByTokenCache (Method) <a name="AcquireOnBehalfOfTokenByTokenCache"></a> 

 Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireOnBehalfOfTokenByTokenCache(ClientId: Text; ClientSecret: Text; LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var NewTokenCache: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal - App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*LoginHint ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user login hint, i.e. authentication email.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The token cache acquired when the access token was requested .

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*NewTokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the new token cache.

### AcquireOnBehalfOfTokensByTokenCache (Method) <a name="AcquireOnBehalfOfTokensByTokenCache"></a> 

 Gets the token and token cache via the On-Behalf-Of OAuth2 v1.0 protocol flow.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireOnBehalfOfTokensByTokenCache(ClientId: Text; ClientSecret: Text; LoginHint: Text; RedirectURL: Text; Scopes: List of [Text]; TokenCache: Text; var AccessToken: Text; var IdToken: Text; var NewTokenCache: Text)
```
#### Parameters
*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal - App registrations experience assigned to your app.

*ClientSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) secret configured in the Azure Portal - Certificates & Secrets.

*LoginHint ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user login hint, i.e. authentication email.

*RedirectURL ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The redirectURL of your app, where authentication responses can be sent and received by your app. It must exactly match one of the redirectURLs you registered in the portal. If this parameter is empty, the default Business Central URL will be used.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*TokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The token cache acquired when the access token was requested .

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

*NewTokenCache ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the new token cache.

### AcquireTokensWithUserCredentials (Method) <a name="AcquireTokensWithUserCredentials"></a> 

 Gets the token with username and password.
 

#### Syntax
```
[NonDebuggable]
[TryFunction]
procedure AcquireTokensWithUserCredentials(OAuthAuthorityUrl: Text; ClientId: Text; Scopes: List of [Text]; UserName: Text; Credential: Text; var AccessToken: Text; var IdToken: Text)
```
#### Parameters
*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*ClientId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Application (client) ID that the Azure portal - App registrations experience assigned to your app.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*UserName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user name, i.e. authentication email..

*Credential ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user credential.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

### AcquireTokensWithUserCredentials (Method) <a name="AcquireTokensWithUserCredentials"></a> 

 Gets the token with username and password.
 

#### Syntax
```
[NonDebuggable]
[Scope('OnPrem')]
[TryFunction]
procedure AcquireTokensWithUserCredentials(OAuthAuthorityUrl: Text; Scopes: List of [Text]; UserName: Text; Credential: Text; var AccessToken: Text; var IdToken: Text)
```
#### Parameters
*OAuthAuthorityUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The identity authorization provider URL.

*Scopes ([List of [Text]]())* 

A list of scopes that you want the user to consent to.

*UserName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user name, i.e. authentication email..

*Credential ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The user credential.

*AccessToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the access token.

*IdToken ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the id token.

### GetLastErrorMessage (Method) <a name="GetLastErrorMessage"></a> 

 Get the last error message that happened during acquiring of an access token.
 

#### Syntax
```
procedure GetLastErrorMessage(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The last error message that happened during acquiring of an access token.
### GetDefaultRedirectURL (Method) <a name="GetDefaultRedirectURL"></a> 

 Returns the default Business Central redirectURL
 

#### Syntax
```
[NonDebuggable]
procedure GetDefaultRedirectURL(var RedirectUrl: text)
```
#### Parameters
*RedirectUrl ([text]())* 




## OAuth2ControlAddIn (Page 502)
### SetOAuth2Properties (Method) <a name="SetOAuth2Properties"></a> 
#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure SetOAuth2Properties(AuthRequestUrl: Text; AuthInitialState: Text)
```
#### Parameters
*AuthRequestUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*AuthInitialState ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



### GetAuthCode (Method) <a name="GetAuthCode"></a> 
#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetAuthCode(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### GetAuthError (Method) <a name="GetAuthError"></a> 
#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetAuthError(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### GetGrantConsentSuccess (Method) <a name="GetGrantConsentSuccess"></a> 
#### Syntax
```
[Scope('OnPrem')]
[NonDebuggable]
procedure GetGrantConsentSuccess(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*



## Prompt Interaction (Enum 501)

 This enum contains the Prompt Interaction values possible for OAuth 2.0.
 

### None (value: 0)


 No prompt parameter in the request
 

### Login (value: 1)


 The user should be prompted to reauthenticate.
 

### Select Account (value: 2)


 The user is prompted to select an account, interrupting single sign on. The user may select an existing signed-in account, enter their credentials for a remembered account, or choose to use a different account altogether.
 

### Consent (value: 3)


 User consent has been granted, but needs to be updated. The user should be prompted to consent.
 

### Admin Consent (value: 4)


 An administrator should be prompted to consent on behalf of all users in their organization.
 

