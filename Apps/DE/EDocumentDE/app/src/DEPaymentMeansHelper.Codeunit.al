// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Peppol;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;

codeunit 11037 "DE Payment Means Helper"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Returns the UNCL4461 payment means code for the given Payment Method Code.
    /// Falls back to '58' (SEPA Credit Transfer) if no code is configured.
    /// </summary>
    procedure GetPaymentMeansCode(PaymentMethodCode: Code[10]): Code[3]
    var
        PaymentMethod: Record "Payment Method";
    begin
        if PaymentMethodCode <> '' then
            if PaymentMethod.Get(PaymentMethodCode) then
                if PaymentMethod."PEPPOL Payment Means Code" <> '' then
                    exit(PaymentMethod."PEPPOL Payment Means Code");
        exit('58');
    end;

    /// <summary>
    /// Returns the IBAN of the bill-to customer's preferred bank account.
    /// Fires OnGetCustomerPayeeIBAN to allow connector override.
    /// Falls back to FindFirst on customer bank accounts if no preferred account is set.
    /// </summary>
    procedure GetCustomerIBAN(CustomerNo: Code[20]): Text[50]
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        IBAN: Text[50];
        Handled: Boolean;
    begin
        OnGetCustomerPayeeIBAN(CustomerNo, IBAN, Handled);
        if Handled then
            exit(IBAN);
        if Customer.Get(CustomerNo) then begin
            if Customer."Preferred Bank Account Code" <> '' then
                if CustomerBankAccount.Get(CustomerNo, Customer."Preferred Bank Account Code") then
                    exit(CustomerBankAccount.IBAN);
            CustomerBankAccount.SetRange("Customer No.", CustomerNo);
            if CustomerBankAccount.FindFirst() then
                exit(CustomerBankAccount.IBAN);
        end;
        exit('');
    end;

    /// <summary>
    /// Returns the SEPA Creditor Identifier from the company bank account.
    /// Used for SEPA Direct Debit payment means (49/59) in the SellerTradeParty/AccountingSupplierParty.
    /// </summary>
    procedure GetCreditorNo(CompanyBankAccountCode: Code[20]): Code[35]
    var
        BankAccount: Record "Bank Account";
    begin
        if CompanyBankAccountCode <> '' then
            if BankAccount.Get(CompanyBankAccountCode) then
                exit(BankAccount."Creditor No.");
        exit('');
    end;

    /// <summary>
    /// Validates that all required payment data is available for the given document before export.
    /// Called from XRechnungFormat.Check() and ZUGFeRDFormat.Check().
    /// Covers card payment data, and SEPA direct debit mandate completeness.
    /// </summary>
    procedure CheckPaymentDataAvailable(SourceDocumentHeader: RecordRef)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentMethodCodeFieldRef: FieldRef;
        DirectDebitMandateIDFieldRef: FieldRef;
        PaymentMethod: Record "Payment Method";
        EmptyDocVariant: Variant;
        PaymentMethodCode: Code[10];
        PaymentMeansCode: Code[3];
        DirectDebitMandateID: Code[35];
        Handled: Boolean;
        PrimaryAccountNumberID: Text;
        HolderName: Text;
        CardDataMissingErr: Label 'No card payment data is available for payment means code %1. Subscribe to the OnGetPaymentCardInfo event in codeunit "DE Payment Means Helper" to provide the card details.', Comment = '%1 = UNCL4461 payment means code';
        SEPADDOnCrMemoErr: Label 'Payment means code %1 (SEPA direct debit) cannot be used on a credit memo. Use a credit transfer code (30 or 58) instead.', Comment = '%1 = UNCL4461 payment means code';
        MandateIDMissingErr: Label 'Direct debit mandate ID is missing on the document. Set it in the Payment tab before releasing.';
    begin
        if not (SourceDocumentHeader.Number() in
            [Database::"Sales Header",
             Database::"Sales Invoice Header",
             Database::"Sales Cr.Memo Header",
             Database::"Service Header",
             Database::"Service Invoice Header",
             Database::"Service Cr.Memo Header"])
        then
            exit;

        PaymentMethodCodeFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Payment Method Code"));
        PaymentMethodCode := PaymentMethodCodeFieldRef.Value();
        if PaymentMethodCode <> '' then
            if PaymentMethod.Get(PaymentMethodCode) then
                PaymentMeansCode := PaymentMethod."PEPPOL Payment Means Code";

        case true of
            PaymentMeansCode in ['48', '54', '55', '70']:
                begin
                    // Pass empty variant during check — subscriber should set Handled:=true if they can provide card data
                    OnGetPaymentCardInfo(EmptyDocVariant, PaymentMeansCode, PrimaryAccountNumberID, HolderName, Handled);
                    if not Handled then
                        Error(CardDataMissingErr, PaymentMeansCode);
                end;
            PaymentMeansCode in ['49', '59']:
                begin
                    if SourceDocumentHeader.Number() in [Database::"Sales Cr.Memo Header", Database::"Service Cr.Memo Header"] then
                        Error(SEPADDOnCrMemoErr, PaymentMeansCode);
                    // Service documents do not carry Direct Debit Mandate ID — skip mandate check
                    if SourceDocumentHeader.Number() in [Database::"Service Header", Database::"Service Invoice Header", Database::"Service Cr.Memo Header"] then
                        exit;
                    DirectDebitMandateIDFieldRef := SourceDocumentHeader.Field(SalesInvoiceHeader.FieldNo("Direct Debit Mandate ID"));
                    DirectDebitMandateID := DirectDebitMandateIDFieldRef.Value();
                    if DirectDebitMandateID = '' then
                        Error(MandateIDMissingErr);
                    CheckMandateData(DirectDebitMandateID);
                end;
        end;
    end;

    local procedure CheckMandateData(DirectDebitMandateID: Code[35])
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        CustomerBankAccount: Record "Customer Bank Account";
        MandateNotFoundErr: Label 'SEPA Direct Debit Mandate %1 does not exist.', Comment = '%1 = Mandate ID';
        BankAccountNotFoundErr: Label 'Customer bank account %1 on mandate %2 does not exist.', Comment = '%1 = Bank Account Code, %2 = Mandate ID';
        IBANMissingErr: Label 'Customer bank account %1 on mandate %2 has no IBAN. Set up the IBAN before releasing the document.', Comment = '%1 = Bank Account Code, %2 = Mandate ID';
    begin
        if not SEPADirectDebitMandate.Get(DirectDebitMandateID) then
            Error(MandateNotFoundErr, DirectDebitMandateID);
        if not CustomerBankAccount.Get(SEPADirectDebitMandate."Customer No.", SEPADirectDebitMandate."Customer Bank Account Code") then
            Error(BankAccountNotFoundErr, SEPADirectDebitMandate."Customer Bank Account Code", DirectDebitMandateID);
        if CustomerBankAccount.IBAN = '' then
            Error(IBANMissingErr, SEPADirectDebitMandate."Customer Bank Account Code", DirectDebitMandateID);
    end;

    /// <summary>
    /// Fires when card payment data is needed for export or pre-export check.
    /// DocumentHeader contains the source document (Sales Invoice Header, Sales Cr.Memo Header, etc.) as a Variant.
    /// It may be empty during the Check() pre-validation — subscribers should set Handled := true if they can provide card data.
    /// Subscribe to provide PrimaryAccountNumberID and HolderName. Set Handled := true to confirm data was provided.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnGetPaymentCardInfo(DocumentHeader: Variant; PaymentMeansCode: Code[3]; var PrimaryAccountNumberID: Text; var HolderName: Text; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Fires when the customer payee IBAN is needed (e.g. credit memo PayeeFinancialAccount).
    /// Subscribe to return a specific IBAN for the given customer instead of looking up bank accounts.
    /// Set Handled := true to use the returned IBAN.
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnGetCustomerPayeeIBAN(CustomerNo: Code[20]; var IBAN: Text[50]; var Handled: Boolean)
    begin
    end;
}
