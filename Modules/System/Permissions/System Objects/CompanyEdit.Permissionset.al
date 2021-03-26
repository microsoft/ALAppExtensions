permissionset 93 "Company - Edit"
{
    Assignable = False;

    IncludedPermissionSets = "Company - Read";

    Permissions = system "Create a new company" = X,
                  system "Delete a company" = X,
                  system "Rename an existing company" = X,
                  tabledata Company = IMD;
}
