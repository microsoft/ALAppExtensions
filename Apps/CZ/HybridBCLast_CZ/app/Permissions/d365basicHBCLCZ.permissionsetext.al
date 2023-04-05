#if not CLEAN21
permissionsetextension 31000 "D365 BASIC - HBCLCZ" extends "D365 BASIC"
{
    Permissions = tabledata "Stg VAT Control Report Line" = RIMD,
                  tabledata "Stg VAT Posting Setup" = RIMD;
}
#endif