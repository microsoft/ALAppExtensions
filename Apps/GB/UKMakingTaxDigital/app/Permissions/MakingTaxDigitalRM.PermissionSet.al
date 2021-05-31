permissionset 10502 "Making Tax Digital - RM"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Making Tax Digital - Read";

    Permissions = tabledata "MTD Liability" = M,
                  tabledata "MTD Payment" = M,
                  tabledata "MTD Return Details" = M,
                  tabledata "MTD Missing Fraud Prev. Hdr" = M,
                  tabledata "MTD Session Fraud Prev. Hdr" = M,
                  tabledata "MTD Default Fraud Prev. Hdr" = M;
}