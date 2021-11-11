Provides helper functions for encryption and hashing. 

Encryption is always turned on for online versions, and you cannot turn it off.

Use this module to do the following:
- Encrypt plain text into encrypted value.
- Decrypt encrypted text into plain text.
- Check if encryption is enabled.
- Check whether the encryption key is present, which only works if encryption is enabled.
- Get the recommended question to activate encryption.
- Generate a hash from a string or a stream based on the provided hash algorithm.
- Generate a keyed hash or a keyed base64 encoded hash from a string based on provided hash algorithm and key.
- Generate a base64 encoded hash or a keyed base64 encoded hash from a string based on provided hash algorithm.

Advanced Encryption Standard functionality:
- Initialize a new instance of the RijndaelManaged class with default values.
- Initialize a new instance of the RijndaelManaged class providing the encryption key.
- Initializes a new instance of the RijndaelManaged class providing the encryption key and block size.
- Initializes a new instance of the RijndaelManaged class providing the encryption key, block size and cipher mode.
- Initializes a new instance of the RijndaelManaged class providing the encryption key, block size, cipher mode and padding mode.
- Set a new block size value for the RijndaelManaged class.
- Set a new cipher mode value for the RijndaelManaged class.
- Set a new padding mode value for the RijndaelManaged class.
- Set the key and vector for the RijndaelManaged class.
- Determine whether the specified key size is valid for the current algorithm.
- Specify the key sizes, in bits, that are supported by the symmetric algorithm.
- Specify the block sizes, in bits, that are supported by the symmetric algorithm.
- Get the key and vector from the RijndaelManaged class.
- Return plain text as an encrypted value.
- Return encrypted text as plain text.

For on-premises versions, you can also use this module to do the following:
- Turn on or turn off encryption.
- Publish an event that allows subscription when turning encryption on or off.


# Public Objects
## [Obsolete] Signature Key (Table 1461)

 Represents the key of asymmetric algorithm.
 

### FromXmlString (Method) <a name="FromXmlString"></a> 

 Saves an key value from the key information from an XML string.
 

