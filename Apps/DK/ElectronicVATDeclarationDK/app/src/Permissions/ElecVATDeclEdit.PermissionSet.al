namespace Microsoft.Finance.VAT.Reporting;

permissionset 13612 "Elec. VAT Decl. Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Elec. VAT Decl. Read";

    Permissions =
        tabledata "Elec. VAT Decl. Communication" = IMD,
        tabledata "Elec. VAT Decl. Setup" = IMD;
}
