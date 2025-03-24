#pragma warning disable AA0247
permissionsetextension 14181 "D365 FULL ACCESS - ELSTER VAT Localization for Germany" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "Elec. VAT Decl. Setup" = RIMD,
                  tabledata "Sales VAT Advance Notif." = RIMD,
                  tabledata "Elec. VAT Decl. Buffer" = RIMD;
}
