tableextension 31000 "VAT Posting Setup CZZ" extends "VAT Posting Setup"
{
    fields
    {
        field(31010; "Sales Adv. Letter Account CZZ"; Code[20])
        {
            Caption = 'Sales Advance Letter Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Sales Adv. Letter Account CZZ");
            end;
        }
        field(31013; "Sales Adv. Letter VAT Acc. CZZ"; Code[20])
        {
            Caption = 'Sales Advance Letter VAT Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Sales Adv. Letter VAT Acc. CZZ");
            end;
        }
        field(31020; "Purch. Adv. Letter Account CZZ"; Code[20])
        {
            Caption = 'Purchase Advance Letter Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Purch. Adv. Letter Account CZZ");
            end;
        }
        field(31023; "Purch. Adv.Letter VAT Acc. CZZ"; Code[20])
        {
            Caption = 'Purchase Advance Letter VAT Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Purch. Adv.Letter VAT Acc. CZZ");
            end;
        }
    }
}
