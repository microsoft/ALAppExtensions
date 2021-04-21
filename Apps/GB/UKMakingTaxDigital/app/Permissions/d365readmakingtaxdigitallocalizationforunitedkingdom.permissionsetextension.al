permissionsetextension 47548 "D365 READ - Making Tax Digital Localization for United Kingdom" extends "D365 READ"
{
    Permissions = tabledata "MTD Liability" = R,
                  tabledata "MTD Payment" = R,
                  tabledata "MTD Return Details" = R;
}
