namespace Microsoft.DataMigration;

using System.Environment.Configuration;
using System.Telemetry;
using System.Security.AccessControl;
using System.Security.User;


page 4022 "Migration User Mapping"
{
    PageType = NavigatePage;
    SourceTable = "User Mapping Work";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    UsageCategory = Tasks;
    Caption = 'Define User Mappings';
    Permissions = tabledata "My Notifications" = RIMD,
                    tabledata "User" = RIMD,
                    tabledata "Hybrid Company Status" = RIM;
    layout
    {
        area(Content)
        {
            group("Parent Group")
            {
                ShowCaption = false;
                Visible = GroupVisible;

                group("Instructions")
                {
                    ShowCaption = false;
                    InstructionalText = 'Choose a cloud user to map to an on-premises user to update user-specific open transaction data.';
                }
                group(Users)
                {
                    ShowCaption = false;
                    repeater(UserList)
                    {
                        ShowCaption = false;
                        field("Source User ID2"; Rec."Source User ID")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'On-Premises User';
                            ToolTip = 'Specifies the user from the on-premises system.';
                            Visible = true;
                            Width = 10;
                            Editable = false;
                        }
                        field("Dest User ID2"; Rec."Dest User ID")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Cloud User';
                            ToolTip = 'Specifies the user in the cloud system.';

                            Visible = true;
                            AssistEdit = false;

                            trigger OnValidate()
                            var
                                OriginalUserID: Code[50];
                            begin
                                OriginalUserID := Rec."Dest User ID";

                                rec.Reset();
                                rec.SetFilter("Dest User ID", '<>%1&=%2', '', OriginalUserID);
                                if rec.FindSet() then
                                    error('This ID has already been mapped to another Source User ID');
                            end;
                        }
                    }
                }

                group("Instructions2")
                {
                    ShowCaption = false;

                    InstructionalText = 'Once you have mapped all of the users, clicking OK will update the tables.';
                }

            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(OK)
            {
                ApplicationArea = All;
                Caption = 'OK';
                Tooltip = 'OK';
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    FeatureTelemetry.LogUptake('0000JMG', HybridCloudManagement.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
                    FeatureTelemetry.LogUsage('0000JMH', HybridCloudManagement.GetFeatureTelemetryName(), 'Mapping OnPrem users');
                    ValidateAndProcess();
                end;
            }

            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                Tooltip = 'Cancel';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    if Dialog.Confirm(CancelConfirmMsg, false) then
                        CurrPage.Close();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        WarnUserMappingDoneBefore();
        GroupVisible := true;
        TempUser.SetFilter("Authentication Email", '<>%1', '');
        FillUserIDList();
    end;

    var
        TempUser: Record "User" temporary;
        GroupVisible: Boolean;
        NotAllUsersMappedMsg: Label 'Not all users are mapped. Do you want to run the mapping process anyway?';
        CancelConfirmMsg: Label 'Exit without processing user mapping?';
        UserMappingWasDoneContinueQst: Label 'You already mapped users in this migration on %1. If you map users again, you might run into unwanted results. Are you sure that you want to continue?', Comment = '%1 - Date and time when the last user mapping was done';


    local procedure ValidateAndProcess()
    begin
        Rec.Reset();
        Rec.SetFilter("Dest User ID", '=%1', '');

        if Rec.FindSet() then
            if not Dialog.Confirm(NotAllUsersMappedMsg, false) then
                error('');

        ProcessUserMapping();
        UpdateSetupRecord();
        Message('User mapping complete!');
        CurrPage.Close();
    end;

    local procedure ProcessUserMapping()
    var
        User: Record User;
        User2: Record User;
        UserManagement: Codeunit "User Management";
    begin
        Rec.Reset();
        Rec.SetFilter("Dest User ID", '<>%1', '');
        Rec.SetFilter("Source User ID", '<>%1', Rec."Dest User ID");
        if Rec.FindSet() then
            repeat
                User.Reset();
                User.SetFilter("User Name", '=%1', Rec."Dest User ID");
                if not User.IsEmpty() then begin
                    User2.SetFilter("User Name", '=%1', Rec."Dest User ID");
                    if User2.FindFirst() then begin
                        User2."User Name" := Rec."Source User ID";
                        User2.Modify(true);
                    end;
                    UserManagement.RenameUser(Rec."Dest User ID", Rec."Source User ID");
                end;
            until Rec.Next() = 0;
    end;

    local procedure FillUserIDList();
    var
        UserMappingSource: Record "User Mapping Source";
        UserName: Code[50];
    begin
        UserMappingSource.Reset();
        UserMappingSource.FindSet();
        repeat
            if not Rec.Get(UserMappingSource."User ID") then begin
                Rec.Init();
                Rec."Source User ID" := UserMappingSource."User ID";
                if FoundValidUser(UserMappingSource."Authentication Object ID", UserMappingSource."Name Identifier", UserMappingSource."Authentication Email", UserName) then
                    Rec."Dest User ID" := UserName;
                Rec.Insert();
            end;
        until UserMappingSource.Next() = 0;
    end;

    local procedure FoundValidUser(AuthenticationObjectID: Text[80]; NameIdentifier: Text[250]; AuthenticationEmail: Text[50]; var UserID: Code[50]): Boolean;
    var
        User: Record User;
        UserProperty: Record "User Property";
    begin
        UserID := '';
        if AuthenticationObjectID <> '' then begin
            UserProperty.SetFilter("Authentication Object ID", '=%1', AuthenticationObjectID);
            if UserProperty.FindFirst() then
                if User.Get(UserProperty."User Security ID") then begin
                    UserID := User."User Name";
                    exit(true);
                end;
        end;
        if NameIdentifier <> '' then begin
            UserProperty.SetFilter("Name Identifier", '=%1', NameIdentifier);
            if UserProperty.FindFirst() then
                if User.Get(UserProperty."User Security ID") then begin
                    UserID := User."User Name";
                    exit(true);
                end;
        end;
        if AuthenticationEmail <> '' then begin
            User.SetFilter("Authentication Email", '=%1', AuthenticationEmail);
            if User.FindFirst() then begin
                UserID := User."User Name";
                exit(true);
            end else
                exit(false)
        end else
            exit(false);
    end;

    procedure WarnUserMappingDoneBefore()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if not HybridCompanyStatus.Get() then
            exit;

        if not HybridCompanyStatus."User Mapping Completed" then
            exit;

        if not Confirm(StrSubstNo(UserMappingWasDoneContinueQst, HybridCompanyStatus."Last User Mapping DateTime")) then
            Error('');
    end;


    procedure UpdateSetupRecord()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        if not HybridCompanyStatus.Get() then
            HybridCompanyStatus.Insert();

        HybridCompanyStatus."Last User Mapping DateTime" := CurrentDateTime;
        HybridCompanyStatus."User Mapping Completed" := true;
        HybridCompanyStatus.Modify();
    end;
}

