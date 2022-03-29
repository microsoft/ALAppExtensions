permissionset 19149 "EssentialHeadlines - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Essential Business Headlines - Edit';

    IncludedPermissionSets = "EssentialHeadlines - Read";

    Permissions = tabledata "Ess. Business Headline Per Usr" = IMD,
                    tabledata "Headline Details Per User" = IMD;
}
