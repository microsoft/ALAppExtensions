table 4701 "VAT Group Calculation"
{
    DataCaptionFields = "VAT Report No.", "Box No.";
    Caption = 'VAT Group Member Calculation';

    fields
    {
        field(1; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Editable = false;
            Caption = 'ID';
        }
        field(2; "VAT Group Submission No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "VAT Group Submission Header"."No." where(ID = field("VAT Group Submission ID"));
            Caption = 'VAT Group Submission';

        }
        field(3; "VAT Group Submission ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Submission ID';
            Editable = false;
            TableRelation = "VAT Group Submission Header".ID;
        }
        field(4; "VAT Report No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "VAT Report Header"."No." where("VAT Report Config. Code" = const("VAT Return"));
            Caption = 'VAT Return No.';
        }
        field(5; "Group Member Name"; Text[250])
        {
            Caption = 'Group Member Name';
            DataClassification = CustomerContent;
        }
        field(6; "Box No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Box No.';
        }
        field(7; Amount; Decimal)
        {
            AutoFormatType = 1;
            DataClassification = CustomerContent;
            Caption = 'Amount';
            Editable = false;
        }
        field(8; "Submitted On"; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Submitted On';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    var
        Total: Decimal;

    internal procedure GetTotal(): Decimal
    begin
        if Rec.FindSet() then
            repeat
                Total += Rec.Amount;
            until Rec.Next() = 0;
        exit(Total);
    end;
}