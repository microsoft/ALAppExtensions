namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Security.AccessControl;

permissionsetextension 39041 "D365 READ - Envestnet Yodlee Bank Feeds" extends "D365 READ"
{
    Permissions = tabledata "MS - Yodlee Bank Acc. Link" = R,
                  tabledata "MS - Yodlee Bank Service Setup" = R,
                  tabledata "MS - Yodlee Bank Session" = R,
                  tabledata "MS - Yodlee Data Exchange Def" = R;
}
