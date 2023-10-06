namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Security.AccessControl;

permissionsetextension 30000 "D365 BASIC ISV - Envestnet Yodlee Bank Feeds" extends "D365 BASIC ISV"
{
    Permissions = tabledata "MS - Yodlee Bank Acc. Link" = RIMD,
                  tabledata "MS - Yodlee Bank Service Setup" = RIMD,
                  tabledata "MS - Yodlee Bank Session" = RIMD,
                  tabledata "MS - Yodlee Data Exchange Def" = RIMD;
}
