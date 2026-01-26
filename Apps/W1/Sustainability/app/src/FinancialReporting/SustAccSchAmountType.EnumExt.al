namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.FinancialReports;

enumextension 6212 "Sust. Acc. Sch. Amount Type" extends "Account Schedule Amount Type"
{
    value(6210; "Carbon Fee")
    {
        Caption = 'Carbon Fee';
    }
    value(6211; "CO2e")
    {
        Caption = 'CO2e';
    }
}