permissionset 133401 "Test Set A"
{
    Assignable = true;

    IncludedPermissionSets = "Test Set B",
                             "Test Set C";

    Permissions = codeunit "Permission Set Relation" = X,
                  page "Tenant Permission Subform" = X;
}