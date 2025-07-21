// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool.Helpers;
using Microsoft.Bank.Payment;

codeunit 19058 "Create IN Payment Method"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPayments: Codeunit "Contoso Payments";
    begin
        ContosoPayments.InsertBankPaymentMethod(Cheque(), ChequePaymentLbl, Enum::"Payment Balance Account Type"::"G/L Account", '');
    end;

    procedure Cheque(): Code[10]
    begin
        exit(ChequeTok);
    end;

    var
        ChequeTok: Label 'CHEQUE', MaxLength = 10;
        ChequePaymentLbl: Label 'Cheque payment', MaxLength = 100;
}
