namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Security.AccessControl;

permissionsetextension 14538 "D365 BUS FULL ACCESS - Envestnet Yodlee Bank Feeds" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "MS - Yodlee Bank Acc. Link" = RIMD,
                  tabledata "MS - Yodlee Bank Service Setup" = RIMD,
                  tabledata "MS - Yodlee Bank Session" = RIMD,
                  tabledata "MS - Yodlee Data Exchange Def" = RIMD;
}
