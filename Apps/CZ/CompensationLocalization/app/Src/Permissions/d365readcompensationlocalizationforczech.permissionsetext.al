permissionsetextension 37555 "D365 READ - Compensation Localization for Czech" extends "D365 READ"
{
    Permissions = tabledata "Compens. Report Selections CZC" = R,
                  tabledata "Compensation Header CZC" = R,
                  tabledata "Compensation Line CZC" = R,
                  tabledata "Compensations Setup CZC" = R,
                  tabledata "Posted Compensation Header CZC" = R,
                  tabledata "Posted Compensation Line CZC" = R;
}
