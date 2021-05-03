permissionsetextension 13804 "D365 READ - Late Payment Prediction" extends "D365 READ"
{
    Permissions = tabledata "LP Machine Learning Setup" = R,
                  tabledata "LP ML Input Data" = R;
}
