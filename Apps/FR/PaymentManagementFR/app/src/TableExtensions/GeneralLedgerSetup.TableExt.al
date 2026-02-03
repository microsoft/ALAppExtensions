// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;
using Microsoft.Finance.GeneralLedger.Setup;


tableextension 10834 "General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        modify("Unrealized VAT")
        {
            trigger OnAfterValidate()
            begin
                if not "Unrealized VAT" then begin
                    PaymentClass.SetFilter(
                      PaymentClass."Unrealized VAT Reversal", '=%1', PaymentClass."Unrealized VAT Reversal"::Delayed);
                    if PaymentClass.Find('-') then
                        Error(
                          Text10801Lbl, PaymentClass.TableCaption(), PaymentClass.Code,
                          PaymentClass.FieldCaption("Unrealized VAT Reversal"), PaymentClass."Unrealized VAT Reversal");
                end
            end;
        }
    }
    var
        PaymentClass: Record "Payment Class FR";
        Text10801Lbl: Label '%1 %2 has %3 set to %4.', Comment = '%1 = Table Caption, %2 = Code, %3 = field caption, %4 = Unrealized VAT Reversal';
}