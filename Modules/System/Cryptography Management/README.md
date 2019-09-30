Provides helper functions for encryption and hashing. 
s
Encryption is always turned on for online versions, and you cannot turn it off.

Use this module to do the following:
- Encrypt plain text into encrypted value.
- Decrypt encrypted text into plain text.
- Check if encryption is enabled.
- Check whether the encryption key is present, which only works if encryption is enabled.
- Get the recommended question to activate encryption.
- Generates a hash from a string or a stream based on the provided hash algorithm.
- Generates a keyed hash or a keyed base64 encoded hash from a string based on provided hash algorithm and key.
- Generates a base64 encoded hash or a keyed base64 encoded hash from a string based on provided hash algorithm.

For on-premises versions, you can also use this module to do the following:
- Turn on or turn off encryption.
- Publish an event that allows subscription when turning encryption on or off.

# Public Objects
## Cryptography Management (Codeunit 1266)

 Provides helper functions for encryption and hashing.
 For encryption in an on-premises versions, use it to turn encryption on or off, and import and export the encryption key.
 Encryption is always turned on for online versions.
 

### Encrypt (Method) <a name="Encrypt"></a> 

 Returns plain text as an encrypted value.
 

#### Syntax
```
procedure Encrypt(InputString: Text): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to encrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Encrypted value.
### Decrypt (Method) <a name="Decrypt"></a> 

 Returns encrypted text as plain text.
 

#### Syntax
```
procedure Decrypt(EncryptedString: Text): Text
```
#### Parameters
*EncryptedString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to decrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Plain text.
### IsEncryptionEnabled (Method) <a name="IsEncryptionEnabled"></a> 

 Checks if Encryption is enabled.
 

#### Syntax
```
procedure IsEncryptionEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if encryption is enabled, false otherwise.
### IsEncryptionPossible (Method) <a name="IsEncryptionPossible"></a> 

 Checks whether the encryption key is present, which only works if encryption is enabled.
 

#### Syntax
```
procedure IsEncryptionPossible(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the encryption key exists, false otherwise.
### GetEncryptionIsNotActivatedQst (Method) <a name="GetEncryptionIsNotActivatedQst"></a> 

 Gets the recommended question to activate encryption.
 

#### Syntax
```
procedure GetEncryptionIsNotActivatedQst(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

String of a recommended question to activate encryption.
### EnableEncryption (Method) <a name="EnableEncryption"></a> 

 Enables encryption.
 

#### Syntax
```
[Scope('OnPrem')]
procedure EnableEncryption(Silent: Boolean)
```
#### Parameters
*Silent ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Enables encryption silently if true, otherwise will prompt the user.

### DisableEncryption (Method) <a name="DisableEncryption"></a> 

 Disables encryption.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DisableEncryption(Silent: Boolean)
```
#### Parameters
*Silent ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Turns off encryption silently if true, otherwise will prompt the user.

### OnBeforeEnableEncryptionOnPrem (Event) <a name="OnBeforeEnableEncryptionOnPrem"></a> 

 Publishes an event that allows subscription when enabling encryption.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnBeforeEnableEncryptionOnPrem()
```
### OnBeforeDisableEncryptionOnPrem (Event) <a name="OnBeforeDisableEncryptionOnPrem"></a> 

 Publishes an event that allows subscription when disabling encryption.
 

#### Syntax
```
[IntegrationEvent(false, false)]
[Scope('OnPrem')]
internal procedure OnBeforeDisableEncryptionOnPrem()
```
### GenerateHash (Method) <a name="GenerateHash"></a> 

 Generates a hash from a string based on the provided hash algorithm.
 

#### Syntax
```
procedure GenerateHash(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms include MD5, SHA1, SHA256, SHA384, and SHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Hashed value.
### GenerateHash (Method) <a name="GenerateHash"></a> 

 Generates a keyed hash from a string based on provided hash algorithm and key.
 

#### Syntax
```
procedure GenerateHash(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*"Key" ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Hashed value.
### GenerateHash (Method) <a name="GenerateHash"></a> 

 Generates a hash from a stream based on the provided hash algorithm.
 

#### Syntax
```
procedure GenerateHash(InputString: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
```
#### Parameters
*InputString ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Input string.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.
### GenerateHashAsBase64String (Method) <a name="GenerateHashAsBase64String"></a> 

 Generates a base64 encoded hash from a string based on provided hash algorithm.
 

#### Syntax
```
procedure GenerateHashAsBase64String(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms include MD5, SHA1, SHA256, SHA384, and SHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.
### GenerateHashAsBase64String (Method) <a name="GenerateHashAsBase64String"></a> 

 Generates a keyed base64 encoded hash from a string based on provided hash algorithm and key.
 

#### Syntax
```
procedure GenerateHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*"Key" ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.
### GenerateBase64KeyedHashAsBase64String (Method) <a name="GenerateBase64KeyedHashAsBase64String"></a> 

 Generates keyed base64 encoded hash from provided string based on provided hash algorithm and base64 key.
 

#### Syntax
```
procedure GenerateBase64KeyedHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*"Key" ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.

## Data Encryption Management (Page 9905)
