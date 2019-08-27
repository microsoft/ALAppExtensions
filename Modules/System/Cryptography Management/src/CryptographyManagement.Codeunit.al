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
    /// <param name="InputString">Input string.</param>
    /// <param name="HashAlgorithmType">The available hash algorithms include HMACMD5, HMACSHA1, HMACSHA256, HMACSHA384, and HMACSHA512.</param>
    /// <returns>Base64 hashed value.</returns>
    procedure GenerateHash(InputString: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    begin
        exit(CryptographyManagementImpl.GenerateHash(InputString, HashAlgorithmType));
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

}

