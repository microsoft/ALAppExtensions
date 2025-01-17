namespace Microsoft.Finance.AuditFileExport;

permissionset 13689 "SAF-T DK - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "SAF-T DK - Read";

    Permissions = tabledata "Imported SAF-T File DK" = IMD;
}