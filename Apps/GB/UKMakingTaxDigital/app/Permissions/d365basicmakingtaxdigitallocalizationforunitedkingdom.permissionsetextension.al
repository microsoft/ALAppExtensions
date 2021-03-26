permissionsetextension 17113 "D365 BASIC - Making Tax Digital Localization for United Kingdom" extends "D365 BASIC"
{
    Permissions = tabledata "MTD Liability" = RIMD,
                  tabledata "MTD Payment" = RIMD,
                  tabledata "MTD Return Details" = RIMD;
}
