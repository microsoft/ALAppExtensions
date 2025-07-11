namespace Microsoft.Finance.VAT.Reporting;

permissionset 13611 "Elec. VAT Decl. Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Elec. VAT Decl. Objects";

    Permissions =
        tabledata "Elec. VAT Decl. Communication" = R,
        tabledata "Elec. VAT Decl. Setup" = R;
}