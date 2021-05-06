permissionsetextension 13912 "D365 TEAM MEMBER - Making Tax Digital Localization for United Kingdom" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "MTD Liability" = RIMD,
                  tabledata "MTD Payment" = RIMD,
                  tabledata "MTD Return Details" = RIMD;
}
