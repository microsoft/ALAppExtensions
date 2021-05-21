page 20004 "APIV1 - Aut. Users"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'user', Locked = true;
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
                    Caption = 'userSecurityId', Locked = true;
                    Editable = false;
                }
                field(userName; "User Name")
                {
                    Caption = 'userName', Locked = true;
                    Editable = false;
                }
                field(displayName; "Full Name")
                {
                    Caption = 'displayName', Locked = true;
                    Editable = false;
                }
                field(state; State)
                {
                    Caption = 'state', Locked = true;
                }
                field(expiryDate; "Expiry Date")
                {
                    Caption = 'expiryDate', Locked = true;
                }
                part(userGroupMember; "APIV1 - Aut. User Group Member")
                {
                    Caption = 'userGroupMember', Locked = true;
                    EntityName = 'userGroupMember';
                    EntitySetName = 'userGroupMembers';
                    SubPageLink = "User Security ID" = FIELD("User Security ID");
                }
                part(userPermission; "APIV1 - Aut. User Permission")
                {
                    Caption = 'userPermission', Locked = true;
                    EntityName = 'userPermission';
                    EntitySetName = 'userPermissions';
                    SubPageLink = "User Security ID" = FIELD("User Security ID");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        BINDSUBSCRIPTION(AutomationAPIManagement);
        IF EnvironmentInfo.IsSaaS() THEN
            SETFILTER("License Type", '<>%1', "License Type"::"External User");
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}

