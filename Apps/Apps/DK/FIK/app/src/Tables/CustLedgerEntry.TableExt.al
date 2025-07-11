// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

tableextension 13610 CustLedgerEntry extends "Cust. Ledger Entry"
{
    fields
    {
        modify("Payment Method Code")
        {
            trigger OnAfterValidate();
            var
                BankAccount: Record "Bank Account";
                CustBankAcc: Record "Customer Bank Account";
                PaymentMethod: Record "Payment Method";
                FIKMgt: Codeunit FIKManagement;
            begin
                IF "Bal. Account Type" = "Bal. Account Type"::"Bank Account" THEN
                    IF PaymentMethod.GET("Payment Method Code") THEN BEGIN
                        IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::" " THEN
                            EXIT;
                        IF "Applies-to ID" = '' THEN
                            FIKMgt.CheckCustRefundPaymentTypeValidation(PaymentMethod);
                        BankAccount.GET("Bal. Account No.");
                        IF CustBankAcc.GET("Customer No.", "Recipient Bank Account") THEN
                            FIKMgt.CheckBankTransferCountryRegion(BankAccount."Country/Region Code", CustBankAcc."Country/Region Code", PaymentMethod);
                    END
            end;
        }
    }
}
