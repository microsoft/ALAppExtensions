tableextension 31288 "Bank Acc. Reconciliation CZB" extends "Bank Acc. Reconciliation"
{
    fields
    {
        field(11707; "Created From Bank Stat. CZB"; Boolean)
        {
            Caption = 'Created From Bank Statement';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
