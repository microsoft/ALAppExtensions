// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for the Advanced Encryption Standard.
/// </summary>

codeunit 1258 "Rijndael Cryptography"
{
    Access = Public;

    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";

    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class with default values.
    /// </summary>
    procedure InitRijndaelProvider()
    begin
        CryptographyManagementImpl.InitRijndaelProvider();
    end;

    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class providing the encryption key.
    /// </summary>
    /// <param name="EncryptionKey">Represents the secret key for the symmetric algorithm.</param>
    procedure InitRijndaelProvider(EncryptionKey: Text)
    begin
        CryptographyManagementImpl.InitRijndaelProvider(EncryptionKey);
    end;

    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class providing the encryption key and block size.
    /// </summary>
    /// <param name="EncryptionKey">Represents the secret key for the symmetric algorithm.</param>
    /// <param name="BlockSize">Represents the block size, in bits, of the cryptographic operation.</param>
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer)
    begin
        CryptographyManagementImpl.InitRijndaelProvider(EncryptionKey, BlockSize);
    end;

    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class providing the encryption key, block size and cipher mode.
    /// </summary>
    /// <param name="EncryptionKey">Represents the secret key for the symmetric algorithm.</param>
    /// <param name="BlockSize">Represents the block size, in bits, of the cryptographic operation.</param>
    /// <param name="CipherMode">Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB</param>
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text)
    begin
        CryptographyManagementImpl.InitRijndaelProvider(EncryptionKey, BlockSize, CipherMode);
    end;


    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class providing the encryption key, block size, cipher mode and padding mode.
    /// </summary>
    /// <param name="EncryptionKey">Represents the secret key for the symmetric algorithm.</param>
    /// <param name="BlockSize">Represents the block size, in bits, of the cryptographic operation.</param>
    /// <param name="CipherMode">Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB</param>
    /// <param name="PaddingMode">Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros</param>
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text; PaddingMode: Text)
    begin
        CryptographyManagementImpl.InitRijndaelProvider(EncryptionKey, BlockSize, CipherMode, PaddingMode);
    end;

    /// <summary>
    /// Sets a new block size value for the RijndaelManaged class.
    /// </summary>
    /// <param name="BlockSize">Represents the block size, in bits, of the cryptographic operation.</param>
    procedure SetBlockSize(BlockSize: Integer)
    begin
        CryptographyManagementImpl.SetBlockSize(BlockSize);
    end;

    /// <summary>
    /// Sets a new cipher mode value for the RijndaelManaged class.
    /// </summary>
    /// <param name="CipherMode">Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB</param>
    procedure SetCipherMode(CipherMode: Text)
    begin
        CryptographyManagementImpl.SetCipherMode(CipherMode);
    end;

    /// <summary>
    /// Sets a new padding mode value for the RijndaelManaged class.
    /// </summary>
    /// <param name="PaddingMode">Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros</param>
    procedure SetPaddingMode(PaddingMode: Text)
    begin
        CryptographyManagementImpl.SetPaddingMode(PaddingMode);
    end;

    /// <summary>
    /// Sets the key and vector for the RijndaelManaged class.
    /// </summary>
    /// <param name="KeyAsBase64">Represents the secret key for the symmetric algorithm encoded as Base64 Text</param>
    /// <param name="VectorAsBase64">Represents the initialization vector (IV) for the symmetric algorithm encoded as Base64 Text</param>
    procedure SetEncryptionData(KeyAsBase64: Text; VectorAsBase64: Text)
    begin
        CryptographyManagementImpl.SetEncryptionData(KeyAsBase64, VectorAsBase64);
    end;

    /// <summary>
    /// Determines whether the specified key size is valid for the current algorithm.
    /// </summary>
    /// <param name="KeySize">Key Size.</param>
    /// <returns>True if the key size is valid; false otherwise.</returns>
    procedure IsValidKeySize(KeySize: Integer): Boolean
    begin
        exit(CryptographyManagementImpl.IsValidKeySize(KeySize))
    end;

    /// <summary>
    /// Specifies the key sizes, in bits, that are supported by the symmetric algorithm.
    /// </summary>
    /// <param name="MinSize">Minimum Size in bits</param>
    /// <param name="MaxSize">Maximum Size in bits</param>
    /// <param name="SkipSize">Skip Size in bits</param>
    procedure GetLegalKeySizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    begin
        CryptographyManagementImpl.GetLegalKeySizeValues(MinSize, MaxSize, SkipSize);
    end;

    /// <summary>
    /// Specifies the block sizes, in bits, that are supported by the symmetric algorithm.
    /// </summary>
    /// <param name="MinSize">Minimum Size in bits</param>
    /// <param name="MaxSize">Maximum Size in bits</param>
    /// <param name="SkipSize">Skip Size in bits</param>
    procedure GetLegalBlockSizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    begin
        CryptographyManagementImpl.GetLegalBlockSizeValues(MinSize, MaxSize, SkipSize);
    end;

    /// <summary>
    /// Gets the key and vector from the RijndaelManaged class
    /// </summary>
    /// <param name="KeyAsBase64">Represents the secret key for the symmetric algorithm encoded as Base64 Text</param>
    /// <param name="VectorAsBase64">Represents the initialization vector (IV) for the symmetric algorithm encoded as Base64 Text</param>
    procedure GetEncryptionData(var KeyAsBase64: Text; var VectorAsBase64: Text)
    begin
        CryptographyManagementImpl.GetEncryptionData(KeyAsBase64, VectorAsBase64);
    end;

    /// <summary>
    /// Returns plain text as an encrypted value.
    /// </summary>
    /// <param name="PlainText">The value to encrypt.</param>
    /// <returns>Encrypted value.</returns>
    procedure Encrypt(PlainText: Text) CryptedText: Text
    begin
        CryptedText := CryptographyManagementImpl.EncryptRijndael(PlainText);
    end;

    /// <summary>
    /// Returns encrypted text as plain text.
    /// </summary>
    /// <param name="CryptedText">The value to decrypt.</param>
    /// <returns>Plain text.</returns>    
    procedure Decrypt(CryptedText: Text) PlainText: Text
    begin
        PlainText := CryptographyManagementImpl.DecryptRijndael(CryptedText);
    end;
}
