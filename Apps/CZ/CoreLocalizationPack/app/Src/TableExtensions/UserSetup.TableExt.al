tableextension 11717 "User Setup CZL" extends "User Setup"
{
    fields
    {
        field(11778; "Allow VAT Posting From CZL"; Date)
        {
            Caption = 'Allow VAT Posting From';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
            begin
                GLSetup.Get();
                GLSetup.TestField("Use VAT Date CZL");
            end;
        }
        field(11779; "Allow VAT Posting To CZL"; Date)
        {
            Caption = 'Allow VAT Posting To';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
            begin
                GLSetup.Get();
                GLSetup.TestField("Use VAT Date CZL");
            end;
        }
    }
}
