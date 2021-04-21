permissionsetextension 19999 "D365 TEAM MEMBER - Compensation Localization for Czech" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Compens. Report Selections CZC" = RIMD,
                  tabledata "Compensation Header CZC" = RIMD,
                  tabledata "Compensation Line CZC" = RIMD,
                  tabledata "Compensations Setup CZC" = RIMD,
                  tabledata "Posted Compensation Header CZC" = RIMD,
                  tabledata "Posted Compensation Line CZC" = RIMD;
}
