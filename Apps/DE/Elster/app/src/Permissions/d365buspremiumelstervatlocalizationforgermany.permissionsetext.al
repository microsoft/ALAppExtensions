#pragma warning disable AA0247
permissionsetextension 16295 "D365 BUS PREMIUM - ELSTER VAT Localization for Germany" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "Elec. VAT Decl. Setup" = RIMD,
                  tabledata "Sales VAT Advance Notif." = RIMD,
                  tabledata "Elec. VAT Decl. Buffer" = RIMD;
}
