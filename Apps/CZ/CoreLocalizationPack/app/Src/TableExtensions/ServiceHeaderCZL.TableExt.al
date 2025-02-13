// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using System.Utilities;
using Microsoft.Sales.Setup;
using Microsoft.Foundation.Company;

tableextension 11734 "Service Header CZL" extends "Service Header"
{
    fields
    {
        modify("VAT Reporting Date")
        {
            trigger OnAfterValidate()
            var
                VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
            begin
                if not VATReportingDateMgt.IsVATDateEnabled() then
                    TestField("VAT Reporting Date", "Posting Date");
                CheckCurrencyExchangeRateCZL("VAT Reporting Date");
                if "Currency Code" <> '' then
                    VATDateUpdateVATCurrencyFactorCZL()
            end;
        }
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Pending);
            end;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Pending);
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
                TestField(Status, Status::Pending);
            end;
        }
        field(11720; "Bank Account Code CZL"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Document Type" = filter(Quote | Order | Invoice)) "Bank Account" else
            if ("Document Type" = filter("Credit Memo")) "Customer Bank Account".Code where("Customer No." = field("Bill-to Customer No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
                CustomerBankAccount: Record "Customer Bank Account";
            begin
                if CurrFieldNo = Rec.FieldNo("Bank Account Code CZL") then
                    TestField(Status, Status::Pending);
                if "Bank Account Code CZL" = '' then begin
                    UpdateBankInfoCZL('', '', '', '', '', '', '');
                    exit;
                end;
                case "Document Type" of
                    "Document Type"::Quote, "Document Type"::Order, "Document Type"::Invoice:
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
                    "Document Type"::"Credit Memo":
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
        field(11774; "VAT Currency Factor CZL"; Decimal)
        {
            Caption = 'VAT Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;

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
                if "Document Type" = "Document Type"::"Credit Memo" then
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
    }

    var
        ConfirmManagement: Codeunit "Confirm Management";

    local procedure CheckCurrencyExchangeRateCZL(CurrencyDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrExchRateNotExistsErr: Label '%1 does not exist for currency %2 and date %3.', Comment = '%1 = CurrExchRate.TableCaption, %2 = Currency Code, %3 = Date';
    begin
        if "Currency Code" = '' then
            exit;
        if not CurrencyExchangeRate.CurrencyExchangeRateExist("Currency Code", CurrencyDate) then
            Error(CurrExchRateNotExistsErr)
    end;

    local procedure VATDateUpdateVATCurrencyFactorCZL()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        VATCurrencyFactor: Decimal;
        UpdateChangedFieldQst: Label 'You have changed %1. Do you want to update %2?', Comment = '%1 = field caption, %2 = field caption';
    begin
        if "VAT Currency Code CZL" <> '' then begin
            VATCurrencyFactor := CurrencyExchangeRate.ExchangeRate("VAT Reporting Date", "VAT Currency Code CZL");
            if "VAT Currency Factor CZL" <> VATCurrencyFactor then
                if ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdateChangedFieldQst, FieldCaption("VAT Reporting Date"), FieldCaption("VAT Currency Factor CZL")), true) then
                    Validate("VAT Currency Factor CZL", VATCurrencyFactor);
        end;
    end;

    procedure UpdateVATCurrencyFactorCZL()
    var
        UpdateChangedFieldQst: Label 'You have changed %1. Do you want to update %2?', Comment = '%1 = field caption, %2 = field caption';
    begin
        if "Currency Code" = '' then begin
            "VAT Currency Factor CZL" := 0;
            exit;
        end;

        if ("Currency Factor" <> xRec."Currency Factor") and ("Currency Factor" <> "VAT Currency Factor CZL") then begin
            if (xRec."Currency Factor" = "VAT Currency Factor CZL") then begin
                Validate("VAT Currency Factor CZL", "Currency Factor");
                exit;
            end;
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdateChangedFieldQst, FieldCaption("Currency Factor"), FieldCaption("VAT Currency Factor CZL")), true) then
                Validate("VAT Currency Factor CZL", "Currency Factor");
        end;
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
    var
        CountryRegion: Record "Country/Region";
        IsHandled: Boolean;
        Result: Boolean;
    begin
        OnBeforeIsIntrastatTransactionCZL(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if "EU 3-Party Trade" then
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
        if "Payment Method Code" = '' then
            exit;

        if SalesReceivablesSetup.ReadPermission then
            SalesReceivablesSetup.Get()
        else
            exit;

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
    local procedure OnAfterUpdateBankInfoCZL(var ServiceHeader: Record "Service Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetDefaulBankAccountNoCZL(var ServiceHeader: Record "Service Header"; var BankAccountNo: Code[20]; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeIsIntrastatTransactionCZL(ServiceHeader: Record "Service Header"; var Result: Boolean; var IsHandled: Boolean)
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
}
