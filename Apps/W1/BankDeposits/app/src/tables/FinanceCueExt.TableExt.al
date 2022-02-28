tableextension 1696 FinanceCueExt extends "Finance Cue"
{
    fields
    {
        field(10150; "Bank Deposits to Post"; Integer)
        {
            CalcFormula = Count("Bank Deposit Header" WHERE("Total Deposit Lines" = FILTER(<> 0)));
            Caption = 'Bank Deposits to Post';
            FieldClass = FlowField;
        }
    }
}