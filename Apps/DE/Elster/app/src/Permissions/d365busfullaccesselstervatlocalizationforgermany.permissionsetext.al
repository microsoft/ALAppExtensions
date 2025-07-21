#pragma warning disable AA0247
permissionsetextension 8697 "D365 BUS FULL ACCESS - ELSTER VAT Localization for Germany" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Elec. VAT Decl. Setup" = RIMD,
                  tabledata "Sales VAT Advance Notif." = RIMD,
                  tabledata "Elec. VAT Decl. Buffer" = RIMD;
}
