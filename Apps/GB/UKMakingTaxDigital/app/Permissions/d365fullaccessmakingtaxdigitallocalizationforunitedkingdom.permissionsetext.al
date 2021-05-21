permissionsetextension 45170 "D365 FULL ACCESS - Making Tax Digital Localization for United Kingdom" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "MTD Liability" = RIMD,
                  tabledata "MTD Payment" = RIMD,
                  tabledata "MTD Return Details" = RIMD;
}
