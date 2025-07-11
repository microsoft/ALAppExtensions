namespace Microsoft.Finance.AuditFileExport;

permissionset 13688 "SAF-T DK - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "SAF-T Objects DK";

    Permissions = tabledata "Imported SAF-T File DK" = R;
}