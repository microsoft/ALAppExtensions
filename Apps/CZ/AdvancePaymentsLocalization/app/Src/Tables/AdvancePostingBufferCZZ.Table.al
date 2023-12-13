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
}
