permissionset 27075 "DataSharing- Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'AnonymizedDataSharing - Objects';

    Permissions = codeunit "MS - Data Sharing Mgt." = X,
                    page "MS - Data Sharing Learn More" = X,
                    page "MS - Data Sharing Setup" = X,
                    table "MS - Data Sharing Setup" = X;
}