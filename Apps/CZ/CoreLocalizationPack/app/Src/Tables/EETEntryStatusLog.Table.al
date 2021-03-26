table 31129 "EET Entry Status Log CZL"
{
    Caption = 'EET Entry Status Log';
    DrillDownPageID = "EET Entry Status Log CZL";
    LookupPageID = "EET Entry Status Log CZL";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "EET Entry No."; Integer)
        {
            Caption = 'EET Entry No.';
            TableRelation = "EET Entry CZL";
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                ShowErrorMessages();
            end;
        }
        field(20; Status; Enum "EET Status CZL")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(25; "Changed At"; DateTime)
        {
            Caption = 'Changed At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "EET Entry No.")
        {
        }
    }

    trigger OnInsert()
    begin
        LockTable();
        "Entry No." := GetLastEntryNo() + 1;
    end;

    trigger OnDelete()
    begin
        ClearErrorMessages();
    end;

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure SetErrorMessage(var TempErrorMessage: Record "Error Message" temporary)
    var
        ErrorMessage: Record "Error Message";
    begin
        if TempErrorMessage.FindSet() then
            repeat
                ErrorMessage := TempErrorMessage;
                ErrorMessage.ID := 0;
                ErrorMessage.Validate("Record ID", RecordId());
                ErrorMessage.Validate("Context Record ID", RecordId());
                ErrorMessage.Insert(true);
            until TempErrorMessage.Next() = 0;
    end;

    procedure ShowErrorMessages()
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(Rec);
        ErrorMessage.ShowErrorMessages(false);
    end;

    procedure ClearErrorMessages()
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetRange("Context Record ID", RecordId);
        ErrorMessage.DeleteAll();
    end;
}

