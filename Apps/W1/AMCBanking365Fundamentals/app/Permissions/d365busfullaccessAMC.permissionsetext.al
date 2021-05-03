permissionsetextension 20102 "D365 BUS FULL ACCESS - AMC" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "AMC Bank Banks" = RIMD,
                  tabledata "AMC Bank Pmt. Type" = RIMD,
                  tabledata "AMC Banking Setup" = RIMD;
}
