// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1279 "Cryptography Management Impl."
{
    Access = Internal;

    var
        CryptographyManagement: Codeunit "Cryptography Management";
        RijndaelProvider: DotNet "Cryptography.RijndaelManaged";
        CryptoStreamMode: DotNet "Cryptography.CryptoStreamMode";
        ExportEncryptionKeyFileDialogTxt: Label 'Choose the location where you want to save the encryption key.';
        ExportEncryptionKeyConfirmQst: Label 'The encryption key file must be protected by a password and stored in a safe location.\\Do you want to save the encryption key?';
        FileImportCaptionMsg: Label 'Select a key file to import.';
        DefaultEncryptionKeyFileNameTxt: Label 'EncryptionKey.key';
        KeyFileFilterTxt: Label 'Key File(*.key)|*.key';
        ReencryptConfirmQst: Label 'The encryption is already enabled. Continuing will decrypt the encrypted data and encrypt it again with the new key.\\Do you want to continue?';
        EncryptionKeyImportedMsg: Label 'The key was imported successfully.';
        EnableEncryptionConfirmQst: Label 'Enabling encryption will generate an encryption key on the server.\It is recommended that you save a copy of the encryption key in a safe location.\\Do you want to continue?';
        DisableEncryptionConfirmQst: Label 'Disabling encryption will decrypt the encrypted data and store it in the database in an unsecure way.\\Do you want to continue?';
        EncryptionCheckFailErr: Label 'Encryption is either not enabled or the encryption key cannot be found.';
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';

    procedure Encrypt(InputString: Text): Text
    begin
        AssertEncryptionPossible();
        if InputString = '' then
            exit('');
        exit(SYSTEM.Encrypt(InputString));
    end;

    procedure Decrypt(EncryptedString: Text): Text
    begin
        AssertEncryptionPossible();
        if EncryptedString = '' then
            exit('');
        exit(SYSTEM.Decrypt(EncryptedString))
    end;

    procedure ExportKey()
    var
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        TempBlob: Codeunit "Temp Blob";
        Password: Text;
    begin
        AssertEncryptionPossible();
        if Confirm(ExportEncryptionKeyConfirmQst, true) then begin
            Password := PasswordDialogManagement.OpenPasswordDialog();
            if Password = '' then
                exit;
        end;

        GetEncryptionKeyAsStream(TempBlob, Password);
        DownloadEncryptionFileFromStream(TempBlob);
    end;

    procedure ExportKeyAsStream(var TempBlob: Codeunit "Temp Blob"; Password: Text)
    begin
        AssertEncryptionPossible();
        GetEncryptionKeyAsStream(TempBlob, Password);
    end;

    local procedure GetEncryptionKeyAsStream(var TempBlob: Codeunit "Temp Blob"; Password: Text)
    var
        FileObj: File;
        FileInStream: InStream;
        TempOutStream: OutStream;
        ServerFilename: Text;
    begin
        ServerFilename := ExportEncryptionKey(Password);
        FileObj.Open(ServerFilename);

        TempBlob.CreateOutStream(TempOutStream);
        FileObj.CreateInStream(FileInStream);
        CopyStream(TempOutStream, FileInStream);

        FileObj.Close();
        FILE.Erase(ServerFilename);
    end;

    local procedure DownloadEncryptionFileFromStream(TempBlob: Codeunit "Temp Blob")
    var
        InStreamObj: InStream;
        FileName: Text;
    begin
        TempBlob.CreateInStream(InStreamObj);
        FileName := DefaultEncryptionKeyFileNameTxt;

        if not DownloadFromStream(InStreamObj, ExportEncryptionKeyFileDialogTxt, '', KeyFileFilterTxt, FileName) then
            if GetLastErrorText() <> '' then
                Error('%1', GetLastErrorText());
    end;

    procedure ImportKey()
    var
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        TempKeyFilePath: Text;
        Password: Text;
    begin
        TempKeyFilePath := UploadFile();

        // TempKeyFilePath is '' if the user cancelled the Upload file dialog.
        if TempKeyFilePath = '' then
            exit;

        Password := PasswordDialogManagement.OpenPasswordDialog(true, true);
        if Password <> '' then
            ImportKeyAndConfirm(TempKeyFilePath, Password);

        FILE.Erase(TempKeyFilePath);
    end;

    procedure ChangeKey()
    var
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        TempKeyFilePath: Text;
        Password: Text;
    begin
        TempKeyFilePath := UploadFile();

        // TempKeyFilePath is '' if the user cancelled the Upload file dialog.
        if TempKeyFilePath = '' then
            exit;

        Password := PasswordDialogManagement.OpenPasswordDialog(true, true);
        if Password <> '' then begin
            if IsEncryptionEnabled() then begin
                if not Confirm(ReencryptConfirmQst, true) then
                    exit;
                DisableEncryption(true);
            end;

            ImportKeyAndConfirm(TempKeyFilePath, Password);
        end;

        FILE.Erase(TempKeyFilePath);
    end;

    procedure EnableEncryption(Silent: Boolean)
    var
        PasswordDialogManagement: Codeunit "Password Dialog Management";
        TempBlob: Codeunit "Temp Blob";
        ShouldExportKey: Boolean;
        Password: Text;
    begin
        if Silent then begin
            CreateEncryptionKeys();
            exit;
        end;

        if Confirm(EnableEncryptionConfirmQst, true) then begin
            if Confirm(ExportEncryptionKeyConfirmQst, true) then begin
                Password := PasswordDialogManagement.OpenPasswordDialog();
                if Password <> '' then
                    ShouldExportKey := true;
            end;

            CreateEncryptionKeys();
            if ShouldExportKey then begin
                GetEncryptionKeyAsStream(TempBlob, Password);
                DownloadEncryptionFileFromStream(TempBlob);
            end;
        end;
    end;

    local procedure CreateEncryptionKeys()
    begin
        // no user interaction on webservices
        CryptographyManagement.OnBeforeEnableEncryptionOnPrem();
        CreateEncryptionKey();
    end;

    procedure DisableEncryption(Silent: Boolean)
    begin
        // Silent is FALSE when we want the user to take action on if the encryption should be disabled or not. In cases like import key
        // Silent should be TRUE as disabling encryption is a must before importing a new key, else data will be lost.
        if not Silent then
            if not Confirm(DisableEncryptionConfirmQst, true) then
                exit;

        CryptographyManagement.OnBeforeDisableEncryptionOnPrem();
        DeleteEncryptionKey();
    end;

    procedure IsEncryptionEnabled(): Boolean
    begin
        exit(EncryptionEnabled());
    end;

    procedure IsEncryptionPossible(): Boolean
    begin
        // ENCRYPTIONKEYEXISTS checks if the correct key is present, which only works if encryption is enabled
        exit(EncryptionKeyExists());
    end;

    local procedure AssertEncryptionPossible()
    begin
        if IsEncryptionEnabled() then
            if IsEncryptionPossible() then
                exit;

        Error(EncryptionCheckFailErr);
    end;

    local procedure UploadFile(): Text
    var
        ServerFileName: Text;
    begin
        Upload(FileImportCaptionMsg, '', KeyFileFilterTxt, DefaultEncryptionKeyFileNameTxt, ServerFileName);
        exit(ServerFileName);
    end;

    local procedure ImportKeyAndConfirm(KeyFilePath: Text; Password: Text)
    begin
        ImportEncryptionKey(KeyFilePath, Password);
        Message(EncryptionKeyImportedMsg);
    end;

    procedure GetEncryptionIsNotActivatedQst(): Text
    begin
        exit(EncryptionIsNotActivatedQst);
    end;

    procedure GenerateHash(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    var
        HashBytes: DotNet Array;
    begin
        if not GenerateHashBytes(HashBytes, InputString, HashAlgorithmType) then
            exit('');
        exit(ConvertByteHashToString(HashBytes));
    end;

    procedure GenerateHashAsBase64String(InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    var
        HashBytes: DotNet Array;
    begin
        if not GenerateHashBytes(HashBytes, InputString, HashAlgorithmType) then
            exit('');
        exit(ConvertByteHashToBase64String(HashBytes));
    end;

    local procedure GenerateHashBytes(var HashBytes: DotNet Array; InputString: Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Boolean
    var
        Encoding: DotNet Encoding;
    begin
        if InputString = '' then
            exit(false);
        if not TryGenerateHash(HashBytes, Encoding.UTF8().GetBytes(InputString), Format(HashAlgorithmType)) then
            Error(GetLastErrorText());
        exit(true);
    end;

    [TryFunction]
    local procedure TryGenerateHash(var HashBytes: DotNet Array; Bytes: DotNet Array; Algorithm: Text)
    var
        HashAlgorithm: DotNet HashAlgorithm;
    begin
        HashAlgorithm := HashAlgorithm.Create(Algorithm);
        HashBytes := HashAlgorithm.ComputeHash(Bytes);
        HashAlgorithm.Dispose();
    end;

    procedure GenerateHash(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    var
        HashBytes: DotNet Array;
        Encoding: DotNet Encoding;
    begin
        if not GenerateKeyedHashBytes(HashBytes, InputString, Encoding.UTF8().GetBytes(Key), HashAlgorithmType) then
            exit('');
        exit(ConvertByteHashToString(HashBytes));
    end;

    procedure GenerateHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    var
        HashBytes: DotNet Array;
        Encoding: DotNet Encoding;
    begin
        if not GenerateKeyedHashBytes(HashBytes, InputString, Encoding.UTF8().GetBytes(Key), HashAlgorithmType) then
            exit('');
        exit(ConvertByteHashToBase64String(HashBytes));
    end;

    procedure GenerateBase64KeyedHashAsBase64String(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    var
        HashBytes: DotNet Array;
        Convert: DotNet Convert;
    begin
        if not GenerateKeyedHashBytes(HashBytes, InputString, Convert.FromBase64String(Key), HashAlgorithmType) then
            exit('');
        exit(ConvertByteHashToBase64String(HashBytes));
    end;

    local procedure GenerateKeyedHashBytes(var HashBytes: DotNet Array; InputString: Text; "Key": DotNet Array; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Boolean
    begin
        if (InputString = '') or (Key.Length() = 0) then
            exit(false);
        if not TryGenerateKeyedHash(HashBytes, InputString, Key, Format(HashAlgorithmType)) then
            Error(GetLastErrorText());
        exit(true);
    end;

    [TryFunction]
    local procedure TryGenerateKeyedHash(var HashBytes: DotNet Array; InputString: Text; "Key": DotNet Array; Algorithm: Text)
    var
        KeyedHashAlgorithm: DotNet KeyedHashAlgorithm;
        Encoding: DotNet Encoding;
    begin
        KeyedHashAlgorithm := KeyedHashAlgorithm.Create(Algorithm);
        KeyedHashAlgorithm.Key(Key);
        HashBytes := KeyedHashAlgorithm.ComputeHash(Encoding.UTF8().GetBytes(InputString));
        KeyedHashAlgorithm.Dispose();
    end;

    local procedure ConvertByteHashToString(HashBytes: DotNet Array): Text
    var
        Byte: DotNet Byte;
        StringBuilder: DotNet StringBuilder;
        I: Integer;
    begin
        StringBuilder := StringBuilder.StringBuilder();
        for I := 0 to HashBytes.Length() - 1 do begin
            Byte := HashBytes.GetValue(I);
            StringBuilder.Append(Byte.ToString('X2'));
        end;
        exit(StringBuilder.ToString());
    end;

    local procedure ConvertByteHashToBase64String(HashBytes: DotNet Array): Text
    var
        Convert: DotNet Convert;
    begin
        exit(Convert.ToBase64String(HashBytes));
    end;

    procedure GenerateHash(InStr: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    var
        MemoryStream: DotNet MemoryStream;
        HashBytes: DotNet Array;
    begin
        if InStr.EOS() then
            exit('');
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStr);
        if not TryGenerateHash(HashBytes, MemoryStream.ToArray(), Format(HashAlgorithmType)) then
            Error(GetLastErrorText());
        exit(ConvertByteHashToString(HashBytes));
    end;

    procedure GenerateBase64KeyedHash(InputString: Text; "Key": Text; HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512): Text
    var
        HashBytes: DotNet Array;
        Convert: DotNet Convert;
    begin
        if not GenerateKeyedHashBytes(HashBytes, InputString, Convert.FromBase64String(Key), HashAlgorithmType) then
            exit('');
        exit(ConvertByteHashToString(HashBytes));
    end;

    procedure SignData(InputString: Text; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    var
        TempBlob: Codeunit "Temp Blob";
        DataOutStream: OutStream;
        DataInStream: InStream;
    begin
        if InputString = '' then
            exit;
        TempBlob.CreateOutStream(DataOutStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DataInStream, TextEncoding::UTF8);
        DataOutStream.WriteText(InputString);
        SignData(DataInStream, XmlString, HashAlgorithm, SignatureOutStream);
    end;

    procedure SignData(InputString: Text; SignatureKey: Codeunit "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        SignData(InputString, SignatureKey.ToXmlString(), HashAlgorithm, SignatureOutStream);
    end;

#if not CLEAN19
#pragma warning disable AL0432
    procedure SignData(InputString: Text; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    var
        TempBlob: Codeunit "Temp Blob";
        DataOutStream: OutStream;
        DataInStream: InStream;
    begin
        if InputString = '' then
            exit;
        TempBlob.CreateOutStream(DataOutStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DataInStream, TextEncoding::UTF8);
        DataOutStream.WriteText(InputString);
        SignData(DataInStream, SignatureKey, HashAlgorithm, SignatureOutStream);
    end;
#pragma warning restore
#endif

#if not CLEAN18
    procedure SignData(InputString: Text; KeyStream: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: OutStream)
    var
        TempBlob: Codeunit "Temp Blob";
        DataOutStream: OutStream;
        DataInStream: InStream;
    begin
        if InputString = '' then
            exit;
        TempBlob.CreateOutStream(DataOutStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DataInStream, TextEncoding::UTF8);
        DataOutStream.WriteText(InputString);
        SignData(DataInStream, KeyStream, HashAlgorithmType, SignatureStream);
    end;
#endif

    procedure SignData(DataInStream: InStream; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    var
        ISignatureAlgorithm: Interface SignatureAlgorithm;
    begin
        if DataInStream.EOS() then
            exit;
        ISignatureAlgorithm := Enum::SignatureAlgorithm::RSA;
        ISignatureAlgorithm.FromXmlString(XmlString);
        ISignatureAlgorithm.SignData(DataInStream, HashAlgorithm, SignatureOutStream);
    end;

    procedure SignData(DataInStream: InStream; SignatureKey: Codeunit "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    begin
        SignData(DataInStream, SignatureKey.ToXmlString(), HashAlgorithm, SignatureOutStream);
    end;

#if not CLEAN19
#pragma warning disable AL0432
    procedure SignData(DataInStream: InStream; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureOutStream: OutStream)
    var
        ISignatureAlgorithm: Interface SignatureAlgorithm;
    begin
        if DataInStream.EOS() then
            exit;
        ISignatureAlgorithm := SignatureKey."Signature Algorithm";
        if SignatureKey."Key Value Type" = SignatureKey."Key Value Type"::XmlString then
            ISignatureAlgorithm.FromXmlString(SignatureKey.ToXmlString());
        ISignatureAlgorithm.SignData(DataInStream, HashAlgorithm, SignatureOutStream);
    end;
#pragma warning restore
#endif

#if not CLEAN18
#pragma warning disable AL0432
    procedure SignData(DataStream: InStream; KeyStream: InStream; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: OutStream)
    var
        SignatureKey: Record "Signature Key";
    begin
        if DataStream.EOS() then
            exit;
        SignatureKey."Signature Algorithm" := SignatureKey."Signature Algorithm"::RSA;
        SignatureKey."Key Value Type" := SignatureKey."Key Value Type"::XmlString;
        SignatureKey.WriteKeyValue(KeyStream);
        SignData(DataStream, SignatureKey, "Hash Algorithm".FromInteger(HashAlgorithmType), SignatureStream);
    end;
#pragma warning restore
#endif

    procedure VerifyData(InputString: Text; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        DataOutStream: OutStream;
        DataInStream: InStream;
    begin
        if InputString = '' then
            exit(false);
        TempBlob.CreateOutStream(DataOutStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DataInStream, TextEncoding::UTF8);
        DataOutStream.WriteText(InputString);
        exit(VerifyData(DataInStream, XmlString, HashAlgorithm, SignatureInStream));
    end;

#if not CLEAN19
#pragma warning disable AL0432
    procedure VerifyData(InputString: Text; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        DataOutStream: OutStream;
        DataInStream: InStream;
    begin
        if InputString = '' then
            exit(false);
        TempBlob.CreateOutStream(DataOutStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DataInStream, TextEncoding::UTF8);
        DataOutStream.WriteText(InputString);
        exit(VerifyData(DataInStream, SignatureKey, HashAlgorithm, SignatureInStream));
    end;
#pragma warning restore
#endif

#if not CLEAN18
    procedure VerifyData(InputString: Text; "Key": Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: InStream): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        DataOutStream: OutStream;
        DataInStream: InStream;
    begin
        if InputString = '' then
            exit(false);
        TempBlob.CreateOutStream(DataOutStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DataInStream, TextEncoding::UTF8);
        DataOutStream.WriteText(InputString);
        exit(VerifyData(DataInStream, "Key", HashAlgorithmType, SignatureStream));
    end;
#endif

    procedure VerifyData(DataInStream: InStream; XmlString: Text; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    var
        ISignatureAlgorithm: Interface SignatureAlgorithm;
    begin
        if DataInStream.EOS() then
            exit(false);
        ISignatureAlgorithm := Enum::SignatureAlgorithm::RSA;
        ISignatureAlgorithm.FromXmlString(XmlString);
        exit(ISignatureAlgorithm.VerifyData(DataInStream, HashAlgorithm, SignatureInStream));
    end;

#if not CLEAN19
#pragma warning disable AL0432
    procedure VerifyData(DataInStream: InStream; var SignatureKey: Record "Signature Key"; HashAlgorithm: Enum "Hash Algorithm"; SignatureInStream: InStream): Boolean
    var
        ISignatureAlgorithm: Interface SignatureAlgorithm;
    begin
        if DataInStream.EOS() then
            exit(false);
        ISignatureAlgorithm := SignatureKey."Signature Algorithm";
        if SignatureKey."Key Value Type" = SignatureKey."Key Value Type"::XmlString then
            ISignatureAlgorithm.FromXmlString(SignatureKey.ToXmlString());
        exit(ISignatureAlgorithm.VerifyData(DataInStream, HashAlgorithm, SignatureInStream));
    end;
#pragma warning restore
#endif

#if not CLEAN18
#pragma warning disable AL0432
    procedure VerifyData(DataStream: InStream; "Key": Text; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512; SignatureStream: InStream): Boolean
    var
        SignatureKey: Record "Signature Key";
    begin
        if DataStream.EOS() then
            exit(false);
        SignatureKey."Signature Algorithm" := SignatureKey."Signature Algorithm"::RSA;
        SignatureKey."Key Value Type" := SignatureKey."Key Value Type"::XmlString;
        SignatureKey.FromXmlString("Key");
        exit(VerifyData(DataStream, SignatureKey, "Hash Algorithm".FromInteger(HashAlgorithmType), SignatureStream));
    end;
#pragma warning restore
#endif

    procedure InitRijndaelProvider()
    begin
        RijndaelProvider := RijndaelProvider.RijndaelManaged();
        RijndaelProvider.GenerateKey();
        RijndaelProvider.GenerateIV();
    end;

    procedure InitRijndaelProvider(EncryptionKey: Text)
    var
        Encoding: DotNet Encoding;
    begin
        InitRijndaelProvider();
        RijndaelProvider."Key" := Encoding.Default().GetBytes(EncryptionKey);
    end;

    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer)
    begin
        InitRijndaelProvider(EncryptionKey);
        SetBlockSize(BlockSize);
    end;

    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text)
    begin
        InitRijndaelProvider(EncryptionKey, BlockSize);
        SetCipherMode(CipherMode);
    end;

    procedure InitRijndaelProvider(EncryptionKey: Text; BlockSize: Integer; CipherMode: Text; PaddingMode: Text)
    begin
        InitRijndaelProvider(EncryptionKey, BlockSize, CipherMode);
        SetPaddingMode(PaddingMode);
    end;

    procedure SetBlockSize(BlockSize: Integer)
    begin
        Construct();
        RijndaelProvider.BlockSize := BlockSize;
    end;

    procedure SetCipherMode(CipherMode: Text)
    var
        CryptographyCipherMode: DotNet "Cryptography.CipherMode";
    begin
        Construct();
        CryptographyCipherMode := RijndaelProvider.Mode();
        RijndaelProvider.Mode := CryptographyCipherMode.Parse(CryptographyCipherMode.GetType(), CipherMode);
    end;

    procedure SetPaddingMode(PaddingMode: Text)
    var
        CryptographyPaddingMode: DotNet "Cryptography.PaddingMode";
    begin
        Construct();
        CryptographyPaddingMode := RijndaelProvider.Padding();
        RijndaelProvider.Padding := CryptographyPaddingMode.Parse(CryptographyPaddingMode.GetType(), PaddingMode);
    end;

    procedure SetEncryptionData(KeyAsBase64: Text; VectorAsBase64: Text)
    var
        Convert: DotNet Convert;
    begin
        Construct();
        RijndaelProvider."Key"(Convert.FromBase64String(KeyAsBase64));
        RijndaelProvider.IV(Convert.FromBase64String(VectorAsBase64));
    end;

    procedure IsValidKeySize(KeySize: Integer): Boolean
    begin
        Construct();
        exit(RijndaelProvider.ValidKeySize(KeySize))
    end;

    procedure GetLegalKeySizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    var
        KeySizes: DotNet "Cryptography.KeySizes";
    begin
        Construct();
        KeySizes := RijndaelProvider.LegalKeySizes().GetValue(0);
        MinSize := KeySizes.MinSize();
        MaxSize := KeySizes.MaxSize();
        SkipSize := KeySizes.SkipSize();
    end;

    procedure GetLegalBlockSizeValues(var MinSize: Integer; var MaxSize: Integer; var SkipSize: Integer)
    var
        KeySizes: DotNet "Cryptography.KeySizes";
    begin
        Construct();
        KeySizes := RijndaelProvider.LegalBlockSizes().GetValue(0);
        MinSize := KeySizes.MinSize();
        MaxSize := KeySizes.MaxSize();
        SkipSize := KeySizes.SkipSize();
    end;

    procedure GetEncryptionData(var KeyAsBase64: Text; var VectorAsBase64: Text)
    var
        Convert: DotNet Convert;
    begin
        Construct();
        KeyAsBase64 := Convert.ToBase64String(RijndaelProvider."Key"());
        VectorAsBase64 := Convert.ToBase64String(RijndaelProvider.IV());
    end;

    procedure EncryptRijndael(PlainText: Text) EncryptedText: Text
    var
        Encryptor: DotNet "Cryptography.ICryptoTransform";
        Convert: DotNet Convert;
        EncMemoryStream: DotNet MemoryStream;
        EncCryptoStream: DotNet "Cryptography.CryptoStream";
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
        EncryptedText := Convert.ToBase64String(EncMemoryStream.ToArray());
    end;

    procedure DecryptRijndael(EncryptedText: Text) PlainText: Text
    var
        Decryptor: DotNet "Cryptography.ICryptoTransform";
        Convert: DotNet Convert;
        DecMemoryStream: DotNet MemoryStream;
        DecCryptoStream: DotNet "Cryptography.CryptoStream";
        DecStreamReader: DotNet StreamReader;
        NullChar: Char;
    begin
        Construct();
        Decryptor := RijndaelProvider.CreateDecryptor();
        DecMemoryStream := DecMemoryStream.MemoryStream(Convert.FromBase64String(EncryptedText));
        DecCryptoStream := DecCryptoStream.CryptoStream(DecMemoryStream, Decryptor, CryptoStreamMode.Read);
        DecStreamReader := DecStreamReader.StreamReader(DecCryptoStream);
#pragma warning disable AA0205
        PlainText := DelChr(DecStreamReader.ReadToEnd(), '>', NullChar);
#pragma warning restore
        DecStreamReader.Close();
        DecCryptoStream.Close();
        DecMemoryStream.Close();
    end;

    local procedure Construct()
    begin
        if IsNull(RijndaelProvider) then
            InitRijndaelProvider();
    end;

    procedure HashRfc2898DeriveBytes(InputString: Text; Salt: Text; NoOfBytes: Integer; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text;
    var
        ByteArray: DotNet Array;
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        Rfc2898DeriveBytes: DotNet Rfc2898DeriveBytes;
    begin
        if Salt = '' then
            exit;

        //Implement password-based key derivation functionality, PBKDF2, by using a pseudo-random number generator based on HMACSHA1.
        Rfc2898DeriveBytes := Rfc2898DeriveBytes.Rfc2898DeriveBytes(InputString, Encoding.ASCII.GetBytes(Salt));

        //Return a Base64 encoded string of the hash of the first X bytes (X = NoOfBytes) returned from the generator.
        if not TryGenerateHash(ByteArray, Rfc2898DeriveBytes.GetBytes(NoOfBytes), Format(HashAlgorithmType)) then
            Error(GetLastErrorText());

        exit(Convert.ToBase64String(ByteArray));
    end;
}
