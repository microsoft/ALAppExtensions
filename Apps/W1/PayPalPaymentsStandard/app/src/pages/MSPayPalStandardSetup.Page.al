namespace Microsoft.Bank.PayPal;

using Microsoft.Utilities;
using System.Environment;
using System.Telemetry;

page 1070 "MS - PayPal Standard Setup"
{
    SourceTable = "MS - PayPal Standard Account";
    Caption = 'PayPal Payments Standard Setup';
    DataCaptionExpression = '';
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Setup)
                {
                    field(Name; Rec.Name)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the name of the PayPal account.';
                    }
                    field(Description; Rec.Description)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies description for what this PayPal account is being used for.';
                    }
                    field("Account ID"; Rec."Account ID")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the email or the Merchant account ID of the PayPal account';
                    }
                    field(Enabled; Rec.Enabled)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the payment service is enabled.';

                        trigger OnValidate();
                        var
                            EnvironmentInfo: Codeunit "Environment Information";
                            MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                            SetupNotification: Notification;
                            NotificationAllowed: Boolean;
                        begin
                            if not Rec.Enabled then
                                exit;

                            NotificationAllowed := true;
                            OnBeforeShowPayPalNotification(NotificationAllowed);

                            if NotificationAllowed and EnvironmentInfo.IsOnPrem()
                            then begin
                                SetupNotification.MESSAGE := EnableAPIForWebhooksMsg;
                                SetupNotification.SCOPE := NOTIFICATIONSCOPE::LocalScope;
                                SetupNotification.SEND();
                            end;

                            MSPayPalStandardMgt.SendSendSetupWebhooksNotification();

                            if GuiAllowed() then
                                MESSAGE(ExchangeWithExternalServicesMsg);
                        end;
                    }
                    field("Always Include on Documents"; Rec."Always Include on Documents")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if this PayPal account should be included on all of the documents by default.';
                    }
                    field("Use Webhook Notifications"; UseWebhoookNotifications)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the PayPal payments should automatically be registered by using PayPal Webhook notifications. When the document is paid by using a PayPal link it will automatically be closed. The notifications can only be used with Business PayPal accounts.';
                        Caption = 'Register payments automatically';
                        trigger OnValidate()
                        begin
                            Rec.Validate(Rec."Disable Webhook Notifications", (not UseWebhoookNotifications));
                        end;
                    }
                }
                field(Logo; MSPayPalStandardTemplate.Logo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Logo';
                    ToolTip = 'Specifies Logo that should be included for this account on all invoices.';
                }
                field(TargetURL; InvoiceTargetURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target URL';
                    Importance = Additional;
                    MultiLine = true;
                    ToolTip = 'Specifies the target URL that will be opened when the customer chooses the link on the invoice.';

                    trigger OnValidate();
                    var
                        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                    begin
                        MSPayPalStandardMgt.ValidateChangeTargetURL();
                        Rec.SetTargetURL(InvoiceTargetURL);
                    end;
                }
                field("Terms of Service"; Rec."Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = TermsOfServiceEditable;
                    ToolTip = 'Specifies PayPal terms of service.';

                    trigger OnAssistEdit();
                    begin
                        TermsOfServiceEditable := not TermsOfServiceEditable;
                    end;

                    trigger OnDrillDown();
                    begin
                        HYPERLINK(Rec."Terms of Service");
                    end;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(SetupTemplate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Setup Template';
                Image = Setup;
                RunObject = Page "MS - PayPal Standard Template";
                RunPageOnRec = false;
                ToolTip = 'Opens Template Setup for all PayPal accounts.';
            }
            action(ActivityLog)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Activity Log';
                Image = Log;
                ToolTip = 'Log listing events for this PayPal account.';

                trigger OnAction();
                var
                    MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
                    ActivityLog: Record "Activity Log";
                    MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                begin
                    MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
                    ActivityLog.ShowEntries(MSPayPalStandardTemplate);
                end;
            }
            action(PaymentRegistratoinSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Registration Setup';
                Image = SetupPayment;
                ToolTip = 'Update Payment Registration setup. Payment Registration Setup is needed if you want to use webhooks to automatically close paid invoices.';
                trigger OnAction()
                var
                    MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                begin
                    MSPayPalStandardMgt.RunPaymentRegistrationSetupForce();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SetupTemplate_Promoted; SetupTemplate)
                {
                }
                actionref(ActivityLog_Promoted; ActivityLog)
                {
                }
                actionref(PaymentRegistratoinSetup_Promoted; PaymentRegistratoinSetup)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    var
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        InvoiceTargetURL := Rec.GetTargetURL();
        UseWebhoookNotifications := not Rec."Disable Webhook Notifications";
        if Rec.Enabled and (not UseWebhoookNotifications) then
            MSPayPalStandardMgt.SendSendSetupWebhooksNotification();
    end;

    trigger OnOpenPage();
    var
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000LHQ', MSPayPalStandardMgt.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered);
        MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
        MSPayPalStandardTemplate.RefreshLogoIfNeeded();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        if not Rec.Enabled then
            if not CONFIRM(STRSUBSTNO(EnableServiceQst, CurrPage.CAPTION()), true) then
                exit(false);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowPayPalNotification(var NotificationAllowed: Boolean);
    begin
    end;

    var
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        InvoiceTargetURL: Text;
        TermsOfServiceEditable: Boolean;
        UseWebhoookNotifications: Boolean;
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = pagecaption (OCR Service Setup)';
        EnableAPIForWebhooksMsg: Label 'PayPal Payment Standard has been enabled. To have invoice status updated to Paid when a customer has paid, contact your system administrator to enable API services.';
        ExchangeWithExternalServicesMsg: Label 'This extension uses a third-party payment service from PayPal. If you enable this extension, you will be subject to the terms, conditions, and privacy policies from PayPal.\\When you connect to PayPal through the PayPal Payments Standard extension, customer data from the invoice, such as the invoice number, due date, amount, and currency, as well as your PayPal account ID, will be inserted into the link to PayPal on invoices and sent to PayPal when the customer uses the link to pay the invoice. This data is used to ensure that the link contains enough information for your customers to pay the invoice, and for PayPal to identify you as the recipient of the payment.\\You also agree that you or your customers are accountable for any payments that are processed though this extension. Microsoft is not responsible for any payment disputes.';
}



