namespace System.Security.AccessControl;

using Microsoft.DataMigration.GP;

permissionset 4713 "HybridGPUS - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'HybridGPUS- Objects';

    Permissions =
        table "GP 1099 Box Mapping" = X,
        table "GP 1099 Migration Log" = X,
        table "Supported Tax Year" = X,
        codeunit "GP Cloud Migration US" = X,
        codeunit "GP Populate Vendor 1099 Data" = X,
        codeunit "GP Vendor 1099 Mapping Helpers" = X,
        codeunit "GP IRS Form Data" = X,
        page "GP 1099 Migration Log" = X,
        page "GP 1099 Migration Log Factbox" = X;
}