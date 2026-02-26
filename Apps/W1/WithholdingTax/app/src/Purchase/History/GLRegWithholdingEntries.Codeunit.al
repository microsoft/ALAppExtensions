// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.WithholdingTax;

codeunit 6788 "G/L Reg.-Withholding Entries"
{
    TableNo = "G/L Register";

    trigger OnRun()
    begin
        WithholdingTaxEntry.SetRange("Entry No.", Rec."From Withholding Tax Entry No.", Rec."To Withholding Tax Entry No.");
        PAGE.Run(PAGE::"Withholding Tax Entries", WithholdingTaxEntry);
    end;

    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
}

