// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1279 "Cryptography Management Impl."
{
    Access = Internal;

    var
        CryptographyManagement: Codeunit "Cryptography Management";
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
        ExportKey: Boolean;
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
                    ExportKey := true;
            end;

            CreateEncryptionKeys();
            if ExportKey then begin
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
}

