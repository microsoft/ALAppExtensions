namespace Microsoft.DataMigration.GP.HistoricalData;

permissionset 40901 "GP Payroll Detail"
{
    Assignable = true;
    Access = Public;
    Caption = 'GP Historical Payroll Details', MaxLength = 30;
    Permissions = tabledata "Hist. Payroll Details" = R,
        page "Hist. Payroll Details" = X;
}