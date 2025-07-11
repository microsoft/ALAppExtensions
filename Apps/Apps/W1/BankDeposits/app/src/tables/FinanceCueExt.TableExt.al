namespace Microsoft.Bank.Deposit;

using Microsoft.Finance.RoleCenters;

tableextension 1696 FinanceCueExt extends "Finance Cue"
{
    fields
    {
        field(10150; "Bank Deposits to Post"; Integer)
        {
            CalcFormula = count("Bank Deposit Header" where("Total Deposit Lines" = filter(<> 0)));
            Caption = 'Bank Deposits to Post';
            FieldClass = FlowField;
        }
    }
}