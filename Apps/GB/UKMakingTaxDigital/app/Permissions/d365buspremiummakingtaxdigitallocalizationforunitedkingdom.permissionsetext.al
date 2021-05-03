permissionsetextension 33211 "D365 BUS PREMIUM - Making Tax Digital Localization for United Kingdom" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "MTD Liability" = RIMD,
                  tabledata "MTD Payment" = RIMD,
                  tabledata "MTD Return Details" = RIMD;
}
