#if not CLEAN20
page 1087 "MS - Wallet Merch. Setup Inv"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Caption = 'Set up Microsoft Pay Payments';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "MS - Wallet Merchant Account";

    layout
    {
        area(content)
        {
            group(General)
            {
                InstructionalText = 'With Microsoft Pay Payments, your customers can pay you using credit cards and PayPal.';
                field(LogoControlDetails; MSWalletMerchantTemplate.Logo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Logo';
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'Specifies the logo that will be included on all invoices.';
                }
                field(TermsOfServiceControlSetup; TermsOfServiceLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the Microsoft Pay Payments terms of service.';

                    trigger OnDrillDown();
                    begin
                        if "Terms of Service" <> '' then
                            Hyperlink("Terms of Service")
                        else
                            Hyperlink(MSWalletMerchantTemplate."Terms of Service");
                    end;
                }
                group(MsPayMerchantDetails)
                {
                    ShowCaption = false;
                    Visible = "Merchant ID" <> '';
                    group(Details)
                    {
                        group(AccountEnabledGroup)
                        {
                            ShowCaption = false;
                            InstructionalText = 'Your Microsoft Pay Payments merchant profile is configured and active. All the invoices you send will contain a link for your customers to pay you using Microsoft Pay Payments.';
                        }
                        field(MerchantIDControl; "Merchant ID")
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ToolTip = 'Specifies the Merchant ID of the Microsoft Pay Payments merchant account.';
                        }

                        group(TestModeGroup)
                        {
                            ShowCaption = false;
                            Visible = "Test Mode";

                            field(TestModeControl; "Test Mode")
                            {
                                ApplicationArea = Invoicing;
                                ToolTip = 'Specifies if test mode is enabled. If you send invoices and get payments while your are in test mode, no actual money transfer will be made.';
                                Editable = "Test Mode";
                            }
                        }
                        field(ConfigureMsPayControl; ConfigureMsPayLbl)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies a link to Microsoft Pay Payments so you can configure your Microsoft Pay Payments merchant profile.';

                            trigger OnDrillDown();
                            var
                                MSWalletMerchantMgt: Codeunit "MS - Wallet Merchant Mgt";
                            begin
                                Hyperlink(MSWalletMerchantMgt.GetMerchantSignupUrl());

                                ConfigureEmailLinkCount += 1;

                                if ConfigureEmailLinkCount >= 4 then
                                    Message(EnablePopUpMsg);
                            end;
                        }
                        field(RemoveAccountControl; RemoveAccountLbl)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies that you want to disconnect your Microsoft Pay Payments account from Invoicing.';

                            trigger OnDrillDown();
                            begin
                                if Confirm(ConfirmDeleteQst, false) then
                                    Delete(true);
                            end;
                        }
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        MSWalletMerchantTemplate.RefreshLogoIfNeeded();
    end;

    trigger OnOpenPage();
    var
        MSWalletMgt: Codeunit "MS - Wallet Mgt.";
    begin
        MSWalletMgt.GetTemplate(MSWalletMerchantTemplate);
        MSWalletMerchantTemplate.RefreshLogoIfNeeded();
    end;

    var
        MSWalletMerchantTemplate: Record "MS - Wallet Merchant Template";
        ConfigureEmailLinkCount: Integer;
        ConfirmDeleteQst: Label 'If you disconnect Invoicing from Microsoft Pay Payments, your customers will not be able to pay existing invoices using online payments.\Are you sure you want to remove the connection?';
        TermsOfServiceLbl: Label 'Terms of Service';
        RemoveAccountLbl: Label 'Disconnect from Microsoft Pay Payments';
        ConfigureMsPayLbl: Label 'Configure Microsoft Pay Payments (opens in a new window)';
        EnablePopUpMsg: Label 'If you cannot see the Microsoft Pay Payments setup window, make sure your browser allows pop-ups.';

}
#endif