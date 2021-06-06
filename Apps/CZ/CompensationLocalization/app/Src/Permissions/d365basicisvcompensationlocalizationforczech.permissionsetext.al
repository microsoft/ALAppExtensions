permissionsetextension 19501 "D365 BASIC ISV - Compensation Localization for Czech" extends "D365 BASIC ISV"
{
    Permissions = tabledata "Compens. Report Selections CZC" = RIMD,
                  tabledata "Compensation Header CZC" = RIMD,
                  tabledata "Compensation Line CZC" = RIMD,
                  tabledata "Compensations Setup CZC" = RIMD,
                  tabledata "Posted Compensation Header CZC" = RIMD,
                  tabledata "Posted Compensation Line CZC" = RIMD;
}
