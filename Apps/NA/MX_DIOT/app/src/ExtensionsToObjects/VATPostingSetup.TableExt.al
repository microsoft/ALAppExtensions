tableextension 27037 "DIOT VAT Posting Setup" extends "VAT Posting Setup"
{
    fields
    {
        field(27000; "DIOT WHT %"; Decimal)
        {
            Caption = 'DIOT WHT Percent';
            MinValue = 0;
        }
    }
}