// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13615 GeneralJournalLine extends "Gen. Journal Line"
{
    fields
    {
        field(13651; GiroAccNo; Code[8])
        {
            Caption = 'Giro Acc No.';
            trigger OnValidate();
            begin
                IF NOT IsForExportToPaymentFile() THEN
                    EXIT;
                IF GiroAccNo <> '' THEN BEGIN
                    IF "Recipient Bank Account" <> '' THEN
                        FIELDERROR("Recipient Bank Account",
                        STRSUBSTNO(FieldIsNotEmptyErr, FIELDCAPTION(GiroAccNo), FIELDCAPTION("Recipient Bank Account")));

                    GiroAccNo := PADSTR('', MAXSTRLEN(GiroAccNo) - STRLEN(GiroAccNo), '0') + GiroAccNo;
                END;
            end;
        }
        modify("Payment Method Code")
        {
            trigger OnBeforeValidate();
            VAR
                BankAccount: Record "Bank Account";
                PaymentMethod: Record "Payment Method";
                VendBankAcc: Record "Vendor Bank Account";
                CustBankAcc: Record "Customer Bank Account";
                FIKManagement: Codeunit FIKManagement;
            begin
                IF "Bal. Account Type" = "Bal. Account Type"::"Bank Account" THEN
                    IF PaymentMethod.GET("Payment Method Code") THEN BEGIN
                        IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::" " THEN
                            EXIT;
                        BankAccount.GET("Bal. Account No.");
                        CASE "Account Type" OF
                            "Account Type"::Customer:
                                BEGIN
                                    FIKManagement.CheckCustRefundPaymentTypeValidation(PaymentMethod);
                                    IF CustBankAcc.GET("Account No.", "Recipient Bank Account") THEN
                                        FIKManagement.CheckBankTransferCountryRegion(BankAccount."Country/Region Code", CustBankAcc."Country/Region Code", PaymentMethod);
                                END;
                            "Account Type"::Vendor:
                                BEGIN
                                    IF VendBankAcc.GET("Account No.", "Recipient Bank Account") THEN
                                        FIKManagement.CheckBankTransferCountryRegion(BankAccount."Country/Region Code", VendBankAcc."Country/Region Code", PaymentMethod);
                                    CASE PaymentMethod.PaymentTypeValidation OF
                                        PaymentMethod.PaymentTypeValidation::"FIK 01", PaymentMethod.PaymentTypeValidation::"FIK 73":
                                            "Payment Reference" := '';
                                        PaymentMethod.PaymentTypeValidation::"FIK 04", PaymentMethod.PaymentTypeValidation::"FIK 71":
                                            "Payment Reference" := FIKManagement.EvaluateFIK("Payment Reference", "Payment Method Code");
                                    END;
                                    UpdateVendorPaymentDetails();
                                END
                        END
                    END
            end;
        }
        modify("Creditor No.")
        {
            trigger OnBeforeValidate();
            var
                FIKManagement: Codeunit FIKManagement;
            begin
                IF NOT IsForExportToPaymentFile() THEN
                    EXIT;

                IF "Creditor No." <> '' THEN BEGIN
                    IF "Recipient Bank Account" <> '' THEN
                        FIELDERROR("Recipient Bank Account",
                          STRSUBSTNO(FieldIsNotEmptyErr, FIELDCAPTION("Creditor No."), FIELDCAPTION("Recipient Bank Account")));

                    "Creditor No." := FIKManagement.FormValidCreditorNo("Creditor No.");
                END;
            end;

        }
        modify("Payment Reference")
        {
            trigger OnBeforeValidate();
            var
                PaymentMethod: Record "Payment Method";
                FIKManagement: Codeunit FIKManagement;
            begin
                IF "Account Type" = "Account Type"::Vendor THEN
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
        modify("Recipient Bank Account")
        {
            trigger OnBeforeValidate();
            begin
                IF IsForExportToPaymentFile() THEN BEGIN
                    UpdateVendorPaymentDetails();
                    IF ("Recipient Bank Account" <> '') AND ("Creditor No." <> '') THEN
                        FIELDERROR("Creditor No.",
                          STRSUBSTNO(FieldIsNotEmptyErr, FIELDCAPTION("Recipient Bank Account"), FIELDCAPTION("Creditor No.")));
                    EXIT;
                END;
            end;
        }
    }

    var
        FieldIsNotEmptyErr: Label '%1 cannot be used while %2 has a value.', Comment = '%1=Field;%2=Field';
        PmtReferenceErr: Label '%1 should be blank for %2 %3.', Comment = '%1=Field;%2=Table;%3=Field"';

    PROCEDURE UpdateVendorPaymentDetails();
    VAR
        PaymentMethod: Record "Payment Method";
    BEGIN
        IF PaymentMethod.GET("Payment Method Code") THEN
            CASE PaymentMethod.PaymentTypeValidation OF
                PaymentMethod.PaymentTypeValidation::"FIK 01", PaymentMethod.PaymentTypeValidation::"FIK 04":
                    BEGIN
                        "Creditor No." := '';
                        "Recipient Bank Account" := '';
                    END;
                PaymentMethod.PaymentTypeValidation::"FIK 71", PaymentMethod.PaymentTypeValidation::"FIK 73":
                    BEGIN
                        GiroAccNo := '';
                        "Recipient Bank Account" := '';
                    END;
                PaymentMethod.PaymentTypeValidation::Domestic, PaymentMethod.PaymentTypeValidation::International:
                    BEGIN
                        "Creditor No." := '';
                        GiroAccNo := '';
                    END;
                else
                    OnUpdateVendorPaymentDetailsCasePaymentTypeValidationElse(Rec, PaymentMethod.PaymentTypeValidation);
            END;
    END;

    PROCEDURE IsForExportToPaymentFile(): Boolean;
    VAR
        PaymentMethod: Record "Payment Method";
    begin
        ;
        IF PaymentMethod.GET("Payment Method Code") THEN
            EXIT(PaymentMethod.PaymentTypeValidation <> PaymentMethod.PaymentTypeValidation::" ");

        EXIT(FALSE);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVendorPaymentDetailsCasePaymentTypeValidationElse(var GenJournalLine: Record "Gen. Journal Line"; PaymentTypeValidation: Enum "Payment Type Validation")
    begin
    end;
}