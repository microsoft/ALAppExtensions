page 4705 "VAT Group Setup Guide"
{
    Caption = 'VAT Group Management';
    PageType = NavigatePage;

    layout
    {
        area(Content)
        {
            group(ProgressBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible AND NOT DoneVisible;
                field(SetupBanner; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Setup Banner';
                }
            }
            group(DoneBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible AND DoneVisible;
                field(CompleteBanner; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Complete Banner';
                }
            }
            group(WelcomePage)
            {
                ShowCaption = false;
                Visible = Step = Step::Welcome;
                group(Welcome)
                {
                    Caption = 'Welcome';
                    InstructionalText = 'The VAT Group Management extension makes it easy to be part of a VAT group.';
                    label(WelcomeLabel)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'This guide will help you define member and representative companies in the VAT group. Group members submit VAT returns to the group representative, who then submits the aggregated return for all member companies to the tax authorities.';
                    }
                }
                group(LetsGo)
                {
                    Caption = 'Let''s get started';
                    InstructionalText = 'Choose Next to configure your company''s role in the VAT group.';
                }
            }
            group(SelectType)
            {
                ShowCaption = false;
                Visible = Step = Step::"Select Type";
                group(ChooseType)
                {
                    Caption = 'Choose your company''s role in the VAT group';
                    InstructionalText = 'The configuration settings depend on your role in the VAT group.';
                }
                field(VATGroupRole; VATGroupRole)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Group Role';
                    ToolTip = 'Specifies whether you are a member of the group, or the group''s representative.';
                    trigger OnValidate()
                    begin
                        ResetControls();
                    end;
                }
                group(NoVATGroupRole)
                {
                    Caption = 'No VAT group role specified';
                    InstructionalText = 'To continue, you must specify your role in the VAT group.';
                    Visible = VATGroupRole = VATGroupRole::" ";
                }
                group(RepresentativeDescription)
                {
                    Caption = 'Group representative';
                    InstructionalText = 'Choose this option to act as the group representative and submit vat returns on behalf of the group. Group members will submit their VAT returns to you instead of the tax authority.';
                    Visible = VATGroupRole = VATGroupRole::Representative;
                }
                group(MemberDescription)
                {
                    Caption = 'Group member';
                    InstructionalText = 'Choose this option to act as a group member and submit VAT your returns to the group representative instead of the tax authority.';
                    Visible = VATGroupRole = VATGroupRole::Member;
                }

            }
            group(RepresentativeSetup)
            {
                ShowCaption = false;
                Visible = Step = Step::"Setup Representative";
                group(RepresentativeSetupInfo)
                {
                    Caption = 'My company is the group representative';
                    InstructionalText = 'As the group representative you must define a list of approved group members who submit their VAT returns to you. You can manage group members on the VAT Report Setup page.';
                    label(RepresentativeSetupInfoMembers)
                    {
                        Caption = 'To add members, choose the number in the Approved Members field.';
                    }
                }
                field(ApprovedMembers; VATReportSetup."Approved Members")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Approved Members';
                    ToolTip = 'Specifies the number of approved members that are allowed to submit their VAT returns. Clicking on this number will open the Approved Members page.';
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"VAT Group Approved Member List");
                        VATReportSetup.CalcFields("Approved Members");
                    end;
                }
                field(GroupSettlementAccount; GroupSettlementAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Group Settlement Account';
                    ToolTip = 'Specifies the settlement account for the VAT group member amounts.';
                    TableRelation = "G/L Account";
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabledRepresentativeStep();
                    end;
                }
                field(VATSettlementAccount; VATSettlementAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Settlement Account';
                    ToolTip = 'Specifies the normal VAT settlement account.';
                    TableRelation = "G/L Account";
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabledRepresentativeStep();
                    end;
                }
                field(VATDueBoxNo; VATDueBoxNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Due Box No.';
                    ToolTip = 'Specifies the box that represents the total due VAT amount from a VAT Group Submission.';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabledRepresentativeStep();
                    end;
                }
                field(GroupSettlementGenJnlTempl; GroupSettleGenJnlTempl)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Group Settlement General Journal Template';
                    ToolTip = 'Specifies the general journal template used for the document to post the Group VAT to the settlement account.';
                    TableRelation = "Gen. Journal Template".Name;
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabledRepresentativeStep();
                    end;
                }
            }
            group(MemberSetup)
            {
                ShowCaption = false;
                Visible = Step = Step::"Setup Member";
                group(MemberSetupInfo)
                {
                    Caption = 'My company is a member of the VAT group';
                    InstructionalText = 'As a group member, you must connect to the representative company for your VAT group.';

                    label(MemberSetupInfoLabel)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Enter connection settings for the group representative company''s Business Central. Connection settings can differ, depending on how Business Central is deployed. The representative can provide this information.';
                    }
                }

                field(MemberGuid; MemberIdentifier)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Group Member Id';
                    ToolTip = 'Specifies the group member identifier.';
                    Editable = false;
                }
                field(GroupRepresentativeBCVersion; GroupRepresentativeBCVersion)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Group Representative Product Version';
                    ToolTip = 'Specifies the product version that the group representative uses.';
                }
                field(APIURL; APIURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'API URL';
                    ToolTip = 'Specifies the API URL of the representative company''s Business Central or Dynamics NAV.';
                    ExtendedDatatype = URL;
                    trigger OnValidate()
                    begin
                        NextEnabled := (APIURL <> '') and (GroupRepresentativeCompany <> '');
                    end;
                }
                field(GroupRepresentativeCompany; GroupRepresentativeCompany)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Group Representative Company';
                    ToolTip = 'Specifies the name of the company in the representative''s Business Central or Dynamics NAV that will receive your VAT returns.';
                    trigger OnValidate()
                    begin
                        NextEnabled := (APIURL <> '') and (GroupRepresentativeCompany <> '');
                    end;
                }
                group(OnPremAuth)
                {
                    ShowCaption = false;
                    Visible = not IsSaaS;
                    field(VATGroupAuthenticationType; VATGroupAuthenticationType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Authentication Type';
                        ToolTip = 'Specifies the authentication types that you can use when connecting to a VAT group representative using Business Central.';
                        trigger OnValidate()
                        begin
                            NextEnabled := (APIURL <> '') and (GroupRepresentativeCompany <> '');
                        end;
                    }
                }
                group(SaasAuth)
                {
                    ShowCaption = false;
                    Visible = IsSaaS;
                    field(VATGroupAuthenticationTypeSaas; VATGroupAuthenticationTypeSaas)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Authentication Type';
                        ToolTip = 'Specifies the authentication types that you can use when connecting to a VAT group representative using Business Central.';
                        trigger OnValidate()
                        begin
                            case VATGroupAuthenticationTypeSaas of
                                VATGroupAuthenticationTypeSaas::WebServiceAccessKey:
                                    VATGroupAuthenticationType := VATGroupAuthenticationType::WebServiceAccessKey;
                                VATGroupAuthenticationTypeSaas::OAuth2:
                                    VATGroupAuthenticationType := VATGroupAuthenticationType::OAuth2;
                            end;

                            NextEnabled := (APIURL <> '') and (GroupRepresentativeCompany <> '');
                        end;
                    }

                    field(GroupRepresentativeOnSaaS; GroupRepresentativeOnSaaS)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Group Representative Uses Business Central Online';
                        ToolTip = 'Specifies whether the group representative is using Business Central online.';
                        Editable = VATGroupAuthenticationType = VATGroupAuthenticationType::OAuth2;
                    }
                }
            }
            group(WebServiceAccessKeyAuthControl)
            {
                ShowCaption = false;
                Visible = Step = Step::"Setup Member WSAK";
                group(WSAKSetupInfo)
                {
                    Caption = 'Web service access key authentication';
                    InstructionalText = 'Please fill in the User Name and Web Service Access Key of the user in the group representative.';
                }
                field(Username; Username)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'User Name';
                    ToolTip = 'Specifies the user name in the representative company''s Business Central that you will use when you connect';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabled();
                    end;
                }
                field(WebServiceAccessKey; WebServiceAccessKey)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Web Service Access Key';
                    ToolTip = 'Specifies the web service access key of a user in the representative company''s Business Central that you will use when you connect.';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabled();
                    end;
                }
            }
            group(OAuth2control)
            {
                ShowCaption = false;
                Visible = (Step = Step::"Setup Member OAuth2") and (not GroupRepresentativeOnSaaS);

                group(OAuth2Info)
                {
                    Caption = 'OAuth2 details';
                    InstructionalText = 'Provide information about the App Registration in Azure Active Directory that will be used to connect with OAuth2.';
                }
                field(ClientId; ClientId)
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Caption = 'Client ID';
                    ToolTip = 'Specifies the client ID from the App Registration in Azure Active Directory.';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabled();
                    end;
                }
                field(ClientSecret; ClientSecret)
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret from the App Registration in Azure Active Directory.';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabled();
                    end;
                }
                field(OAuthAuthorityUrl; OAuthAuthorityUrl)
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = URL;
                    Caption = 'OAuth 2.0 Authority Endpoint';
                    ToolTip = 'Specifies the OAuth 2.0 authority endpoint of the App Registration in Azure Active Directory.';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabled();
                    end;
                }
                field(ResourceURL; ResourceURL)
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = URL;
                    Caption = 'OAuth 2.0 Resource URL';
                    ToolTip = 'Specifies the OAuth 2.0 resource URL of the API you will get access to in Azure Active Directory. For instance https://api.businesscentral.dynamics.com/';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabled();
                    end;
                }
                field(RedirectURL; RedirectURL)
                {
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = URL;
                    Caption = 'OAuth 2.0 Redirect URL';
                    ToolTip = 'Specifies the OAuth 2.0 redirect URL of the App Registration in Azure Active Directory.';
                    trigger OnValidate()
                    begin
                        NextEnabled := IsNextEnabled();
                    end;
                }
                group(OAuth2Finish)
                {
                    ShowCaption = false;
                    InstructionalText = 'Click Next to authenticate, get access to the group representative''s API and continue.';
                }
            }

            group(OAuth2controlSaaStoSaaS)
            {
                ShowCaption = false;
                Visible = (Step = Step::"Setup Member OAuth2") and GroupRepresentativeOnSaaS;
                group(OAuth2InfoSaaSToSaaS)
                {
                    Caption = 'Connect using OAuth2';
                    InstructionalText = 'Click Next to authenticate, get access to the group representative''s API and continue.';
                }

            }
            group(MemberVATReportSetup)
            {
                ShowCaption = false;
                Visible = Step = Step::"Setup VAT Report";
                group(VATReportConfigurationInfo)
                {
                    Caption = 'Select a VAT report configuration';
                    InstructionalText = 'Choose the VAT Report Configuration that is currently being used to send reports to the authorities. At the end of the setup we will create a new configuration based on the one chosen here which will be used to send VAT reports to the group representative.';
                }
                part(VATReportConfigurationPart; "VAT Reports Configuration Part")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Report Configurations';
                    SubPageLink = "VAT Report Version" = filter(<> 'VATGROUP'), "VAT Report Type" = filter("VAT Return");
                    Editable = false;
                }
            }
            group(FinishSetup)
            {
                ShowCaption = false;
                Visible = Step = Step::Finish;
                group(AllDone)
                {
                    Caption = 'All done';
                    InstructionalText = 'Click Finish to save the setup and exit the setup guide.';

                    group(AllDoneTestConnection)
                    {
                        Visible = TestConnectionVisible;
                        ShowCaption = false;
                        InstructionalText = 'To test the connection to the VAT group representative, choose Test Connection.';
                    }
                }
                group(EnableJobQueue)
                {
                    Visible = JobQueueVisible;
                    Caption = 'Automatically refresh VAT report statuses';
                    InstructionalText = 'If enabled this will automatically try to refresh the statuses of submitted VAT returns from the group representative if the submitted report was used in a VAT group report in that period.';
                    field("Enable JobQueue"; IsJobQueueEnabled)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Enable Automatic Refresh';
                        ToolTip = 'Specifies if you want to automatically update the status of the VAT reports with a background task.';
                    }
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test Connection';
                ToolTip = 'Initiates a test connection to the group master company in order to check if the authentication is correctly set up.';
                Visible = TestConnectionVisible;
                Image = InteractionTemplateSetup;
                InFooterBar = true;

                trigger OnAction()
                begin
                    TestConfigurationConnection();
                end;
            }
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                ToolTip = 'Go to previous page';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                ToolTip = 'Go to next page';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                var
                    VATGroupCommunication: Codeunit "VAT Group Communication";
                begin
                    if (Step = Step::"Setup Member OAuth2") and (VATGroupAuthenticationType = VATGroupAuthenticationType::OAuth2) then
                        VATGroupCommunication.GetBearerToken(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, ResourceURL);

                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                ToolTip = 'Finish the wizard';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ValidateAndFinishSetup();
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        VATReportSetup: Record "VAT Report Setup";
        ClientTypeManagement: Codeunit "Client Type Management";
        OAuth2: Codeunit OAuth2;
        Step: Option Welcome,"Select Type","Setup Representative","Setup Member","Setup Member WSAK","Setup Member OAuth2","Setup VAT Report",Finish;
        VATGroupRole: Enum "VAT Group Role";
        VATGroupAuthenticationType: Enum "VAT Group Authentication Type OnPrem";
        VATGroupAuthenticationTypeSaas: Enum "VAT Group Authentication Type Saas";
        NextEnabled, BackEnabled, FinishEnabled, TopBannerVisible, DoneVisible, JobQueueVisible, IsJobQueueEnabled, TestConnectionVisible, IsSaaS, GroupRepresentativeOnSaaS : Boolean;
        MemberIdentifier: Guid;
        [NonDebuggable]
        WebServiceAccessKey, APIURL, Username, ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, ResourceURL : Text[250];
        GroupSettlementAccount, VATSettlementAccount : Code[20];
        GroupSettleGenJnlTempl: Code[10];
        GroupRepresentativeCompany, VATDueBoxNo : Text[30];
        GroupRepresentativeBCVersion: Enum "VAT Group BC Version";
        NotSetUpQst: Label 'The setup for the VAT Group is not finished.\\Are you sure you want to exit?';
        NoVATReportSetupErr: Label 'The VAT report setup was not found. You can create one on the VAT Report Setup page.';
        CouldNotModifyVATReportSetupMsg: Label 'Could not save changes to the %1 table.', Comment = '%1 is the name of a table.';
        ConnectionWorkingMsg: Label 'The connection is working properly. You can now close the Setup Guide.';
        VATReportVersionTok: Label 'VATGROUP', Locked = true;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
    begin
        if not VATReportSetup.Get() then
            Error(NoVATReportSetupErr);

        VATReportSetup.CalcFields("Approved Members");
        GroupRepresentativeBCVersion := VATGroupHelperFunctions.GetVATGroupDefaultBCVersion();
        LoadTopBanners();
        ResetControls();
        MemberIdentifier := CreateGuid();

        IsSaaS := EnvironmentInformation.IsSaaSInfrastructure();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not (Step = Step::Finish) then
            if not Confirm(NotSetUpQst, false) then
                exit(false);
        SaveConfiguration();
        exit(true);
    end;

    local procedure ResetControls()
    begin
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := false;
        TestConnectionVisible := false;
        JobQueueVisible := false;
        DoneVisible := false;

        case Step of
            Step::Welcome:
                ShowWelcomeStep();
            Step::"Select Type":
                ShowSelectTypeStep();
            Step::"Setup Representative":
                ShowSetupRepresentativeStep();
            Step::"Setup Member":
                ShowSetupMemberStep();
            Step::"Setup Member WSAK":
                ShowSetupMemberWSAKStep();
            Step::"Setup Member OAuth2":
                ShowSetupMemberOAuth2Step();
            Step::Finish:
                ShowDoneStep();
        end;
        SaveConfiguration();
    end;

    local procedure NextStep(Backward: Boolean)
    begin
        if Backward then begin
            Step -= 1;
            if (Step = Step::"Setup VAT Report") and (VATGroupRole = VATGroupRole::Representative) then
                Step -= 3;
            if (Step = Step::"Setup Member") and (VATGroupRole = VATGroupRole::Representative) then
                Step -= 1;
            if (Step = Step::"Setup Representative") and (VATGroupRole = VATGroupRole::Member) then
                Step -= 1;
            if (Step = Step::"Setup Member WSAK") and (VATGroupAuthenticationType <> VATGroupAuthenticationType::WebServiceAccessKey) then
                Step -= 1;
            if (Step = Step::"Setup Member OAuth2") and (VATGroupAuthenticationType <> VATGroupAuthenticationType::OAuth2) then
                Step -= 2;
        end else begin
            Step += 1;
            if (Step = Step::"Setup Representative") and (VATGroupRole = VATGroupRole::Member) then
                Step += 1;
            if (Step = Step::"Setup Member") and (VATGroupRole = VATGroupRole::Representative) then
                Step += 3;
            if (Step = Step::"Setup Member WSAK") and (VATGroupAuthenticationType = VATGroupAuthenticationType::WindowsAuthentication) then
                Step += 2;
            if (Step = Step::"Setup Member WSAK") and (VATGroupAuthenticationType = VATGroupAuthenticationType::OAuth2) then
                Step += 1;
            if (Step = Step::"Setup Member OAuth2") and (VATGroupAuthenticationType = VATGroupAuthenticationType::WebServiceAccessKey) then
                Step += 1;
            if (Step = Step::"Setup VAT Report") and (VATGroupRole = VATGroupRole::Representative) then
                Step += 1;
        end;

        ResetControls();
    end;

    local procedure SaveConfiguration()
    begin
        VATReportSetup."VAT Group Role" := VATGroupRole;

        if VATGroupRole = VATGroupRole::Member then begin
            SaveMemberValues();
            CreateVATReportConfiguration();
            UpdateVATPeriodsReportVersion();
        end;

        if VATGroupRole = VATGroupRole::Representative then
            SaveRepresentativeValues();

        if not VATReportSetup.Modify() then begin
            Message(CouldNotModifyVATReportSetupMsg, VATReportSetup.TableCaption());
            exit;
        end;
    end;

    local procedure TestConfigurationConnection()
    var
        VATGroupCommunication: Codeunit "VAT Group Communication";
        QueryURL: Text;
        MemberId: Text;
        HttpResponseBodyText: Text;
    begin
        VATReportSetup.Get();
        MemberId := DelChr(VATReportSetup."Group Member Id", '=', '{|}');

        QueryURL := StrSubstNo(VATGroupCommunication.GetVATGroupSubmissionStatusEndpoint(), 'TestConnCode', MemberId);

        // it will throw an error if it fails so the jobqueue button won't be visible
        VATGroupCommunication.Send('GET', QueryURL, '', HttpResponseBodyText, false);

        // Re-enable when batch request is fixed
        // JobQueueVisible := true;
        Message(ConnectionWorkingMsg);
    end;

    local procedure ValidateAndFinishSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::page, Page::"VAT Group Setup Guide");
        if IsJobQueueEnabled then
            EnableJobQueueStatusUpdate();
    end;

    local procedure EnableJobQueueStatusUpdate()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // delete all the older rows
        JobQueueEntry.SetFilter("Object Type to Run", Format(JobQueueEntry."Object Type to Run"::Codeunit));
        JobQueueEntry.SetFilter("Object ID to Run", Format(Codeunit::"VAT Group Submission Status"));
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll();

        JobQueueEntry.InitRecurringJob(5);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"VAT Group Submission Status";
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry."Notify On Success" := false;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Rerun Delay (sec.)" := 60;
        JobQueueEntry.Description := 'Update VAT Group reports status';
        JobQueueEntry."Maximum No. of Attempts to Run" := 5; // TO DO CHECK HOW OFTEN

        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
    end;

    local procedure ShowWelcomeStep()
    begin
        BackEnabled := false;
    end;

    local procedure ShowSelectTypeStep()
    begin
        BackEnabled := true;
        if VATGroupRole = VATGroupRole::" " then begin
            FinishEnabled := true;
            NextEnabled := false;
            BackEnabled := false;
        end;
    end;

    local procedure ShowSetupRepresentativeStep()
    begin
        NextEnabled := IsNextEnabledRepresentativeStep();
        Clear(VATGroupAuthenticationType);
    end;

    local procedure ShowSetupMemberStep()
    begin
        NextEnabled := (APIURL <> '') and (GroupRepresentativeCompany <> '');
    end;

    local procedure ShowSetupMemberWSAKStep()
    begin
        NextEnabled := (Username <> '') and (WebServiceAccessKey <> '');
    end;

    [NonDebuggable]
    local procedure ShowSetupMemberOAuth2Step()
    var
        RedirectURLText: Text;
    begin
        if GroupRepresentativeOnSaaS then
            NextEnabled := true
        else begin
            OAuth2.GetDefaultRedirectURL(RedirectURLText);
            RedirectURL := CopyStr(RedirectURLText, 1, MaxStrLen(RedirectURL));
            NextEnabled := (ClientId <> '') and (ClientSecret <> '') and (OAuthAuthorityUrl <> '') and (ResourceURL <> '') and (RedirectURL <> '');
        end;
    end;

    local procedure ShowDoneStep()
    begin
        DoneVisible := true;
        FinishEnabled := true;
        NextEnabled := false;

        if VATGroupRole = VATGroupRole::Member then
            TestConnectionVisible := true;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    [NonDebuggable]
    local procedure SaveMemberValues()
    begin
        VATReportSetup."Group Representative Company" := GroupRepresentativeCompany;
        VATReportSetup."VAT Group BC Version" := GroupRepresentativeBCVersion;
        VATReportSetup."Group Representative API URL" := APIURL;
        VATReportSetup."Group Member ID" := MemberIdentifier;
        VATReportSetup."Authentication Type" := VATGroupAuthenticationType;
        VATReportSetup."User Name Key" := VATReportSetup.SetSecret(VATReportSetup."User Name Key", Username);
        VATReportSetup."Web Service Access Key Key" := VATReportSetup.SetSecret(VATReportSetup."Web Service Access Key Key", WebServiceAccessKey);
        VATReportSetup."Client ID Key" := VATReportSetup.SetSecret(VATReportSetup."Client ID Key", ClientId);
        VATReportSetup."Client Secret Key" := VATReportSetup.SetSecret(VATReportSetup."Client Secret Key", ClientSecret);
        VATReportSetup."Authority URL" := OAuthAuthorityUrl;
        VATReportSetup."Resource URL" := ResourceURL;
        VATReportSetup."Redirect URL" := RedirectURL;
        VATReportSetup."Group Representative On SaaS" := GroupRepresentativeOnSaaS;
    end;

    local procedure SaveRepresentativeValues()
    begin
        VATReportSetup."VAT Settlement Account" := VATSettlementAccount;
        VATReportSetup."Group Settlement Account" := GroupSettlementAccount;
        VATReportSetup."VAT Due Box No." := VATDueBoxNo;
        VATReportSetup."Group Settle. Gen. Jnl. Templ." := GroupSettleGenJnlTempl;
    end;

    local procedure CreateVATReportConfiguration()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        CurrPage.VATReportConfigurationPart.Page.GetRecord(VATReportsConfiguration);
        VATReportsConfiguration."Submission Codeunit ID" := Codeunit::"VAT Group Submit To Represent.";
        VATReportsConfiguration."VAT Report Version" := VATReportVersionTok;
        if VATReportsConfiguration.Get(VATReportsConfiguration."VAT Report Type", VATReportsConfiguration."VAT Report Version") then
            VATReportsConfiguration.Modify()
        else
            VATReportsConfiguration.Insert();
    end;

    local procedure UpdateVATPeriodsReportVersion()
    begin
        VATReportSetup."Report Version" := VATReportVersionTok;
    end;

    local procedure IsNextEnabled(): Boolean
    begin
        if VATGroupAuthenticationType = VATGroupAuthenticationType::WebServiceAccessKey then
            exit((APIURL <> '') and (GroupRepresentativeCompany <> '') and (WebServiceAccessKey <> '') and (Username <> ''));

        if VATGroupAuthenticationType = VATGroupAuthenticationType::OAuth2 then
            exit((APIURL <> '') and (GroupRepresentativeCompany <> '') and (ClientId <> '') and (ClientSecret <> '') and (RedirectURL <> '') and (ResourceURL <> '') and (OAuthAuthorityUrl <> ''));
    end;

    local procedure IsNextEnabledRepresentativeStep(): Boolean
    begin
        exit((VATSettlementAccount <> '') and (GroupSettlementAccount <> '') and (GroupSettleGenJnlTempl <> '') and (VATDueBoxNo <> ''));
    end;
}