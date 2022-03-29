// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for encryption and hashing.
/// For encryption in an on-premises versions, use it to turn encryption on or off, and import and export the encryption key.
/// Encryption is always turned on for online versions.
/// </summary>

codeunit 1266 "Cryptography Management"
{
    Access = Public;

    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";

    /// <summary>
    /// Returns plain text as an encrypted value.
    /// </summary>
    /// <param name="InputString">The value to encrypt.</param>
    /// <returns>Encrypted value.</returns>
    procedure Encrypt(InputString: Text): Text
    begin
        exit(CryptographyManagementImpl.Encrypt(InputString));
    end;

    /// <summary>
    /// Returns encrypted text as plain text.
    /// </summary>
    /// <param name="EncryptedString">The value to decrypt.</param>
    /// <returns>Plain text.</returns>
    procedure Decrypt(EncryptedString: Text): Text
    begin
        exit(CryptographyManagementImpl.Decrypt(EncryptedString));
    end;

    /// <summary>
    /// Checks if Encryption is enabled.
    /// </summary>
    /// <returns>True if encryption is enabled, false otherwise.</returns>
    procedure IsEncryptionEnabled(): Boolean
    begin
        exit(CryptographyManagementImpl.IsEncryptionEnabled());
    end;

    /// <summary>
    /// Checks whether the encryption key is present, which only works if encryption is enabled.
    /// </summary>
    /// <returns>True if the encryption key exists, false otherwise.</returns>
    procedure IsEncryptionPossible(): Boolean
    begin
        exit(CryptographyManagementImpl.IsEncryptionPossible());
    end;

    /// <summary>
    /// Gets the recommended question to activate encryption.
    /// </summary>
    /// <returns>String of a recommended question to activate encryption.</returns>
    procedure GetEncryptionIsNotActivatedQst(): Text
    begin
        exit(CryptographyManagementImpl.GetEncryptionIsNotActivatedQst());
    end;

    /// <summary>
    /// Enables encryption.
    /// </summary>
    /// <param name="Silent">Enables encryption silently if true, otherwise will prompt the user.</param>
    [Scope('OnPrem')]
    procedure EnableEncryption(Silent: Boolean)
    begin
        CryptographyManagementImpl.EnableEncryption(Silent);
    end;

    /// <summary>
    /// Disables encryption.
    /// </summary>
    /// <param name="Silent">Turns off encryption silently if true, otherwise will prompt the user.</param>
    [Scope('OnPrem')]
    procedure DisableEncryption(Silent: Boolean)
    begin
        CryptographyManagementImpl.DisableEncryption(Silent);
    end;

    /// <summary>
    /// Publishes an event that allows subscription when enabling encryption.
    /// </summary>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnBeforeEnableEncryptionOnPrem()
    begin
    end;

    /// <summary>
    /// Publishes an event that allows subscription when disabling encryption.
    /// </summary>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnBeforeDisableEncryptionOnPrem()
    begin
    end;

    /// <summary>
    /// Generates a hash from a string based on the provided hash algorithm.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <returns>Hashed value.</returns>
    procedure GenerateHash(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateHash(InputString, HashAlgorithmType));
    end;

    /// <summary>
    /// Generates a keyed hash from a string based on provided hash algorithm and key.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="Key">Key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.</param>
    /// <returns>Hashed value.</returns>
    procedure GenerateHash(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateHash(InputString, Key, HashAlgorithmType));
    end;

    /// <summary>
    /// Generates a hash from a stream based on the provided hash algorithm.
    /// </summary>
    /// <param name="InputInStream">Input string.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.</param>
    /// <returns>Base64 hashed value.</returns>
    procedure GenerateHash(InputInStream: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateHash(InputInStream, HashAlgorithmType));
    end;

    /// <summary>
    /// Generates a base64 encoded hash from a string based on provided hash algorithm.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <returns>Base64 hashed value.</returns>
    procedure GenerateHashAsBase64String(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateHashAsBase64String(InputString, HashAlgorithmType));
    end;

    /// <summary>
    /// Generates a keyed base64 encoded hash from a string based on provided hash algorithm and key.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="Key">Key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.</param>
    /// <returns>Base64 hashed value.</returns>
    procedure GenerateHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateHashAsBase64String(InputString, Key, HashAlgorithmType));
    end;

    /// <summary>
    /// Generates keyed base64 encoded hash from provided string based on provided hash algorithm and base64 key.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="Key">Key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.</param>
    /// <returns>Base64 hashed value.</returns>
    procedure GenerateBase64KeyedHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateBase64KeyedHashAsBase64String(InputString, Key, HashAlgorithmType));
    end;

    /// <summary>
    /// Generates keyed base64 encoded hash from provided string based on provided hash algorithm and base64 key.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="Key">Key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.</param>
    /// <returns>Hashed value.</returns>
    procedure GenerateBase64KeyedHash(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateBase64KeyedHash(InputString, Key, HashAlgorithmType));
    end;

    /// <summary>
    /// Computes the hash value of the specified string and signs it.
    /// </summary>
    /// <param name="InputString">Input string for signing.</param>
    /// <param name="XmlString">The private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureOutStream">The stream to write the signature for the specified string.</param>
    procedure SignData(InputString: Text; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(InputString, XmlString, HashAlgorithm, SignatureOutStream);
    end;

    /// <summary>
    /// Computes the hash value of the specified data and signs it.
    /// </summary>
    /// <param name="DataInStream">The stream of input data.</param>
    /// <param name="XmlString">The private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureOutStream">The stream to write the signature for the specified input data.</param>
    procedure SignData(DataInStream: InStream; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(DataInStream, XmlString, HashAlgorithm, SignatureOutStream);
    end;

    /// <summary>
    /// Computes the hash value of the specified string and signs it.
    /// </summary>
    /// <param name="InputString">Input string for signing.</param>
    /// <param name="SignatureKey">The private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureOutStream">The stream to write the signature for the specified string.</param>
    procedure SignData(InputString: Text; SignatureKey: Codeunit "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(InputString, SignatureKey, HashAlgorithm, SignatureOutStream);
    end;

    /// <summary>
    /// Computes the hash value of the specified data and signs it.
    /// </summary>
    /// <param name="DataInStream">The stream of input data.</param>
    /// <param name="SignatureKey">The private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureOutStream">The stream to write the signature for the specified input data.</param>
    procedure SignData(DataInStream: InStream; SignatureKey: Codeunit "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(DataInStream, SignatureKey, HashAlgorithm, SignatureOutStream);
    end;

#if not CLEAN19
#pragma warning disable AL0432
    /// <summary>
    /// Computes the hash value of the specified string and signs it.
    /// </summary>
    /// <param name="InputString">Input string for signing.</param>
    /// <param name="SignatureKey">The private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureOutStream">The stream to write the signature for the specified string.</param>
    [Obsolete('Replaced by SignData function with XmlString parameter.', '19.1')]
    procedure SignData(InputString: Text; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(InputString, SignatureKey, HashAlgorithm, SignatureOutStream);
    end;

    /// <summary>
    /// Computes the hash value of the specified data and signs it.
    /// </summary>
    /// <param name="DataInStream">The stream of input data.</param>
    /// <param name="SignatureKey">The private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureOutStream">The stream to write the signature for the specified input data.</param>
    [Obsolete('Replaced by SignData function with XmlString parameter.', '19.1')]
    procedure SignData(DataInStream: InStream; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(DataInStream, SignatureKey, HashAlgorithm, SignatureOutStream);
    end;
#pragma warning restore
#endif

#if not CLEAN18
    /// <summary>
    /// Computes the hash value of the specified string and signs it.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="KeyStream">The stream of the private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureStream">The stream to write the output to.</param>
    /// <returns>The signature for the specified string.</returns>
    [Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
    procedure SignData(InputString: Text; KeyStream: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(InputString, KeyStream, HashAlgorithmType, SignatureStream);
    end;

    /// <summary>
    /// Computes the hash value of the specified data and signs it.
    /// </summary>
    /// <param name="DataStream">The stream of input data.</param>
    /// <param name="KeyStream">The stream of the private key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureStream">The stream to write the output to.</param>
    /// <returns>The signature for the specified data.</returns>
    [Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
    procedure SignData(DataStream: InStream; KeyStream: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA5122; SignatureStream: OutStream)
    begin
        CryptographyManagementImpl.SignData(DataStream, KeyStream, HashAlgorithmType, SignatureStream);
    end;
#endif

    /// <summary>
    /// Verifies that a digital signature is valid.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="XmlString">The public key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureInStream">The stream of signature.</param>
    /// <returns>True if the signature is valid; otherwise, false.</returns>
    procedure VerifyData(InputString: Text; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    begin
        exit(CryptographyManagementImpl.VerifyData(InputString, XmlString, HashAlgorithm, SignatureInStream));
    end;

    /// <summary>
    /// Verifies that a digital signature is valid.
    /// </summary>
    /// <param name="DataInStream">The stream of input data.</param>
    /// <param name="XmlString">The public key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureInStream">The stream of signature.</param>
    /// <returns>True if the signature is valid; otherwise, false.</returns>
    procedure VerifyData(DataInStream: InStream; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    begin
        exit(CryptographyManagementImpl.VerifyData(DataInStream, XmlString, HashAlgorithm, SignatureInStream));
    end;

#if not CLEAN19
#pragma warning disable AL0432
    /// <summary>
    /// Verifies that a digital signature is valid.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="SignatureKey">The public key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureInStream">The stream of signature.</param>
    /// <returns>True if the signature is valid; otherwise, false.</returns>
    [Obsolete('Replaced by VerifyData function with XmlString parameter.', '19.1')]
    procedure VerifyData(InputString: Text; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    begin
        exit(CryptographyManagementImpl.VerifyData(InputString, SignatureKey, HashAlgorithm, SignatureInStream));
    end;

    /// <summary>
    /// Verifies that a digital signature is valid.
    /// </summary>
    /// <param name="DataInStream">The stream of input data.</param>
    /// <param name="SignatureKey">The public key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithm">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureInStream">The stream of signature.</param>
    /// <returns>True if the signature is valid; otherwise, false.</returns>
    [Obsolete('Replaced by VerifyData function with XmlString parameter.', '19.1')]
    procedure VerifyData(DataInStream: InStream; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    begin
        exit(CryptographyManagementImpl.VerifyData(DataInStream, SignatureKey, HashAlgorithm, SignatureInStream));
    end;
#pragma warning restore
#endif

#if not CLEAN18
    /// <summary>
    /// Verifies that a digital signature is valid.
    /// </summary>
    /// <param name="InputString">Input string.</param>
    /// <param name="Key">Public key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureStream">The stream of signature.</param>
    /// <returns>True if the digital signature is valid.</returns>
    [Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
    procedure VerifyData(InputString: Text; "Key": Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: InStream): Boolean
    begin
        exit(CryptographyManagementImpl.VerifyData(InputString, "Key", HashAlgorithmType, SignatureStream));
    end;

    /// <summary>
    /// Verifies that a digital signature is valid.
    /// </summary>
    /// <param name="DataStream">The stream of input data.</param>
    /// <param name="Key">Public key to use in the hash algorithm.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms are MD5, SHA1, SHA256, SHA384, and SHA512.</param>
    /// <param name="SignatureStream">The stream of digital signature.</param>
    /// <returns>True if the digital signature is valid.</returns>
    [Obsolete('Replaced by SignData with SignatureKey parameter.', '18.0')]
    procedure VerifyData(DataStream: InStream; "Key": Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: InStream): Boolean
    begin
        exit(CryptographyManagementImpl.VerifyData(DataStream, "Key", HashAlgorithmType, SignatureStream));
    end;
#endif
}
