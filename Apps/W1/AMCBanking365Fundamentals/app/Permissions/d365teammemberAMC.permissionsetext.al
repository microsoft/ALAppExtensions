permissionsetextension 20106 "D365 TEAM MEMBER - AMC" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "AMC Bank Banks" = RIMD,
                  tabledata "AMC Bank Pmt. Type" = RIMD,
                  tabledata "AMC Banking Setup" = R;
}
