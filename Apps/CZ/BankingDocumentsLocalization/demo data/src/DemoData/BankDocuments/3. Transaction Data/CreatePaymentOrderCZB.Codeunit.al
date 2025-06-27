// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.BankDocuments;

using Microsoft.Bank.Documents;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Localization;
using Microsoft.DemoData.Purchases;

codeunit 31481 "Create Payment Order CZB"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreatePaymentOrders();
    end;

    local procedure CreatePaymentOrders()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
        CreateVendor: Codeunit "Create Vendor";
        CreateVendorBankAccount: Codeunit "Create Vendor Bank Account";
        ContosoBankDocumentsCZB: Codeunit "Contoso Bank Documents CZB";
    begin
        PaymentOrderHeaderCZB := ContosoBankDocumentsCZB.InsertPaymentOrderHeader(CreateBankAccountCZ.NBL(), WorkDate(), '1');
        ContosoBankDocumentsCZB.InsertPaymentOrderLine(PaymentOrderHeaderCZB, Enum::"Banking Line Type CZB"::Vendor, CreateVendor.ExportFabrikam(), WorkDate(), CreateVendorBankAccount.ECA(), '108007', 357141.80);
        ContosoBankDocumentsCZB.InsertPaymentOrderLine(PaymentOrderHeaderCZB, Enum::"Banking Line Type CZB"::Vendor, CreateVendor.DomesticFirstUp(), WorkDate(), CreateVendorBankAccount.ECA(), '108001', 92116.02);

        PaymentOrderHeaderCZB := ContosoBankDocumentsCZB.InsertPaymentOrderHeader(CreateBankAccountCZ.NBL(), WorkDate(), OpenExternalDocumentNo());
        ContosoBankDocumentsCZB.InsertPaymentOrderLine(PaymentOrderHeaderCZB, Enum::"Banking Line Type CZB"::Vendor, CreateVendor.ExportFabrikam(), WorkDate(), CreateVendorBankAccount.ECA(), '108011', 440016.90);
        ContosoBankDocumentsCZB.InsertPaymentOrderLine(PaymentOrderHeaderCZB, Enum::"Banking Line Type CZB"::Vendor, CreateVendor.DomesticFirstUp(), WorkDate(), CreateVendorBankAccount.ECA(), '108008', 43685.10);
    end;

    procedure IssueBankStatements()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        PaymentOrderHeaderCZB.SetFilter("External Document No.", '<>%1', OpenExternalDocumentNo());
        if PaymentOrderHeaderCZB.FindSet() then
            repeat
                Codeunit.Run(Codeunit::"Issue Payment Order CZB", PaymentOrderHeaderCZB);
            until PaymentOrderHeaderCZB.Next() = 0;
    end;

    procedure OpenExternalDocumentNo(): Code[35]
    begin
        exit(OpenExternalDocumentNoTok);
    end;

    var
        OpenExternalDocumentNoTok: Label 'OPEN', MaxLength = 35;
}