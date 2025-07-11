namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Security.AccessControl;

permissionsetextension 12900 "D365 BUS PREMIUM - Envestnet Yodlee Bank Feeds" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "MS - Yodlee Bank Acc. Link" = RIMD,
                  tabledata "MS - Yodlee Bank Service Setup" = RIMD,
                  tabledata "MS - Yodlee Bank Session" = RIMD,
                  tabledata "MS - Yodlee Data Exchange Def" = RIMD;
}
