permissionsetextension 1317 "D365 BASIC ISV - Making Tax Digital Localization for United Kingdom" extends "D365 BASIC ISV"
{
    Permissions = tabledata "MTD Liability" = RIMD,
                  tabledata "MTD Payment" = RIMD,
                  tabledata "MTD Return Details" = RIMD;
}
