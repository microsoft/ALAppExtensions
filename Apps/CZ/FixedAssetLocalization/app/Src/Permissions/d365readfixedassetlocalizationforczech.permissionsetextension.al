permissionsetextension 9648 "D365 READ - Fixed Asset Localization for Czech" extends "D365 READ"
{
    Permissions = tabledata "Classification Code CZF" = R,
                  tabledata "FA Extended Posting Group CZF" = R,
                  tabledata "FA History Entry CZF" = R,
                  tabledata "Tax Depreciation Group CZF" = R;
}
