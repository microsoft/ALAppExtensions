// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13613 PurchaseHeader extends "Purchase Header"
{
    fields
    {
        field(13651; GiroAccNo; Code[8])
        {
            Caption = 'Giro Acc No.';
            trigger OnValidate();
            begin
                IF GiroAccNo <> '' THEN
                    GiroAccNo := PADSTR('', MAXSTRLEN(GiroAccNo) - STRLEN(GiroAccNo), '0') + GiroAccNo;
            end;
        }
        modify("Creditor No.")
        {
            trigger OnBeforeValidate();
            var
                FIKManagement: Codeunit FIKManagement;
            begin
                IF "Creditor No." <> '' THEN
                    "Creditor No." := FIKManagement.FormValidCreditorNo("Creditor No.");
            end;
        }
        modify("Payment Method Code")
        {
            trigger OnAfterValidate();
            var
                PaymentMethod: Record "Payment Method";
            begin
                IF PaymentMethod.GET("Payment Method Code") THEN
                    IF PaymentMethod.PaymentTypeValidation IN [PaymentMethod.PaymentTypeValidation::"FIK 01", PaymentMethod.PaymentTypeValidation::"FIK 73"] THEN
                        "Payment Reference" := '';
            end;
        }
        modify("Payment Reference")
        {
            trigger OnAfterValidate();
            VAR
                PaymentMethod: Record "Payment Method";
                FIKManagement: Codeunit FIKManagement;
            begin
                if "Payment Reference" <> '' then begin
                    Rec.TestField("Payment Method Code");
                    PaymentMethod.GET("Payment Method Code");

                    PaymentMethod.TestField(PaymentTypeValidation);
                    CASE PaymentMethod.PaymentTypeValidation OF
                        PaymentMethod.PaymentTypeValidation::"FIK 01", PaymentMethod.PaymentTypeValidation::"FIK 73":
                            ERROR(PmtReferenceErr, FIELDCAPTION("Payment Reference"), PaymentMethod.TABLECAPTION(), "Payment Method Code");
                    end;
                    "Payment Reference" := FIKManagement.EvaluateFIK("Payment Reference", "Payment Method Code");
                end;
            end;
        }
    }
    var
        PmtReferenceErr: Label '%1 should be blank for %2 %3.';
}