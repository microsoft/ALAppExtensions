// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Sales.Customer;

codeunit 144043 "Library - Localization FR"
{
    // Library containing functions specific to FR Localization objects, hence meant to be kept at FR Branch Only.


    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account"; CustomerNo: Code[20])
    begin
        CustomerBankAccount.Init();
        CustomerBankAccount.Validate("Customer No.", CustomerNo);
        CustomerBankAccount.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo(Code), DATABASE::"Customer Bank Account"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Customer Bank Account", CustomerBankAccount.FieldNo(Code))));
        CustomerBankAccount.Insert(true);
    end;

    procedure CreatePaymentClass(var PaymentClass: Record "Payment Class FR")
    begin
        PaymentClass.Init();
        PaymentClass.Validate(Code, LibraryUtility.GenerateRandomCode(PaymentClass.FieldNo(Code), DATABASE::"Payment Class FR"));
        PaymentClass.Insert(true);
    end;

    procedure CreatePaymentHeader(var PaymentHeader: Record "Payment Header FR")
    begin
        PaymentHeader.Init();
        PaymentHeader.Insert(true);
    end;

    procedure CreatePaymentLine(var PaymentLine: Record "Payment Line FR"; No: Code[20])
    var
        RecRef: RecordRef;
    begin
        PaymentLine.Init();
        PaymentLine.Validate("No.", No);
        RecRef.GetTable(PaymentLine);
        PaymentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, PaymentLine.FieldNo("Line No.")));
        PaymentLine.Insert(true);
    end;

    procedure CreatePaymentStatus(var PaymentStatus: Record "Payment Status FR"; PaymentClass: Text[30])
    var
        RecRef: RecordRef;
    begin
        PaymentStatus.Init();
        PaymentStatus.Validate("Payment Class", PaymentClass);
        RecRef.GetTable(PaymentStatus);
        PaymentStatus.Validate(Line, LibraryUtility.GetNewLineNo(RecRef, PaymentStatus.FieldNo(Line)));
        PaymentStatus.Insert(true);
    end;

    procedure CreatePaymentStep(var PaymentStep: Record "Payment Step FR"; PaymentClass: Text[30])
    var
        RecRef: RecordRef;
    begin
        PaymentStep.Init();
        PaymentStep.Validate("Payment Class", PaymentClass);
        RecRef.GetTable(PaymentStep);
        PaymentStep.Validate(Line, LibraryUtility.GetNewLineNo(RecRef, PaymentStep.FieldNo(Line)));
        PaymentStep.Insert(true);
    end;

    procedure CreatePaymentStepLedger(var PaymentStepLedger: Record "Payment Step Ledger FR"; PaymentClass: Text[30]; Sign: Option; Line: Integer)
    begin
        PaymentStepLedger.Init();
        PaymentStepLedger.Validate("Payment Class", PaymentClass);
        PaymentStepLedger.Validate(Sign, Sign);
        PaymentStepLedger.Validate(Line, Line);
        PaymentStepLedger.Insert(true);
    end;

    procedure CreatePaymentSlip()
    begin
        CODEUNIT.Run(CODEUNIT::"Payment Management FR");
    end;
}

