permissionsetextension 27049 "D365 BUS FULL ACCESS - Fixed Asset Localization for Czech" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Classification Code CZF" = RIMD,
                  tabledata "FA Extended Posting Group CZF" = RIMD,
                  tabledata "FA History Entry CZF" = RIMD,
                  tabledata "Tax Depreciation Group CZF" = RIMD;
}
