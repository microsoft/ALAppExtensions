tableextension 31030 "General Posting Setup CZL" extends "General Posting Setup"
{
    fields
    {
        field(11765; "Invt. Rounding Adj. Acc. CZL"; Code[20])
        {
            Caption = 'Invt. Rounding Adj. Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAcc("Invt. Rounding Adj. Acc. CZL");
            end;
        }
    }
}