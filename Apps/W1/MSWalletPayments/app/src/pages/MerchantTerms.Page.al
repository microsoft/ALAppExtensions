#if not CLEAN20
page 1085 "MS - Wallet Merchant Terms"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Caption = 'Microsoft Pay Payments Merchant Terms';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = StandardDialog;
    SourceTable = "MS - Wallet Merchant Template";

    layout
    {
        area(content)
        {
            group(Terms)
            {
                field(MsPayLogo; Logo)
                {
                    ApplicationArea = Invoicing;
                    Visible = IsInvoicing;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'The Microsoft Pay Payments logo.';
                }
                field(TermsOfServiceLbl; TermsOfServiceLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Link to Microsoft Pay Payments Merchant Terms.';

                    trigger OnDrillDown();
                    begin
                        HYPERLINK(MerchantTermsUrlTxt);
                    end;
                }
                field(PrivacyNoticeLbl; PrivacyNoticeLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Link to Privacy notice.';

                    trigger OnDrillDown();
                    begin
                        HYPERLINK(PrivacyNoticeUrlTxt);
                    end;
                }
                field("Accept Terms of Service"; "Accept Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = CanEditAcceptTerms;
                    ToolTip = 'Specifies if you accept the terms of service for Microsoft Pay Payments.';
                }
                group(NOTE1_BusinessCentral)
                {
                    Caption = 'NOTE:';
                    InstructionalText = 'To enable payments in Dynamics 365 Business Central through Microsoft Pay Payments, you must first set up a Microsoft Pay Payments merchant profile. Microsoft Pay Payments is not an online service governed by the Office 365 Online Service Terms. The information that you provide during setup and your use of Microsoft Pay Payments are governed by the Microsoft Pay Payments Merchant Terms. When you choose the OK button below, your Office 365 identity information will be used to set up your Microsoft Pay Payments merchant profile to service your connection with your payment service provider.';
                    Visible = not IsInvoicing;
                    group(NOTE2_BusinessCentral)
                    {
                        ShowCaption = false;
                        InstructionalText = 'By performing this action, you give consent to share your data with an external system. Data imported from external systems into Dynamics 365 Business Central are subject to our privacy statement that can be accessed by choosing the View Privacy Notice link. Please consult the feature technical documentation.';
                    }
                    field(TechnicalDocBusinessCentral; TechnicalDocBusinessCentralLbl)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Link to technical documentation.';

                        trigger OnDrillDown();
                        begin
                            HYPERLINK(TechnicalDocBusinessCentralURLTxt);
                        end;
                    }
                }
                group(NOTE1_Invoicing)
                {
                    Caption = 'NOTE:';
                    InstructionalText = 'To enable payments in Microsoft Invoicing through Microsoft Pay Payments, you must first set up a Microsoft Pay Payments merchant profile. Microsoft Pay Payments is not an online service governed by the Office 365 Online Service Terms. The information that you provide during setup and your use of Microsoft Pay Payments are governed by the Microsoft Pay Payments Merchant Terms. When you choose the OK button below, your Office 365 identity information will be used to set up your Microsoft Pay Payments merchant profile to service your connection with your payment service provider.';
                    Visible = IsInvoicing;
                    group(NOTE2_Invoicing)
                    {
                        ShowCaption = false;
                        InstructionalText = 'By performing this action, you give consent to share your data with an external system. Data imported from external systems into Microsoft Invoicing are subject to our privacy statement that can be accessed by choosing the View Privacy Notice link. Please consult the feature technical documentation.';
                    }
                    field(TechnicalDocInvoicing; TechnicalDocInvoicingLbl)
                    {
                        ApplicationArea = Invoicing;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Link to an introduction to Microsoft Pay Payments.';

                        trigger OnDrillDown();
                        begin
                            HYPERLINK(IntroForInvoicingURLTxt);
                        end;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage();
    var
        EnvInfoProxy: Codeunit "Env. Info Proxy";
    begin
        IsInvoicing := EnvInfoProxy.IsInvoicing();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        CanEditAcceptTerms := NOT "Accept Terms of Service";
        CalcFields(Logo);

        if Logo.Length() = 0 then
            UpdateLogo();

        RefreshLogoIfNeeded();
    end;

    var
        MerchantTermsUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=854338', Locked = true;
        TermsOfServiceLbl: Label 'Microsoft Pay Payments Merchant Terms';
        PrivacyNoticeUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=869492', Locked = true;
        PrivacyNoticeLbl: Label 'View Privacy Notice';
        TechnicalDocBusinessCentralLbl: Label 'For more information on this, go here';
        TechnicalDocInvoicingLbl: Label 'For more information on this, go here';
        TechnicalDocBusinessCentralURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=869493', Locked = true;
        IntroForInvoicingURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2008808', Locked = true;
        CanEditAcceptTerms: Boolean;
        IsInvoicing: Boolean;
}
#endif