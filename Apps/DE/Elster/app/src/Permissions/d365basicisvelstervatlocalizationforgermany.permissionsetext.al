#pragma warning disable AA0247
permissionsetextension 45801 "D365 BASIC ISV - ELSTER VAT Localization for Germany" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Elec. VAT Decl. Setup" = RIMD,
                  tabledata "Sales VAT Advance Notif." = RIMD,
                  tabledata "Elec. VAT Decl. Buffer" = RIMD;
}
