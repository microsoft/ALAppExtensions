// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for the Advanced Encryption Standard.
/// </summary>

codeunit 50102 "DESCryptoServiceProvider"
{
    Access = Public;

    /// <summary>
    /// Encrypts text with DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="VarInput">Represents the input text to be encrypted</param>
    procedure EncryptTextWithDESCryptoServiceProvider(VarInput: Text; Password: Text; Salt: Text) VarOutput: Text
    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";
    begin
        VarOutput := CryptographyManagementImpl.EncryptTextWithDESCryptoServiceProvider(VarInput, Password, Salt);
    end;

    /// <summary>
    /// Decrypts text with DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="VarInput">Represents the input text to be encrypted</param>
    procedure DecryptTextWithDESCryptoServiceProvider(VarInput: Text; Password: Text; Salt: Text) VarOutput: Text
    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";
    begin
        VarOutput := CryptographyManagementImpl.DecryptTextWithDESCryptoServiceProvider(VarInput, Password, Salt);
    end;


    /// <summary>
    /// Encrypts data in stream with DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="InputInstream">Represents the input instream data to be encrypted</param>
    /// <param name="OutputOutstream">Represents the output instream encrypted data </param>
    procedure EncryptStreamWithDESCryptoServiceProvider(Password: Text; InputInstream: InStream; VAR OutputOutstream: Outstream)
    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";
    begin
        CryptographyManagementImpl.EncryptStreamWithDESCryptoServiceProvider(Password, InputInstream, OutputOutstream);
    end;

    /// <summary>
    /// Encrypts data in stream with DESCryptoServiceProvider
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="InputInstream">Represents the input instream data to be decrypted</param>
    /// <param name="OutputOutstream">Represents the output instream decrypted data </param>
    procedure DecryptStreamWithDESCryptoServiceProvider(Password: Text; InputInstream: InStream; VAR OutputOutstream: Outstream)
    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";
    begin
        CryptographyManagementImpl.DecryptStreamWithDESCryptoServiceProvider(Password, InputInstream, OutputOutstream);
    end;
}