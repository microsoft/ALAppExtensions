namespace Microsoft.Sustainability;

using Microsoft.PowerBIReports;
using Microsoft.Sustainability.PowerBIReports;

permissionsetextension 6212 "Sust. Power BI Reports" extends "PowerBi Report Basic"
{
    Permissions =
        codeunit "PBI Sustain. Filter Helper" = X,
        query "Country Region - PBI API" = X,
        query "Emission Fees - PBI API" = X,
        query "Employee Absence - PBI API" = X,
        query "EmployeeLedgerEntry - PBI API" = X,
        query "Employee Quali - PBI API" = X,
        query "Employees - PBI API" = X,
        query "Resp Centre - PBI API" = X,
        query "SusSub Act Category - PBI API" = X,
        query "Sust Account Cat - PBI API" = X,
        query "Sust Accounts - PBI API" = X,
        query "Sustainability Goals - PBI API" = X,
        query "Sust Ledger Entries - PBI API" = X;
}