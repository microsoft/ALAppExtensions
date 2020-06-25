page 20600 "Assisted Setup BF"
{
    Caption = 'Basic Assisted Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            label(Title)
            {
                Caption = 'Welcome';
                Style = StandardAccent;
                ApplicationArea = All;
            }
            group(Instructional)
            {
                Caption = ' ';
                InstructionalText = 'The Basic extension enables the subset Dynamics 365 Business Central capabilities provided by the Basic license.';
            }
            field(DocumentationPart; 'For more information, see the documentation.')
            {
                ApplicationArea = Basic, Suite;
                Caption = ' ';
                ShowCaption = false;
                Editable = false;
                ToolTip = 'For more information, see the documentation.';
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
            field(ConsentPart; 'To enable the service you must read and accept the terms of use.')
            {
                ApplicationArea = Basic, Suite;
                Caption = ' ';
                ShowCaption = false;
                Editable = false;
                ToolTip = 'By enabling this extension you accept the terms of use. To enable the service you must read and accept the terms of use.';
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
            field(AcceptConsent; ConsentAccepted)
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                Caption = 'I understand and accept the terms';
                ToolTip = 'Acknowledge that you have read and accept the terms.';
            }
            /* Temporarily removed due to issue regarding License check
            field(IsSupportedLicenses; IsSupportedLicenses)
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
                    IsSupportedLicenses := BasicMgmt.IsSupportedLicense();
                    if not IsSupportedLicenses then
                        Error(NotSupportedLicensesErr);
                end;
            }
            */
            field(IsSupportedCompanies; IsSupportedCompanies)
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                Caption = 'One company exists in the environment';
                ToolTip = 'To complete the Basic setup there must exists exactly one company in the environment.';
                trigger OnValidate()
                var
                    BasicMgmt: Codeunit "Basic Mgmt BF";
                    NotSupportedCompaniesErr: Label 'Exactly one company must exists in the environment.';
                begin
                    IsSupportedCompanies := BasicMgmt.IsSupportedCompanies();
                    if not IsSupportedCompanies then
                        Error(NotSupportedCompaniesErr);
                end;
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
                //>> Temporarily modified due to issue regarding License check
                //Enabled = ConsentAccepted and IsSupportedLicenses and IsSupportedCompanies;
                Enabled = ConsentAccepted and IsSupportedCompanies;
                //<< Temporarily modified due to issue regarding License check
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

    trigger OnOpenPage()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        BasicMgmt: Codeunit "Basic Mgmt BF";
    begin
        IsSupportedCompanies := BasicMgmt.IsSupportedCompanies();
        //IsSupportedLicenses := BasicMgmt.IsSupportedLicense(); // Temporarily removed due to issue regarding License check
        AssistedSetup.Reset(PAGE::"Assisted Setup BF");
        IsComplete := AssistedSetup.IsComplete(PAGE::"Assisted Setup BF");
        ConsentAccepted := IsComplete;
    end;

    var
        IsComplete: Boolean;
        IsSupportedCompanies: Boolean;
        //IsSupportedLicenses: Boolean; // Temporarily modified due to issue regarding License check
        ConsentAccepted: Boolean;
}
