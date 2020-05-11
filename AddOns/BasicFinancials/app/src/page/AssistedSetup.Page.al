page 20600 "Assisted Setup BF"
{
    Caption = 'Basic Financials Assisted Setup';
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
                InstructionalText = 'The Basic Financials Extensions aligns the User Experience to the license limitations.';
            }
            field(DocumentationPart; 'For more information, see the documentation.')
            {
                ApplicationArea = Basic, Suite;
                Caption = ' ';
                ShowCaption = false;
                Editable = false;
                ToolTip = 'For more information, see the documentation.';
            }
            field(HelpLink; 'Basic Financials documentation')
            {
                ApplicationArea = Basic, Suite;
                Caption = ' ';
                ShowCaption = false;
                Editable = false;
                ToolTip = 'Basic Financials documentation';

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
            field(TermsOfUseLink; 'Basic Financials terms of use')
            {
                ApplicationArea = Basic, Suite;
                Caption = ' ';
                ShowCaption = false;
                Editable = false;
                ToolTip = 'Basic Financials terms of use';

                trigger OnDrillDown()
                begin
                    Hyperlink('https://go.microsoft.com/fwlink/?linkid=');
                end;
            }
            field(AcceptConsent; ConsentAccepted)
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                Caption = 'I understand and accept these terms';
                ToolTip = 'I understand and accept these terms';
            }
            field(IsSupportedLicenses; IsSupportedLicenses)
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
                Caption = 'Basic Financials license has been assigned';
                ToolTip = 'The Basic Financials Extension setup can only be completed, when at least one user has been assigned to a Basic Financials license';
                trigger OnValidate()
                var
                    BasicFinancialsMgmt: Codeunit "Basic Financials Mgmt BF";
                    NotSupportedLicensesErr: Label 'No user has been assigned to a Basic Financials license';
                begin
                    IsSupportedLicenses := BasicFinancialsMgmt.IsSupportedLicenses();
                    if not IsSupportedLicenses then
                        Error(NotSupportedLicensesErr);
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
                Enabled = ConsentAccepted and IsSupportedLicenses;
                Image = Close;
                InFooterBar = true;
                ToolTip = 'choose Finish to complete Basic Financials Assisted Setup';

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
        BasicFinancialsMgmt: Codeunit "Basic Financials Mgmt BF";
    begin
        IsSupportedLicenses := BasicFinancialsMgmt.IsSupportedLicense();
        AssistedSetup.Reset(PAGE::"Assisted Setup BF");
        IsComplete := AssistedSetup.IsComplete(PAGE::"Assisted Setup BF");
        ConsentAccepted := IsComplete;
    end;

    var
        IsComplete: Boolean;
        IsSupportedLicenses: Boolean;
        ConsentAccepted: Boolean;
}
