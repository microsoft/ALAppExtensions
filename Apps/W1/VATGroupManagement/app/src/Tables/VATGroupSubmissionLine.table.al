table 4703 "VAT Group Submission Line"
{
    Caption = 'VAT Group Submission Line';

    fields
    {
        field(1; "VAT Group Submission ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Submission ID';
            Editable = false;
            TableRelation = "VAT Group Submission Header".ID;
        }
        field(5; "VAT Group Submission No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'VAT Group Submission No.';
            TableRelation = "VAT Group Submission Header"."No.";
        }
        field(7; "ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            Editable = false;
        }
        field(10; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Caption = 'Line No.';
            Editable = false;
        }
        field(15; "Row No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Row No.';
        }
        field(20; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(25; "Box No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Box No.';
        }
        field(30; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Amount';
        }
    }

    keys
    {
        key(PK; "VAT Group Submission ID", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        TestField("VAT Group Submission ID");
        Rec.ID := CreateGuid();
    end;
}