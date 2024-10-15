// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;

page 11514 "Swiss QR-Bill Setup"
{
    Caption = 'QR-Bill Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Swiss QR-Bill Setup";
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'QR-Bill Generation and Layout';

                group(Group1)
                {
                    ShowCaption = false;

                    field("Address Type"; "Address Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the address type used for all printed QR-bills. Recommended value is Structured.';
                    }
                    field(DefaultQRBillLayout; "Default Layout")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the default QR-bill layout. It is used for issuing QR-bills for documents that have not been enabled for QR-bills via a payment method but should still have a QR-bill printed.';
                        LookupPageId = "Swiss QR-Bill Layout";
                    }
                    field(LastUsedReferenceNo; "Last Used Reference No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the last used payment reference number. This is an integer value used as a source for calculation and printing the payment reference on the QR-Bill report and in the QR code.';
                    }
                }

                group(Group2)
                {
                    ShowCaption = false;

                    field(QRIBAN; CompanyInformation."Swiss QR-Bill IBAN")
                    {
                        ApplicationArea = All;
                        Caption = 'QR-IBAN';
                        ToolTip = 'Specifies the QR-IBAN value of your primary bank account. This identifies the bank account to which the receiver of your QR-bills will transfer money.';
                        Importance = Promoted;
                        Editable = false;
                        StyleExpr = true;
                        Style = StandardAccent;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Company Information");
                            CurrPage.Update(false);
                        end;
                    }
                    field(IBAN; CompanyInformation.IBAN)
                    {
                        ApplicationArea = All;
                        Caption = 'IBAN';
                        ToolTip = 'Specifies the IBAN value of your primary bank account. This identifies the bank account to which the receiver of your QR-bills will transfer money.';
                        Editable = false;
                        StyleExpr = true;
                        Style = StandardAccent;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Company Information");
                            CurrPage.Update(false);
                        end;
                    }
                    field(PaymentMethods; PaymentMethodsText)
                    {
                        ApplicationArea = All;
                        Caption = 'Payment Methods';
                        ToolTip = 'Specifies how many payment methods have been enabled for QR-bills.';
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
                    field(DocumentTypes; DocumentTypesText)
                    {
                        ApplicationArea = All;
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
            group(IncomingDoc)
            {
                Caption = 'Receiving QR-Bills';

                group(QRBillPaymentJnlSetup)
                {
                    ShowCaption = false;

                    field(PaymentJnlTemplate; "Journal Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the journal template to use for payment journals or purchase journals created from QR-bills through incoming documents.';
                        Importance = Promoted;
                        ShowMandatory = true;
                    }
                    field(PaymentJnlBatch; "Journal Batch")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the journal batch to use for payment journals or purchase journals created from QR-bills through incoming documents.';
                        Importance = Promoted;
                        ShowMandatory = true;
                    }
                }
            }

            group(SEPA)
            {
                Caption = 'Payment File Setup';

                group(GLSetupGroup)
                {
                    ShowCaption = false;

                    field(SEPANonEuroExport; GeneralLedgerSetup."SEPA Non-Euro Export")
                    {
                        ApplicationArea = All;
                        Caption = 'SEPA Non-Euro Export';
                        ToolTip = 'Specifies whether the SEPA Non-Euro Export check box is selected on the General Ledger Setup page.';
                        Editable = false;
                    }
                    field(OpenGLSetup; OpenGLSetupLbl)
                    {
                        ApplicationArea = All;
#pragma warning disable AA0219
                        ToolTip = 'Opens the General Ledger Setup page.';
#pragma warning restore AA0219
                        Caption = ' ';
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"General Ledger Setup");
                            CurrPage.Update(false);
                        end;
                    }
                }

                group(BankExportImportSetup)
                {
                    Caption = 'Bank Export/Import Setup';

                    field(SEPACT; "SEPA CT Setup")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether the SEPA Credit Transfer field has been filled on the Bank Export/Import Setup page.';
                    }
                    field(SEPADD; "SEPA DD Setup")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether the SEPA Direct Transfer field has been filled on the Bank Export/Import Setup page.';
                    }
                    field(SEPACAMT; "SEPA CAMT 054 Setup")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether the SEPA CAMT 054 field has been filled on the Bank Export/Import Setup page.';
                    }
                }
            }
        }
    }

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        PaymentMethodsText: Text;
        DocumentTypesText: Text;
        OpenGLSetupLbl: Label 'Open the general ledger setup.';

    trigger OnInit()
    begin
        CompanyInformation.Get();
        GeneralLedgerSetup.Get();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcFields("SEPA CAMT 054 DataExchDef Code");
        PaymentMethodsText := SwissQRBillMgt.FormatQRPaymentMethodsCount(SwissQRBillMgt.CalcQRPaymentMethodsCount());
        DocumentTypesText := SwissQRBillMgt.FormatEnabledReportsCount(SwissQRBillMgt.CalcEnabledReportsCount());
        CompanyInformation.Find();
        GeneralLedgerSetup.Find();
    end;
}
