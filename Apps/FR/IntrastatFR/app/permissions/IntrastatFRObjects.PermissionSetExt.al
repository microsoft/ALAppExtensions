permissionsetextension 10851 "Intrastat FR - Objects" extends "Intrastat Core - Objects"
{
    Permissions = codeunit "Intrastat Rep. Filter Rcpt. FR" = X,
        codeunit "Intrastat Rep. Filter Shpt. FR" = X,
        codeunit IntrastatReportManagementFR = X;
}