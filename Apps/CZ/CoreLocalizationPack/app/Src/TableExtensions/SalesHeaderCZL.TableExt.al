// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.BatchProcessing;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using System.Utilities;
using Microsoft.Sales.Setup;

tableextension 11703 "Sales Header CZL" extends "Sales Header"
{
    fields
    {
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            var
                NeedUpdateAddCurrencyFactor: Boolean;
            begin
                NeedUpdateAddCurrencyFactor := GeneralLedgerSetup.IsAdditionalCurrencyEnabled();
                OnValidatePostingDateOnBeforeCheckNeedUpdateAddCurrencyFactor(Rec, xRec, IsConfirmedCZL, NeedUpdateAddCurrencyFactor);
                if NeedUpdateAddCurrencyFactor then begin
                    UpdateAddCurrencyFactorCZL();
                    if ("Additional Currency Factor CZL" <> xRec."Additional Currency Factor CZL") and not GetCalledFromWhseDoc() then
                        ConfirmAddCurrencyFactorUpdateCZL();
                end;
                OnValidatePostingDateOnAfterCheckNeedUpdateAddCurrencyFactor(Rec, xRec, NeedUpdateAddCurrencyFactor);
            end;
        }
        modify("VAT Reporting Date")
        {
            trigger OnAfterValidate()
            var
                VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
                NeedUpdateVATCurrencyFactor: Boolean;
            begin
                if not VATReportingDateMgt.IsVATDateEnabled() then
                    TestField("VAT Reporting Date", "Posting Date");
                CheckCurrencyExchangeRateCZL("VAT Reporting Date");

                NeedUpdateVATCurrencyFactor := ("Currency Code" <> '') and ("VAT Reporting Date" <> xRec."VAT Reporting Date");
                OnValidateVATDateOnBeforeCheckNeedUpdateVATCurrencyFactorCZL(Rec, IsConfirmedCZL, NeedUpdateVATCurrencyFactor, xRec);
                if NeedUpdateVATCurrencyFactor then begin
                    UpdateVATCurrencyFactorCZL();
                    if ("VAT Currency Factor CZL" <> xRec."VAT Currency Factor CZL") and not GetCalledFromWhseDoc() then
                        ConfirmVATCurrencyFactorUpdateCZL();
                end;
                OnValidateVATDateOnAfterCheckNeedUpdateVATCurrencyFactorCZL(Rec, xRec, NeedUpdateVATCurrencyFactor);
            end;
        }
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(11719; "Constant Symbol CZL"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(11720; "Bank Account Code CZL"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Document Type" = filter(Quote | Order | Invoice | "Blanket Order")) "Bank Account" else
            if ("Document Type" = filter("Credit Memo" | "Return Order")) "Customer Bank Account".Code where("Customer No." = field("Bill-to Customer No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
                CustomerBankAccount: Record "Customer Bank Account";
            begin
                if CurrFieldNo = Rec.FieldNo("Bank Account Code CZL") then
                    TestField(Status, Status::Open);
                if "Bank Account Code CZL" = '' then begin
                    UpdateBankInfoCZL('', '', '', '', '', '', '');
                    exit;
                end;
                case "Document Type" of
                    "Document Type"::Quote, "Document Type"::Order,
                    "Document Type"::Invoice, "Document Type"::"Blanket Order":
                        begin
                            BankAccount.Get("Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              BankAccount."No.",
                              BankAccount."Bank Account No.",
                              BankAccount."Bank Branch No.",
                              BankAccount.Name,
                              BankAccount."Transit No.",
                              BankAccount.IBAN,
                              BankAccount."SWIFT Code");
                        end;
                    "Document Type"::"Credit Memo", "Document Type"::"Return Order":
                        begin
                            TestField("Bill-to Customer No.");
                            CustomerBankAccount.Get("Bill-to Customer No.", "Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              CustomerBankAccount.Code,
                              CustomerBankAccount."Bank Account No.",
                              CustomerBankAccount."Bank Branch No.",
                              CustomerBankAccount.Name,
                              CustomerBankAccount."Transit No.",
                              CustomerBankAccount.IBAN,
                              CustomerBankAccount."SWIFT Code");
                        end;
                end;
            end;
        }
        field(11721; "Bank Account No. CZL"; Text[30])
        {
            Caption = 'Bank Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11722; "Bank Branch No. CZL"; Text[20])
        {
            Caption = 'Bank Branch No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11723; "Bank Name CZL"; Text[100])
        {
            Caption = 'Bank Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11724; "Transit No. CZL"; Text[20])
        {
            Caption = 'Transit No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11725; "IBAN CZL"; Code[50])
        {
            Caption = 'IBAN';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11726; "SWIFT Code CZL"; Code[20])
        {
            Caption = 'SWIFT Code';
            Editable = false;
            TableRelation = "SWIFT Code";
            DataClassification = CustomerContent;
        }
        field(11750; "Additional Currency Factor CZL"; Decimal)
        {
            Caption = 'Additional Currency Factor';
            DecimalPlaces = 0 : 15;
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(11774; "VAT Currency Factor CZL"; Decimal)
        {
            Caption = 'VAT Currency Factor';
            DecimalPlaces = 0 : 15;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Currency Code");
            end;
        }
        field(11775; "VAT Currency Code CZL"; Code[10])
        {
            Caption = 'VAT Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            Editable = false;

            trigger OnValidate()
            begin
                TestField("VAT Currency Code CZL", "Currency Code");
                UpdateVATCurrencyFactorCZL();
            end;
        }
#if not CLEANSCHEMA25
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Replaced by VAT Reporting Date.';
        }
#endif
        field(11781; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(11786; "Credit Memo Type CZL"; Enum "Credit Memo Type CZL")
        {
            Caption = 'Credit Memo Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if IsCreditDocType() then
                    TestField("Credit Memo Type CZL")
                else
                    Clear("Credit Memo Type CZL");
            end;
        }
#if not CLEANSCHEMA25
        field(31068; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
#endif
        field(31072; "EU 3-Party Intermed. Role CZL"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "EU 3-Party Intermed. Role CZL" then
                    "EU 3-Party Trade" := true;
            end;
        }
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ConfirmManagement: Codeunit "Confirm Management";
        GlobalDocumentType: Enum "Sales Document Type";
        GlobalDocumentNo: Code[20];
        GlobalIsIntrastatTransaction: Boolean;
        IsConfirmedCZL: Boolean;
        UpdateExchRateQst: Label 'Do you want to update the exchange rate for VAT?';
        UpdateExchRateForAddCurrencyQst: Label 'Do you want to update the exchange rate for additional currency?';

    local procedure CheckCurrencyExchangeRateCZL(CurrencyDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrExchRateNotExistsErr: Label '%1 does not exist for currency %2 and date %3.', Comment = '%1 = CurrExchRate.TableCaption, %2 = Currency Code, %3 = Date';
    begin
        if "Currency Code" = '' then
            exit;
        if not CurrencyExchangeRate.CurrencyExchangeRateExist("Currency Code", CurrencyDate) then
            Error(CurrExchRateNotExistsErr, CurrencyExchangeRate.TableCaption, "Currency Code", CurrencyDate);
    end;

    procedure UpdateVATCurrencyFactorCZLByCurrencyFactorCZL()
    begin
        if "Currency Code" = '' then begin
            "VAT Currency Factor CZL" := 0;
            exit;
        end;

        if ("Currency Factor" <> xRec."Currency Factor") and
           ("Currency Factor" <> "VAT Currency Factor CZL") and
           ("VAT Reporting Date" = "Posting Date")
        then begin
            "VAT Currency Factor CZL" := "Currency Factor";
            if (xRec."Currency Factor" = xRec."VAT Currency Factor CZL") or
               (xRec."Currency Factor" = 0) or GetHideValidationDialog()
            then
                Validate("VAT Currency Factor CZL")
            else
                ConfirmVATCurrencyFactorUpdateCZL();
        end
    end;

    internal procedure UpdateAddCurrencyFactorCZL()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrencyDate: Date;
        IsUpdated: Boolean;
    begin
        OnBeforeUpdateAddCurrencyFactorCZL(Rec, IsUpdated, CurrencyExchangeRate);
        if IsUpdated then
            exit;

        if GeneralLedgerSetup.IsAdditionalCurrencyEnabled() then begin
            if "Posting Date" <> 0D then
                CurrencyDate := "Posting Date"
            else
                CurrencyDate := WorkDate();

            "Additional Currency Factor CZL" := CurrencyExchangeRate.ExchangeRate(CurrencyDate, GeneralLedgerSetup.GetAdditionalCurrencyCode());
        end else
            "Additional Currency Factor CZL" := 0;

        OnAfterUpdateAddCurrencyFactorCZL(Rec, GetHideValidationDialog());
    end;

    local procedure UpdateVATCurrencyFactorCZL()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        UpdateCurrencyExchangeRates: Codeunit "Update Currency Exchange Rates";
        CurrencyDate: Date;
        IsUpdated: Boolean;
    begin
        OnBeforeUpdateVATCurrencyFactorCZL(Rec, IsUpdated, CurrencyExchangeRate);
        if IsUpdated then
            exit;

        if "Currency Code" <> '' then begin
            if "VAT Reporting Date" <> 0D then
                CurrencyDate := "VAT Reporting Date"
            else
                CurrencyDate := WorkDate();

            if UpdateCurrencyExchangeRates.ExchangeRatesForCurrencyExist(CurrencyDate, "Currency Code") then
                "VAT Currency Factor CZL" := CurrencyExchangeRate.ExchangeRate(CurrencyDate, "Currency Code")
            else
                UpdateCurrencyExchangeRates.ShowMissingExchangeRatesNotification("Currency Code");
        end else
            "VAT Currency Factor CZL" := 0;

        OnAfterUpdateVATCurrencyFactorCZL(Rec, GetHideValidationDialog());
    end;

    procedure ConfirmAddCurrencyFactorUpdateCZL(): Boolean
    var
        IsHandled: Boolean;
        ForceConfirm: Boolean;
    begin
        IsHandled := false;
        ForceConfirm := false;
        OnBeforeConfirmUpdateAddCurrencyFactorCZL(Rec, xRec, HideValidationDialog, IsHandled, ForceConfirm);
        if IsHandled then
            exit;

        if GetHideValidationDialog() or not GuiAllowed or ForceConfirm then
            IsConfirmedCZL := true
        else
            IsConfirmedCZL := ConfirmManagement.GetResponseOrDefault(UpdateExchRateForAddCurrencyQst, true);
        if IsConfirmedCZL then
            Validate("Additional Currency Factor CZL")
        else
            "Additional Currency Factor CZL" := xRec."Additional Currency Factor CZL";
        exit(IsConfirmedCZL);
    end;

    procedure ConfirmVATCurrencyFactorUpdateCZL(): Boolean
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        ReplacePostingDate: Boolean;
        ReplaceVATDate: Boolean;
    begin
        OnBeforeConfirmUpdateVATCurrencyFactorCZL(Rec, HideValidationDialog);

        BatchProcessingMgt.GetBooleanParameter(Rec.RecordId, Enum::"Batch Posting Parameter Type"::"Replace Posting Date", ReplacePostingDate);
        BatchProcessingMgt.GetBooleanParameter(Rec.RecordId, Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDate);
        if GetHideValidationDialog() or not GuiAllowed or ReplacePostingDate or ReplaceVATDate then
            IsConfirmedCZL := true
        else
            IsConfirmedCZL := ConfirmManagement.GetResponseOrDefault(UpdateExchRateQst, true);
        if IsConfirmedCZL then
            Validate("VAT Currency Factor CZL")
        else
            "VAT Currency Factor CZL" := xRec."VAT Currency Factor CZL";
        exit(IsConfirmedCZL);
    end;

    procedure UpdateBankInfoCZL(BankAccountCode: Code[20]; BankAccountNo: Text[30]; BankBranchNo: Text[20]; BankName: Text[100]; TransitNo: Text[20]; IBANCode: Code[50]; SWIFTCode: Code[20])
    begin
        "Bank Account Code CZL" := BankAccountCode;
        "Bank Account No. CZL" := BankAccountNo;
        "Bank Branch No. CZL" := BankBranchNo;
        "Bank Name CZL" := BankName;
        "Transit No. CZL" := TransitNo;
        "IBAN CZL" := IBANCode;
        "SWIFT Code CZL" := SWIFTCode;
        OnAfterUpdateBankInfoCZL(Rec);
    end;

    procedure IsIntrastatTransactionCZL(): Boolean
    begin
        if ("Document Type" <> GlobalDocumentType) or ("No." <> GlobalDocumentNo) or ("No." = '') then begin
            GlobalDocumentType := "Document Type";
            GlobalDocumentNo := "No.";
            GlobalIsIntrastatTransaction := UpdateGlobalIsIntrastatTransaction();
        end;
        exit(GlobalIsIntrastatTransaction);
    end;

    procedure ShipOrReceiveInventoriableTypeItemsCZL(): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", "Document Type");
        SalesLine.SetRange("Document No.", "No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                if ((SalesLine."Qty. to Ship" <> 0) or (SalesLine."Return Qty. to Receive" <> 0)) and SalesLine.IsInventoriableItem() then
                    exit(true);
            until SalesLine.Next() = 0;
    end;

    local procedure UpdateGlobalIsIntrastatTransaction(): Boolean
    var
        CountryRegion: Record "Country/Region";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeUpdateGlobalIsIntrastatTransaction(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if "EU 3-Party Intermed. Role CZL" then
            exit(false);
        exit(CountryRegion.IsIntrastatCZL("VAT Country/Region Code", false));
    end;

    procedure GetDefaulBankAccountNoCZL() BankAccountNo: Code[20]
    var
        BankAccount: Record "Bank Account";
        IsHandled: Boolean;
    begin
        OnBeforeGetDefaulBankAccountNoCZL(Rec, BankAccountNo, IsHandled);
        if IsHandled then
            exit(BankAccountNo);
        exit(BankAccount.GetDefaultBankAccountNoCZL("Responsibility Center", "Currency Code"));
    end;

    procedure CheckPaymentQRCodePrintIBANCZL()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PaymentMethod: Record "Payment Method";
        CompanyInformation: Record "Company Information";
    begin
        if "Document Type" in ["Document Type"::"Blanket Order", "Document Type"::"Credit Memo", "Document Type"::Quote, "Document Type"::"Return Order"] then
            exit;

        if "Payment Method Code" = '' then
            exit;

        SalesReceivablesSetup.Get();

        if not SalesReceivablesSetup."Print QR Payment CZL" then
            exit;

        PaymentMethod.Get("Payment Method Code");
        if not PaymentMethod."Print QR Payment CZL" then
            exit;

        if "Bank Account Code CZL" = '' then begin
            CompanyInformation.Get();
            if CompanyInformation.IBAN <> '' then
                exit;
        end else
            if "IBAN CZL" <> '' then
                exit;

        ConfirmCheckPaymentQRCodePrintIBAN();
    end;

    local procedure ConfirmCheckPaymentQRCodePrintIBAN()
    var

        EmptyIBANQst: Label 'Bank Account has empty IBAN, QR payment will not be printed on Sales document.\\Do you want to continue?';
    begin
        ConfirmProcess(EmptyIBANQst);
    end;

    local procedure ConfirmProcess(ConfirmQuestion: Text)
    var
        IsHandled: Boolean;
    begin
        OnBeforeConfirmProcessCZL(ConfirmQuestion, IsHandled);
        if IsHandled then
            exit;
        if not IsConfirmDialogAllowedCZL() then
            exit;
        if not ConfirmManagement.GetResponse(ConfirmQuestion, false) then
            Error('');
    end;

    local procedure IsConfirmDialogAllowedCZL() IsAllowed: Boolean
    begin
        IsAllowed := GuiAllowed();
        OnIsConfirmDialogAllowedCZL(IsAllowed);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankInfoCZL(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeUpdateGlobalIsIntrastatTransaction(SalesHeader: Record "Sales Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVATDateOnBeforeCheckNeedUpdateVATCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; var IsIsConfirmedCZL: Boolean; var NeedUpdateVATCurrencyFactor: Boolean; xSalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVATDateOnAfterCheckNeedUpdateVATCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var NeedUpdateVATCurrencyFactor: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateVATCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; var IsUpdated: Boolean; var CurrencyExchangeRate: Record "Currency Exchange Rate")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateVATCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmUpdateVATCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; var HideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDefaulBankAccountNoCZL(var SalesHeader: Record "Sales Header"; var BankAccountNo: Code[20]; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmProcessCZL(ConfirmQuestion: Text; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsConfirmDialogAllowedCZL(var IsAllowed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePostingDateOnBeforeCheckNeedUpdateAddCurrencyFactor(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var IsConfirmedCZL: Boolean; var NeedUpdateAddCurrencyFactor: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidatePostingDateOnAfterCheckNeedUpdateAddCurrencyFactor(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var NeedUpdateAddCurrencyFactor: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAddCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; var IsUpdated: Boolean; var CurrencyExchangeRate: Record "Currency Exchange Rate")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAddCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; GetHideValidationDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmUpdateAddCurrencyFactorCZL(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var HideValidationDialog: Boolean; var IsHandled: Boolean; var ForceConfirm: Boolean)
    begin
    end;
}
