permissionsetextension 6342 "D365 FULL ACCESS - Standard Audit File - Tax Localization for Norway" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "SAF-T Export File" = RIMD,
                  tabledata "SAF-T Export Header" = RIMD,
                  tabledata "SAF-T Export Line" = RIMD,
                  tabledata "SAF-T Export Setup" = RIMD,
                  tabledata "SAF-T G/L Account Mapping" = RIMD,
                  tabledata "SAF-T Mapping" = RIMD,
                  tabledata "SAF-T Mapping Category" = RIMD,
                  tabledata "SAF-T Mapping Range" = RIMD,
                  tabledata "SAF-T Mapping Source" = RIMD,
                  tabledata "SAF-T Missing Field" = RIMD,
                  tabledata "SAF-T Setup" = RIMD,
                  tabledata "SAF-T Source Code" = RIMD;
}
