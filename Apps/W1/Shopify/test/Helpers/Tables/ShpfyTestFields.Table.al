// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using System.TestLibraries.Utilities;
using System.Utilities;

/// <summary>
/// Table Shpfy Test Fields (ID 135600).
/// </summary>
table 139560 "Shpfy Test Fields"
{
    Caption = 'Shpfy Test Fields';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; BigIntegerField; Integer)
        {
            Caption = 'BigInteger Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(2; BlobField; Blob)
        {
            Caption = 'Blob Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(3; BooleanField; Boolean)
        {
            Caption = 'Boolean Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(4; CodeField; Code[20])
        {
            Caption = 'Code Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(5; TextField; Text[100])
        {
            Caption = 'Text Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(6; DateField; Date)
        {
            Caption = 'Date Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(7; DateTimeField; DateTime)
        {
            Caption = 'DateTime Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(8; DecimalField; Decimal)
        {
            Caption = 'Decimal Field';
            DataClassification = SystemMetadata;
            AutoFormatType = 0;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(9; DurationField; Duration)
        {
            Caption = 'Duration Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(10; GuidField; Guid)
        {
            Caption = 'Guid Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(11; IntegerField; Integer)
        {
            Caption = 'Integer Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(12; OptionField; Option)
        {
            Caption = 'Option Field';
            DataClassification = SystemMetadata;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
        field(13; TimeField; Time)
        {
            Caption = 'Time Field';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Message(ValidateMsg);
            end;
        }
    }
    keys
    {
        key(PK; BigIntegerField)
        {
            Clustered = true;
        }
    }
    var
        ValidateMsg: Label 'Validate Triggger Executed', Locked = true;

    internal procedure CreateNewRecordWithAnyValues() Result: Record "Shpfy Test Fields"
    var
        Any: Codeunit Any;
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        OutStream: OutStream;
    begin
        Result.Init();
        Result.BigIntegerField := Any.IntegerInRange(100, 15654);
        RecordRef.GetTable(Result);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(Any.AlphanumericText(25));
        TempBlob.ToRecordRef(RecordRef, Result.FieldNo(BlobField));
        RecordRef.SetTable(Result);
        Result.BooleanField := true;
        Result.CodeField := CopyStr(Any.AlphanumericText(MaxStrLen(Result.CodeField)), 1, MaxStrLen(Result.CodeField));
        Result.TextField := CopyStr(Any.AlphanumericText(MaxStrLen(Result.TextField)), 1, MaxStrLen(Result.TextField));
        Result.DateField := Any.DateInRange(100);
        Result.DateTimeField := CurrentDateTime();
        Result.DecimalField := Any.DecimalInRange(9999, 3);
        Result.DurationField := 65466;
        Result.GuidField := CreateGuid();
        Result.IntegerField := Any.IntegerInRange(100, 6546);
        Result.OptionField := Any.IntegerInRange(0, 9);
        Result.TimeField := Time();
        Result.Insert();
    end;

    internal procedure GetBlobData(): Text
    var
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        InStream: InStream;
        Data: Text;
    begin
        RecordRef.GetTable(Rec);
        FieldRef := RecordRef.Field(Rec.FieldNo(BlobField));
        TempBlob.FromFieldRef(FieldRef);
        TempBlob.CreateInStream(InStream);
        InStream.Read(Data);
        exit(Data);
    end;
}