permissionset 4810 "Intrastat Core - Objects"
{
    Assignable = false;
    Caption = 'Intrastat Core - Objects';

    Permissions =
        table "Intrastat Report Setup" = X,
        table "Intrastat Report Header" = X,
        table "Intrastat Report Line" = X,
        table "Intrastat Report Checklist" = X,

        codeunit IntrastatReportManagement = X,

        page "Intrastat Report Setup" = X,
        page "Intrastat Report List" = X,
        page "Intrastat Report" = X,
        page "Intrastat Report Subform" = X,
        page "Intrastat Report Checklist" = X,
        page "Intrastat Report Setup Wizard" = X,
        page "Intrastat Report Lines" = X,

        report "Intrastat Report Get Lines" = X;
}