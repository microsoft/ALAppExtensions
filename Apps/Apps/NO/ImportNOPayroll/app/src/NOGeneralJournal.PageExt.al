namespace Microsoft.Payroll.Norway;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 10609 "NO General Journal" extends "General Journal"
{
    actions
    {
        modify(ImportPayrollFile)
        {
            Visible = true;
        }
    }
}