permissionset 19150 "EssentialHeadlines - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Essential Business Headlines - Objects';

    Permissions = codeunit "Ess. Bus. Headline Subscribers" = X,
                    codeunit "Essential Bus. Headline Mgt." = X,
                    codeunit "Headlines Install" = X,
                    page "Headline Details" = X,
                    query "Best Sold Item Headline" = X,
                    query "Sales Increase Headline" = X,
                    query "Top Customer Headline" = X,
                    table "Ess. Business Headline Per Usr" = X,
                    table "Headline Details Per User" = X;
}