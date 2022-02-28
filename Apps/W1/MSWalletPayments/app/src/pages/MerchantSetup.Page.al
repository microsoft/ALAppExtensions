#if not CLEAN20
page 1080 "MS - Wallet Merchant Setup"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Caption = 'Microsoft Pay Payments Setup';
    DataCaptionExpression = Description;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "MS - Wallet Merchant Account";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Setup)
                {
                    field(Name; Name)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Specifies the name of the Microsoft Pay Payments account.';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Specifies description of what this Microsoft Pay Payments merchant account is being used for.';
                    }
                    field("Merchant ID"; "Merchant ID")
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the Merchant ID of the Microsoft Pay Payments merchant account';
                    }
                    field(Enabled; Enabled)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the payment service is enabled.';

                        trigger OnValidate();
                        var
                            MSWalletMgt: Codeunit "MS - Wallet Mgt.";
                        begin
                            if Enabled then begin
                                MESSAGE(MSWalletMgt.GetDeprecationMessageNotification());
                                MESSAGE(ExchangeWithExternalServicesMsg);
                            end;

                        end;
                    }
                    field("Always Include on Documents"; "Always Include on Documents")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if this Microsoft Pay Payments merchant account should be included on all of the documents by default.';
                    }
                    field("Test Mode"; "Test Mode")
                    {
                        ApplicationArea = Invoicing;
                        ToolTip = 'Specifies if test mode is enabled. If you send invoices and get payments in test mode, no actual money transfer will be made.';
                        Visible = IsInvApp;
                    }
                }
                field(Logo; MSWalletMerchantTemplate.Logo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Logo';
                    Editable = false;
                    ToolTip = 'Specifies the logo that should be included for this account on all invoices.';
                }
                field("Terms of Service"; "Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies Microsoft Pay Payments terms of service.';

                    trigger OnDrillDown();
                    begin
                        HYPERLINK("Terms of Service");
                    end;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(GetMerchantID)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Merchant Account Setup...';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Opens a link to sign up for merchant ID';

                trigger OnAction();
                var
                    MSWalletMerchantMgt: Codeunit "MS - Wallet Merchant Mgt";
                begin
                    MSWalletMerchantMgt.StartMerchantOnboardingExperience("Primary Key", MSWalletMerchantTemplate);
                    MSWalletMerchantTemplate.RefreshLogoIfNeeded();
                end;
            }
            action(ActivityLog)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Activity Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                ToolTip = 'Log listing events for this Microsoft Pay Payments merchant account.';

                trigger OnAction();
                var
                    MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template";
                    ActivityLog: Record "Activity Log";
                    MSWalletMgt: Codeunit "MS - Wallet Mgt.";
                begin
                    MSWalletMgt.GetTemplate(MSWalletMerchantTemplate);
                    ActivityLog.ShowEntries(MSWalletMerchantTemplate);
                end;
            }

            group(Mode)
            {
                Caption = 'Account Mode';
                action(SetLiveMode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set Live Mode';
                    Image = Apply;
                    Enabled = "Test Mode";
                    ToolTip = 'Reset to live mode. This means that an actual money transfer will be made when you pay an invoice.';
                    trigger OnAction();
                    begin
                        if Confirm(LiveModeChangeConfirmQst) then begin
                            "Test Mode" := false;
                            CurrPage.Update();
                        end;
                    end;
                }
                action(SetTestMode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set Test Mode';
                    Image = UnApply;
                    Enabled = (NOT "Test Mode");
                    ToolTip = 'Set to test mode. This allows you to send invoices and pay them in test mode where no actual money transfers will be made.';
                    trigger OnAction();
                    begin
                        if Confirm(TestModeChangeConfirmQst) then begin
                            "Test Mode" := true;
                            CurrPage.Update();
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        MSWalletMerchantTemplate.RefreshLogoIfNeeded();
    end;

    trigger OnDeleteRecord(): Boolean;
    begin
        DisableEnableConfirm := TRUE;
        EXIT(TRUE);
    end;

    trigger OnOpenPage();
    var
        MSWalletMgt: Codeunit "MS - Wallet Mgt.";
        EnvInfoProxy: Codeunit "Env. Info Proxy";
    begin
        MSWalletMgt.GetTemplate(MSWalletMerchantTemplate);
        MSWalletMerchantTemplate.RefreshLogoIfNeeded();
        MSWalletMgt.SendDeprecationNotification(MSWalletMerchantTemplate.RecordId());

        IsInvApp := EnvInfoProxy.IsInvoicing();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        IF (NOT Enabled) AND (NOT DisableEnableConfirm) THEN
            IF NOT CONFIRM(EnableServiceQst, TRUE) THEN
                EXIT(FALSE);
    end;

    var
        MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template";
        EnableServiceQst: Label 'Microsoft Pay Payments Account Setup is not enabled. Are you sure you want to exit?';
        TestModeChangeConfirmQst: Label 'Changing the account setup to Test Mode will make you unable to accept Live Mode payments through Microsoft Pay Payments.\\Do you want to continue?';
        LiveModeChangeConfirmQst: Label 'Changing the account setup to Live Mode will make you unable to accept Test Mode payments through Microsoft Pay Payments.\\Do you want to continue?';
        ExchangeWithExternalServicesMsg: Label 'This extension uses the Microsoft Pay Payments service. By enabling this extension, you will be subject to the applicable terms, conditions, and privacy policies that Microsoft Pay Payments may make available.\\When you establish a connection through the Microsoft Pay Payments extension, customer data from the invoice, such as invoice number, due date, amount, and currency, as well as your Microsoft Pay Payments account ID, will be inserted into the Microsoft Pay Payments payment link on invoices and sent to Microsoft Pay Payments when the customer chooses the link to pay. This data is used to ensure that the link contains enough information for your customers to pay the invoice, as well as for Microsoft Pay Payments to identify you as the recipient of a payment using the link.\\By installing this solution, you agree for this limited set of data to be sent to the Microsoft Pay Payments service. Note that you can disable or uninstall the Microsoft Pay Payments extension at any time to discontinue the functionality.';
        DisableEnableConfirm: Boolean;
        IsInvApp: Boolean;
}
#endif