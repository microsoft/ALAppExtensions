permissionset 9986 "Word Templates - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Language - Read",
                             "Object Selection - Read";

    Permissions = tabledata "Word Template" = R,
                  tabledata "Word Templates Table" = r,
                  tabledata AllObjWithCaption = r,
                  tabledata AllObj = r,
                  tabledata Field = r;
}