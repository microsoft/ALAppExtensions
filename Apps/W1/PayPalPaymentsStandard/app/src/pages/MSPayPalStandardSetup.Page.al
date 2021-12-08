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
                    field(Name; Name)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the name of the PayPal account.';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies description for what this PayPal account is being used for.';
                    }
                    field("Account ID"; "Account ID")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the email or the Merchant account ID of the PayPal account';
                    }
                    field(Enabled; Enabled)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the payment service is enabled.';

                        trigger OnValidate();
                        var
                            EnvironmentInfo: Codeunit "Environment Information";
                            SetupNotification: Notification;
                            NotificationAllowed: Boolean;
                        begin
                            IF NOT Enabled THEN
                                EXIT;

                            NotificationAllowed := true;
                            OnBeforeShowPayPalNotification(NotificationAllowed);

                            IF NotificationAllowed AND EnvironmentInfo.IsOnPrem()
                            THEN BEGIN
                                SetupNotification.MESSAGE := EnableAPIForWebhooksMsg;
                                SetupNotification.SCOPE := NOTIFICATIONSCOPE::LocalScope;
                                SetupNotification.SEND();
                            END;

                            IF GuiAllowed() THEN
                                MESSAGE(ExchangeWithExternalServicesMsg);
                        end;
                    }
                    field("Always Include on Documents"; "Always Include on Documents")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if this PayPal account should be included on all of the Documents by default.';
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
                        SetTargetURL(InvoiceTargetURL);
                    end;
                }
                field("Terms of Service"; "Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = TermsOfServiceEditable;
                    ToolTip = 'Specifies PayPal terms of service.';

                    trigger OnAssistEdit();
                    begin
                        TermsOfServiceEditable := NOT TermsOfServiceEditable;
                    end;

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
            action(SetupTemplate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Setup Template';
                Image = Setup;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
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
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        InvoiceTargetURL := GetTargetURL();
    end;

    trigger OnOpenPage();
    var
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
        MSPayPalStandardTemplate.RefreshLogoIfNeeded();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        IF NOT Enabled THEN
            IF NOT CONFIRM(STRSUBSTNO(EnableServiceQst, CurrPage.CAPTION()), TRUE) THEN
                EXIT(FALSE);
        EXIT(TRUE);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowPayPalNotification(var NotificationAllowed: Boolean);
    begin
    end;

    var
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        InvoiceTargetURL: Text;
        TermsOfServiceEditable: Boolean;
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = pagecaption (OCR Service Setup)';
        EnableAPIForWebhooksMsg: Label 'PayPal Payment Standard has been enabled. To have invoice status updated to Paid when a customer has paid, contact your system administrator to enable API services.';
        ExchangeWithExternalServicesMsg: Label 'This extension uses a third-party payment service from PayPal. If you enable this extension, you will be subject to the terms, conditions, and privacy policies from PayPal.\\When you connect to PayPal through the PayPal Payments Standard extension, customer data from the invoice, such as the invoice number, due date, amount, and currency, as well as your PayPal account ID, will be inserted into the link to PayPal on invoices and sent to PayPal when the customer uses the link to pay the invoice. This data is used to ensure that the link contains enough information for your customers to pay the invoice, and for PayPal to identify you as the recipient of the payment.\\You also agree that you or your customers are accountable for any payments that are processed though this extension. Microsoft is not responsible for any payment disputes.';
}

