page 20600 "Assisted Setup BF"
{
    Caption = 'Basic Assisted Setup guide';
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
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible;

                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(FirstPage)
            {
                Caption = '';

                group("Welcome")
                {
                    Caption = 'Welcome';

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
                                Hyperlink('https://go.microsoft.com/fwlink/?linkid=');
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
                                Hyperlink('https://go.microsoft.com/fwlink/?linkid=');
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
                        /* Temporarily removed due to issue regarding License check
                        field(HasBCBasicLicense; HasBCBasicLicense)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = true;
                            Caption = 'Basic license has been assigned';
                            ToolTip = 'To complete the Basic setup the Basic license must be assigned to at least one user.';
                            trigger OnValidate()
                            var
                                BasicMgmt: Codeunit "Basic Mgmt BF";
                                NotSupportedLicensesErr: Label 'At least one user must have the Basic license.';
                            begin
                                HasBCBasicLicense := BasicMgmt.IsSupportedLicense();
                                if not HasBCBasicLicense then
                                    Error(NotSupportedLicensesErr);
                            end;
                        }
                        */
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
                Enabled = ConsentAccepted;
                Image = Close;
                InFooterBar = true;
                ToolTip = 'Choose Finish to complete the Basic assisted setup guide.';

                trigger OnAction();
                var
                    AssistedSetup: Codeunit "Assisted Setup";
                begin
                    AssistedSetup.Complete(PAGE::"Assisted Setup BF");
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
        AssistedSetup: Codeunit "Assisted Setup";
        BasicMgmt: Codeunit "Basic Mgmt BF";
    begin
        //HasBCBasicLicense  := BasicMgmt.IsSupportedLicense(); // Temporarily removed due to issue regarding License check
        AssistedSetup.Reset(PAGE::"Assisted Setup BF");
        IsComplete := AssistedSetup.IsComplete(PAGE::"Assisted Setup BF");
        ConsentAccepted := IsComplete;

        if not BasicMgmt.IsSupportedCompanies() then begin
            Notification.Message(NotSupportedCompanyMsg);
            Notification.Scope(NotificationScope::LocalScope);
            Notification.send();
        end;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CURRENTCLIENTTYPE))
      then
            if MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref")
        then
                TopBannerVisible := MediaResourcesStandard."Media Reference".HASVALUE;
    end;

    var
        Notification: Notification;
        MediaRepositoryStandard: Record 9400;
        MediaResourcesStandard: Record 2000000182;
        TopBannerVisible: Boolean;
        IsComplete: Boolean;

        //HasBCBasicLicense: Boolean; // Temporarily removed due to issue regarding License check
        ConsentAccepted: Boolean;
        NotSupportedCompanyMsg: Label 'This extension is intended only for one company.';
}