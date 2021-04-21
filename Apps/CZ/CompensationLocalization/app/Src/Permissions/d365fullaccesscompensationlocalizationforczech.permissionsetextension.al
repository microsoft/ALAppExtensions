permissionsetextension 34645 "D365 FULL ACCESS - Compensation Localization for Czech" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "Compens. Report Selections CZC" = RIMD,
                  tabledata "Compensation Header CZC" = RIMD,
                  tabledata "Compensation Line CZC" = RIMD,
                  tabledata "Compensations Setup CZC" = RIMD,
                  tabledata "Posted Compensation Header CZC" = RIMD,
                  tabledata "Posted Compensation Line CZC" = RIMD;
}
