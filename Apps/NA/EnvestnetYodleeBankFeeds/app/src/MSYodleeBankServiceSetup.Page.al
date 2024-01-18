namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Environment;
using Microsoft.Foundation.Company;
using System.Telemetry;
using Microsoft.Bank.BankAccount;
using System.Security.Encryption;
using Microsoft.Utilities;

page 1450 "MS - Yodlee Bank Service Setup"
{
    Caption = 'Envestnet Yodlee Bank Feeds Service Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Page,Encryption,Bank';
    ShowFilter = false;
    SourceTable = "MS - Yodlee Bank Service Setup";
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Cobrand)
                {
                    Caption = 'Cobrand';
                    Visible = AdvancedView;
                    field(CobrandEnvironmentName; CobrandEnvName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cobrand Name';
                        Editable = EditableByNotEnabled;
                        ExtendedDatatype = Masked;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the cobrand name.';

                        trigger OnValidate();
                        begin
                            Rec.SaveCobrandEnvironmentName(Rec."Cobrand Environment Name", CobrandEnvName);
                            PreconfiguredCredentials := Rec.HasDefaultCredentials();
                        end;
                    }
                    field(CobrandName; CobrandLogin)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cobrand Login';
                        Editable = EditableByNotEnabled;
                        ExtendedDatatype = Masked;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the cobrand username.';

                        trigger OnValidate();
                        begin
                            Rec.SaveCobrandName(Rec."Cobrand Name", CobrandLogin);
                            PreconfiguredCredentials := Rec.HasDefaultCredentials();
                        end;
                    }
                    field(CobrandPwd; CobrandPassword)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cobrand Password';
                        Editable = EditableByNotEnabled;
                        ExtendedDatatype = Masked;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the cobrand password.';

                        trigger OnValidate();
                        begin
                            Rec.SaveCobrandPassword(Rec."Cobrand Password", CobrandPassword);
                            PreconfiguredCredentials := Rec.HasDefaultCredentials();
                        end;
                    }
                    field(DefaultCredentials; PreconfiguredCredentials)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Pre-configured Credentials';
                        Editable = false;
                        ToolTip = 'Specifies if the cobrand username and password are preconfigured by an administrator.';
                    }
                }
                group(Consumer)
                {
                    Caption = 'Consumer';
                    field("Consumer Name"; Rec."Consumer Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = ConsumerEditable;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the consumer username. If you leave the field blank, a username is created automatically.';
                    }
                    group(ConsumerAdvanced)
                    {
                        Visible = AdvancedView;
                        field(ConsumerPwd; ConsumerPassword)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Consumer Password';
                            Editable = EditableByNotEnabled;
                            ExtendedDatatype = Masked;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the consumer password.';

                            trigger OnValidate();
                            begin
                                Rec.SaveConsumerPassword(Rec."Consumer Password", ConsumerPassword);
                            end;
                        }
                    }
                    field("User Profile Email Address"; Rec."User Profile Email Address")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Consumer Email Address';
                        Editable = EditableByNotEnabled;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the email address that will be associated with the created consumer.';
                        Visible = UserProfileEmaiLAddressIsVisible;
                    }
                }
                group(Enabling)
                {
                    field("Log Web Requests"; Rec."Log Web Requests")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies if web request responses should be logged to the Activity Log table. This is normally only required for troubleshooting.';
                    }
                    field("Accept Terms of Use"; Rec."Accept Terms of Use")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = EditableByNotEnabled;
                        ToolTip = 'Specifies if you accept the terms of use for the Envestnet Yodlee Bank Feeds service.';

                        trigger OnValidate();
                        var
                            TempMSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup" temporary;
                        begin
                            if Rec."Accept Terms of Use" then begin
                                TempMSYodleeBankServiceSetup.COPY(Rec);
                                TempMSYodleeBankServiceSetup."Accept Terms of Use" := false;
                                TempMSYodleeBankServiceSetup.INSERT();

                                PAGE.RUNMODAL(PAGE::"MS - Yodlee Terms of use", TempMSYodleeBankServiceSetup);

                                TempMSYodleeBankServiceSetup.GET();
                                if not TempMSYodleeBankServiceSetup."Accept Terms of Use" then
                                    ERROR('');
                            end;
                        end;
                    }
                    field(Enabled; Rec.Enabled)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the service should be enabled.';

                        trigger OnValidate();
                        begin
                            ValidateEnabled();
                        end;
                    }
                    field(ShowEnableWarning; ShowServiceEnableWarning)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        Enabled = not EditableByNotEnabled;
                        ShowCaption = false;
                        ToolTip = 'Specifies that the service must be disabled to make changes.';

                        trigger OnDrillDown();
                        begin
                            DrilldownCode();
                        end;
                    }
                }
            }
            group(Service)
            {
                Caption = 'Service';
                Visible = AdvancedView;
                field("Service URL"; Rec."Service URL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the URL of the Envestnet Yodlee Bank Feeds service.';

                    trigger OnValidate();
                    begin
                        UpdateMaskedValues();
                    end;
                }
                field("Bank Acc. Linking URL"; Rec."Bank Acc. Linking URL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the URL of the Envestnet Yodlee Bank Account Linking page.';
                }
                field("Bank Feed Import Format"; Rec."Bank Feed Import Format")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ToolTip = 'Specifies the format that Envestnet Yodlee bank feeds are imported in.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SetDefaults)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Defaults';
                Enabled = EditableByNotEnabled;
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Set the default values for the Envestnet Yodlee Bank Feeds service.';

                trigger OnAction();
                var
                    MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
                begin
                    Rec.SetValuesToDefault();
                    Rec.SetDefaultBankStatementImportCode();

                    if not ISNULLGUID(Rec."Cobrand Name") then
                        MSYodleeBankServiceSetup.DeleteFromIsolatedStorage(Rec."Cobrand Name");

                    if not ISNULLGUID(Rec."Cobrand Password") then
                        MSYodleeBankServiceSetup.DeleteFromIsolatedStorage(Rec."Cobrand Password");

                    CLEAR(Rec."Cobrand Name");
                    CLEAR(Rec."Cobrand Password");
                    Rec.MODIFY(true);

                    AdvancedViewOnOpen := not Rec.HasDefaultCredentials();
                    AdvancedView := not Rec.HasDefaultCredentials();

                    CurrPage.UPDATE();
                end;
            }
            action(TestSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test Setup';
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Verify that the Envestnet Yodlee service has been configured correctly. A consumer account is automatically created when the service is enabled.';

                trigger OnAction();
                var
                    MSYodleeBankSession: Record "MS - Yodlee Bank Session";
                begin
                    MSYodleeBankSession.ResetSessionTokens();
                    Rec.CheckSetup();
                end;
            }
            action(ResetTokens)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reset Tokens';
                Image = ResetStatus;
                ToolTip = 'Reset any active session tokens.';

                trigger OnAction();
                var
                    MSYodleeBankSession: Record "MS - Yodlee Bank Session";
                begin
                    MSYodleeBankSession.ResetSessionTokens();
                end;
            }
            action(Disable)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Disable Service';
                Image = Delete;
                ToolTip = 'Stop using this service. Use this action only if something went wrong when you turned off the "Enabled" toggle.';

                trigger OnAction();
                var
                    MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
                    MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
                begin
                    if CONFIRM(RemoveConsumerOnDeleteQst, true) then begin
                        if MSYodleeServiceMgt.UnregisterConsumer() then
                            exit
                        else begin
                            Rec.DeletePassword(Rec."Cobrand Name");
                            Rec.DeletePassword(Rec."Cobrand Password");
                            Rec.DeletePassword(Rec."Consumer Password");
                            Rec.DeleteSessionTokens();

                            Rec.GET();
                            clear(Rec."Consumer Password");
                            clear(Rec."Consumer Name");
                            clear(Rec."Cobrand Name");
                            clear(Rec."Cobrand Password");
                            Rec.MODIFY(true);
                            Session.LogMessage('0000DXV', UserRemovedWithoutUnregisteringTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
                            MSYodleeBankAccLink.DELETEALL(true);
                            Rec.Enabled := false;
                            ValidateEnabled();
                        end;
                    end else
                        ERROR('');
                end;
            }
            action(ShowAdvancedSettings)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Advanced Settings';
                Enabled = not AdvancedView;
                Image = ViewDetails;
                ToolTip = 'Show all of the setup fields for the Envestnet Yodlee service.';
                Visible = not AdvancedViewOnOpen;

                trigger OnAction();
                begin
                    AdvancedView := not AdvancedView;
                end;
            }


        }
        area(navigation)
        {
            action(EncryptionManagement)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Encryption Management';
                Image = EncryptionKeys;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page "Data Encryption Management";
                RunPageMode = View;
                ToolTip = 'Configure encryption settings.';
            }
            action(ActivityLog)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Activity Log';
                Image = Log;
                ToolTip = 'View Envestnet Yodlee activities.';

                trigger OnAction();
                var
                    ActivityLog: Record "Activity Log";
                begin
                    ActivityLog.ShowEntries(Rec);
                end;
            }
            group("Data Exchange")
            {
                Caption = 'Data Exchange';
                action(ExportDataExchangeDefinition)
                {
                    ApplicationArea = Advanced;
                    Caption = 'Export Default Data Exchange Definition';
                    Image = Export;
                    ToolTip = 'Export the data exchange definition that is used to import Envestnet Yodlee bank feeds.';

                    trigger OnAction();
                    var
                        MSYodleeDataExchangeDef: Record "MS - Yodlee Data Exchange Def";
                    begin
                        MSYodleeDataExchangeDef.ExportDataExchDefinition();
                    end;
                }
                action(ResetDataExchangeDefinitionToDefault)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reset Data Exchange Definition to Default';
                    Image = Restore;
                    ToolTip = 'Use the default data exchange definition for the Envestnet Yodlee Bank Feeds service.';

                    trigger OnAction();
                    var
                        MSYodleeDataExchangeDef: Record "MS - Yodlee Data Exchange Def";
                    begin
                        MSYodleeDataExchangeDef.ResetDataExchToDefault();
                        Rec.ResetDefaultBankStatementImportFormat();
                        Rec.MODIFY();
                        CurrPage.UPDATE();
                    end;
                }
            }
            group(Bank)
            {
                Caption = 'Bank';
                action(BankAccounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = Page "Bank Account List";
                    RunPageMode = View;
                    ToolTip = 'View the bank accounts.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        EditableByNotEnabled := not Rec.Enabled;
        UpdateBasedOnEnable();
        UpdateMaskedValues();
    end;

    trigger OnOpenPage();
    var
        EnvironmentInformation: Codeunit "Environment Information";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GY3', 'Yodlee', Enum::"Feature Uptake Status"::Discovered);
        Rec.RESET();
        if not Rec.GET() then begin
            Rec.INIT();
            Rec.SetValuesToDefault();
            Rec.INSERT(true);
        end;
        UpdateBasedOnEnable();

        AdvancedViewOnOpen := not Rec.HasDefaultCredentials();
        AdvancedView := not Rec.HasDefaultCredentials();
        ConsumerEditable := AdvancedView and EditableByNotEnabled;
        UserProfileEmaiLAddressIsVisible := (not EnvironmentInformation.IsSaaS()) or CompanyInformationMgt.IsDemoCompany();
    end;

    var
        CobrandEnvName: Text[50];
        CobrandLogin: Text[50];
        CobrandPassword: Text[50];
        ConsumerPassword: Text[50];
        EditableByNotEnabled: Boolean;
        ConsumerEditable: Boolean;
        PreconfiguredCredentials: Boolean;
        AdvancedView: Boolean;
        AdvancedViewOnOpen: Boolean;
        ShowServiceEnableWarning: Text;
        EnabledWarningTok: Label 'You must disable the service before you can make changes.';
        DisableEnableQst: Label 'Do you want to disable the bank feed service?';
        RemoveConsumerOnDisableQst: Label 'Disabling the service will unlink all online bank accounts.\\Do you want to continue?';
        RemoveConsumerOnDeleteQst: Label 'Disabling the service will break all links from the service to online bank accounts.\\Do you want to continue?';
        YodleeTelemetryCategoryTok: Label 'AL Yodlee', Locked = true;
        UserRemovedWithoutUnregisteringTxt: Label 'Unregistering consumer didn''t work, and the user removed the user name without unregistering.', Locked = true;
        UserProfileEmaiLAddressIsVisible: Boolean;

    local procedure UpdateBasedOnEnable();
    begin
        EditableByNotEnabled := not Rec.Enabled;
        ConsumerEditable := AdvancedView and EditableByNotEnabled;
        ShowServiceEnableWarning := '';
        if CurrPage.EDITABLE() and Rec.Enabled then
            ShowServiceEnableWarning := EnabledWarningTok;
    end;

    local procedure UpdateMaskedValues();
    begin
        if Rec.HasPassword(Rec."Consumer Password") then
            ConsumerPassword := '*************'
        else
            ConsumerPassword := '';

        if Rec.HasCobrandPassword(Rec."Cobrand Password") then
            CobrandPassword := '*************'
        else
            CobrandPassword := '';

        if Rec.HasCobrandName(Rec."Cobrand Name") then
            CobrandLogin := '*************'
        else
            CobrandLogin := '';

        if Rec.HasCobrandEnvironmentName(Rec."Cobrand Environment Name") then
            CobrandEnvName := '*************'
        else
            CobrandEnvName := '';

        PreconfiguredCredentials := Rec.HasDefaultCredentials();
    end;

    local procedure DrilldownCode();
    begin
        if not Rec.Enabled then
            exit;

        if CONFIRM(DisableEnableQst, true) then begin
            Rec.VALIDATE(Enabled, false);
            ValidateEnabled();
        end;
    end;

    local procedure ValidateEnabled();
    var
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        EmptyGuid: Guid;
    begin
        if MSYodleeBankSession.GET() then begin
            MSYodleeBankSession."Cob. Token Last Date Updated" := 0DT;
            MSYodleeBankSession."Cons. Token Last Date Updated" := 0DT;
            CLEAR(MSYodleeBankSession."Cobrand Session Token");
            CLEAR(MSYodleeBankSession."Consumer Session Token");
            MSYodleeBankSession.MODIFY(true);
        end;

        if (not Rec.Enabled) and (Rec."Consumer Name" <> '') and Rec.HasPassword(Rec."Consumer Password") then
            if CONFIRM(RemoveConsumerOnDisableQst, true) then begin
                CurrPage.SAVERECORD(); // GET on this Rec is performed on UnregisterConsumer
                MSYodleeServiceMgt.SetDisableRethrowException(true);
                MSYodleeServiceMgt.UnregisterConsumer();
                Rec.GET();
            end else
                ERROR(''); // rollback & prevent disable

        if not Rec.Enabled then begin
            MSYodleeServiceMgt.UnlinkAllBankAccounts();
            if not Rec.HasPassword(Rec."Consumer Password") then begin
                Rec."Consumer Name" := '';
                if IsolatedStorage.Delete(Rec."Consumer Password", DataScope::Company) then;
                Rec."Consumer Password" := EmptyGuid;
                Rec.Modify();
            end;
        end;
        UpdateBasedOnEnable();
        Commit();
        CurrPage.UPDATE();
    end;
}

#pragma implicitwith restore

