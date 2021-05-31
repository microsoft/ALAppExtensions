permissionset 10501 "Making Tax Digital - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "MTD Liability" = R,
                  tabledata "MTD Payment" = R,
                  tabledata "MTD Return Details" = R,
                  tabledata "MTD Missing Fraud Prev. Hdr" = R,
                  tabledata "MTD Session Fraud Prev. Hdr" = R,
                  tabledata "MTD Default Fraud Prev. Hdr" = R;
}