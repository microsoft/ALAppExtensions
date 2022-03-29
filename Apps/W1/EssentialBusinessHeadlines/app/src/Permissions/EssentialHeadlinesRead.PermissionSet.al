permissionset 19151 "EssentialHeadlines - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Essential Business Headlines - Read';

    IncludedPermissionSets = "EssentialHeadlines - Objects";

    Permissions = tabledata "Ess. Business Headline Per Usr" = R,
                    tabledata "Headline Details Per User" = R;
}
