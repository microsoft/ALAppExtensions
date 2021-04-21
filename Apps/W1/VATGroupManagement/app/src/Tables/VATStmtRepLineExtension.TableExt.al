tableextension 4703 "VAT Stmt. Rep. Line Extension" extends "VAT Statement Report Line"
{
    fields
    {
        field(4700; "Representative Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Representative Amount';
            Editable = false;
        }
        field(4701; "Group Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            Caption = 'Group Amount';
            Editable = false;
        }
    }
}