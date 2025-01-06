// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Payments;

using Microsoft.eServices.EDocument;

table 6101 "E-Document Payment"
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
        }
        field(2; "Payment No."; Integer)
        {
            Caption = 'Payment No.';
            AutoIncrement = true;
        }
        field(20; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(21; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 2;

            trigger OnValidate()
            begin
                this.CalculateVAT();
            end;
        }
        field(22; "VAT Base"; Decimal)
        {
            Caption = 'VAT Base';
            DecimalPlaces = 2;
        }
        field(23; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DecimalPlaces = 2;
        }
        field(24; Status; Enum "Payment Status")
        {
            Caption = 'Status';
        }
        field(25; Direction; Enum "E-Document Direction")
        {
            Caption = 'Direction';
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.", "Payment No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if Rec.Status = Rec.Status::" " then
            Rec.Status := Rec.Status::Created;
    end;

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
}