page 20101 "AMC Banking Setup"
{
    AdditionalSearchTerms = 'bank file import,bank file export,bank transfer,amc,bank service setup,bank data conversion';
    ApplicationArea = Basic, Suite;
    Caption = 'AMC Banking Setup';
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Page,Sign-up,Assisted setup,Bank Name,Encryption,Support';
    SourceTable = "AMC Banking Setup";
    UsageCategory = Administration;
    ContextSensitiveHelpPage = '300';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Enabled; Rec."AMC Enabled")
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether the AMC Banking 365 Fundamentals feature is enabled.';
                    ApplicationArea = Basic, Suite;
                }
                group(User)
                {
                    Caption = 'User information';
                    field("User Name"; "User Name")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the user name that represents your company''s sign-up for the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files.';
                    }
                    field(Password; PasswordText)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Password';
                        Editable = CurrPageEditable;
                        ExtendedDatatype = Masked;
                        ShowMandatory = true;
                        ToolTip = 'Specifies your company''s password to the service that converts bank data to the format required by your bank. The password that you enter in the Password field must be the same as on the service provider''s sign-on page.';

                        trigger OnValidate()
                        begin
                            SavePassword(PasswordText);
                            Commit();
                            if PasswordText <> '' then
                                CheckEncryption();
                        end;
                    }
                }

                group(SolutionLicense)
                {
                    Caption = 'Solution information';
                    group(SolutionGrp)
                    {
                        Caption = '';
                        field("Solution"; "Solution")
                        {
                            ApplicationArea = Suite;
                            Visible = true;
                            Enabled = false;
                            ToolTip = 'Specifies a customizable calendar for bank''s that holds the bank''s working days and holidays. Choose the field to select another bank calendars or to set up a customized calendar.';
                        }
                    }
                    Group(LicenseGrp)
                    {
                        Caption = '';
                        field("BCLicenseNumber"; BCLicenseNumberText)
                        {
                            ApplicationArea = Basic, Suite;
                            Visible = true;
                            Enabled = true;
                            Editable = false;
                            AssistEdit = true;
                            Caption = 'License';
                            ToolTip = 'License number of Business Central for AMC Banking';
                            trigger OnAssistEdit()
                            begin
                                if CurrPage.Editable() then
                                    if CONFIRM(StrSubstNo(CopyBCLicenseQst, BCLicenseNumberText)) then
                                        "User Name" := CopyStr(BCLicenseNumberText, 1, 50);
                            end;
                        }
                    }
                }
            }
            group(Service)
            {
                Caption = 'Service';
                field("Service URL"; "Service URL")
                {
                    Editable = EditUrlAllowed;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files. The service specified in the Service URL field is called when users export or import bank files.';
                    trigger OnDrillDown()
                    begin
                        Rec.Modify();
                        AMCBankServiceRequestMgt.ShowServiceLinkPage('myaccount', true);
                    end;
                }
                field("Namespace API Version"; "Namespace API Version")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default namespace for the AMC Banking.';
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(SignUp)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sign-up here';
                Image = SignUp;
                Promoted = true;
                ToolTip = 'Calls the sign-up page for the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files. This is the web page where you enter your company''s user name and password to sign up for the service.';
                PromotedCategory = Category4;
                PromotedOnly = true;
                trigger OnAction();
                begin
                    PAGE.RunModal(Page::"AMC Bank Signup to Service");
                end;
            }
        }
        area(processing)
        {
            action(AMCAssistedSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Assisted Setup';
                ToolTip = 'Runs Service setup wizard';
                Visible = true;
                Enabled = true;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;

                trigger OnAction()
                var
                begin
                    PAGE.RunModal(PAGE::"AMC Bank Assisted Setup", Rec);
                end;
            }
        }
        area(navigation)
        {
            action(BankList)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Name List';
                Image = ListPage;
                Promoted = true;
                PromotedCategory = Category6;
                RunObject = Page "AMC Bank Bank Name List";
                RunPageMode = View;
                ToolTip = 'View or update the list of banks in your country/region that you can use to import or export bank account data using the AMC Banking.';
            }
            action(EncryptionManagement)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Encryption Management';
                Image = EncryptionKeys;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedIsBig = true;
                RunObject = Page "Data Encryption Management";
                RunPageMode = View;
                ToolTip = 'Enable or disable data encryption. Data encryption helps make sure that unauthorized users cannot read business data.';
            }
            action(ActivityLog)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Activity Log';
                Image = Log;
                ToolTip = 'View AMC Banking 365 service activities.';

                trigger OnAction();
                var
                    ActivityLog: Record "Activity Log";
                    DataTypeManagement: Codeunit "Data Type Management";
                    RecRef: RecordRef;
                begin
                    IF DataTypeManagement.GetRecordRef(Rec, RecRef) THEN BEGIN
                        ActivityLog.SETRANGE(ActivityLog."Record ID", RecRef.RECORDID());
                        PAGE.RUNMODAL(PAGE::"AMC Bank Webcall Log", ActivityLog);
                    END;
                end;
            }
            action(Support)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Get support';
                Image = OnlineHelp;
                Promoted = true;
                ToolTip = 'Calls the web site where the provider of the AMC Banking publishes status and support information about the service.';
                PromotedCategory = Category8;
                trigger OnAction();
                begin
                    Hyperlink("Support URL");
                end;
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPageEditable := CurrPage.Editable();
        EditUrlAllowed := not AMCBankingMgt.IsSolutionSandbox(Rec);
        if Rec.HasPassword() then
            PasswordText := 'Password Dots';
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000H4M', 'AMC Banking 365 Fundamentals', Enum::"Feature Uptake Status"::"Set up");
        CheckedEncryption := false;
        if not Get() then begin
            Init();
            Insert(true);
        end;
        BCLicenseNumberText := AMCBankingMgt.GetLicenseNumber();
    end;

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankServiceRequestMgt: codeunit "AMC Bank Service Request Mgt.";
        [NonDebuggable]
        PasswordText: Text[50];
        CheckedEncryption: Boolean;
        CopyBCLicenseQst: Label 'Do you want to copy the License %1 to the User name field?', Comment = '%1=BC License Number';
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management page?';
        CurrPageEditable: Boolean;
        BCLicenseNumberText: Text;
        EditUrlAllowed: Boolean;

    local procedure CheckEncryption()
    begin
        if not CheckedEncryption and not EncryptionEnabled() then begin
            CheckedEncryption := true;
            if Confirm(EncryptionIsNotActivatedQst) then begin
                PAGE.Run(PAGE::"Data Encryption Management");
                CheckedEncryption := false;
            end;
        end;
    end;


}

