#if not CLEAN21
permissionsetextension 31003 "INTELLIGENT CLOUD - HBCLCZ" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "Stg VAT Control Report Line" = RIMD,
                  tabledata "Stg VAT Posting Setup" = RIMD;
}
#endif