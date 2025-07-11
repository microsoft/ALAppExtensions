// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Company;
using System.Environment;
using System.Environment.Configuration;
using System.Utilities;

page 11516 "Swiss QR-Bill Setup Wizard"
{
    Caption = 'QR-Bill Setup Guide';
    PageType = NavigatePage;
    SourceTable = "Swiss QR-Bill Setup";
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                ShowCaption = false;
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStd."Media Reference")
                {
#pragma warning disable AA0219
                    ToolTip = ' ';
#pragma warning restore AA0219
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                ShowCaption = false;
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesFinished."Media Reference")
                {
#pragma warning disable AA0219
                    ToolTip = ' ';
#pragma warning restore AA0219
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Start)
            {
                Visible = WelcomeStepVisible;
                group(Welcome)
                {
                    Caption = 'WELCOME TO THE SETUP OF THE QR-BILL FOR SWITZERLAND';
                    Visible = WelcomeStepVisible;
                    group(StartDescription)
                    {
                        ShowCaption = false;
                        InstructionalText = 'QR-Bill Management for Switzerland is replacing the existing multiplicity of payment slips in Switzerland and will increase efficiency and simplify of payment handling. This set of features for Dynamics 365 Business Central will enable both issuer and receivers of QR-bills to efficiently manage bills and payments. If you do not want to set this up right now, close this page. If you continue with the setup but get interrupted during the process, you can always close the assisted setup and resume where you left. Your setup choices will be saved during the process, even if you close.';
                    }
                }
            }

            group(CompanySetup)
            {
                Visible = CompanyInfoStepVisible;

                group(CompanySetupDescription)
                {
                    Caption = 'QR-BILL SETUP (STEP 1 OF 6): GENERATING AND ISSUING QR-BILLS';
                    InstructionalText = 'For QR-bills to be correctly generated and issued, certain information must be set up in the system, starting with basic information on the Company Information page. Your company’s address is important to verify and is listed below. You must also specify the QR-IBAN issued to you and save this in your company information by entering it below.';
                }

                group(QRIBANValueDetails)
                {
                    ShowCaption = false;

                    field(QRIBAN; CompanyInformation."Swiss QR-Bill IBAN")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the QR-IBAN value of your primary bank account. This identifies the bank account to which the receiver of your QR-bills will transfer money.';
                        Caption = 'QR-IBAN';

                        trigger OnValidate()
                        var
                            NewIBAN: Code[50];
                        begin
                            NewIBAN := CompanyInformation."Swiss QR-Bill IBAN";
                            CompanyInformation.Find();
                            CompanyInformation.Validate("Swiss QR-Bill IBAN", NewIBAN);
                            CompanyInformation.Modify();
                        end;
                    }
                    field(IBAN; CompanyInformation.IBAN)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the IBAN value of your primary bank account. This identifies the bank account to which the receiver of your QR-bills will transfer money.';
                        Caption = 'IBAN';
                        Editable = false;
                        StyleExpr = true;
                        Style = StandardAccent;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Company Information");
                            CurrPage.Update(false);
                        end;
                    }
                    field(Address; CompanyAddress)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the address.';
                        Caption = 'Address';
                        Editable = false;
                        MultiLine = true;
                        StyleExpr = true;
                        Style = StandardAccent;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Company Information");
                            CurrPage.Update(false);
                        end;
                    }
                }
            }

            group(BasicFieldsStep)
            {
                ShowCaption = false;
                Visible = BasicFieldsStepVisible;

                group(BasicFieldsDescription)
                {
                    Caption = 'QR-BILL SETUP (STEP 2 OF 6): GENERATING AND ISSUING QR-BILLS';
                    InstructionalText = 'Here you must specify important information regarding the display of addresses on QR-bills. The Address Type field determines how address fields are shown. The recommended value is Structured. German Umlaut Chars Encoding determines how umlaut characters are show and saved in the QR code and, ultimately, shown to the receiver who scans the QR-bill. The recommended value it Double.';
                }
                group(BasicFieldsDetails)
                {
                    ShowCaption = false;

                    field(AddressType; "Address Type")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the address type used for all printed QR-Bills. Recommended value is Structured.';
                    }
                }
            }
            group(DefaultLayoutStep)
            {
                ShowCaption = false;
                Visible = DefaultLayoutStepVisible;

                group(DefaultLayoutDescription)
                {
                    Caption = 'QR-BILL SETUP (STEP 3 OF 6): GENERATING AND ISSUING QR-BILLS';
                    InstructionalText = 'Select the default layout of the QR-bill. It is used for issuing QR-bills for documents that have not been enabled for QR-bills via a payment method (the next step in this guide) but should still have a QR-bill printed. The recommended value is DEFAULT QR-IBAN. You can also create other QR-Bill layouts and select one of those.';
                }
                group(DefaultLayoutDetails)
                {
                    ShowCaption = false;

                    field(DefaultLayout; "Default Layout")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default QR-bill layout. It is used for issuing QR-bills for documents that have not been enabled for QR-bills via a payment method but should still have a QR-bill printed.';
                        LookupPageId = "Swiss QR-Bill Layout";
                    }
                }
            }
            group(PaymentMethodsStep)
            {
                ShowCaption = false;
                Visible = PaymentMethodsStepVisible;

                group(PaymentMethodsDescription)
                {
                    Caption = 'QR-BILL SETUP (STEP 4 OF 6): GENERATING AND ISSUING QR-BILLS';
                    InstructionalText = 'Issuing QR-bills is tightly connected to sales invoices and service invoices. Whether or not a QR-bill is issued and printed when printing one of these document types is determined by the payment method specified on the customer card. If a payment type is enabled with a QR-bill layout, a QR-bill will be generated and printed. You must enable at least one payment method with a QR-bill layout to be able to issue QR-bills.';
                }
                group(PaymentMethodsDetails)
                {
                    ShowCaption = false;

                    field(PaymentMethods; PaymentMethodsText)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        Caption = 'Payment Methods';
                        ToolTip = 'Specifies how many payment methods have been enabled for QR-Bills.';
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Payment Methods");
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
            group(DocumentTypeStep)
            {
                ShowCaption = false;
                Visible = DocumentTypeStepVisible;

                group(DocumentTypeDescription)
                {
                    Caption = 'QR-BILL SETUP (STEP 5 OF 6): GENERATING AND ISSUING QR-BILLS';
                    InstructionalText = 'When you print sales invoices or service invoices, you can generate and issue QR-bills. To set this up you, must enable each document type for QR-bills according to your usage of these document types. When you enable a document type for QR-bills, the system will automatically insert an additional report selection for the selected document type. As a minimum, you must enable sales invoices for QR-bills.';
                }
                group(DocumentTypeDetails)
                {
                    ShowCaption = false;

                    field(DocumentTypeCount; DocumentTypesText)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies how many document types have been enabled for QR-bills.';
                        Caption = 'Document Types';
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Swiss QR-Bill Reports");
                            CurrPage.Update(false);
                        end;
                    }
                }
            }

            group(IncomingDocStep)
            {
                ShowCaption = false;
                Visible = IncomingDocStepVisible;

                group(IncomingDocDescription)
                {
                    Caption = 'QR-BILL SETUP (STEP 6 OF 6): RECEIVING QR-BILLS';
                    InstructionalText = 'You scan or import QR-bills using the Incoming Documents functionality. An incoming document will be created when you scan or import a QR-bill. From the incoming document, you can create a purchase journal that will post the purchase/invoice issued by the vendor. You can use a certain journal template and journal batch for posting these journals. Select the template and batch here.';
                }

                group(IncomingDocDetails)
                {
                    ShowCaption = false;

                    field(PaymentJnlTemplate; "Journal Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the journal template to use for payment journals or purchase journals created from QR-bills through incoming documents.';
                        ShowMandatory = true;
                    }
                    field(PaymentJnlBatch; "Journal Batch")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the journal batch to use for payment journals or purchase journals created from QR-bills through incoming documents.';
                        ShowMandatory = true;
                    }
                }
            }

            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishActionEnabled;
                group(FinishedChild)
                {
                    Caption = 'The QR-Bill setup is completed!';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        ShowCaption = false;
                        InstructionalText = 'You''re ready to use the QR-Bill functionality.';
                    }
                    group(FinishSummaryWarningGroup)
                    {
                        ShowCaption = false;
                        Visible = FinishSummaryWarningVisible;

                        field(FinishSummaryWarningField; FinishSummaryWarningText)
                        {
                            ApplicationArea = All;
#pragma warning disable AA0219
                            ToolTip = ' ';
#pragma warning restore AA0219
                            Caption = ' ';
                            ShowCaption = false;
                            Editable = false;
                            Style = Unfavorable;
                        }
                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ToolTip = ' ';
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ToolTip = ' ';
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ToolTip = ' ';
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if CloseAction = CloseAction::OK then
            If not GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"Swiss QR-Bill Setup Wizard") then
                if not Confirm(SetupNotCompletedQst) then
                    Error('');
    end;

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        SetRecFilter();
        Step := Step::Start;
        EnableControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        case Step of
            Step::CompanySetup:
                RefreshCompanyInfo();
            Step::PaymentMethods:
                RefreshPaymentMethods();
            Step::DocumentTypes:
                RefreshDocumentTypes();
        end;
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        CompanyInformation: Record "Company Information";
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        Step: Option Start,CompanySetup,BasicSetupFields,QRLayout,PaymentMethods,DocumentTypes,IncomingDoc,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        WelcomeStepVisible: Boolean;
        CompanyInfoStepVisible: Boolean;
        BasicFieldsStepVisible: Boolean;
        DefaultLayoutStepVisible: Boolean;
        IncomingDocStepVisible: Boolean;
        DocumentTypeStepVisible: Boolean;
        PaymentMethodsStepVisible: Boolean;
        TopBannerVisible: Boolean;
        FinishSummaryWarningVisible: Boolean;
        FinishSummaryWarningText: Text;
        CompanyAddress: Text;
        PaymentMethodsText: Text;
        DocumentTypesText: Text;
        PaymentMethodsCount: Integer;
        DocumentTypesCount: Integer;
        SetupNotCompletedQst: Label 'Set up QR-Bill has not been completed.\\Are you sure that you want to exit?';
        FinishSummaryQRIBANLbl: Label 'Company QR-IBAN is not filled (step 1 of 6).';
        FinishSummaryPaymentMethodsLbl: Label 'There are no payment methods enabled with a QR-bill layout (step 4 of 6).';
        FinishSummaryDocumentTypesLbl: Label 'There are no document types enabled for QR-bills (step 5 of 6).';
        FinishSummaryJournalSetupLbl: Label 'Journal template and batch are not setup for an incoming QR-bills (step 6 of 6).';
        QRIBANConfirmQst: Label 'Company QR-IBAN is not filled.\\Do you want to continue?';
        PaymentMethodsConfirmQst: Label 'There are no payment methods enabled with a QR-bill layout.\\Do you want to continue?';
        DocumentTypesConfirmQst: Label 'There are no document typse enabled for QR-bills.\\Do you want to continue?';
        JournalSetupConfirmQst: Label 'Journal template and batch are not set up for incoming QR-bills.\\Do you want to continue?';

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::CompanySetup:
                ShowCompanySetupStep();
            Step::BasicSetupFields:
                ShowBasicFieldsStep();
            Step::QRLayout:
                ShowDefaultLayoutStep();
            Step::PaymentMethods:
                ShowPaymentMethodsStep();
            Step::DocumentTypes:
                ShowDocumentTypesStep();
            Step::IncomingDoc:
                ShowIncomingDocStep();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Swiss QR-Bill Setup Wizard");
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then
            Step := Step - 1
        else
            if ConfirmNextStep() then
                Step := Step + 1;
        EnableControls();
    end;

    local procedure ConfirmNextStep(): Boolean
    begin
        case Step of
            Step::CompanySetup:
                if CompanyInformation."Swiss QR-Bill IBAN" = '' then
                    exit(Confirm(QRIBANConfirmQst));
            Step::PaymentMethods:
                if PaymentMethodsCount = 0 then
                    exit(Confirm(PaymentMethodsConfirmQst));
            Step::DocumentTypes:
                if DocumentTypesCount = 0 then
                    exit(Confirm(DocumentTypesConfirmQst));
            Step::IncomingDoc:
                if ("Journal Template" = '') or ("Journal Batch" = '') then
                    exit(Confirm(JournalSetupConfirmQst));
        end;
        exit(true);
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := false;

        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowCompanySetupStep();
    begin
        RefreshCompanyInfo();

        WelcomeStepVisible := false;
        CompanyInfoStepVisible := true;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowBasicFieldsStep();
    begin
        WelcomeStepVisible := false;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := true;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDefaultLayoutStep();
    begin
        WelcomeStepVisible := false;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := true;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowPaymentMethodsStep();
    begin
        RefreshPaymentMethods();

        WelcomeStepVisible := false;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := true;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDocumentTypesStep();
    begin
        RefreshDocumentTypes();

        WelcomeStepVisible := false;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := true;
        IncomingDocStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowIncomingDocStep();
    begin
        WelcomeStepVisible := false;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := true;

        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        RefreshFinishSummary();

        WelcomeStepVisible := false;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := false;

        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        WelcomeStepVisible := false;
        CompanyInfoStepVisible := false;
        BasicFieldsStepVisible := false;
        DefaultLayoutStepVisible := false;
        PaymentMethodsStepVisible := false;
        DocumentTypeStepVisible := false;
        IncomingDocStepVisible := false;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CurrentClientType())) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CurrentClientType()))
        then
            if MediaResourcesStd.GET(MediaRepositoryStandard."Media Resources Ref") AND
                MediaResourcesFinished.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesFinished."Media Reference".HasValue();
    end;

    local procedure RefreshCompanyInfo()
    begin
        CompanyInformation.Find();
        CompanyAddress := '';
        SwissQRBillMgt.AddLineIfNotBlanked(CompanyAddress, CompanyInformation.Address);
        SwissQRBillMgt.AddLineIfNotBlanked(CompanyAddress, CompanyInformation."Address 2");
        SwissQRBillMgt.AddLineIfNotBlanked(CompanyAddress, CompanyInformation.City);
        SwissQRBillMgt.AddLineIfNotBlanked(CompanyAddress, CompanyInformation."Post Code");
        SwissQRBillMgt.AddLineIfNotBlanked(CompanyAddress, CompanyInformation."Country/Region Code");
    end;

    local procedure RefreshPaymentMethods()
    begin
        PaymentMethodsCount := SwissQRBillMgt.CalcQRPaymentMethodsCount();
        PaymentMethodsText := SwissQRBillMgt.FormatQRPaymentMethodsCount(PaymentMethodsCount);
    end;

    local procedure RefreshDocumentTypes()
    begin
        DocumentTypesCount := SwissQRBillMgt.CalcEnabledReportsCount();
        DocumentTypesText := SwissQRBillMgt.FormatEnabledReportsCount(DocumentTypesCount);
    end;

    local procedure RefreshFinishSummary()
    begin
        FinishSummaryWarningText := '';

        CompanyInformation.Find();
        if CompanyInformation."Swiss QR-Bill IBAN" = '' then
            FinishSummaryWarningText := FinishSummaryQRIBANLbl;
        if PaymentMethodsCount = 0 then
            SwissQRBillMgt.AddLine(FinishSummaryWarningText, FinishSummaryPaymentMethodsLbl);
        if DocumentTypesCount = 0 then
            SwissQRBillMgt.AddLine(FinishSummaryWarningText, FinishSummaryDocumentTypesLbl);
        if ("Journal Template" = '') or ("Journal Batch" = '') then
            SwissQRBillMgt.AddLine(FinishSummaryWarningText, FinishSummaryJournalSetupLbl);

        FinishSummaryWarningVisible := FinishSummaryWarningText <> '';
    end;
}
