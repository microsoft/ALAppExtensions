tableextension 18934 "Bank Account Ext" extends "Bank Account"
{
    fields
    {
        field(18929; "Stale Cheque Stipulated Period"; DateFormula)
        {
            Caption = 'Stale Cheque Stipulated Period';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                StipulatePeriod := Format("Stale Cheque Stipulated Period");
                if StrPos(StipulatePeriod, '-') <> 0 then
                    Error(StipulatedPeriodNegativeErr);
            end;
        }
    }

    var
        StipulatePeriod: Text[30];
        StipulatedPeriodNegativeErr: Label 'Stale Cheque Stipulated Period can''t be negative.';
}