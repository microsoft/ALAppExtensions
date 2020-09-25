page 30004 "APIV2 - Aut. Users"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User';
    EntitySetCaption = 'Users';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'user';
    EntitySetName = 'users';
    InsertAllowed = false;
    PageType = API;
    SourceTable = User;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(userSecurityId; "User Security ID")
                {
                    Caption = 'User Security Id';
                    Editable = false;
                }
                field(userName; "User Name")
                {
                    Caption = 'User Name';
                    Editable = false;
                }
                field(displayName; "Full Name")
                {
                    Caption = 'Display Name';
                    Editable = false;
                }
                field(state; State)
                {
                    Caption = 'State';
                }
                field(expiryDate; "Expiry Date")
                {
                    Caption = 'Expiry Date';
                }
                part(userGroupMember; 5442)
                {
                    Caption = 'User Group Member';
                    EntityName = 'userGroupMember';
                    EntitySetName = 'userGroupMembers';
                    SubPageLink = "User Security ID" = Field("User Security ID");
                }
                part(userPermission; 5446)
                {
                    Caption = 'User Permission';
                    EntityName = 'userPermission';
                    EntitySetName = 'userPermissions';
                    SubPageLink = "User Security ID" = Field("User Security ID");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EnvironmentInfo: Codeunit 457;
    begin
        BindSubscription(AutomationAPIManagement);
        if EnvironmentInfo.IsSaaS() then
            SetFilter("License Type", '<>%1', "License Type"::"External User");
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}

