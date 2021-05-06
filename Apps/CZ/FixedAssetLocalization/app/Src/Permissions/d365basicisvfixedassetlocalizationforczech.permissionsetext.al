permissionsetextension 47518 "D365 BASIC ISV - Fixed Asset Localization for Czech" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Classification Code CZF" = RIMD,
                  tabledata "FA Extended Posting Group CZF" = RIMD,
                  tabledata "FA History Entry CZF" = RIMD,
                  tabledata "Tax Depreciation Group CZF" = RIMD;
}
