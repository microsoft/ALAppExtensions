#if not CLEAN21
permissionsetextension 31002 "D365 TEAM MEMBER - HBCLCZ" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Stg VAT Control Report Line" = RIMD,
                  tabledata "Stg VAT Posting Setup" = RIMD;
}
#endif