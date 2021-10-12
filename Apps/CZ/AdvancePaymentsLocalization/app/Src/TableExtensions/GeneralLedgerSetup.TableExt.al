tableextension 31003 "General Ledger Setup CZZ" extends "General Ledger Setup"
{
    fields
    {
        field(31010; "Adv. Deduction Exch. Rate CZZ"; Enum "Adv. Deduction Exch. Rate CZZ")
        {
            Caption = 'Advance Letter Deduction Exchange Rate';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                ChangeAdvDeductErr: Label 'You cannot change, because some letter to use exists.';
            begin
                SalesAdvLetterHeaderCZZ.SetFilter("Currency Code", '<>0');
                SalesAdvLetterHeaderCZZ.SetFilter("To Use", '<>0');
                if not SalesAdvLetterHeaderCZZ.IsEmpty() then
                    Error(ChangeAdvDeductErr);
            end;
        }
    }
}
