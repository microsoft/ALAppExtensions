namespace Microsoft.API.V2;

using System.Environment;
using System.Security.AccessControl;

page 30082 "APIV2 - Aut. Security Groups"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Security Group';
    EntitySetCaption = 'Security Groups';
    DelayedInsert = true;
    EntityName = 'securityGroup';
    EntitySetName = 'securityGroups';
    PageType = API;
    SourceTable = "Security Group Buffer";
    Extensible = false;
    SourceTableTemporary = true;
    ODataKeyFields = "Group ID";
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec."Group ID")
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                    Editable = false;
                }
                field(groupName; Rec."Group Name")
                {
                    Caption = 'Group Name';
                    Editable = false;
                }
                part(securityGroupMembers; "APIV2 - Aut. Sec. Gr. Members")
                {
                    Caption = 'User Group Member';
                    EntityName = 'securityGroupMember';
                    EntitySetName = 'securityGroupMembers';
                    SubPageLink = "Security Group Code" = field(Code);
                }
                part(securityGroupPermissions; "APIV2 - Aut. User Permissions")
                {
                    Caption = 'Security Group Permissions';
                    EntityName = 'userPermission';
                    EntitySetName = 'userPermissions';
                    SubPageLink = "User Security ID" = field("Group User SID");
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not AreRecordsLoaded then begin
            LoadRecords();
            AreRecordsLoaded := true;
            if Rec.IsEmpty() then
                exit(false);
        end;

        exit(true);
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        SecurityGroup.Delete(Rec.Code);
    end;

    local procedure LoadRecords()
    begin
        SecurityGroup.GetGroups(Rec);
    end;

    var
        SecurityGroup: Codeunit "Security Group";
        AutomationAPIManagement: Codeunit "Automation - API Management";
        AreRecordsLoaded: Boolean;
}


