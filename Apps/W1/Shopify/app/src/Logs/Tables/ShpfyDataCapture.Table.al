// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Reflection;

table 30114 "Shpfy Data Capture"
{
    Access = Internal;
    Caption = 'Shopify Data Capture';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Linked To Table"; Integer)
        {
            Caption = 'Linked To Table';
            DataClassification = SystemMetadata;
        }
        field(3; "Linked To Id"; Guid)
        {
            Caption = 'Linked To Id';
            DataClassification = SystemMetadata;
        }
        field(4; Data; Blob)
        {
            Caption = 'Data';
            DataClassification = SystemMetadata;
        }
        field(5; "Hash No."; Integer)
        {
            Caption = 'Hash No.';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Indx01; "Linked To Table", "Linked To Id") { }
    }

    internal procedure GetData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields(Data);
        if Rec.Data.HasValue then begin
            Rec.Data.CreateInStream(InStream, TextEncoding::UTF8);
            exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
        end;
    end;

    internal procedure Add(TableNo: Integer; RecSystemId: Guid; RecData: Text)
    var
        DataCapture: Record "Shpfy Data Capture";
        Hash: Codeunit "Shpfy Hash";
        HashNumber: Integer;
        OutStream: OutStream;
    begin
        HashNumber := Hash.CalcHash(RecData);
        DataCapture.SetRange("Linked To Table", TableNo);
        DataCapture.SetRange("Linked To Id", RecSystemId);
        if DataCapture.FindLast() and (DataCapture."Hash No." = HashNumber) then
            exit;
        Clear(DataCapture);
        DataCapture."Linked To Table" := TableNo;
        DataCapture."Linked To Id" := RecSystemId;
        DataCapture."Hash No." := HashNumber;
        DataCapture.Data.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(RecData);
        DataCapture.Insert();
    end;

    internal procedure Add(TableNo: Integer; RecSystemId: Guid; RecData: JsonToken)
    begin
        Add(TableNo, RecSystemId, Format(RecData));
    end;

    internal procedure Add(TableNo: Integer; RecSystemId: Guid; RecData: JsonObject)
    begin
        Add(TableNo, RecSystemId, Format(RecData));
    end;
}
