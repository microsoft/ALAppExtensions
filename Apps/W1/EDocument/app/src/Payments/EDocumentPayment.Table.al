// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Payments;

using Microsoft.eServices.EDocument;

table 6107 "E-Document Payment"
{
    Caption = 'E-Document Payment';
    DataClassification = CustomerContent;
    DrillDownPageId = "E-Document Payments";
    LookupPageId = "E-Document Payments";

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            TableRelation = "E-Document"."Entry No";
            AllowInCustomizations = Always;

            trigger OnValidate()
            begin
                this.SetPaymentDirection();
            end;
        }
        field(2; "Payment No."; Integer)
        {
            Caption = 'Payment No.';
            AutoIncrement = true;
            AllowInCustomizations = Always;
        }
        field(20; Date; Date)
        {
            Caption = 'Date';
            ToolTip = 'Specifies the date when the payment was made.';
        }
        field(21; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 2;
            ToolTip = 'Specifies the total payment amount including VAT.';

            trigger OnValidate()
            begin
                this.CalculateVAT();
            end;
        }
        field(22; "VAT Base"; Decimal)
        {
            Caption = 'VAT Base';
            DecimalPlaces = 2;
            Editable = false;
            ToolTip = 'Specifies the net amount used as basis for VAT calculation for this payment transaction.';
        }
        field(23; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DecimalPlaces = 2;
            Editable = false;
            ToolTip = 'Specifies the calculated tax amount for this payment transaction.';
        }
        field(24; Status; Enum "Payment Status")
        {
            Caption = 'Status';
            Editable = false;
            InitValue = Created;
            ToolTip = 'Specifies the current state of the payment.';
        }
        field(25; Direction; Enum "E-Document Direction")
        {
            Caption = 'Direction';
            Editable = false;
            ToolTip = 'Specifies whether this payment is being received (incoming) or sent (outgoing).';
        }
    }

    keys
    {
        key(PK; "E-Document Entry No.", "Payment No.")
        {
            Clustered = true;
        }
    }

    local procedure CalculateVAT()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocLog: Codeunit "E-Document Log";
    begin
        EDocument.Get(Rec."E-Document Entry No.");
        EDocumentService := EDocLog.GetLastServiceFromLog(EDocument);
        if not EDocumentService."Calculate Payment VAT" then
            exit;

        Rec."VAT Base" := Rec.Amount / (EDocument."Amount Incl. VAT" / EDocument."Amount Excl. VAT");
        Rec."VAT Amount" := Rec.Amount - Rec."VAT Base";
    end;

    local procedure SetPaymentDirection()
    var
        EDocument: Record "E-Document";
    begin
        EDocument.Get(Rec."E-Document Entry No.");
        if EDocument.Direction = EDocument.Direction::Outgoing then
            Rec.Direction := Rec.Direction::Incoming
        else
            Rec.Direction := Rec.Direction::Outgoing;
    end;
}