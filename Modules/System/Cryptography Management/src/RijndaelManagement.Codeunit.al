// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 50101 "Rijndael Management"
{
    Access = Public;

    var
        RijndaelManagementImpl: Codeunit "Rijndael Management Impl.";

        /// <summary>
        /// Initializes a new instance of the RijndaelManaged class with default values
        /// </summary>
    procedure InitRijndaelProvider()
    begin
        RijndaelManagementImpl.InitRijndaelProvider();
    end;

    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class
    /// <param name=EncryptionKey>Represents the secret key for the symmetric algorithm.</param>
    /// </summary>
    procedure InitRijndaelProvider(EncryptionKey: Text)
    begin
        RijndaelManagementImpl.InitRijndaelProvider(EncryptionKey);
    end;

    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class
    /// <param name=EncryptionKey>Represents the secret key for the symmetric algorithm.</param>
    /// <param name=BlockSize>Represents the block size, in bits, of the cryptographic operation.</param>
    /// </summary>
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer)
    begin
        RijndaelManagementImpl.InitRijndaelProvider(EncryptionKey, BlockSize);
    end;

    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class
    /// <param name=EncryptionKey>Represents the secret key for the symmetric algorithm.</param>
    /// <param name=BlockSize>Represents the block size, in bits, of the cryptographic operation.</param>
    /// <param name=ChiperMode>Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB</param>
    /// </summary>
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; ChiperMode: Text)
    begin
        RijndaelManagementImpl.InitRijndaelProvider(EncryptionKey, BlockSize, ChiperMode);
    end;


    /// <summary>
    /// Initializes a new instance of the RijndaelManaged class
    /// <param name=EncryptionKey>Represents the secret key for the symmetric algorithm.</param>
    /// <param name=BlockSize>Represents the block size, in bits, of the cryptographic operation.</param>
    /// <param name=ChiperMode>Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB</param>
    /// <param name=PaddingMode>Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros</param>    
    /// </summary>
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; ChiperMode: Text; PaddingMode: Text)
    begin
        RijndaelManagementImpl.InitRijndaelProvider(EncryptionKey, BlockSize, ChiperMode, PaddingMode);
    end;

    /// <summary>
    /// Set new block size value for the RijndaelManaged class    
    /// <param name=BlockSize>Represents the block size, in bits, of the cryptographic operation.</param>
    /// </summary>
    procedure SetBlockSize(BlockSize: Integer)
    begin
        RijndaelManagementImpl.SetBlockSize(BlockSize);
    end;

    /// <summary>
    /// Set new chiper mode value for the RijndaelManaged class    
    /// <param name=ChiperMode>Represents the cipher mode used in the symmetric algorithm. Valid values: ECB,CBC,CFB,CTS,OFB</param>
    /// </summary>
    procedure SetChiperMode(ChiperMode: Text)
    begin
        RijndaelManagementImpl.SetChiperMode(ChiperMode);
    end;

    /// <summary>
    /// Set new padding mode value for the RijnadaelManaged class    
    /// <param name=PaddingMode>Represents the padding mode used in the symmetric algorithm.. Valid values: None,ANSIX923,ISO10126,PKCS7,Zeros</param>    
    /// </summary>
    procedure SetPaddingMode(PaddingMode: Text)
    begin
        RijndaelManagementImpl.SetPaddingMode(PaddingMode);
    end;

    /// <summary>
    /// Set the key and vector for the RijnadaelManaged class    
    /// <param name=KeyAsBase64>Represents the secret key for the symmetric algorithm encoded as Base64 Text</param>    
    /// <param name=VectorBase64>Represents the initialization vector (IV) for the symmetric algorithm encoded as Base64 Text</param>    
    /// </summary>
    procedure SetEncryptionData(KeyAsBase64: Text; VectorAsBase64: Text)
    begin
        RijndaelManagementImpl.SetEncryptionData(KeyAsBase64, VectorAsBase64);
    end;

    /// <summary>
    /// Determines whether the specified key size is valid for the current algorithm.
    /// <param name=KeySize>Key Size.</param>
    /// </summary>
    procedure IsValidKeySize(KeySize: Integer): Boolean
    begin
        exit(RijndaelManagementImpl.IsValidKeySize(KeySize))
    end;

    /// <summary>
    /// Specifies the key sizes, in bits, that are supported by the symmetric algorithm.
    /// <param name=MinSize>Minimum Size in bits</param>
    /// <param name=MaxSize>Mazimum Size in bits</param>
    /// <param name=SkipSize>Skip Size in bits</param>
    /// </summary>
    procedure GetLegalKeySizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    begin
        RijndaelManagementImpl.GetLegalKeySizeValues(MinSize, MaxSize, SkipSize);
    end;

    /// <summary>
    /// Specifies the block sizes, in bits, that are supported by the symmetric algorithm.
    /// <param name=MinSize>Minimum Size in bits</param>
    /// <param name=MaxSize>Mazimum Size in bits</param>
    /// <param name=SkipSize>Skip Size in bits</param>
    /// </summary>
    procedure GetLegalBlockSizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    begin
        RijndaelManagementImpl.GetLegalBlockSizeValues(MinSize, MaxSize, SkipSize);
    end;

    /// <summary>
    /// Get the key and vector from the RijnadaelManaged class    
    /// <param name=KeyAsBase64>Represents the secret key for the symmetric algorithm encoded as Base64 Text</param>    
    /// <param name=VectorBase64>Represents the initialization vector (IV) for the symmetric algorithm encoded as Base64 Text</param>    
    /// </summary>
    procedure GetEncryptionData(var KeyAsBase64: Text; var VectorAsBase64: Text)
    begin
        RijndaelManagementImpl.GetEncryptionData(KeyAsBase64, VectorAsBase64);
    end;

    /// <summary>
    /// Returns plain text as an encrypted value.
    /// </summary>
    /// <param name="PlainText">The value to encrypt.</param>
    /// <returns>Encrypted value.</returns>
    procedure Encrypt(PlainText: Text) CryptedText: Text
    begin
        CryptedText := RijndaelManagementImpl.Encrypt(PlainText);
    end;

    /// <summary>
    /// Returns encrypted text as plain text.
    /// </summary>
    /// <param name="CryptedText">The value to decrypt.</param>
    /// <returns>Plain text.</returns>    
    procedure Decrypt(CryptedText: Text) PlainText: Text
    begin
        PlainText := RijndaelManagementImpl.Decrypt(CryptedText);
    end;

}
