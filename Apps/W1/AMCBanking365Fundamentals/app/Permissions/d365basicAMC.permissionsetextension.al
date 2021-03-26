permissionsetextension 20100 "D365 BASIC - AMC" extends "D365 BASIC"
{
    Permissions = tabledata "AMC Bank Banks" = RIMD,
                  tabledata "AMC Bank Pmt. Type" = RIMD,
                  tabledata "AMC Banking Setup" = R;
}
