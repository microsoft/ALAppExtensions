#pragma warning disable AA0247
permissionsetextension 31300 "Intrastat CZ - Objects" extends "Intrastat Core - Objects"
{
    Permissions =
        codeunit "Data Class. Eval. Handler CZ" = X,
        codeunit "Install Application CZ" = X,
        codeunit IntrastatReportManagementCZ = X,
        codeunit "Intrastat Transformation CZ" = X,
        page "Intrastat Delivery Groups CZ" = X,
        page "Specific Movements CZ" = X,
        page "Statistic Indications CZ" = X,
        table "Specific Movement CZ" = X;
}