#### Syntax
```
procedure FromXmlString(XmlString: Text)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing key information.

### ToXmlString (Method) <a name="ToXmlString"></a> 

 Gets an XML string containing the key of the saved key value.
 

#### Syntax
```
procedure ToXmlString(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

An XML string containing the key of the saved key value.
### FromBase64String (Method) <a name="FromBase64String"></a> 

 Saves an key value from an certificate in Base64 format
 

#### Syntax
```
[NonDebuggable]
procedure FromBase64String(CertBase64Value: Text; Password: Text; IncludePrivateParameters: Boolean)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*IncludePrivateParameters ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

true to include private parameters; otherwise, false.


## SignatureAlgorithm (Interface)
### FromXmlString (Method) <a name="FromXmlString"></a> 
#### Syntax
```
procedure FromXmlString(XmlString: Text)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



### SignData (Method) <a name="SignData"></a> 
#### Syntax
```
procedure SignData(DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
```
#### Parameters
*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 



*HashAlgorithm ([Enum "Hash Algorithm"]())* 



*SignatureOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 



### ToXmlString (Method) <a name="ToXmlString"></a> 
#### Syntax
```
procedure ToXmlString(IncludePrivateParameters: Boolean): Text
```
#### Parameters
*IncludePrivateParameters ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### VerifyData (Method) <a name="VerifyData"></a> 
#### Syntax
```
procedure VerifyData(DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
```
#### Parameters
*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 



*HashAlgorithm ([Enum "Hash Algorithm"]())* 



*SignatureInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 



#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*



## CertificateRequest (Codeunit 1463)

 Provides helper functionality for creating Certificate Signing Requests (CSR:s) and Self Signed Certificates.
 

### InitializeRSA (Method) <a name="InitializeRSA"></a> 

 Initializes a new instance of RSACryptoServiceProvider with the specified key size and returns the key as an XML string.
 

#### Syntax
```
procedure InitializeRSA(KeySize: Integer; IncludePrivateParameters: Boolean; var KeyAsXmlString: Text)
```
#### Parameters
*KeySize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The size of the key in bits.

*IncludePrivateParameters ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True to include a public and private RSA key in KeyAsXmlString. False to include only the public key.

*KeyAsXmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Returns an XML string that contains the key of the RSA object that was created.

### InitializeCertificateRequestUsingRSA (Method) <a name="InitializeCertificateRequestUsingRSA"></a> 

 Initializes a new instance of the CertificateRequest with the specified parameters and the initialized RSA key.
 

#### Syntax
```
procedure InitializeCertificateRequestUsingRSA(SubjectName: Text; HashAlgorithm: Enum "Hash Algorithm"; RSASignaturePaddingMode: Enum "RSA Signature Padding")
```
#### Parameters
*SubjectName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The string representation of the subject name for the certificate or certificate request.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The hash algorithm to use when signing the certificate or certificate request.

*RSASignaturePaddingMode ([Enum "RSA Signature Padding"]())* 

The RSA signature padding to apply if self-signing or being signed with an X509Certificate2.

### AddX509BasicConstraintToCertificateRequest (Method) <a name="AddX509BasicConstraintToCertificateRequest"></a> 

 Adds a X509BasicConstraint to the Certificate Request. See https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509basicconstraintsextension
 

#### Syntax
```
procedure AddX509BasicConstraintToCertificateRequest(CertificateAuthority: Boolean; HasPathLengthConstraint: Boolean; PathLengthConstraint: Integer; Critical: Boolean)
```
#### Parameters
*CertificateAuthority ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if the certificate is from a certificate authority (CA). Otherwise, false.

*HasPathLengthConstraint ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if the certificate has a restriction on the number of path levels it allows; otherwise, false.

*PathLengthConstraint ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of levels allowed in a certificate's path.

*Critical ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if the extension is critical. Otherwise, false.

### AddX509EnhancedKeyUsageToCertificateRequest (Method) <a name="AddX509EnhancedKeyUsageToCertificateRequest"></a> 

 Adds a X509EnhancedKeyUsage to the Certificate Request. See https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509enhancedkeyusageextension
 

#### Syntax
```
procedure AddX509EnhancedKeyUsageToCertificateRequest(OidValues: List of [Text]; Critical: Boolean)
```
#### Parameters
*OidValues ([List of [Text]]())* 

List of Oid values (for example '1.3.6.1.5.5.7.3.2') to add.

*Critical ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if the extension is critical; otherwise, false.

### AddX509KeyUsageToCertificateRequest (Method) <a name="AddX509KeyUsageToCertificateRequest"></a> 

 Adds a X509KeyUsage to the certificate request. See https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509keyusageextension
 

#### Syntax
```
procedure AddX509KeyUsageToCertificateRequest(X509KeyUsageFlags: Integer; Critical: Boolean)
```
#### Parameters
*X509KeyUsageFlags ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The sum of all flag values that are to be added. See https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509keyusageflags

*Critical ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if the extension is critical; otherwise, false.

### CreateSigningRequest (Method) <a name="CreateSigningRequest"></a> 

 Creates an ASN.1 DER-encoded PKCS#10 CertificationRequest and returns a Base 64 encoded string.
 

#### Syntax
```
procedure CreateSigningRequest(var SigningRequestPemString: Text)
```
#### Parameters
*SigningRequestPemString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Returns the SigningRequest in Base 64 string format.

### GetX509CertificateRequestExtensionCount (Method) <a name="GetX509CertificateRequestExtensionCount"></a> 

 Gets how many X509Extensions have been added to the X509CertificateRequest.
 

#### Syntax
```
procedure GetX509CertificateRequestExtensionCount(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of added extensions.
### CreateSigningRequest (Method) <a name="CreateSigningRequest"></a> 

 Creates an ASN.1 DER-encoded PKCS#10 CertificationRequest and returns it in an OutStream.
 

#### Syntax
```
procedure CreateSigningRequest(SigningRequestOutStream: OutStream)
```
#### Parameters
*SigningRequestOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

OutStream.

### CreateSelfSigned (Method) <a name="CreateSelfSigned"></a> 

 Creates a self-signed certificate using the established subject, key, and optional extensions.
 

#### Syntax
```
procedure CreateSelfSigned(NotBefore: DateTime; NotAfter: DateTime; X509ContentType: Enum "X509 Content Type"; var CertBase64Value: Text)
```
#### Parameters
*NotBefore ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The oldest date and time when this certificate is considered valid.

*NotAfter ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The date and time when this certificate is no longer considered valid.

*X509ContentType ([Enum "X509 Content Type"]())* 

Specifies the format of an X.509 certificate.

*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Returns the certificate value encoded using the Base64 algorithm.


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

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Key to use in the hash algorithm.

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

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Key to use in the hash algorithm.

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

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Key to use in the hash algorithm.

*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Base64 hashed value.
### GenerateBase64KeyedHash (Method) <a name="GenerateBase64KeyedHash"></a> 

 Generates keyed base64 encoded hash from provided string based on provided hash algorithm and base64 key.
 

#### Syntax
```
procedure GenerateBase64KeyedHash(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Key to use in the hash algorithm.

*HashAlgorithmType ([Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512]())* 

The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Hashed value.
### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified string and signs it.
 

#### Syntax
```
procedure SignData(InputString: Text; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string for signing.

*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The private key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the signature for the specified string.

### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified data and signs it.
 

#### Syntax
```
procedure SignData(DataInStream: InStream; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
```
#### Parameters
*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of input data.

*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The private key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the signature for the specified input data.

### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified string and signs it.
 

#### Syntax
```
[Obsolete('Replaced by SignData function with XmlString parameter.', '19.1')]
procedure SignData(InputString: Text; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string for signing.

*SignatureKey ([Record "Signature Key"]())* 

The private key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the signature for the specified string.

### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified data and signs it.
 

#### Syntax
```
[Obsolete('Replaced by SignData function with XmlString parameter.', '19.1')]
procedure SignData(DataInStream: InStream; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
```
#### Parameters
*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of input data.

*SignatureKey ([Record "Signature Key"]())* 

The private key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the signature for the specified input data.

### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified string and signs it.
 

#### Syntax
```
[Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
procedure SignData(InputString: Text; KeyStream: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: OutStream)
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*KeyStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of the private key to use in the hash algorithm.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the output to.

### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified data and signs it.
 

#### Syntax
```
[Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
procedure SignData(DataStream: InStream; KeyStream: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA5122; SignatureStream: OutStream)
```
#### Parameters
*DataStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of input data.

*KeyStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of the private key to use in the hash algorithm.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA5122]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The stream to write the output to.

### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid.
 

#### Syntax
```
procedure VerifyData(InputString: Text; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The public key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of signature.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the signature is valid; otherwise, false.
### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid.
 

#### Syntax
```
procedure VerifyData(DataInStream: InStream; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
```
#### Parameters
*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of input data.

*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The public key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of signature.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the signature is valid; otherwise, false.
### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid.
 

#### Syntax
```
[Obsolete('Replaced by VerifyData function with XmlString parameter.', '19.1')]
procedure VerifyData(InputString: Text; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*SignatureKey ([Record "Signature Key"]())* 

The public key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of signature.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the signature is valid; otherwise, false.
### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid.
 

#### Syntax
```
[Obsolete('Replaced by VerifyData function with XmlString parameter.', '19.1')]
procedure VerifyData(DataInStream: InStream; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
```
#### Parameters
*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of input data.

*SignatureKey ([Record "Signature Key"]())* 

The public key to use in the hash algorithm.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of signature.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the signature is valid; otherwise, false.
### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid.
 

#### Syntax
```
[Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
procedure VerifyData(InputString: Text; "Key": Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: InStream): Boolean
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Input string.

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Public key to use in the hash algorithm.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of signature.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the digital signature is valid.
### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid.
 

#### Syntax
```
[Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
procedure VerifyData(DataStream: InStream; "Key": Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: InStream): Boolean
```
#### Parameters
*DataStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of input data.

*Key ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Public key to use in the hash algorithm.

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.

*SignatureStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of digital signature.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the digital signature is valid.

## DESCryptoServiceProvider (Codeunit 1379)

 Provides helper functions for the Data Encryption Standard (DES)
 

### EncryptText (Method) <a name="EncryptText"></a> 

 Encrypts text with DotNet Cryptography.DESCryptoServiceProvider
 

#### Syntax
```
[NonDebuggable]
procedure EncryptText(DecryptedText: Text; Password: Text; Salt: Text)EncryptedText: Text
```
#### Parameters
*DecryptedText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the text to encrypt

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the password to be used to initialize a new instance of DotNet System.Security.Cryptography.Rfc2898DeriveBytes

*Salt ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the salt to be used to initialize a new instance of System.Security.Cryptography.Rfc2898DeriveBytes

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Returns the encrypted text
### DecryptText (Method) <a name="DecryptText"></a> 

 Decrypts text with DotNet Cryptography.DESCryptoServiceProvider
 

#### Syntax
```
[NonDebuggable]
procedure DecryptText(EncryptedText: Text; Password: Text; Salt: Text)DecryptedText: Text
```
#### Parameters
*EncryptedText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the text to decrypt

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the password to be used to initialize a new instance of DotNet System.Security.Cryptography.Rfc2898DeriveBytes

*Salt ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the salt to be used to initialize a new instance of System.Security.Cryptography.Rfc2898DeriveBytes

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Returns the decrypted text
### EncryptStream (Method) <a name="EncryptStream"></a> 

 Encrypts data in stream with DotNet Cryptography.DESCryptoServiceProvider
 

#### Syntax
```
[NonDebuggable]
[Obsolete('Replaced, add the salt parameter to continue using this function', '18.0')]
procedure EncryptStream(Password: Text; InputInstream: InStream; var OutputOutstream: Outstream)
```
#### Parameters
*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes

*InputInstream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Represents the input instream data to encrypt

*OutputOutstream ([Outstream]())* 

Represents the output instream encrypted data

### DecryptStream (Method) <a name="DecryptStream"></a> 

 Decrypts data in stream with DotNet Cryptography.DESCryptoServiceProvider
 

#### Syntax
```
[NonDebuggable]
[Obsolete('Replaced, add the salt parameter to continue using this function', '18.0')]
procedure DecryptStream(Password: Text; InputInstream: InStream; var OutputOutstream: Outstream)
```
#### Parameters
*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes

*InputInstream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Represents the input instream data to decrypt

*OutputOutstream ([Outstream]())* 

Represents the output instream decrypted data

### EncryptStream (Method) <a name="EncryptStream"></a> 

 Encrypts data in stream with DotNet Cryptography.DESCryptoServiceProvider
 

#### Syntax
```
[NonDebuggable]
procedure EncryptStream(Password: Text; Salt: Text; InputInstream: InStream; var OutputOutstream: Outstream)
```
#### Parameters
*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes

*Salt ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the salt to be used to initialize a new instance of System.Security.Cryptography.Rfc2898DeriveBytes

*InputInstream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Represents the input instream data to encrypt

*OutputOutstream ([Outstream]())* 

Represents the output instream encrypted data

### DecryptStream (Method) <a name="DecryptStream"></a> 

 Decrypts data in stream with DotNet Cryptography.DESCryptoServiceProvider
 

#### Syntax
```
[NonDebuggable]
procedure DecryptStream(Password: Text; Salt: Text; InputInstream: InStream; var OutputOutstream: Outstream)
```
#### Parameters
*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes

*Salt ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the salt to be used to initialize a new instance of System.Security.Cryptography.Rfc2898DeriveBytes

*InputInstream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Represents the input instream data to decrypt

*OutputOutstream ([Outstream]())* 

Represents the output instream decrypted data


## DSACryptoServiceProvider (Codeunit 1447)

 Defines a wrapper object to access the cryptographic service provider (CSP) implementation of the DSA algorithm.
 

### ToXmlString (Method) <a name="ToXmlString"></a> 

 Creates and returns an XML string representation of the current DSA object.
 

#### Syntax
```
procedure ToXmlString(IncludePrivateParameters: Boolean): Text
```
#### Parameters
*IncludePrivateParameters ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

true to include private parameters; otherwise, false.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

An XML string encoding of the current DSA object.
### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified stream using the specified hash algorithm and signs the resulting hash value.
 

#### Syntax
```
procedure SignData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing DSA key information.

*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The input stream to hash and sign.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The hash algorithm to use to create the hash value.

*SignatureOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The DSA signature stream for the specified data.

### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid by calculating the hash value of the specified stream using the specified hash algorithm and comparing it to the provided signature.
 

#### Syntax
```
procedure VerifyData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing DSA key information.

*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The input stream of data that was signed.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The name of the hash algorithm used to create the hash value of the data.

*SignatureInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of signature data to be verified.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the signature is valid; otherwise, false.

## Rfc2898DeriveBytes (Codeunit 1378)

 Provides helper functions for the Advanced Encryption Standard.
 

### HashRfc2898DeriveBytes (Method) <a name="HashRfc2898DeriveBytes"></a> 
If generating the hash fails, it throws a dotnet error.


 Generates a base64 encoded hash from a string based on the provided hash algorithm.
 

#### Syntax
```
procedure HashRfc2898DeriveBytes(InputString: Text; Salt: Text; NoOfBytes: Integer; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
```
#### Parameters
*InputString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the input to be hashed

*Salt ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The salt used to derive the key

*NoOfBytes ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of pseudo-random key bytes to generate

*HashAlgorithmType ([Option MD5,SHA1,SHA256,SHA384,SHA512]())* 

Represents the HashAlgorithmType, which returns the encrypted hash in the desired algorithm type

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Hash of input

## Rijndael Cryptography (Codeunit 1258)

 Provides helper functions for the Advanced Encryption Standard.
 

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class with default values.
 

#### Syntax
```
procedure InitRijndaelProvider()
```
### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key and block size.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key, block size and cipher mode.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

*CipherMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB

### InitRijndaelProvider (Method) <a name="InitRijndaelProvider"></a> 

 Initializes a new instance of the RijndaelManaged class providing the encryption key, block size, cipher mode and padding mode.
 

#### Syntax
```
procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text; PaddingMode: Text)
```
#### Parameters
*EncryptionKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm.

*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

*CipherMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB

*PaddingMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros

### SetBlockSize (Method) <a name="SetBlockSize"></a> 

 Sets a new block size value for the RijndaelManaged class.
 

#### Syntax
```
procedure SetBlockSize(BlockSize: Integer)
```
#### Parameters
*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

### SetCipherMode (Method) <a name="SetCipherMode"></a> 

 Sets a new cipher mode value for the RijndaelManaged class.
 

#### Syntax
```
procedure SetCipherMode(CipherMode: Text)
```
#### Parameters
*CipherMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB

### SetPaddingMode (Method) <a name="SetPaddingMode"></a> 

 Sets a new padding mode value for the RijndaelManaged class.
 

#### Syntax
```
procedure SetPaddingMode(PaddingMode: Text)
```
#### Parameters
*PaddingMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros

### SetEncryptionData (Method) <a name="SetEncryptionData"></a> 

 Sets the key and vector for the RijndaelManaged class.
 

#### Syntax
```
procedure SetEncryptionData(KeyAsBase64: Text; VectorAsBase64: Text)
```
#### Parameters
*KeyAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm encoded as Base64 Text

*VectorAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the initialization vector (IV) for the symmetric algorithm encoded as Base64 Text

### IsValidKeySize (Method) <a name="IsValidKeySize"></a> 

 Determines whether the specified key size is valid for the current algorithm.
 

#### Syntax
```
procedure IsValidKeySize(KeySize: Integer): Boolean
```
#### Parameters
*KeySize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Key Size.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the key size is valid; false otherwise.
### GetLegalKeySizeValues (Method) <a name="GetLegalKeySizeValues"></a> 

 Specifies the key sizes, in bits, that are supported by the symmetric algorithm.
 

#### Syntax
```
procedure GetLegalKeySizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
```
#### Parameters
*MinSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Minimum Size in bits

*MaxSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Maximum Size in bits

*SkipSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Skip Size in bits

### GetLegalBlockSizeValues (Method) <a name="GetLegalBlockSizeValues"></a> 

 Specifies the block sizes, in bits, that are supported by the symmetric algorithm.
 

#### Syntax
```
procedure GetLegalBlockSizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
```
#### Parameters
*MinSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Minimum Size in bits

*MaxSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Maximum Size in bits

*SkipSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Skip Size in bits

### GetEncryptionData (Method) <a name="GetEncryptionData"></a> 

 Gets the key and vector from the RijndaelManaged class
 

#### Syntax
```
procedure GetEncryptionData(var KeyAsBase64: Text; var VectorAsBase64: Text)
```
#### Parameters
*KeyAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the secret key for the symmetric algorithm encoded as Base64 Text

*VectorAsBase64 ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the initialization vector (IV) for the symmetric algorithm encoded as Base64 Text

### Encrypt (Method) <a name="Encrypt"></a> 

 Returns plain text as an encrypted value.
 

#### Syntax
```
procedure Encrypt(PlainText: Text)CryptedText: Text
```
#### Parameters
*PlainText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to encrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Encrypted value.
### Decrypt (Method) <a name="Decrypt"></a> 

 Returns encrypted text as plain text.
 

#### Syntax
```
procedure Decrypt(CryptedText: Text)PlainText: Text
```
#### Parameters
*CryptedText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value to decrypt.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Plain text.

## RSACryptoServiceProvider (Codeunit 1445)

 Performs asymmetric encryption and decryption using the implementation of the RSA algorithm provided by the cryptographic service provider (CSP).
 

### ToXmlString (Method) <a name="ToXmlString"></a> 

 Creates and returns an XML string containing the key of the current RSA object.
 

#### Syntax
```
[NonDebuggable]
procedure ToXmlString(IncludePrivateParameters: Boolean): Text
```
#### Parameters
*IncludePrivateParameters ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

true to include a public and private RSA key; false to include only the public key.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

An XML string containing the key of the current RSA object.
### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified data and signs it.
 

#### Syntax
```
[NonDebuggable]
procedure SignData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing RSA key information.

*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The input stream to hash and sign.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The hash algorithm to use to create the hash value.

*SignatureOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The RSA signature stream for the specified data.

### VerifyData (Method) <a name="VerifyData"></a> 

 Verifies that a digital signature is valid by determining the hash value in the signature using the provided public key and comparing it to the hash value of the provided data.
 

#### Syntax
```
[NonDebuggable]
procedure VerifyData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing RSA key information.

*DataInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The input stream of data that was signed.

*HashAlgorithm ([Enum "Hash Algorithm"]())* 

The name of the hash algorithm used to create the hash value of the data.

*SignatureInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The stream of signature data to be verified.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the signature is valid; otherwise, false.
### Encrypt (Method) <a name="Encrypt"></a> 

 Encrypts the specified text with the RSA algorithm.
 

#### Syntax
```
[NonDebuggable]
procedure Encrypt(XmlString: Text; PlainTextInStream: InStream; OaepPadding: Boolean; EncryptedTextOutStream: OutStream)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing RSA key information.

*PlainTextInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The input stream to encrypt.

*OaepPadding ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True to perform RSA encryption using OAEP padding; otherwise, false to use PKCS#1 padding.

*EncryptedTextOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The RSA encryption stream for the specified text.

### Decrypt (Method) <a name="Decrypt"></a> 

 Decrypts the specified text that was previously encrypted with the RSA algorithm.
 

#### Syntax
```
[NonDebuggable]
procedure Decrypt(XmlString: Text; EncryptedTextInStream: InStream; OaepPadding: Boolean; DecryptedTextOutStream: OutStream)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing RSA key information.

*EncryptedTextInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The input stream to decrypt.

*OaepPadding ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

true to perform RSA encryption using OAEP padding; otherwise, false to use PKCS#1 padding.

*DecryptedTextOutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The RSA decryption stream for the specified text.


## X509Certificate2 (Codeunit 1286)

 Provides helper functions to work with the X509Certificate2 class.
 

### VerifyCertificate (Method) <a name="VerifyCertificate"></a> 
When certificate cannot be initialized


 Verifes that a certificate is initialized and can be exported.
 

#### Syntax
```
[NonDebuggable]
procedure VerifyCertificate(var CertBase64Value: Text; Password: Text; X509ContentType: Enum "X509 Content Type"): Boolean
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*X509ContentType ([Enum "X509 Content Type"]())* 

Specifies the format of an X.509 certificate

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if certificate is verified
### GetCertificateFriendlyName (Method) <a name="GetCertificateFriendlyName"></a> 

 Specifies the friendly name of the certificate based on it's Base64 value.
 

#### Syntax
```
[NonDebuggable]
procedure GetCertificateFriendlyName(CertBase64Value: Text; Password: Text; var FriendlyName: Text)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*FriendlyName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents certificate Friendly Name

### GetCertificateSubject (Method) <a name="GetCertificateSubject"></a> 

 Specifies the subject of the certificate based on it's Base64 value.
 

#### Syntax
```
[NonDebuggable]
procedure GetCertificateSubject(CertBase64Value: Text; Password: Text; var Subject: Text)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*Subject ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate subject distinguished name

### GetCertificateThumbprint (Method) <a name="GetCertificateThumbprint"></a> 

 Specifies the thumbprint of the certificate based on it's Base64 value.
 

#### Syntax
```
[NonDebuggable]
procedure GetCertificateThumbprint(CertBase64Value: Text; Password: Text; var Thumbprint: Text)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*Thumbprint ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Thumbprint

### GetCertificateIssuer (Method) <a name="GetCertificateIssuer"></a> 

 Specifies the issuer of the certificate based on it's Base64 value.
 

#### Syntax
```
[NonDebuggable]
procedure GetCertificateIssuer(CertBase64Value: Text; Password: Text; var Issuer: Text)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*Issuer ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Issuer

### GetCertificateExpiration (Method) <a name="GetCertificateExpiration"></a> 

 Specifies the expiration date of the certificate based on it's Base64 value.
 

#### Syntax
```
[NonDebuggable]
procedure GetCertificateExpiration(CertBase64Value: Text; Password: Text; var Expiration: DateTime)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*Expiration ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

Certificate Expiration Date

### GetCertificateNotBefore (Method) <a name="GetCertificateNotBefore"></a> 

 Specifies the NotBefore date of the certificate based on it's Base64 value.
 

#### Syntax
```
[NonDebuggable]
procedure GetCertificateNotBefore(CertBase64Value: Text; Password: Text; var NotBefore: DateTime)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*NotBefore ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

Certificate NotBefore Date

### HasPrivateKey (Method) <a name="HasPrivateKey"></a> 

 Checks whether the certificate has a private key based on it's Base64 value.
 

#### Syntax
```
[NonDebuggable]
procedure HasPrivateKey(CertBase64Value: Text; Password: Text): Boolean
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the certificate has private key
### GetCertificatePropertiesAsJson (Method) <a name="GetCertificatePropertiesAsJson"></a> 

 Specifies the certificate details in Json object
 

#### Syntax
```
[NonDebuggable]
procedure GetCertificatePropertiesAsJson(CertBase64Value: Text; Password: Text; var CertPropertyJson: Text)
```
#### Parameters
*CertBase64Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the certificate value encoded using the Base64 algorithm

*Password ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate Password

*CertPropertyJson ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Certificate details in json


## SignedXml (Codeunit 1460)

 Provides a functionality to singing an xml document.
 

### InitializeSignedXml (Method) <a name="InitializeSignedXml"></a> 

 Initializes a new instance of the SignedXml class from the specified XML document.
 

#### Syntax
```
procedure InitializeSignedXml(SigningXmlDocument: XmlDocument)
```
#### Parameters
*SigningXmlDocument ([XmlDocument]())* 

The XmlDocument object to use to initialize the new instance of SignedXml.

### InitializeSignedXml (Method) <a name="InitializeSignedXml"></a> 

 Initializes a new instance of the SignedXml class from the specified XmlElement object.
 

#### Syntax
```
procedure InitializeSignedXml(SigningXmlElement: XmlElement)
```
#### Parameters
*SigningXmlElement ([XmlElement]())* 

The XmlElement object to use to initialize the new instance of SignedXml.

### SetSigningKey (Method) <a name="SetSigningKey"></a> 

 Sets the key used for signing a SignedXml object.
 

#### Syntax
```
[Obsolete('Replaced by SetSigningKey function with XmlString parameter.', '19.1')]
procedure SetSigningKey(var SignatureKey: Record "Signature Key")
```
#### Parameters
*SignatureKey ([Record "Signature Key"]())* 

The key used for signing the SignedXml object.

### SetSigningKey (Method) <a name="SetSigningKey"></a> 

 Sets the key used for signing a SignedXml object.
 

#### Syntax
```
procedure SetSigningKey(XmlString: Text)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing key information.

### SetSigningKey (Method) <a name="SetSigningKey"></a> 

 Sets the key used for signing a SignedXml object.
 

#### Syntax
```
procedure SetSigningKey(XmlString: Text; SignatureAlgorithm: Enum SignatureAlgorithm)
```
#### Parameters
*XmlString ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The XML string containing key information.

*SignatureAlgorithm ([Enum SignatureAlgorithm]())* 

The type of asymmetric algorithms.

### InitializeReference (Method) <a name="InitializeReference"></a> 

 Initializes a new instance of the Reference class with the specified Uri.
 

#### Syntax
```
procedure InitializeReference(Uri: Text)
```
#### Parameters
*Uri ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Uri with which to initialize the new instance of Reference.

### SetDigestMethod (Method) <a name="SetDigestMethod"></a> 

 Sets the digest method Uniform Resource Identifier (URI) of the current Reference.
 

#### Syntax
```
procedure SetDigestMethod(DigestMethod: Text)
```
#### Parameters
*DigestMethod ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The digest method URI of the current Reference. The default value is http://www.w3.org/2001/04/xmlenc#sha256.

### AddXmlDsigExcC14NTransformToReference (Method) <a name="AddXmlDsigExcC14NTransformToReference"></a> 

 Adds a XmlDsigExcC14NTransform object to the list of transforms to be performed on the data before passing it to the digest algorithm.
 

#### Syntax
```
procedure AddXmlDsigExcC14NTransformToReference(InclusiveNamespacesPrefixList: Text)
```
#### Parameters
*InclusiveNamespacesPrefixList ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that contains namespace prefixes to canonicalize using the standard canonicalization algorithm.

### SetCanonicalizationMethod (Method) <a name="SetCanonicalizationMethod"></a> 

 Sets the canonicalization algorithm that is used before signing for the current SignedInfo object.
 

#### Syntax
```
procedure SetCanonicalizationMethod(CanonicalizationMethod: Text)
```
#### Parameters
*CanonicalizationMethod ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The canonicalization algorithm used before signing for the current SignedInfo object.

### SetXmlDsigExcC14NTransformAsCanonicalizationMethod (Method) <a name="SetXmlDsigExcC14NTransformAsCanonicalizationMethod"></a> 

 Sets the XmlDsigExcC14NTransform as canonicalization algorithm that is used before signing for the current SignedInfo object.
 

#### Syntax
```
procedure SetXmlDsigExcC14NTransformAsCanonicalizationMethod(InclusiveNamespacesPrefixList: Text)
```
#### Parameters
*InclusiveNamespacesPrefixList ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A string that contains namespace prefixes to canonicalize using the standard canonicalization algorithm.

### SetSignatureMethod (Method) <a name="SetSignatureMethod"></a> 

 Sets the name of the algorithm used for signature generation and validation for the current SignedInfo object.
 

#### Syntax
```
procedure SetSignatureMethod(SignatureMethod: Text)
```
#### Parameters
*SignatureMethod ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the algorithm used for signature generation and validation for the current SignedInfo object.

### InitializeKeyInfo (Method) <a name="InitializeKeyInfo"></a> 

 Initializes a new instance of the KeyInfo class.
 

#### Syntax
```
procedure InitializeKeyInfo()
```
### AddClause (Method) <a name="AddClause"></a> 

 Adds a xml element of KeyInfoNode to the collection of KeyInfoClause.
 

#### Syntax
```
procedure AddClause(KeyInfoNodeXmlElement: XmlElement)
```
#### Parameters
*KeyInfoNodeXmlElement ([XmlElement]())* 

The xml element of KeyInfoNode to add to the collection of KeyInfoClause.

### InitializeDataObject (Method) <a name="InitializeDataObject"></a> 

 Initializes a new instance of the DataObject class.
 

#### Syntax
```
procedure InitializeDataObject()
```
### AddObject (Method) <a name="AddObject"></a> 

 Adds a xml element of DataObject object to the list of objects to be signed.
 

#### Syntax
```
procedure AddObject(DataObjectXmlElement: XmlElement)
```
#### Parameters
*DataObjectXmlElement ([XmlElement]())* 

The xml element of DataObject to add to the list of objects to be signed.

### AddXmlDsigExcC14NTransformToReference (Method) <a name="AddXmlDsigExcC14NTransformToReference"></a> 

 Adds a AddXmlDsigExcC14NTransformToReference object to the list of transforms to be performed on the data before passing it to the digest algorithm.
 

#### Syntax
```
procedure AddXmlDsigExcC14NTransformToReference()
```
### AddXmlDsigEnvelopedSignatureTransform (Method) <a name="AddXmlDsigEnvelopedSignatureTransform"></a> 

 Adds a AddXmlDsigEnvelopedSignatureTransform object to the list of transforms to be performed on the data before passing it to the digest algorithm.
 

#### Syntax
```
procedure AddXmlDsigEnvelopedSignatureTransform()
```
### ComputeSignature (Method) <a name="ComputeSignature"></a> 

 Computes an Xml digital signature from Xml document.
 

#### Syntax
```
procedure ComputeSignature()
```
### GetXml (Method) <a name="GetXml"></a> 

 Returns the Xml representation of a signature.
 

#### Syntax
```
procedure GetXml(): XmlElement
```
#### Return Value
*[XmlElement]()*

The Xml representation of the signature.
### GetXmlDsigDSAUrl (Method) <a name="GetXmlDsigDSAUrl"></a> 

 Represents the Uniform Resource Identifier (URI) for the standard DSA algorithm for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigDSAUrl(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2000/09/xmldsig#dsa-sha1.
### GetXmlDsigExcC14NTransformUrl (Method) <a name="GetXmlDsigExcC14NTransformUrl"></a> 

 Represents the Uniform Resource Identifier (URI) for exclusive XML canonicalization.
 

#### Syntax
```
procedure GetXmlDsigExcC14NTransformUrl(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2001/10/xml-exc-c14n#.
### GetXmlDsigHMACSHA1Url (Method) <a name="GetXmlDsigHMACSHA1Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the standard HMACSHA1 algorithm for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigHMACSHA1Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2000/09/xmldsig#hmac-sha1.
### GetXmlDsigRSASHA1Url (Method) <a name="GetXmlDsigRSASHA1Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the standard RSA signature method for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigRSASHA1Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2000/09/xmldsig#rsa-sha1.
### GetXmlDsigRSASHA256Url (Method) <a name="GetXmlDsigRSASHA256Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the RSA SHA-256 signature method variation for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigRSASHA256Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2001/04/xmldsig-more#rsa-sha256.
### GetXmlDsigRSASHA384Url (Method) <a name="GetXmlDsigRSASHA384Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the RSA SHA-384 signature method variation for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigRSASHA384Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2001/04/xmldsig-more#rsa-sha384.
### GetXmlDsigRSASHA512Url (Method) <a name="GetXmlDsigRSASHA512Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the RSA SHA-512 signature method variation for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigRSASHA512Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2001/04/xmldsig-more#rsa-sha512.
### GetXmlDsigSHA1Url (Method) <a name="GetXmlDsigSHA1Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the standard SHA1 digest method for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigSHA1Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2000/09/xmldsig#sha1.
### GetXmlDsigSHA256Url (Method) <a name="GetXmlDsigSHA256Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the standard SHA256 digest method for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigSHA256Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2001/04/xmlenc#sha256.
### GetXmlDsigSHA384Url (Method) <a name="GetXmlDsigSHA384Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the standard SHA384 digest method for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigSHA384Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2001/04/xmldsig-more#sha384.
### GetXmlDsigSHA512Url (Method) <a name="GetXmlDsigSHA512Url"></a> 

 Represents the Uniform Resource Identifier (URI) for the standard SHA512 digest method for XML digital signatures.
 

#### Syntax
```
procedure GetXmlDsigSHA512Url(): Text[250]
```
#### Return Value
*[Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The value http://www.w3.org/2001/04/xmlenc#sha512.

## Data Encryption Management (Page 9905)

 Exposes functionality that allows super users for on-premises versions to enable or disable encryption, import, export or change the encryption key.
 


## Hash Algorithm (Enum 1445)

 Specifies the types of hash algorithm.
 

### MD5 (value: 0)


 Specifies the MD5 hash algorithm
 

### SHA1 (value: 1)


 Specifies the SHA1 hash algorithm
 

### SHA256 (value: 2)


 Specifies the SHA256 hash algorithm
 

### SHA384 (value: 3)


 Specifies the SHA384 hash algorithm
 

### SHA512 (value: 4)


 Specifies the SHA512 hash algorithm
 


## RSA Signature Padding (Enum 1285)

 Enum that specifies all of the available padding modes. For more details check .NET RSASignaturePadding Class
 

### Pkcs1 (value: 0)


 Specifies PKCS #1 v1.5 padding mode.
 

### Pss (value: 1)


 Specifies PSS padding mode.
 


## SignatureAlgorithm (Enum 1446)

 Specifies the types of asymmetric algorithms.
 

### RSA (value: 0)


 Specifies the RSA algorithm implemented by RSACryptoServiceProvider
 

### DSA (value: 1)


 Specifies the DSA algorithm implemented by DSACryptoServiceProvider
 


## Signature Key Value Type (Enum 1447)
### XmlString (value: 0)


## X509 Content Type (Enum 1286)
Specifies the format of an X.509 certificate.

### Unknown (value: 0)


 Specifies unknown X.509 certificate.
 

### Cert (value: 1)


 Specifies a single X.509 certificate.
 

### PFXSerializedCert (value: 2)


 Specifies a single serialized X.509 certificate.
 

### Pkcs12 (value: 3)


 Specifies a PKCS #12-formatted certificate. The Pkcs12 value is identical to the Pfx value.
 

### SerializedStore (value: 4)


 Specifies a serialized store.
 

### Pkcs7 (value: 5)


 Specifies a PKCS #7-formatted certificate.
 

### Authenticode (value: 6)


 Specifies an Authenticode X.509 certificate.
 

