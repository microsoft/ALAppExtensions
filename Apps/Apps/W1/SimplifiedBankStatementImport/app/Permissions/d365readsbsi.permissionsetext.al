namespace Microsoft.Bank.StatementImport;

using System.Security.AccessControl;

permissionsetextension 8855 "D365 READ - SBSI" extends "D365 READ"
{
    IncludedPermissionSets = "Simplified Bank Stat. Import";
}
