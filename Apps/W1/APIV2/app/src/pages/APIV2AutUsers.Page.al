namespace Microsoft.API.V2;

using System.Security.AccessControl;
using System.Environment;
using System.Threading;

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
    ODataKeyFields = "User Security ID";

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
                field(userName; Rec."User Name")
                {
                    Caption = 'User Name';
                    Editable = false;
                }
                field(displayName; Rec."Full Name")
                {
                    Caption = 'Display Name';
                    Editable = false;
                }
                field(state; Rec.State)
                {
                    Caption = 'State';
                }
                field(expiryDate; Rec."Expiry Date")
                {
                    Caption = 'Expiry Date';
                }
                field(contactEmail; Rec."Contact Email")
                {
                    Caption = 'Contact Email';
                }
                part(securityGroupMember; "APIV2 - Aut. Sec. Gr. Members")
                {
                    Caption = 'User Group Member';
                    EntityName = 'securityGroupMember';
                    EntitySetName = 'securityGroupMembers';
                    SubPageLink = "User Security ID" = field("User Security ID");
                }
                part(userPermission; "APIV2 - Aut. User Permissions")
                {
                    Caption = 'User Permission';
                    EntityName = 'userPermission';
                    EntitySetName = 'userPermissions';
                    SubPageLink = "User Security ID" = field("User Security ID");
                }
                part(scheduledJobs; "APIV2 - Aut. Scheduled Jobs")
                {
                    Caption = 'Scheduled Jobs';
                    EntityName = 'scheduledJob';
                    EntitySetName = 'scheduledJobs';
                    SubPageLink = "Job Queue Category Code" = const('APIUSERJOB');
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        BindSubscription(AutomationAPIManagement);
        if EnvironmentInformation.IsSaaS() then
            Rec.SetFilter("License Type", '<>%1', Rec."License Type"::"External User");
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        APIV2AutCreateNewUsers: Codeunit "APIV2 - Aut. Create New Users";
        AlreadyScheduledCreateUsersJobLbl: Label 'You cannot get new users while a task is already in progress.';

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure GetNewUsersFromOffice365Async(var ActionContext: WebServiceActionContext)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntryId: Guid;
    begin
        if IsPendingOperation() then
            Error(AlreadyScheduledCreateUsersJobLbl);

        JobQueueEntryId := APIV2AutCreateNewUsers.CreateNewUsersFromAzureADInBackground();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Scheduled Jobs");
        ActionContext.AddEntityKey(JobQueueEntry.FieldNo(SystemId), JobQueueEntryId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Created);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure GetNewUsersFromOffice365(var ActionContext: WebServiceActionContext)
    begin
        if IsPendingOperation() then
            Error(AlreadyScheduledCreateUsersJobLbl);

        Codeunit.Run(Codeunit::"APIV2 - Aut. Create New Users");

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Users");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    local procedure IsPendingOperation(): Boolean
    begin
        exit(APIV2AutCreateNewUsers.IsJobScheduled());
    end;
}

