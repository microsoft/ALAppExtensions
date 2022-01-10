// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1446 "RSACryptoServiceProvider Impl." implements SignatureAlgorithm
{
    Access = Internal;

    var
        DotNetRSACryptoServiceProvider: DotNet RSACryptoServiceProvider;

    procedure GetInstance(var DotNetAsymmetricAlgorithm: DotNet AsymmetricAlgorithm)
    begin
        DotNetAsymmetricAlgorithm := DotNetRSACryptoServiceProvider;
    end;

    #region SignData
    [NonDebuggable]
    procedure SignData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        FromXmlString(XmlString);
        SignData(DataInStream, HashAlgorithm, SignatureOutStream);
    end;

    [NonDebuggable]
    procedure SignData(DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    var
        Bytes: DotNet Array;
        Signature: DotNet Array;
    begin
        if DataInStream.EOS() then
            exit;
        InStreamToArray(DataInStream, Bytes);
        SignData(Bytes, HashAlgorithm, Signature);
        ArrayToOutStream(Signature, SignatureOutStream);
    end;

    [NonDebuggable]
    local procedure SignData(Bytes: DotNet Array; HashAlgorithm: Enum "Hash Algorithm"; var Signature: DotNet Array)
    begin
        if Bytes.Length() = 0 then
            exit;
        TrySignData(Bytes, HashAlgorithm, Signature);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TrySignData(Bytes: DotNet Array; HashAlgorithm: Enum "Hash Algorithm"; var Signature: DotNet Array)
    begin
        Signature := DotNetRSACryptoServiceProvider.SignData(Bytes, Format(HashAlgorithm));
    end;
    #endregion

    #region VerifyData
    [NonDebuggable]
    procedure VerifyData(XmlString: Text; DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    begin
        FromXmlString(XmlString);
        exit(VerifyData(DataInStream, HashAlgorithm, SignatureInStream));
    end;

    [NonDebuggable]
    procedure VerifyData(DataInStream: InStream; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    var
        Bytes: DotNet Array;
        Signature: DotNet Array;
    begin
        if DataInStream.EOS() or SignatureInStream.EOS() then
            exit(false);
        InStreamToArray(DataInStream, Bytes);
        InStreamToArray(SignatureInStream, Signature);
        exit(VerifyData(Bytes, HashAlgorithm, Signature));
    end;

    [NonDebuggable]
    local procedure VerifyData(Bytes: DotNet Array; HashAlgorithm: Enum "Hash Algorithm"; Signature: DotNet Array): Boolean
    var
        Verified: Boolean;
    begin
        if Bytes.Length() = 0 then
            exit(false);
        Verified := TryVerifyData(Bytes, HashAlgorithm, Signature);
        if not Verified and (GetLastErrorText() <> '') then
            Error(GetLastErrorText());
        exit(Verified);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryVerifyData(Bytes: DotNet Array; HashAlgorithm: Enum "Hash Algorithm"; Signature: DotNet Array)
    begin
        if not DotNetRSACryptoServiceProvider.VerifyData(Bytes, Format(HashAlgorithm), Signature) then
            Error('');
    end;
    #endregion

    #region Encryption & Decryption
    [NonDebuggable]
    procedure Encrypt(XmlString: Text; PlainTextInStream: InStream; OaepPadding: Boolean; EncryptedTextOutStream: OutStream)
    var
        PlainTextBytes: DotNet Array;
        EncryptedTextBytes: DotNet Array;
    begin
        FromXmlString(XmlString);
        InStreamToArray(PlainTextInStream, PlainTextBytes);
        EncryptedTextBytes := DotNetRSACryptoServiceProvider.Encrypt(PlainTextBytes, OaepPadding);
        ArrayToOutStream(EncryptedTextBytes, EncryptedTextOutStream);
    end;

    [NonDebuggable]
    procedure Decrypt(XmlString: Text; EncryptedTextInStream: InStream; OaepPadding: Boolean; DecryptedTextOutStream: OutStream)
    var
        EncryptedTextBytes: DotNet Array;
        DecryptedTextBytes: DotNet Array;
    begin
        FromXmlString(XmlString);
        InStreamToArray(EncryptedTextInStream, EncryptedTextBytes);
        DecryptedTextBytes := DotNetRSACryptoServiceProvider.Decrypt(EncryptedTextBytes, OaepPadding);
        ArrayToOutStream(DecryptedTextBytes, DecryptedTextOutStream);
    end;
    #endregion

    #region XmlString
    [NonDebuggable]
    procedure ToXmlString(IncludePrivateParameters: Boolean): Text
    begin
        exit(DotNetRSACryptoServiceProvider.ToXmlString(IncludePrivateParameters));
    end;

    [NonDebuggable]
    procedure FromXmlString(XmlString: Text)
    begin
        RSACryptoServiceProvider();
        DotNetRSACryptoServiceProvider.FromXmlString(XmlString);
    end;
    #endregion

    local procedure RSACryptoServiceProvider()
    begin
        DotNetRSACryptoServiceProvider := DotNetRSACryptoServiceProvider.RSACryptoServiceProvider();
    end;

    [NonDebuggable]
    local procedure ArrayToOutStream(Bytes: DotNet Array; OutputOutStream: OutStream)
    var
        DotNetMemoryStream: DotNet MemoryStream;
    begin
        DotNetMemoryStream := DotNetMemoryStream.MemoryStream(Bytes);
        CopyStream(OutputOutStream, DotNetMemoryStream);
    end;

    [NonDebuggable]
    local procedure InStreamToArray(InputInStream: InStream; var Bytes: DotNet Array)
    var
        DotNetMemoryStream: DotNet MemoryStream;
    begin
        DotNetMemoryStream := DotNetMemoryStream.MemoryStream();
        CopyStream(DotNetMemoryStream, InputInStream);
        Bytes := DotNetMemoryStream.ToArray();
    end;
}