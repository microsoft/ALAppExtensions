permissionsetextension 20105 "D365 READ - AMC" extends "D365 READ"
{
    Permissions = tabledata "AMC Bank Banks" = R,
                  tabledata "AMC Bank Pmt. Type" = R,
                  tabledata "AMC Banking Setup" = R;
}
