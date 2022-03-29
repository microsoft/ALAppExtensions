#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Represents the key of asymmetric algorithm.
/// </summary>
table 1461 "Signature Key"
{
    TableType = Temporary;
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteTag = '19.1';
    ObsoleteReason = 'The xml representation of key is used instead.';

    fields
    {
        field(1; "Key Index"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Signature Algorithm"; Enum SignatureAlgorithm)
        {
            DataClassification = SystemMetadata;
            Description = 'Specifies the asymmetric algorithm which represent saved key.';
        }
        field(3; "Key Value Type"; Enum "Signature Key Value Type")
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'Specifies the format of saved key.';
        }
        field(4; "Key Value Blob"; Blob)
        {
            Caption = 'Key Value';
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'Gets the saved value of key in format which is specified by Key Value Type field.';
        }
    }

    keys
    {
        key(PrimaryKey; "Key Index")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Saves an key value from the key information from an XML string.
    /// </summary>
    /// <param name="XmlString">The XML string containing key information.</param>
    procedure FromXmlString(XmlString: Text)
    begin
        Rec."Key Value Type" := Rec."Key Value Type"::XmlString;
        WriteKeyValue(XmlString);
    end;

    /// <summary>
    /// Gets an XML string containing the key of the saved key value.
    /// </summary>
    /// <returns>An XML string containing the key of the saved key value.</returns>
    procedure ToXmlString(): Text
    begin
        Rec.TestField("Key Value Type", Rec."Key Value Type"::XmlString);
        exit(ReadKeyValue());
    end;

    /// <summary>
    /// Saves an key value from an certificate in Base64 format
    /// </summary>
    /// <param name="CertBase64Value">Represents the certificate value encoded using the Base64 algorithm</param>
    /// <param name="Represents the password of the certificate">Certificate Password</param>
    /// <param name="IncludePrivateParameters">true to include private parameters; otherwise, false.</param>
    [NonDebuggable]
    procedure FromBase64String(CertBase64Value: Text; Password: Text; IncludePrivateParameters: Boolean)
    var
        X509Certificate2: DotNet X509Certificate2;
        CertInitializeErr: Label 'Unable to initialize certificate!';
    begin
        if not TryInitializeCertificateFromBase64Format(CertBase64Value, Password, X509Certificate2) then
            Error(CertInitializeErr);
        FromXmlString(X509Certificate2.PrivateKey.ToXmlString(IncludePrivateParameters));
    end;

    local procedure ReadKeyValue() KeyValue: Text
    var
        KeyValueInStream: InStream;
    begin
        Rec."Key Value Blob".CreateInStream(KeyValueInStream, TextEncoding::UTF8);
        KeyValueInStream.Read(KeyValue);
    end;

    [TryFunction]
    internal procedure TryGetInstance(var DotNetAsymmetricAlgorithm: DotNet AsymmetricAlgorithm)
    var
        ISignatureAlgorithm: Interface SignatureAlgorithm;
    begin
        ISignatureAlgorithm := Rec."Signature Algorithm";
        case Rec."Key Value Type" of
            Rec."Key Value Type"::XmlString:
                ISignatureAlgorithm.FromXmlString(Rec.ToXmlString());
        end;
        ISignatureAlgorithm.GetInstance(DotNetAsymmetricAlgorithm);
    end;

    local procedure WriteKeyValue(KeyValue: Text)
    var
        KeyValueOutStream: OutStream;
    begin
        Rec."Key Value Blob".CreateOutStream(KeyValueOutStream, TextEncoding::UTF8);
        KeyValueOutStream.Write(KeyValue);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryInitializeCertificateFromBase64Format(CertBase64Value: Text; Password: Text; var X509Certificate2: DotNet X509Certificate2)
    var
        X509KeyStorageFlags: DotNet X509KeyStorageFlags;
        Convert: DotNet Convert;
    begin
        X509Certificate2 := X509Certificate2.X509Certificate2(Convert.FromBase64String(CertBase64Value), Password, X509KeyStorageFlags.Exportable);
        if IsNull(X509Certificate2) then
            Error('');
    end;

    internal procedure WriteKeyValue(KeyValueInStream: InStream)
    var
        KeyValueOutStream: OutStream;
    begin
        Rec."Key Value Blob".CreateOutStream(KeyValueOutStream, TextEncoding::UTF8);
        CopyStream(KeyValueOutStream, KeyValueInStream);
    end;
}
#endif