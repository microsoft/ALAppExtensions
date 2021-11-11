This module contains supporting tools for authenticating via OAuth 1.0 authorization protocol.

Use this module to do the following:

- Get the OAuth access token and secret by following the implicit authorization flow.
- Get the OAuth access token and secret by following the authorization code flow.
- Get the authorization header that corresponds to the call from the REST API.

# Public Objects
## OAuth (Codeunit 1288)

 Contains methods supporting authentication via OAuth 1.0 protocol.
 

### GetOAuthAccessToken (Method) <a name="GetOAuthAccessToken"></a> 

 Gets an OAuth request token from an OAuth provider.
 

#### Syntax
```
[TryFunction]
[NonDebuggable]
procedure GetOAuthAccessToken(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenUrl: Text; CallbackUrl: Text; var AccessTokenKey: Text; var AccessTokenSecret: Text)
```
#### Parameters
*ConsumerKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth consumer key. Cannot be null.

*ConsumerSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth consumer secret. Cannot be null.

*RequestTokenUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the OAuth provider. Cannot be null.

*CallbackUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Local URL for OAuth callback. Cannot be null.

*AccessTokenKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth response token key.

*AccessTokenSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth response token secret.

### GetOAuthAccessToken (Method) <a name="GetOAuthAccessToken"></a> 

 Gets an OAuth access token from an OAuth provider.
 

#### Syntax
```
[TryFunction]
[NonDebuggable]
procedure GetOAuthAccessToken(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenUrl: Text; Verifier: Text; RequestTokenKey: Text; RequestTokenSecret: Text; var AccessTokenKey: Text; var AccessTokenSecret: Text)
```
#### Parameters
*ConsumerKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth consumer key. Cannot be null.

*ConsumerSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth consumer secret. Cannot be null.

*RequestTokenUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the OAuth provider. Cannot be null.

*Verifier ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

An OAuth verifier string. Cannot be null.

*RequestTokenKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth request token key. Cannot be null.

*RequestTokenSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth request token secret. Cannot be null.

*AccessTokenKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the OAuth response token key.

*AccessTokenSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the OAuth response token secret.

### GetAuthorizationHeader (Method) <a name="GetAuthorizationHeader"></a> 

 Gets the authorization header for an OAuth specific REST call.
 

#### Syntax
```
[TryFunction]
[NonDebuggable]
procedure GetAuthorizationHeader(ConsumerKey: Text; ConsumerSecret: Text; RequestTokenKey: Text; RequestTokenSecret: Text; RequestUrl: Text; RequestMethod: Enum "Http Request Type"; var AuthorizationHeader: Text)
```
#### Parameters
*ConsumerKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth consumer key. Cannot be null.

*ConsumerSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth consumer secret. Cannot be null.

*RequestTokenKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth response token key. Cannot be null.

*RequestTokenSecret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The OAuth response token secret. Cannot be null.

*RequestUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The REST URL. Cannot be null.

*RequestMethod ([Enum "Http Request Type"]())* 

The REST method call with capital letters(POST, GET, PUT, PATCH, DELETE).

*AuthorizationHeader ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Exit parameter containing the requested OAuth specific authorization header.


## Http Request Type (Enum 1289)

 This enum contains the REST Http Request types.
 

### GET (value: 0)


 Specifies that the Http request type is GET.
 

### POST (value: 1)


 Specifies that the Http request type is POST.
 

### PATCH (value: 2)


 Specifies that the Http request type is PATCH.
 

### PUT (value: 3)


 Specifies that the Http request type is PUT.
 

### DELETE (value: 4)


 Specifies that the Http request type is DELETE.
 

### HEAD (value: 5)


 Specifies that the Http request type is HEAD.
 

### OPTIONS (value: 6)


 Specifies that the Http request type is OPTIONS.
 

