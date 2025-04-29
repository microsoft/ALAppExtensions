// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoTool.Helpers;

using Microsoft.Foundation.PaymentTerms;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Payment;

codeunit 5569 "Contoso Payments"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Payment Terms" = rim,
        tabledata "Payment Method" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertPaymentTerms(Code: Code[10]; DueDateCalculation: Text[30]; DiscountDateCalculation: Text[30]; DiscountPer: Decimal; Description: Text[100])
    var
        PaymentTerms: Record "Payment Terms";
        Exists: Boolean;
    begin
        if PaymentTerms.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PaymentTerms.Validate(Code, Code);
        Evaluate(PaymentTerms."Due Date Calculation", DueDateCalculation);
        PaymentTerms.Validate("Due Date Calculation");

        Evaluate(PaymentTerms."Discount Date Calculation", DiscountDateCalculation);
        PaymentTerms.Validate("Discount Date Calculation");

        PaymentTerms.Validate("Discount %", DiscountPer);
        PaymentTerms.Validate(Description, Description);

        if Exists then
            PaymentTerms.Modify(true)
        else
            PaymentTerms.Insert(true);
    end;

    procedure InsertBankPaymentMethod(Code: Code[10]; Description: Text[100]; BalAccountType: Enum "Payment Balance Account Type"; BalAccountNo: Code[20])
    var
        PaymentMethod: Record "Payment Method";
        Exists: Boolean;
    begin
        if PaymentMethod.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        PaymentMethod.Validate(Code, Code);
        PaymentMethod.Validate(Description, Description);
        PaymentMethod.Validate("Bal. Account Type", BalAccountType);
        PaymentMethod.Validate("Bal. Account No.", BalAccountNo);

        if Exists then
            PaymentMethod.Modify(true)
        else
            PaymentMethod.Insert(true);
    end;
}
