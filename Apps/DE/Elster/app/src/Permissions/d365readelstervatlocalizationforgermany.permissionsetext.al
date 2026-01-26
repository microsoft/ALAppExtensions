#pragma warning disable AA0247
permissionsetextension 9615 "D365 READ - ELSTER VAT Localization for Germany" extends "D365 READ"
{
    Permissions = tabledata "Elec. VAT Decl. Setup" = R,
                  tabledata "Sales VAT Advance Notif." = R,
                  tabledata "Elec. VAT Decl. Buffer" = R;
}
