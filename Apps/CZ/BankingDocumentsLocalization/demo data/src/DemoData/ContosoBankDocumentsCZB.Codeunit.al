// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.Bank.Documents;
using Microsoft.DemoData.Bank;
using Microsoft.DemoTool;

codeunit 31429 "Contoso Bank Documents CZB"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Bank Statement Header CZB" = rim,
        tabledata "Bank Statement Line CZB" = rim,
        tabledata "Payment Order Header CZB" = rim,
        tabledata "Payment Order Line CZB" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertBankStatementHeader(BankAccountNo: Code[20]; DocumentDate: Date; ExternalDocumentNo: Code[35]): Record "Bank Statement Header CZB"
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
    begin
        BankStatementHeaderCZB.Init();
        BankStatementHeaderCZB."No." := '';
        BankStatementHeaderCZB.Validate("Bank Account No.", BankAccountNo);
        BankStatementHeaderCZB.Validate("Document Date", DocumentDate);
        BankStatementHeaderCZB.Validate("External Document No.", ExternalDocumentNo);
        BankStatementHeaderCZB.Insert(true);

        exit(BankStatementHeaderCZB);
    end;

    procedure InsertBankStatementLine(BankStatementHeaderCZB: Record "Bank Statement Header CZB"; Description: Text[100]; AccountNo: Text[30]; VariableSymbol: Code[10]; Amount: Decimal)
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
    begin
        BankStatementLineCZB.Init();
        BankStatementLineCZB.Validate("Bank Statement No.", BankStatementHeaderCZB."No.");
        BankStatementLineCZB.Validate("Line No.", GetNextBankStatementLineNo(BankStatementHeaderCZB));
        BankStatementLineCZB.Validate(Description, Description);
        BankStatementLineCZB.Validate("Account No.", AccountNo);
        BankStatementLineCZB.Validate("Variable Symbol", VariableSymbol);
        BankStatementLineCZB.Validate(Amount, Amount);
        BankStatementLineCZB.Insert(true);
    end;

    local procedure GetNextBankStatementLineNo(BankStatementHeaderCZB: Record "Bank Statement Header CZB"): Integer
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
    begin
        BankStatementLineCZB.SetRange("Bank Statement No.", BankStatementHeaderCZB."No.");
        BankStatementLineCZB.SetCurrentKey("Line No.");

        if BankStatementLineCZB.FindLast() then
            exit(BankStatementLineCZB."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertPaymentOrderHeader(BankAccountNo: Code[20]; DocumentDate: Date; ExternalDocumentNo: Code[35]): Record "Payment Order Header CZB"
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        PaymentOrderHeaderCZB.Init();
        PaymentOrderHeaderCZB."No." := '';
        PaymentOrderHeaderCZB.Validate("Bank Account No.", BankAccountNo);
        PaymentOrderHeaderCZB.Validate("Document Date", DocumentDate);
        PaymentOrderHeaderCZB.Validate("External Document No.", ExternalDocumentNo);
        PaymentOrderHeaderCZB.Insert(true);

        exit(PaymentOrderHeaderCZB);
    end;

    procedure InsertPaymentOrderLine(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; Type: Enum "Banking Line Type CZB"; No: Code[20]; DueDate: Date; BankAccountCode: Code[20]; VariableSymbol: Code[10]; AmountLCY: Decimal)
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.Validate("Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB.Validate("Line No.", GetNextPaymentOrderLineNo(PaymentOrderHeaderCZB));
        PaymentOrderLineCZB.Validate(Type, Type);
        PaymentOrderLineCZB.Validate("No.", No);
        PaymentOrderLineCZB.Validate("Due Date", DueDate);
        PaymentOrderLineCZB.Validate("Cust./Vendor Bank Account Code", BankAccountCode);
        PaymentOrderLineCZB.Validate("Variable Symbol", VariableSymbol);
        PaymentOrderLineCZB.Validate("Amount (LCY)", AmountLCY);
        PaymentOrderLineCZB.Insert(true);
    end;

    local procedure GetNextPaymentOrderLineNo(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"): Integer
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB.SetCurrentKey("Line No.");

        if PaymentOrderLineCZB.FindLast() then
            exit(PaymentOrderLineCZB."Line No." + 10000)
        else
            exit(10000);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateBankAccountCZB: Codeunit "Create Bank Account CZB";
    begin
        if Module <> Enum::"Contoso Demo Data Module"::Bank then
            exit;

        BindSubscription(CreateBankAccountCZB);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateBankAccountCZB: Codeunit "Create Bank Account CZB";
    begin
        if Module <> Enum::"Contoso Demo Data Module"::Bank then
            exit;

        UnbindSubscription(CreateBankAccountCZB);
    end;
}
