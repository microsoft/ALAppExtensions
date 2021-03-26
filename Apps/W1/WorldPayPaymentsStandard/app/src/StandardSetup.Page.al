page 1360 "MS - WorldPay Standard Setup"
{
    Caption = 'WorldPay Payments Standard Setup';
    DataCaptionExpression = '';
    InsertAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    PageType = Card;
    SourceTable = "MS - WorldPay Standard Account";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Nested)
                {
                    field(Name; Name)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the name of the WorldPay account.';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies a description of what this WorldPay account is used for.';
                    }
                    field("Account ID"; "Account ID")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the email or the merchant account ID of the WorldPay account.';

                        trigger OnValidate()
                        begin
                            VALIDATE("Account ID", DELCHR("Account ID", '<>'));
                        end;
                    }
                    field(Enabled; Enabled)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if the payment service is enabled.';

                        trigger OnValidate()
                        begin
                            // If we transition from disabled to enabled state
                            // show 3rd party notice message
                            IF NOT xRec.Enabled AND Enabled THEN
                                MESSAGE(ThirdPartyNoticeMsg);
                        end;
                    }
                    field("Always Include on Documents"; "Always Include on Documents")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to make this WorldPay account available on all documents.';
                    }
                }
                field(Logo; MSWorldPayStdTemplate.Logo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Logo';
                    Editable = false;
                    ToolTip = 'Specifies the logo to include for this account on all invoices.';
                }
                field(TargetURL; TargetURL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target URL';
                    Importance = Additional;
                    MultiLine = true;
                    ToolTip = 'Specifies the address of the web page that opens when the customer chooses the link on the invoice.';

                    trigger OnValidate()
                    var
                        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
                    begin
                        MSWorldPayStandardMgt.ValidateChangeTargetURL();
                        SetTargetURL(TargetURL);
                    end;
                }
                field("Terms of Service"; "Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = TermsOfServiceEditable;
                    ToolTip = 'Specifies WorldPay terms of service.';

                    trigger OnAssistEdit()
                    begin
                        TermsOfServiceEditable := NOT TermsOfServiceEditable;
                    end;

                    trigger OnDrillDown()
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
                RunObject = Page "MS - WorldPay Std. Template";
                RunPageOnRec = false;
                ToolTip = 'Opens Template Setup for all WorldPay accounts.';
            }
            action(ActivityLog)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Activity Log';
                Image = Log;
                ToolTip = 'Log listing events for this WorldPay account.';

                trigger OnAction()
                var
                    MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
                    ActivityLog: Record "Activity Log";
                    MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
                begin
                    MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);
                    ActivityLog.ShowEntries(MSWorldPayStdTemplate);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        TargetURL := GetTargetURL();
    end;

    trigger OnOpenPage()
    var
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
    begin
        MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);
        MSWorldPayStdTemplate.RefreshLogoIfNeeded();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        IF NOT Enabled THEN
            IF NOT CONFIRM(STRSUBSTNO(EnableServiceQst, CurrPage.CAPTION()), TRUE) THEN
                EXIT(FALSE);

        IF CloseAction = ACTION::Cancel THEN
            EXIT(TRUE);
    end;

    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        TargetURL: Text;
        TermsOfServiceEditable: Boolean;
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = pagecaption (WorldPay Payments Standard Setup)';
        ThirdPartyNoticeMsg: Label 'This extension uses the WorldPay, a third-party provider. By enabling this extension, you will be subject to the applicable terms, conditions, and privacy policies that WorldPay may make available.\\When you establish a connection through the WorldPay Payments Standard extension, customer data from the invoice, such as invoice number, due date, amount, and currency, as well as your WorldPay account ID, will be inserted into the WorldPay payment link on invoices and sent to WorldPay when the customer chooses the link to pay. This data is used to ensure that the link contains enough information for your customers to pay the invoice, as well as for WorldPay to identify you as the recipient of a payment using the link.\\By installing this solution, you agree for this limited set of data to be sent to the WorldPay. Note that you can disable or uninstall the WorldPay Payments Standard extension at any time to discontinue the functionality.';
}

