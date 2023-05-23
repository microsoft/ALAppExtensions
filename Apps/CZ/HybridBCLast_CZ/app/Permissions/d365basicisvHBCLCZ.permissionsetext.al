#if not CLEAN21
permissionsetextension 31001 "D365 BASIC ISV - HBCLCZ" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Stg VAT Control Report Line" = RIMD,
                  tabledata "Stg VAT Posting Setup" = RIMD;
}
#endif