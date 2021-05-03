permissionsetextension 8401 "D365 BUS FULL ACCESS - Making Tax Digital Localization for United Kingdom" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "MTD Liability" = RIMD,
                  tabledata "MTD Payment" = RIMD,
                  tabledata "MTD Return Details" = RIMD;
}
