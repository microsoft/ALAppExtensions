// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1382 "DESCryptoServiceProvider Impl."
{
    Access = Internal;

    [NonDebuggable]
    procedure EncryptText(VarInput: Text; Password: Text; Salt: Text) VarOutput: Text
    var
        ByteArray: DotNet Array;
        SymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm";
        Encoding: DotNet Encoding;
    begin
        if VarInput = '' then
            exit;

        ConstructDESCryptoServiceProvider(SymmetricAlgorithm, Password, Salt);
        ByteArray := Encoding.Default.GetBytes(VarInput);
        TransformToArray(SymmetricAlgorithm.CreateEncryptor(), ByteArray);
        VarOutput := Encoding.Default.GetString(ByteArray, 0, ByteArray.Length);
    end;

    [NonDebuggable]
    procedure DecryptText(VarInput: Text; Password: Text; Salt: Text) VarOutput: Text
    var
        ByteArray: DotNet Array;
        Encoding: DotNet Encoding;
        SymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm";
    begin
        if VarInput = '' then
            exit;

        ConstructDESCryptoServiceProvider(SymmetricAlgorithm, Password, Salt);
        ByteArray := Encoding.Default.GetBytes(VarInput);
        TransformToArray(SymmetricAlgorithm.CreateDecryptor(), ByteArray);
        VarOutput := Encoding.Default.GetString(ByteArray, 0, ByteArray.Length);
    end;

    [NonDebuggable]
    procedure EncryptStream(Password: Text; Salt: Text; InputInstream: InStream; VAR OutputOutstream: Outstream)
    var
        MemoryStream: DotNet MemoryStream;
        ByteArray: DotNet Array;
        SymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm";
    begin
        InStreamToArray(InputInstream, ByteArray);

        ConstructDESCryptoServiceProvider(SymmetricAlgorithm, Password, Salt);
        TransformToArray(SymmetricAlgorithm.CreateEncryptor(), ByteArray);

        MemoryStream := MemoryStream.MemoryStream(ByteArray);
        CopyStream(OutputOutstream, MemoryStream);
    end;

    [NonDebuggable]
    procedure DecryptStream(Password: Text; Salt: Text; InputInstream: InStream; var OutputOutstream: Outstream)
    var
        MemoryStream: DotNet MemoryStream;
        ByteArray: DotNet Array;
        SymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm";
    begin
        InStreamToArray(InputInstream, ByteArray);
        ConstructDESCryptoServiceProvider(SymmetricAlgorithm, Password, Salt);
        TransformToArray(SymmetricAlgorithm.CreateDecryptor(), ByteArray);

        MemoryStream := MemoryStream.MemoryStream(ByteArray);
        CopyStream(OutputOutstream, MemoryStream);
    end;

    local procedure InStreamToArray(InputInstream: InStream; var ByteArray: DotNet Array)
    var
        MemoryStream: DotNet MemoryStream;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InputInstream);
        ByteArray := MemoryStream.ToArray();
    end;

    [NonDebuggable]
    local procedure ConstructDESCryptoServiceProvider(var SymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm"; Password: Text; Salt: Text)
    var
        Encoding: DotNet Encoding;
        DESCryptoServiceProvider: DotNet "Cryptography.DESCryptoServiceProvider";
        Rfc2898DeriveBytes: DotNet Rfc2898DeriveBytes;
    begin
        Rfc2898DeriveBytes := Rfc2898DeriveBytes.Rfc2898DeriveBytes(Password, Encoding.ASCII.GetBytes(Salt));

        SymmetricAlgorithm := DESCryptoServiceProvider.DESCryptoServiceProvider();
        SymmetricAlgorithm.Key := Rfc2898DeriveBytes.GetBytes(8);
        SymmetricAlgorithm.IV := Rfc2898DeriveBytes.GetBytes(8);
    end;

    local procedure TransformToArray(CryptoTransform: DotNet "Cryptography.ICryptoTransform"; var ByteArray: DotNet Array)
    begin
        ByteArray := CryptoTransform.TransformFinalBlock(ByteArray, 0, ByteArray.Length);
    end;
}