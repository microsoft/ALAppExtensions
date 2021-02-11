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

    internal procedure WriteKeyValue(KeyValueInStream: InStream)
    var
        KeyValueOutStream: OutStream;
    begin
        Rec."Key Value Blob".CreateOutStream(KeyValueOutStream, TextEncoding::UTF8);
        CopyStream(KeyValueOutStream, KeyValueInStream);
    end;
}