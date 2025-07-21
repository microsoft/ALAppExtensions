#pragma warning disable AA0247
permissionsetextension 32689 "D365 TEAM MEMBER - ELSTER VAT Localization for Germany" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Elec. VAT Decl. Setup" = RIMD,
                  tabledata "Sales VAT Advance Notif." = RIMD,
                  tabledata "Elec. VAT Decl. Buffer" = RIMD;
}
