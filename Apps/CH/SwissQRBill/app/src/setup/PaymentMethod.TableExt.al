// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

using Microsoft.Bank.Payment;

tableextension 11512 "Swiss QR-Bill Payment Method" extends "Payment Method"
{
    fields
    {
        field(11510; "Swiss QR-Bill Layout"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Swiss QR-Bill Layout";
            Caption = 'QR-Bill Layout';
        }
        field(11511; "Swiss QR-Bill Bank Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Bank Account";
            Caption = 'QR-Bill Bank Account No.';
        }

        modify("Bal. Account No.")
        {
            trigger OnAfterValidate()
            begin
                if ("Bal. Account Type" = "Bal. Account Type"::"Bank Account") and
                   ("Bal. Account No." <> '') and ("Swiss QR-Bill Bank Account No." <> "Bal. Account No.")
                then
                    if "Swiss QR-Bill Bank Account No." = '' then
                        "Swiss QR-Bill Bank Account No." := "Bal. Account No."
                    else
                        if Confirm(ChangeQRBillBankAccountQst) then
                            "Swiss QR-Bill Bank Account No." := "Bal. Account No.";
            end;
        }
    }

    var
        ChangeQRBillBankAccountQst: Label 'Do you want to copy Bal. Acount No. to the QR-Bill Bank Account No.?';
}
