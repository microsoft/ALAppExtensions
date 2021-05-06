permissionsetextension 42047 "D365 BASIC - Fixed Asset Localization for Czech" extends "D365 BASIC"
{
    Permissions = tabledata "Classification Code CZF" = RIMD,
                  tabledata "FA Extended Posting Group CZF" = RIMD,
                  tabledata "FA History Entry CZF" = RIMD,
                  tabledata "Tax Depreciation Group CZF" = RIMD;
}
