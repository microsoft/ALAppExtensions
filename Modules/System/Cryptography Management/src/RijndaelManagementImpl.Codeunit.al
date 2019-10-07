// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 50100 "Rijndael Management Impl."
{
    Access = Internal;

    var
        RijndaelProvider: DotNet RijndaelManaged;
        CryptoStreamMode: DotNet CryptoStreamMode;


    [Scope('OnPrem')]
    procedure InitRijndaelProvider()
    begin
        RijndaelProvider := RijndaelProvider.RijndaelManaged();
        RijndaelProvider.GenerateKey();
        RijndaelProvider.GenerateIV();
    end;

    [Scope('OnPrem')]
    procedure InitRijndaelProvider(EncryptionKey: Text)
    var
        Encoding: DotNet Encoding;
    begin
        InitRijndaelProvider();
        RijndaelProvider."Key" := Encoding.Default().GetBytes(EncryptionKey);
    end;

    [Scope('OnPrem')]
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer)
    begin
        InitRijndaelProvider(EncryptionKey);
        SetBlockSize(BlockSize);
    end;

    [Scope('OnPrem')]
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; ChiperMode: Text)
    begin
        InitRijndaelProvider(EncryptionKey, BlockSize);
        SetChiperMode(ChiperMode);
    end;

    [Scope('OnPrem')]
    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; ChiperMode: Text; PaddingMode: Text)
    begin
        InitRijndaelProvider(EncryptionKey, BlockSize, ChiperMode);
        SetPaddingMode(PaddingMode);
    end;

    [Scope('OnPrem')]
    procedure SetBlockSize(BlockSize: Integer)
    begin
        Construct();
        RijndaelProvider.BlockSize := BlockSize;
    end;

    [Scope('OnPrem')]
    procedure SetChiperMode(ChiperMode: Text)
    var
        CryptographyChiperMode: DotNet ChiperMode;
    begin
        Construct();
        CryptographyChiperMode := RijndaelProvider.Mode();
        RijndaelProvider.Mode := CryptographyChiperMode.Parse(CryptographyChiperMode.GetType(), ChiperMode);
    end;

    [Scope('OnPrem')]
    procedure SetPaddingMode(PaddingMode: Text)
    var
        CryptographyPaddingMode: DotNet PaddingMode;
    begin
        Construct();
        CryptographyPaddingMode := RijndaelProvider.Padding();
        RijndaelProvider.Padding := CryptographyPaddingMode.Parse(CryptographyPaddingMode.GetType(), PaddingMode);
    end;

    [Scope('OnPrem')]
    procedure SetEncryptionData(KeyAsBase64: Text; VectorAsBase64: Text)
    var
        Convert: DotNet Convert;
    begin
        Construct();
        RijndaelProvider."Key"(Convert.FromBase64String(KeyAsBase64));
        RijndaelProvider.IV(Convert.FromBase64String(VectorAsBase64));
    end;

    [Scope('OnPrem')]
    procedure IsValidKeySize(KeySize: Integer): Boolean
    begin
        Construct();
        exit(RijndaelProvider.ValidKeySize(KeySize))
    end;

    [Scope('OnPrem')]
    procedure GetLegalKeySizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    var
        KeySizes: DotNet KeySizes;
    begin
        Construct();
        KeySizes := RijndaelProvider.LegalKeySizes().GetValue(0);
        MinSize := KeySizes.MinSize();
        MaxSize := KeySizes.MaxSize();
        SkipSize := KeySizes.SkipSize();
    end;

    [Scope('OnPrem')]
    procedure GetLegalBlockSizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    var
        KeySizes: DotNet KeySizes;
    begin
        Construct();
        KeySizes := RijndaelProvider.LegalBlockSizes().GetValue(0);
        MinSize := KeySizes.MinSize();
        MaxSize := KeySizes.MaxSize();
        SkipSize := KeySizes.SkipSize();
    end;

    [Scope('OnPrem')]
    procedure GetEncryptionData(var KeyAsBase64: Text; var VectorAsBase64: Text)
    var
        Convert: DotNet Convert;
    begin
        Construct();
        KeyAsBase64 := Convert.ToBase64String(RijndaelProvider."Key"());
        VectorAsBase64 := Convert.ToBase64String(RijndaelProvider.IV());
    end;

    [Scope('OnPrem')]
    procedure Encrypt(PlainText: Text) CryptedText: Text
    var
        Encryptor: DotNet ICryptoTransform;
        Convert: DotNet Convert;
        EncMemoryStream: DotNet MemoryStream;
        EncCryptoStream: DotNet CryptoStream;
        EncStreamWriter: DotNet StreamWriter;
    begin
        Construct();
        Encryptor := RijndaelProvider.CreateEncryptor();
        EncMemoryStream := EncMemoryStream.MemoryStream();
        EncCryptoStream := EncCryptoStream.CryptoStream(EncMemoryStream, Encryptor, CryptoStreamMode.Write);
        EncStreamWriter := EncStreamWriter.StreamWriter(EncCryptoStream);
        EncStreamWriter.Write(PlainText);
        EncStreamWriter.Close();
        EncCryptoStream.Close();
        EncMemoryStream.Close();
        CryptedText := Convert.ToBase64String(EncMemoryStream.ToArray());
    end;

    [Scope('OnPrem')]
    procedure Decrypt(CryptedText: Text) PlainText: Text
    var
        Decryptor: DotNet ICryptoTransform;
        Convert: DotNet Convert;
        DecMemoryStream: DotNet MemoryStream;
        DecCryptoStream: DotNet CryptoStream;
        DecStreamReader: DotNet StreamReader;
        NullChar: Char;
    begin
        Construct();
        Decryptor := RijndaelProvider.CreateDecryptor();
        DecMemoryStream := DecMemoryStream.MemoryStream(Convert.FromBase64String(CryptedText));
        DecCryptoStream := DecCryptoStream.CryptoStream(DecMemoryStream, Decryptor, CryptoStreamMode.Read);
        DecStreamReader := DecStreamReader.StreamReader(DecCryptoStream);
        PlainText := DelChr(DecStreamReader.ReadToEnd(), '>', NullChar);
        DecStreamReader.Close();
        DecCryptoStream.Close();
        DecMemoryStream.Close();
    end;

    local procedure Construct()
    begin
        if IsNull(RijndaelProvider) then
            InitRijndaelProvider();
    end;

}