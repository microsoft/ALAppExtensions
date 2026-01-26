namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.FinancialReports;
using Microsoft.Sustainability.Account;

tableextension 6221 "Sust. Acc. Schedule Line" extends "Acc. Schedule Line"
{
    fields
    {
        modify(Totaling)
        {
            TableRelation = if ("Totaling Type" = const("Sust. Accounts")) "Sustainability Account";
        }
    }
}