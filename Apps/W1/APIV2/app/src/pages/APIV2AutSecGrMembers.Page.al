page 30081 "APIV2 - Aut. Sec. Gr. Members"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Security Group Member';
    EntitySetCaption = 'Security Group Members';
    DelayedInsert = true;
    EntityName = 'securityGroupMember';
    EntitySetName = 'securityGroupMembers';
    Extensible = false;
    PageType = API;
    SourceTable = "Security Group Member Buffer";
    SourceTableTemporary = true;
    ODataKeyFields = "Security Group Code", "User Security ID";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(userSecurityId; Rec."User Security ID")
                {
                    Caption = 'User Security Id';
                    Editable = false;
                }
                field(securityGroupCode; Rec."Security Group Code")
                {
                    Editable = false;
                    Caption = 'Security Group Code';
                }
                field(securityGroupName; Rec."Security Group Name")
                {
                    Editable = false;
                    Caption = 'Security Group Name';
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not AreRecordsLoaded then begin
            LoadRecords();
            AreRecordsLoaded := true;
        end;
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    local procedure LoadRecords()
    begin
        SecurityGroup.GetMembers(Rec);
    end;

    var
        SecurityGroup: Codeunit "Security Group";
        AutomationAPIManagement: Codeunit "Automation - API Management";
        AreRecordsLoaded: Boolean;
}


