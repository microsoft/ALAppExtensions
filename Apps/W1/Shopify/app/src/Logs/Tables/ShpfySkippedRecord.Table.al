namespace Microsoft.Integration.Shopify;

using System.Reflection;
using Microsoft.Utilities;

/// <summary>
/// Table Shpfy Skipped Record (ID 30159).
/// </summary>
table 30159 "Shpfy Skipped Record"
{
    Caption = 'Shpfy Skipped Record';
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Shopify Id"; BigInteger)
        {
            Caption = 'Skipped Record Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Table Name" := GetTableCaption();
            end;
        }
        field(4; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            DataClassification = SystemMetadata;
        }
        field(5; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Description := GetRecDescription();
            end;
        }
        field(6; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
        }
        field(7; "Skipped Reason"; Text[250])
        {
            Caption = 'Skipped Reason';
            DataClassification = SystemMetadata;
        }
        field(8; "Created On"; DateTime)
        {
            Caption = 'Created On';
            DataClassification = SystemMetadata;
        }
        field(9; "Created Time"; Time)
        {
            Caption = 'Created Time';
            DataClassification = SystemMetadata;
        }


    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    local procedure GetTableCaption(): Text[250]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if "Table ID" <> 0 then
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, "Table ID") then
                exit(AllObjWithCaption."Object Caption");
    end;

    local procedure GetRecDescription() Result: Text
    var
        RecRef: RecordRef;
        PKFilter: Text;
        Delimiter: Text;
        Pos: Integer;
    begin
        if RecRef.Get("Record ID") then begin
            RecRef.SetRecFilter();
            PKFilter := RecRef.GetView();
            repeat
                Pos := StrPos(PKFilter, '=FILTER(');
                if Pos <> 0 then begin
                    PKFilter := CopyStr(PKFilter, Pos + 8);
                    Result += Delimiter + CopyStr(PKFilter, 1, StrPos(PKFilter, ')') - 1);
                    Delimiter := ',';
                end;
            until Pos = 0;
        end;
    end;

    /// <summary>
    /// Show related record from Record ID field.
    /// </summary>
    internal procedure ShowPage()
    var
        TableMetadata: Record "Table Metadata";
        PageManagement: Codeunit "Page Management";
        RecordId: RecordID;
    begin
        RecordId := "Record ID";

        if RecordID.TableNo() = 0 then
            exit;
        if not TableMetadata.Get(RecordID.TableNo()) then
            exit;

        if not TableMetadata.DataIsExternal then begin
            PageManagement.PageRun(RecordID);
            exit;
        end;
    end;
}
