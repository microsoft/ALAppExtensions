// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
using Microsoft.Finance.Currency;

table 31013 "Advance Posting Buffer CZZ"
{
    Caption = 'Advance Posting Buffer';
    ReplicateData = false;
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(8; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
        }
        field(12; "VAT Calculation Type"; Enum "Tax Calculation Type")
        {
            Caption = 'VAT Calculation Type';
        }
        field(14; "VAT Base Amount"; Decimal)
        {
            Caption = 'VAT Base Amount';
        }
        field(25; "Amount (ACY)"; Decimal)
        {
            Caption = 'Amount (ACY)';
        }
        field(26; "VAT Amount (ACY)"; Decimal)
        {
            Caption = 'VAT Amount (ACY)';
        }
        field(29; "VAT Base Amount (ACY)"; Decimal)
        {
            Caption = 'VAT Base Amount (ACY)';
        }
        field(32; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DecimalPlaces = 1 : 1;
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
            Clustered = true;
        }
    }

    procedure PrepareForPurchAdvLetterEntry(var PurchAdvLetterEntry: Record "Purch. Adv. Letter Entry CZZ")
    begin
        Clear(Rec);
        "VAT Bus. Posting Group" := PurchAdvLetterEntry."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := PurchAdvLetterEntry."VAT Prod. Posting Group";
        "VAT Calculation Type" := PurchAdvLetterEntry."VAT Calculation Type";
        "VAT %" := PurchAdvLetterEntry."VAT %";
        Amount := PurchAdvLetterEntry.Amount;
        "VAT Base Amount" := PurchAdvLetterEntry."VAT Base Amount";
        "VAT Amount" := PurchAdvLetterEntry."VAT Amount";
        "Amount (ACY)" := PurchAdvLetterEntry."Amount (LCY)";
        "VAT Base Amount (ACY)" := PurchAdvLetterEntry."VAT Base Amount (LCY)";
        "VAT Amount (ACY)" := PurchAdvLetterEntry."VAT Amount (LCY)";
        OnAfterPrepareForPurchAdvLetterEntry(PurchAdvLetterEntry, Rec);
    end;

    procedure PrepareForPurchAdvLetterLine(var PurchAdvLetterLine: Record "Purch. Adv. Letter Line CZZ")
    begin
        Clear(Rec);
        "VAT Bus. Posting Group" := PurchAdvLetterLine."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := PurchAdvLetterLine."VAT Prod. Posting Group";
        "VAT Calculation Type" := PurchAdvLetterLine."VAT Calculation Type";
        "VAT %" := PurchAdvLetterLine."VAT %";
        Amount := PurchAdvLetterLine."Amount Including VAT";
        "VAT Base Amount" := PurchAdvLetterLine.Amount;
        "VAT Amount" := PurchAdvLetterLine."VAT Amount";
        "Amount (ACY)" := PurchAdvLetterLine."Amount Including VAT (LCY)";
        "VAT Base Amount (ACY)" := PurchAdvLetterLine."Amount (LCY)";
        "VAT Amount (ACY)" := PurchAdvLetterLine."VAT Amount (LCY)";
        OnAfterPrepareForPurchAdvLetterLine(PurchAdvLetterLine, Rec);
    end;

    procedure PrepareForSalesAdvLetterEntry(var SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ")
    begin
        Clear(Rec);
        "VAT Bus. Posting Group" := SalesAdvLetterEntry."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := SalesAdvLetterEntry."VAT Prod. Posting Group";
        "VAT Calculation Type" := SalesAdvLetterEntry."VAT Calculation Type";
        "VAT %" := SalesAdvLetterEntry."VAT %";
        Amount := SalesAdvLetterEntry.Amount;
        "VAT Base Amount" := SalesAdvLetterEntry."VAT Base Amount";
        "VAT Amount" := SalesAdvLetterEntry."VAT Amount";
        "Amount (ACY)" := SalesAdvLetterEntry."Amount (LCY)";
        "VAT Base Amount (ACY)" := SalesAdvLetterEntry."VAT Base Amount (LCY)";
        "VAT Amount (ACY)" := SalesAdvLetterEntry."VAT Amount (LCY)";
        OnAfterPrepareForSalesAdvLetterEntry(SalesAdvLetterEntry, Rec);
    end;

    procedure PrepareForSalesAdvLetterLine(var SalesAdvLetterLine: Record "Sales Adv. Letter Line CZZ")
    begin
        Clear(Rec);
        "VAT Bus. Posting Group" := SalesAdvLetterLine."VAT Bus. Posting Group";
        "VAT Prod. Posting Group" := SalesAdvLetterLine."VAT Prod. Posting Group";
        "VAT Calculation Type" := SalesAdvLetterLine."VAT Calculation Type";
        "VAT %" := SalesAdvLetterLine."VAT %";
        Amount := SalesAdvLetterLine."Amount Including VAT";
        "VAT Base Amount" := SalesAdvLetterLine.Amount;
        "VAT Amount" := SalesAdvLetterLine."VAT Amount";
        "Amount (ACY)" := SalesAdvLetterLine."Amount Including VAT (LCY)";
        "VAT Base Amount (ACY)" := SalesAdvLetterLine."Amount (LCY)";
        "VAT Amount (ACY)" := SalesAdvLetterLine."VAT Amount (LCY)";
        OnAfterPrepareForSalesAdvLetterLine(SalesAdvLetterLine, Rec);
    end;

    procedure Update(AdvancePostingBuffer: Record "Advance Posting Buffer CZZ")
    begin
        OnBeforeUpdate(Rec, AdvancePostingBuffer);

        Rec := AdvancePostingBuffer;
        if Find() then begin
            Amount += AdvancePostingBuffer.Amount;
            "VAT Base Amount" += AdvancePostingBuffer."VAT Base Amount";
            "VAT Amount" += AdvancePostingBuffer."VAT Amount";
            "Amount (ACY)" += AdvancePostingBuffer."Amount (ACY)";
            "VAT Base Amount (ACY)" += AdvancePostingBuffer."VAT Base Amount (ACY)";
            "VAT Amount (ACY)" += AdvancePostingBuffer."VAT Amount (ACY)";
            OnUpdateOnBeforeModify(Rec, AdvancePostingBuffer);
            Modify();
            OnUpdateOnAfterModify(Rec, AdvancePostingBuffer);
        end else
            Insert();

        OnAfterUpdate(Rec, AdvancePostingBuffer);
    end;

    procedure UpdateLCYAmounts(CurrencyCode: Code[10]; CurrencyFactor: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if (CurrencyCode = '') or (CurrencyFactor = 0) then begin
            Rec."VAT Base Amount (ACY)" := Rec."VAT Base Amount";
            Rec."VAT Amount (ACY)" := Rec."VAT Amount";
            Rec."Amount (ACY)" := Rec.Amount;
        end else begin
            Rec."Amount (ACY)" :=
              Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                  0D, CurrencyCode,
                  Rec.Amount, CurrencyFactor));
            Rec."VAT Amount (ACY)" :=
              Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                  0D, CurrencyCode,
                  Rec."VAT Amount", CurrencyFactor));
            Rec."VAT Base Amount (ACY)" := Rec."Amount (ACY)" - Rec."VAT Amount (ACY)";
        end;
    end;

    procedure RecalcAmountsByCoefficient(Coeff: Decimal)
    begin
        Amount := Round(Amount * Coeff);
        case "VAT Calculation Type" of
            "VAT Calculation Type"::"Normal VAT":
                "VAT Amount" := Round(Amount * "VAT %" / (100 + "VAT %"));
            "VAT Calculation Type"::"Reverse Charge VAT":
                "VAT Amount" := 0;
        end;
        "VAT Base Amount" := Amount - "VAT Amount";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrepareForPurchAdvLetterEntry(var PurchAdvLetterEntry: Record "Purch. Adv. Letter Entry CZZ"; var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrepareForPurchAdvLetterLine(var PurchAdvLetterLine: Record "Purch. Adv. Letter Line CZZ"; var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrepareForSalesAdvLetterEntry(var SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrepareForSalesAdvLetterLine(var SalesAdvLetterLine: Record "Sales Adv. Letter Line CZZ"; var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdate(var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary; var FormAdvancePostingBuffer: Record "Advance Posting Buffer CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateOnBeforeModify(var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary; var FormAdvancePostingBuffer: Record "Advance Posting Buffer CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateOnAfterModify(var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary; var FormAdvancePostingBuffer: Record "Advance Posting Buffer CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdate(var AdvancePostingBuffer: Record "Advance Posting Buffer CZZ" temporary; var FormAdvancePostingBuffer: Record "Advance Posting Buffer CZZ")
    begin
    end;
}
