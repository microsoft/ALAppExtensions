// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13612 VendorLedgerEntry extends "Vendor Ledger Entry"
{
    fields
    {
        field(13651; GiroAccNo; Code[8])
        {
            Caption = 'Giro Acc No.';
            trigger OnValidate();
            begin
                IF (GiroAccNo <> '') THEN
                    IF ("Recipient Bank Account" <> '') THEN
                        FIELDERROR("Recipient Bank Account", STRSUBSTNO(FieldIsNotEmptyErr, FIELDCAPTION(GiroAccNo), FIELDCAPTION("Recipient Bank Account")))
                    ELSE
                        GiroAccNo := PADSTR('', MAXSTRLEN(GiroAccNo) - STRLEN(GiroAccNo), '0') + GiroAccNo;
            end;
        }
        modify("Payment Reference")
        {
            trigger OnBeforeValidate();
            var
                PaymentMethod: Record "Payment Method";
                FIKManagement: Codeunit FIKManagement;
            begin
                IF "Payment Reference" <> '' THEN BEGIN
                    Rec.TESTFIELD("Payment Method Code");
                    PaymentMethod.GET("Payment Method Code");
                    BEGIN
                        PaymentMethod.TESTFIELD(PaymentTypeValidation);
                        CASE PaymentMethod.PaymentTypeValidation OF
                            PaymentMethod.PaymentTypeValidation::"FIK 01",
                        PaymentMethod.PaymentTypeValidation::"FIK 73":
                                ERROR(PmtReferenceErr, FIELDCAPTION("Payment Reference"), PaymentMethod.TABLECAPTION(), "Payment Method Code");
                        END;
                        "Payment Reference" := FIKManagement.EvaluateFIK("Payment Reference", "Payment Method Code");
                    END;
                END;
            end;
        }
        modify("Payment Method Code")
        {
            trigger OnAfterValidate();
            VAR
                BankAccount: Record "Bank Account";
                PaymentMethod: Record "Payment Method";
                VendBankAcc: Record "Vendor Bank Account";
                FIKManagement: Codeunit FIKManagement;
            begin
                IF "Bal. Account Type" = "Bal. Account Type"::"Bank Account" THEN
                    IF PaymentMethod.GET("Payment Method Code") THEN BEGIN
                        IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::" " THEN
                            EXIT;
                        BankAccount.GET("Bal. Account No.");
                        CASE PaymentMethod.PaymentTypeValidation OF
                            PaymentMethod.PaymentTypeValidation::"FIK 01", PaymentMethod.PaymentTypeValidation::"FIK 73":
                                "Payment Reference" := '';
                            PaymentMethod.PaymentTypeValidation::"FIK 04", PaymentMethod.PaymentTypeValidation::"FIK 71":
                                "Payment Reference" := FIKManagement.EvaluateFIK("Payment Reference", "Payment Method Code");
                        END;
                        IF VendBankAcc.GET("Vendor No.", "Recipient Bank Account") THEN
                            FIKManagement.CheckBankTransferCountryRegion(BankAccount."Country/Region Code", VendBankAcc."Country/Region Code", PaymentMethod);
                    END
            end;
        }
        modify("Creditor No.")
        {
            trigger OnBeforeValidate();
            var
                FIKManagement: Codeunit FIKManagement;
            begin
                IF ("Creditor No." <> '') THEN
                    IF ("Recipient Bank Account" <> '') THEN
                        FIELDERROR("Recipient Bank Account", STRSUBSTNO(FieldIsNotEmptyErr, FIELDCAPTION("Creditor No."), FIELDCAPTION("Recipient Bank Account")))
                    ELSE
                        "Creditor No." := FIKManagement.FormValidCreditorNo("Creditor No.");
            end;
        }
    }
    var
        FieldIsNotEmptyErr: Label '%1 cannot be used while %2 has a value.';
        PmtReferenceErr: Label '%1 should be blank for %2 %3.', Comment = '%1=Field;%2=Table;%3=Field';
}