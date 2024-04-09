// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.VAT.Clause;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;

table 31005 "Sales Adv. Letter Line CZZ"
{
    Caption = 'Sales Adv. Letter Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "Sales Adv. Letter Lines CZZ";
    LookupPageID = "Sales Adv. Letter Lines CZZ";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Adv. Letter Header CZZ";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                Validate("VAT Prod. Posting Group");
            end;
        }
        field(11; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate()
            var
                VATPostingSetup: Record "VAT Posting Setup";
                IsHandled: Boolean;
            begin
                TestStatusOpen();
                if "VAT Prod. Posting Group" = '' then begin
                    "VAT Bus. Posting Group" := '';
                    Validate("Amount Including VAT", 0);
                    exit;
                end;

                if "VAT Bus. Posting Group" = '' then begin
                    GetHeader();
                    "VAT Bus. Posting Group" := SalesAdvLetterHeaderCZZ."VAT Bus. Posting Group";
                end;

                VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");

                "VAT %" := VATPostingSetup."VAT %";
                "VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                "VAT Identifier" := VATPostingSetup."VAT Identifier";
                "VAT Clause Code" := VATPostingSetup."VAT Clause Code";

                IsHandled := false;
                OnValidateVATProdPostingGroupOnBeforeCheckVATCalcType(Rec, VATPostingSetup, IsHandled);
                if not IsHandled then begin
                    if not (VATPostingSetup."VAT Calculation Type" in ["Tax Calculation Type"::"Normal VAT", "Tax Calculation Type"::"Reverse Charge VAT"]) then
                        VATPostingSetup.FieldError("VAT Calculation Type");
                    if "VAT Calculation Type" = "Tax Calculation Type"::"Reverse Charge VAT" then
                        "VAT %" := 0;
                end;

                OnValidateVATProdPostingGroupOnBeforeUpdateAmounts(Rec, xRec);
                UpdateAmounts();
            end;
        }
        field(15; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
                ModifyAmountErr: Label 'You cannot modify %1 because Advance Letter is linked to Document.', Comment = '%1 = Amount Including VAT FieldCaption';
            begin
                TestStatusOpen();
                AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
                AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", Rec."Document No.");
                if not AdvanceLetterApplicationCZZ.IsEmpty() then
                    Error(ModifyAmountErr, FieldCaption("Amount Including VAT"));
                UpdateAmounts();
            end;
        }
        field(20; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "VAT Amount (LCY)"; Decimal)
        {
            Caption = 'VAT Amount (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "Amount Including VAT (LCY)"; Decimal)
        {
            Caption = 'Amount Including VAT (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(26; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(28; "VAT Clause Code"; Code[20])
        {
            Caption = 'VAT Clause Code';
            DataClassification = CustomerContent;
            TableRelation = "VAT Clause";
        }
    }
    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        TestStatusOpen();
    end;

    trigger OnDelete()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnDeleteOnBeforeTestStatusOpen(Rec, IsHandled);
        if not IsHandled then
            TestStatusOpen();
    end;

    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        Currency: Record Currency;

    local procedure UpdateAmounts()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        IsHandled: Boolean;
    begin
        TestField("VAT Prod. Posting Group");

        IsHandled := false;
        OnBeforeUpdateAmounts(Rec, xRec, CurrFieldNo, IsHandled);
        if IsHandled then
            exit;

        GetHeader();
        "Amount Including VAT" := Round("Amount Including VAT", Currency."Amount Rounding Precision");
        case "VAT Calculation Type" of
            "VAT Calculation Type"::"Normal VAT":
                "VAT Amount" :=
                  Round("Amount Including VAT" * "VAT %" / (100 + "VAT %"),
                    Currency."Amount Rounding Precision",
                    Currency.VATRoundingDirection());
            "VAT Calculation Type"::"Reverse Charge VAT":
                "VAT Amount" := 0;
        end;

        Amount := "Amount Including VAT" - "VAT Amount";

        if SalesAdvLetterHeaderCZZ."Currency Code" = '' then begin
            "Amount (LCY)" := Amount;
            "VAT Amount (LCY)" := "VAT Amount";
            "Amount Including VAT (LCY)" := "Amount Including VAT";
        end else begin
            "Amount Including VAT (LCY)" :=
              Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                  SalesAdvLetterHeaderCZZ."Posting Date", SalesAdvLetterHeaderCZZ."Currency Code",
                  "Amount Including VAT", SalesAdvLetterHeaderCZZ."Currency Factor"));
            "VAT Amount (LCY)" :=
              Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                  SalesAdvLetterHeaderCZZ."Posting Date", SalesAdvLetterHeaderCZZ."Currency Code",
                  "VAT Amount", SalesAdvLetterHeaderCZZ."Currency Factor"));
            "Amount (LCY)" := "Amount Including VAT (LCY)" - "VAT Amount (LCY)";
        end;

        OnAfterUpdateAmounts(Rec, xRec, CurrFieldNo);
    end;

    procedure GetHeader()
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetHeader(Rec, SalesAdvLetterHeaderCZZ, IsHandled, Currency);
        if IsHandled then
            exit;

        TestField("Document No.");
        if "Document No." <> SalesAdvLetterHeaderCZZ."No." then begin
            SalesAdvLetterHeaderCZZ.Get("Document No.");
            if SalesAdvLetterHeaderCZZ."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                SalesAdvLetterHeaderCZZ.TestField("Currency Factor");
                Currency.Get(SalesAdvLetterHeaderCZZ."Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
        end;

        OnAfterGetHeader(Rec, SalesAdvLetterHeaderCZZ, Currency);
    end;

    procedure TestStatusOpen()
    begin
        GetHeader();
        OnBeforeTestStatusOpen(Rec, SalesAdvLetterHeaderCZZ);

        SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::New);

        OnAfterTestStatusOpen(Rec, SalesAdvLetterHeaderCZZ);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVATProdPostingGroupOnBeforeCheckVATCalcType(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; VATPostingSetup: Record "VAT Posting Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateVATProdPostingGroupOnBeforeUpdateAmounts(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; xSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetHeader(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHanded: Boolean; var Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetHeader(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAmounts(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; xSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CurrentFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAmounts(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var xSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; CurrentFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestStatusOpen(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestStatusOpen(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteOnBeforeTestStatusOpen(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var IsHandled: Boolean)
    begin
    end;
}
