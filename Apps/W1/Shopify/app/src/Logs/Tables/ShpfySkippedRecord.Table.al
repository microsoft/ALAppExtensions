namespace Microsoft.Integration.Shopify;

using System.Reflection;
using Microsoft.Utilities;

/// <summary>
/// Table Shpfy Skipped Record (ID 30159).
/// </summary>
table 30159 "Shpfy Skipped Record"
{
    Caption = 'Shopify Skipped Record';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            ToolTip = 'Specifies the number of the entry, as assigned from the specific number series when the entry was created.';
        }
        field(2; "Shopify Id"; BigInteger)
        {
            Caption = 'Shopify Id';
            ToolTip = 'Specifies the Shopify Id of the skipped record.';
        }
        field(3; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            ToolTip = 'Specifies the Table Id of the skipped record.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Table Name" := GetTableCaption();
            end;
        }
        field(4; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            ToolTip = 'Specifies the table name of the skipped record.';
            DataClassification = SystemMetadata;
        }
        field(5; "Record ID"; RecordID)
        {
            Caption = 'Record Id';
            ToolTip = 'Specifies the record Id of the skipped record.';

            trigger OnValidate()
            begin
                Description := GetRecDescription();
            end;
        }
        field(6; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the skipped record.';
        }
        field(7; "Skipped Reason"; Text[250])
        {
            Caption = 'Skipped Reason';
            ToolTip = 'Specifies the reason why the record was skipped.';
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        DeleteLogEntriesLbl: Label 'Are you sure that you want to delete Shopify log entries?';

    local procedure GetTableCaption(): Text[250]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if "Table ID" <> 0 then
            if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, "Table ID") then
                exit(AllObjWithCaption."Object Caption");
    end;

    local procedure GetRecDescription() Result: Text[250]
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
        PageManagement: Codeunit "Page Management";
    begin
        if "Record ID".TableNo() <> 0 then
            PageManagement.PageRun("Record ID");
    end;

    /// <summary> 
    /// Delete Entries.
    /// </summary>
    /// <param name="DaysOld">Parameter of type Integer.</param>
    internal procedure DeleteEntries(DaysOld: Integer);
    begin
        if not Confirm(DeleteLogEntriesLbl) then
            exit;

        if DaysOld > 0 then begin
            Rec.SetFilter(SystemCreatedAt, '<=%1', CreateDateTime(Today - DaysOld, Time));
            if not Rec.IsEmpty() then
                Rec.DeleteAll(false);
            Rec.SetRange(SystemCreatedAt);
        end else
            if not Rec.IsEmpty() then
                Rec.DeleteAll(false);
    end;
}