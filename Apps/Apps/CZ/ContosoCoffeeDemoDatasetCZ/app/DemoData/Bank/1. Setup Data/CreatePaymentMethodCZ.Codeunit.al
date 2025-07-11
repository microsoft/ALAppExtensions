// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool.Helpers;
using Microsoft.Bank.Payment;

codeunit 31206 "Create Payment Method CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.InsertBankPaymentMethod(COD(), CashondeliverypaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
        ContosoPayments.InsertBankPaymentMethod(COMPENS(), PaidbycompensationLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
    end;


    procedure COD(): Code[10]
    begin
        exit(CODTok);
    end;

    procedure COMPENS(): Code[10]
    begin
        exit(COMPENSTok);
    end;

    var
        CODTok: Label 'COD', MaxLength = 10, Comment = 'Cash on delivery';
        CashondeliverypaymentLbl: Label 'Cash on delivery payment', MaxLength = 100;
        COMPENSTok: Label 'COMPENS', MaxLength = 10, Comment = 'Compensation';
        PaidbycompensationLbl: Label 'Paid by compensation', MaxLength = 100;
}
