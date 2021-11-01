// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This table contains references to archived media and blob fields.
/// </summary>

table 602 "Data Archive Media Field"
{
    Access = Public;
    Extensible = true;
    Caption = 'Data Archive Media Field';
    DataClassification = CustomerContent;
    Permissions = tabledata "Data Archive" = rimd,
                  tabledata "Data Archive Table" = rimd,
                  tabledata "Data Archive Media Field" = rimd;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Data Archive Entry No."; Integer)
        {
            Caption = 'Data Archive Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "Data Archive";
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(5; "Field Content"; Media)
        {
            Caption = 'Field Content';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Data Archive Entry No.", "Table No.")
        {
        }
    }

    //    procedure InsertNewMedia(var DataArchiveTable: Record "Data Archive Table"; var InsStr: InStream)
    procedure InsertNewMedia(var InsStr: InStream; RecRef: RecordRef; CurrentDataArchiveEntryNo: Integer)
    begin
        Rec.Init();
        Rec."Data Archive Entry No." := CurrentDataArchiveEntryNo;
        Rec."Table No." := RecRef.Number;
        Rec."Entry No." := 0;
        Rec."Field Content".ImportStream(InsStr, RecRef.Name);
        Rec.Insert();
    end;
}
