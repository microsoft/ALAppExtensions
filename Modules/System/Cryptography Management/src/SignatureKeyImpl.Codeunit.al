// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1473 "Signature Key Impl."
{
    Access = Internal;

    var
        TempBlob: Codeunit "Temp Blob";
        CertInitializeErr: Label 'Unable to initialize certificate!';

    procedure FromXmlString(XmlString: Text)
    begin
        WriteKeyValue(XmlString);
    end;

    procedure FromBase64String(CertBase64Value: Text; Password: Text; IncludePrivateParameters: Boolean)
    var
        X509Certificate2: DotNet X509Certificate2;
    begin
        if not TryInitializeCertificateFromBase64Format(CertBase64Value, Password, X509Certificate2) then
            Error(CertInitializeErr);
        FromXmlString(X509Certificate2.PrivateKey.ToXmlString(IncludePrivateParameters));
    end;

    internal procedure ToXmlString(): Text
    begin
        exit(ReadKeyValue());
    end;

    [TryFunction]
    local procedure TryInitializeCertificateFromBase64Format(CertBase64Value: Text; Password: Text; var X509Certificate2: DotNet X509Certificate2)
    var
        X509KeyStorageFlags: DotNet X509KeyStorageFlags;
        Convert: DotNet Convert;
    begin
        X509Certificate2 := X509Certificate2.X509Certificate2(Convert.FromBase64String(CertBase64Value), Password, X509KeyStorageFlags.Exportable);
    end;

    local procedure WriteKeyValue(KeyValue: Text)
    var
        KeyValueOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(KeyValueOutStream, TextEncoding::UTF8);
        KeyValueOutStream.Write(KeyValue);
    end;

    local procedure ReadKeyValue() KeyValue: Text
    var
        KeyValueInStream: InStream;
    begin
        TempBlob.CreateInStream(KeyValueInStream, TextEncoding::UTF8);
        KeyValueInStream.Read(KeyValue);
    end;
}