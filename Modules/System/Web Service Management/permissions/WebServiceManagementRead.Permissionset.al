permissionset 6710 "Web Service Management - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata AllObj = r,
                  tabledata AllObjWithCaption = r,
                  tabledata Field = r,
                  tabledata "Tenant Web Service" = r,
                  tabledata "Tenant Web Service Columns" = R,
                  tabledata "Tenant Web Service Filter" = R,
                  tabledata "Tenant Web Service OData" = R,
                  tabledata "Web Service" = R,
                  tabledata "Web Service Aggregate" = R;
}