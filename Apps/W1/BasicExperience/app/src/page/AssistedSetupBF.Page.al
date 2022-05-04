page 20600 "Assisted Setup BF"
{
    Caption = 'Basic Experience Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            group(MediaStandard)
            {
                ShowCaption = false;
                Editable = false;
                Visible = TopBannerVisible;

                field(MediaResources; MediaResources."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(FirstPage)
            {
                Caption = '';
                Visible = TopBannerVisible;
                group("Welcome")
                {
                    Caption = 'Welcome to Basic Experience Setup';

                    group(Introduction)
                    {
                        Caption = '';
                        InstructionalText = 'The Basic Experience extension enables the subset of Business Central capabilities provided by the Basic license.';

                        field(DocumentationPart; 'For more information, see the documentation.')
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = ' ';
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Learn more';
                        }
                        field(HelpLink; 'Basic documentation')
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = ' ';
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Basic documentation';

                            trigger OnDrillDown()
                            begin
                                Hyperlink(DocLbl);
                            end;
                        }
                    }

                    group("Terms")
                    {
                        Caption = 'Terms of Use';

                        group(Terms1)
                        {
                            Caption = '';
                            InstructionalText = 'By enabling this extension you accept the terms of use. To enable the service you must read and accept the terms of use.';
                        }
                        field(TermsOfUseLink; 'Basic terms of use')
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = ' ';
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Basic terms of use';

                            trigger OnDrillDown()
                            begin
                                Hyperlink(TermsOfUseLbl);
                            end;
                        }
                    }
                    group(Terms3)
                    {
                        Caption = '';

                        field(AcceptConsent; ConsentAccepted)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = true;
                            Caption = 'I understand and accept the terms';
                            ToolTip = 'Acknowledge that you have read and accept the terms.';
                        }
                    }
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Finish")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = ConsentAccepted and HasBCBasicLicense;
                Image = Close;
                InFooterBar = true;
                ToolTip = 'Choose Finish to complete the Basic Experience setup.';

                trigger OnAction();
                var
                    GuidedExperience: Codeunit "Guided Experience";
                begin
                    FeatureTelemetry.LogUptake('0000H6Z', 'Basic Experience', Enum::"Feature Uptake Status"::"Set up");
                    GuidedExperience.CompleteAssistedSetup(ObjectType::Page, PAGE::"Assisted Setup BF");
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    var
        GuidedExperience: Codeunit "Guided Experience";
        BasicMgmt: Codeunit "Basic Mgmt BF";
    begin
        FeatureTelemetry.LogUptake('0000H70', 'Basic Experience', Enum::"Feature Uptake Status"::Discovered);
        HasBCBasicLicense := BasicMgmt.IsSupportedLicense();
        GuidedExperience.ResetAssistedSetup(ObjectType::Page, PAGE::"Assisted Setup BF");
        IsComplete := GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, PAGE::"Assisted Setup BF");
        ConsentAccepted := IsComplete;

        if not BasicMgmt.IsSupportedCompanies() then begin
            Notification.Message(NotSupportedCompanyMsg);
            Notification.Scope(NotificationScope::LocalScope);
            Notification.send();
        end;

        if not HasBCBasicLicense then begin
            Notification.Message(LicenseNotAssignedMsg);
            Notification.Scope(NotificationScope::LocalScope);
            Notification.send();
        end;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepository.GET('AssistedSetup-NoText-400px.png', FORMAT(CURRENTCLIENTTYPE))
      then
            if MediaResources.GET(MediaRepository."Media Resources Ref")
        then
                TopBannerVisible := MediaResources."Media Reference".HASVALUE;
    end;

    var
        MediaRepository: Record "Media Repository";
        MediaResources: Record "Media Resources";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Notification: Notification;
        TopBannerVisible: Boolean;
        IsComplete: Boolean;

        HasBCBasicLicense: Boolean;
        ConsentAccepted: Boolean;
        NotSupportedCompanyMsg: Label 'This extension is intended only for one company.';
        LicenseNotAssignedMsg: Label 'At least one user must have the Basic license assigned.';
        DocLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2130800', Locked = true;
        TermsOfUseLbl: Label ' https://go.microsoft.com/fwlink/?linkid=2130900', Locked = true;
}