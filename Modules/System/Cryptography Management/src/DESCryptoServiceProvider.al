// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
// Provides helper functions for the Data Encryption Standard (DES)
/// </summary>

codeunit 1379 "DESCryptoServiceProvider"
{
    Access = Public;

    var
        DESCryptoServiceProviderImpl: Codeunit "DESCryptoServiceProvider Impl.";

    /// <summary>
    /// Encrypts text with DotNet Cryptography.DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of DotNet System.Security.Cryptography.Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of System.Security.Cryptography.Rfc2898DeriveBytes</param>
    /// <param name="EncryptedText">Represents the text to encrypt</param>
    /// <param name="DecryptedText">Returns the encrypted text</param>
    procedure EncryptTextWithDESCryptoServiceProvider(DecryptedText: Text; Password: Text; Salt: Text) EncryptedText: Text
    begin
        EncryptedText := DESCryptoServiceProviderImpl.EncryptTextWithDESCryptoServiceProvider(DecryptedText, Password, Salt);
    end;

    /// <summary>
    /// Decrypts text with DotNet Cryptography.DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of DotNet System.Security.Cryptography.Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of System.Security.Cryptography.Rfc2898DeriveBytes</param>
    /// <param name="EncryptedText">Represents the text to decrypt</param>
    /// <param name="DecryptedText">Returns the decrypted text</param>
    procedure DecryptTextWithDESCryptoServiceProvider(EncryptedText: Text; Password: Text; Salt: Text) DecryptedText: Text
    begin
        DecryptedText := DESCryptoServiceProviderImpl.DecryptTextWithDESCryptoServiceProvider(EncryptedText, Password, Salt);
    end;


    /// <summary>
    /// Encrypts data in stream with DotNet Cryptography.DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="InputInstream">Represents the input instream data to encrypt</param>
    /// <param name="OutputOutstream">Represents the output instream encrypted data</param>
    procedure EncryptStreamWithDESCryptoServiceProvider(Password: Text; EncryptStream: InStream; VAR DecryptStream: Outstream)
    begin
        DESCryptoServiceProviderImpl.EncryptStreamWithDESCryptoServiceProvider(Password, EncryptStream, DecryptStream);
    end;

    /// <summary>
    /// Encrypts data in stream with DotNet Cryptography.DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="InputInstream">Represents the input instream data to decrypt</param>
    /// <param name="OutputOutstream">Represents the output instream decrypted data</param>
    procedure DecryptStreamWithDESCryptoServiceProvider(Password: Text; InputInstream: InStream; VAR OutputOutstream: Outstream)
    begin
        DESCryptoServiceProviderImpl.DecryptStreamWithDESCryptoServiceProvider(Password, InputInstream, OutputOutstream);
    end;
}