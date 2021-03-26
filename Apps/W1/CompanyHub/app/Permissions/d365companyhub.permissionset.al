permissionset 2143 "D365 COMPANY HUB"
{
    Assignable = true;

    Permissions = tabledata "COHUB Company Endpoint" = RIMD,
                  tabledata "COHUB Company KPI" = RIMD,
                  tabledata "COHUB Enviroment" = RIMD,
                  tabledata "COHUB Group" = RIMD,
                  tabledata "COHUB Group Company Summary" = RIMD,
                  tabledata "COHUB User Task" = RIMD;
}
