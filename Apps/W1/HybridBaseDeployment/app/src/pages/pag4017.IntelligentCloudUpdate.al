page 4017 "Intelligent Cloud Update"
{
    Caption = 'Cloud Migration Update';
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            group(Banner1)
            {
                Editable = false;
                Visible = TopBannerVisible;
                ShowCaption = false;
                field(MediaResourcesStandard; MediaResources_Standard."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(IntelligentCloudUpdateInfo)
            {
                ShowCaption = false;
                Visible = UpdateVisible;

                group("Para1.1")
                {
                    Caption = 'Welcome To Cloud Migration Update';

                    group("Para1.1.1")
                    {
                        Caption = '';
                        InstructionalText = 'This process will update your Cloud Migration environment to the latest version.';

#pragma warning disable AA0218, AA0225
                        field(UpdateICInfo; StrSubstNo(VersionTxt, DeployedVersion, LatestVersion))
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = '';
                        }
#pragma warning restore
                        field(ProcessUpdateTxt; PleaseWaitTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionUpdate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update';
                ToolTip = 'Update your cloud migration environment.';
                Image = Approve;
                InFooterBar = true;
                Enabled = IsSuperAndSetupComplete and (DeployedVersion <> LatestVersion);
                Visible = not IsOnPrem;

                trigger OnAction()
                begin
                    HybridDeployment.RunUpgrade();
                    Message(UpdateReplicationTxt);
                    IntelligentCloudSetup.UpdateDeployedToLatest();
                    CurrPage.Close();
                end;
            }

            action(ActionCancel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cancel';
                ToolTip = 'Cancel';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit()
    var
        PermissionManager: Codeunit "Permission Manager";
        UserPermissions: Codeunit "User Permissions";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        UpdateVisible := true;
        IsSuperAndSetupComplete := PermissionManager.IsIntelligentCloud() and UserPermissions.IsSuper(UserSecurityId());
        IsOnPrem := NOT EnvironmentInformation.IsSaaS();

        if not IsSuperAndSetupComplete then
            Error(RunUpdatePermissionErr);

        if IntelligentCloudSetup.Get() then
            HybridDeployment.Initialize(IntelligentCloudSetup."Product ID");

        LoadTopBanners();

        HybridDeployment.GetVersionInformation(DeployedVersion, LatestVersion);
        IntelligentCloudSetup.SetLatestVersion(LatestVersion);
    end;

    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResources_Standard: Record "Media Resources";
        ClientTypeManagement: Codeunit "Client Type Management";
        HybridDeployment: Codeunit "Hybrid Deployment";
        VersionTxt: Label 'You are currently running version %1. The latest available version is %2.', Comment = '%1 - the current version, %2 - the new version';
        PleaseWaitTxt: Label 'This can take a few minutes to complete.';
        UpdateReplicationTxt: Label 'The update has completed successfully.';
        RunUpdatePermissionErr: Label 'You do not have permissions to run this update. Please contact your system administrator to update your Cloud Migration environment.';
        IsSuperAndSetupComplete: Boolean;
        IsOnPrem: Boolean;
        TopBannerVisible: Boolean;
        DeployedVersion: Text;
        LatestVersion: Text;
        UpdateVisible: Boolean;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType())) then
            TopBannerVisible := MediaResources_Standard.GET(MediaRepositoryStandard."Media Resources Ref");
    end;
}