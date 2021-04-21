table 4702 "VAT Group Submission Header"
{
    Caption = 'VAT Group Submission Header';
    LookupPageId = "VAT Group Submission";
    DataCaptionFields = "No.", "Group Member Name";

    fields
    {
        field(1; "ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }

        field(5; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';

        }
        field(6; "VAT Group Return No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'VAT Group Return No.';
            TableRelation = "VAT Report Header"."No.";

        }
        field(10; "Group Member ID"; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Group Member ID';
            TableRelation = "VAT Group Approved Member";
            ValidateTableRelation = true;
        }
        field(15; "Group Member Name"; Text[250])
        {
            Caption = 'Group Member Name';
            FieldClass = FlowField;
            CalcFormula = lookup("VAT Group Approved Member"."Group Member Name" where(ID = field("Group Member ID")));
        }
        field(20; "Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Start Date';
        }
        field(25; "End Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'End Date';
        }
        field(30; "Submitted On"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Submitted On';
        }
        field(35; Company; Text[30])
        {
            DataClassification = OrganizationIdentifiableInformation;
            Caption = 'Company';
        }
    }

    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
        key("Submitted On"; "Submitted On")
        {
        }
        key("No."; "No.")
        {
        }
        key("VAT Group Return No."; "VAT Group Return No.")
        {
        }
        key(Dates; "Start Date", "End Date")
        {
        }
    }

    trigger OnInsert()
    begin
        Rec.ID := CreateGuid();
        Rec."Submitted On" := CurrentDateTime();
        Rec.TestField("Group Member ID");
    end;

    trigger OnDelete()
    var
        VATGroupSubmissionLine: Record "VAT Group Submission Line";
    begin
        VATGroupSubmissionLine.SetRange("VAT Group Submission ID", Rec.ID);
        if not VATGroupSubmissionLine.IsEmpty() then
            VATGroupSubmissionLine.DeleteAll();
    end;

    internal procedure SetFiltersForLastSubmissionInAPeriod(StartDate: Date; EndDate: Date; SetVATGroupReturnNoFilter: Boolean; VATGroupReturnNo: code[20])
    begin
        Rec.SetCurrentKey("Submitted On");
        Rec.SetRange("Start Date", StartDate);
        Rec.SetRange("End Date", EndDate);
        if SetVATGroupReturnNoFilter then
            Rec.SetRange("VAT Group Return No.", VATGroupReturnNo);
    end;
}
