permissionsetextension 44314 "D365 READ - Standard Audit File - Tax Localization for Norway" extends "D365 READ"
{
    Permissions = tabledata "SAF-T Export File" = R,
                  tabledata "SAF-T Export Header" = R,
                  tabledata "SAF-T Export Line" = R,
                  tabledata "SAF-T Export Setup" = R,
                  tabledata "SAF-T G/L Account Mapping" = R,
                  tabledata "SAF-T Mapping" = R,
                  tabledata "SAF-T Mapping Category" = R,
                  tabledata "SAF-T Mapping Range" = R,
                  tabledata "SAF-T Mapping Source" = R,
                  tabledata "SAF-T Missing Field" = R,
                  tabledata "SAF-T Setup" = R,
                  tabledata "SAF-T Source Code" = R;
}
