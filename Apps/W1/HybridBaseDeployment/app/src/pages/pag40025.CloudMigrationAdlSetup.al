page 40025 "Cloud Migration ADL Setup"
{

    Caption = 'Azure Data Lake Migration Setup';
    AdditionalSearchTerms = 'adl,data lake,migration,data migration,cloud migration,intelligent,cloud,sync,replication';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;
    SourceTable = "Cloud Migration ADL Setup";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Banner1)
            {
                Editable = false;
                Visible = TopBannerVisible and not DoneVisible;
                ShowCaption = false;
                field(MediaResourcesStandard; MediaResources_Standard."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Banner2)
            {
                Editable = false;
                Visible = TopBannerVisible and DoneVisible;
                ShowCaption = false;
                field(MediaResourcesDone; MediaResources_Done."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Initial)
            {
                Visible = Step = Step::Initial;
                ShowCaption = false;

                group(Welcome)
                {
                    Caption = 'Welcome to the Azure Data Lake Migration Setup';
                    group(Welcome_1)
                    {
                        ShowCaption = false;
                        InstructionalText = 'This will enable you to migrate your on-premises Dynamics solution to your own Azure Data Lake storage account.';
                    }
                }

                group(Description)
                {
                    ShowCaption = false;

                    group(Description_1)
                    {
                        ShowCaption = false;
                        InstructionalText = 'If you don''t already have an Azure Data Lake storage account, you will need to first set one up. To learn more about Azure Data Lake, refer to the documentation using the link below.';

                        field(AdlInfo; MoreAdlInfoTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                Hyperlink(AdlInfoUrlTxt);
                            end;
                        }

                        field(PrivacyNotice; PrivacyNoticeTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                Hyperlink(PrivacyNoticeUrlTxt);
                            end;
                        }

#pragma warning disable AA0218
                        field(AcceptLegal; LegalAccepted)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'I accept warning & privacy notice';

                            trigger OnValidate()
                            begin
                                NextEnabled := LegalAccepted;
                            end;
                        }
#pragma warning restore                        
                    }
                }
            }

            group(Setup)
            {
                Visible = Step = Step::Setup;
                ShowCaption = false;

                group(StorageAccount)
                {
                    Caption = 'Connection Information';
                    InstructionalText = 'Enter the connection information for your Azure Data Lake storage account. This is where we''ll be moving all of your data.';

                    field("Storage Account Name"; Rec."Storage Account Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Tooltip = 'Specifies the name of your Azure Data Lake storage account.';

                        trigger OnValidate()
                        begin
                            NextEnabled := (Rec."Storage Account Name" <> '') and (Rec."Storage Account Key" <> '');
                        end;
                    }
                    field("Storage Account Key"; Rec."Storage Account Key")
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        HideValue = false;
                        ToolTip = 'Specifies the key to your Azure Data Lake storage account.';

                        trigger OnValidate()
                        begin
                            NextEnabled := (Rec."Storage Account Name" <> '') and (Rec."Storage Account Key" <> '');
                        end;
                    }
                }
            }

            group(Done)
            {
                Visible = Step = Step::Done;
                ShowCaption = false;

                group(AllDone)
                {
                    Caption = 'That''s It!';
                    InstructionalText = 'When you click finish, we will run a one-time data movement between your on-premises system and the Azure Data Lake storage account that you specified.';

                    group(WhatsNext)
                    {
                        ShowCaption = false;
                        InstructionalText = 'You will be able to monitor the progress of your Azure Data Lake movement on the Cloud Migration Management page. Once it''s finished, you can proceed with disabling the cloud migration.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                ToolTip = 'Back';
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
                Enabled = NextEnabled;
                Image = NextRecord;
                ToolTip = 'Next';
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;
                ToolTip = 'Finish';

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    HybridCloudManagement.RunAdlMigration(Rec);
                    Message(MigrationTriggeredMsg);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResources_Standard: Record "Media Resources";
        MediaResources_Done: Record "Media Resources";
        Step: Option Initial,Setup,Done;
        LegalAccepted: Boolean;
        TopBannerVisible: Boolean;
        DoneVisible: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        AdlMigrationNotAllowedErr: Label 'Azure Data Lake migration is not available. You must first set up the cloud migration for a supported on-premises ERP product.';
        MigrationInProgressErr: Label 'You may not start an Azure Data Lake migration while another migration is in progress.';
        MigrationTriggeredMsg: Label 'The Azure Data Lake migration has been started. You can view the progress on the Cloud Migration Management page.';
        MoreAdlInfoTxt: Label 'More about Azure Data Lake';
        PrivacyNoticeTxt: Label 'Privacy Notice';
        AdlInfoUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2135056', Locked = true;
        PrivacyNoticeUrlTxt: Label 'https://go.microsoft.com/fwlink/?LinkId=724009', Locked = true;

    local procedure NextStep(Backwards: Boolean)
    begin
        if (Step > 0) and Backwards then
            Step -= 1
        else
            Step += 1;

        case Step of
            Step::Initial:
                ShowInitialStep();
            Step::Setup:
                ShowSetupStep();
            Step::Done:
                ShowDoneStep();
        end;
    end;

    local procedure ShowInitialStep()
    begin
        NextEnabled := LegalAccepted;
        BackEnabled := false;
        FinishEnabled := false;
    end;

    local procedure ShowSetupStep()
    begin
        NextEnabled := (Rec."Storage Account Name" <> '') and (Rec."Storage Account Key" <> '');
        BackEnabled := true;
        FinishEnabled := false;
    end;

    local procedure ShowDoneStep()
    begin
        NextEnabled := false;
        BackEnabled := true;
        FinishEnabled := true;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResources_Standard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResources_Done.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResources_Done."Media Reference".HasValue();
    end;

    trigger OnOpenPage()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if not HybridCloudManagement.CanSetupAdlMigration() then
            Error(AdlMigrationNotAllowedErr);

        HybridReplicationSummary.SetRange(Status, HybridReplicationSummary.Status::InProgress);
        if not HybridReplicationSummary.IsEmpty() then
            Error(MigrationInProgressErr);

        Rec.Init();
        Rec.Insert();

        LoadTopBanners();
    end;
}