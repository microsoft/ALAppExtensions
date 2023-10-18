namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Security.AccessControl;

permissionsetextension 21619 "INTELLIGENT CLOUD - Envestnet Yodlee Bank Feeds" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "MS - Yodlee Bank Acc. Link" = R,
                  tabledata "MS - Yodlee Bank Service Setup" = R,
                  tabledata "MS - Yodlee Bank Session" = R,
                  tabledata "MS - Yodlee Data Exchange Def" = R;
}
