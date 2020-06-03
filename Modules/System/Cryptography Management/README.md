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
- Set a new block size value for the RijnadaelManaged class.
- Set a new cipher mode value for the RijnadaelManaged class.
- Set a new padding mode value for the RijnadaelManaged class.
- Set the key and vector for the RijnadaelManaged class.
- Determine whether the specified key size is valid for the current algorithm.
- Specify the key sizes, in bits, that are supported by the symmetric algorithm.
- Specify the block sizes, in bits, that are supported by the symmetric algorithm.
- Get the key and vector from the RijnadaelManaged class.
- Return plain text as an encrypted value.
- Return encrypted text as plain text.

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
### SignData (Method) <a name="SignData"></a> 

 Computes the hash value of the specified string and signs it.
 

#### Syntax
```
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

 Sets a new block size value for the RijnadaelManaged class.
 

#### Syntax
```
procedure SetBlockSize(BlockSize: Integer)
```
#### Parameters
*BlockSize ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Represents the block size, in bits, of the cryptographic operation.

### SetCipherMode (Method) <a name="SetCipherMode"></a> 

 Sets a new cipher mode value for the RijnadaelManaged class.
 

#### Syntax
```
procedure SetCipherMode(CipherMode: Text)
```
#### Parameters
*CipherMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB

### SetPaddingMode (Method) <a name="SetPaddingMode"></a> 

 Sets a new padding mode value for the RijnadaelManaged class.
 

#### Syntax
```
procedure SetPaddingMode(PaddingMode: Text)
```
#### Parameters
*PaddingMode ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros

### SetEncryptionData (Method) <a name="SetEncryptionData"></a> 

 Sets the key and vector for the RijnadaelManaged class.
 

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

 Gets the key and vector from the RijnadaelManaged class
 

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


## Data Encryption Management (Page 9905)

 Exposes functionality that allows super users for on-premises versions to enable or disable encryption, import, export or change the encryption key.
 


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
 

