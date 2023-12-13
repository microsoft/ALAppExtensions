// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;

page 31186 "VAT Document Line CZZ"
{
    PageType = ListPart;
    Caption = 'VAT Document Line';
    SourceTable = "Advance Posting Buffer CZZ";
    SourceTableTemporary = true;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT bus. posting group.';

                    trigger OnValidate()
                    var
                        VATBusPostGr: Code[20];
                    begin
                        VATBusPostGr := Rec."VAT Bus. Posting Group";
                        Rec.Init();
                        Rec."VAT Bus. Posting Group" := VATBusPostGr;
                    end;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT prod. posting group.';

                    trigger OnValidate()
                    var
                        VATPostingSetup: Record "VAT Posting Setup";
                    begin
                        VATPostingSetup.Get(Rec."VAT Bus. Posting Group", Rec."VAT Prod. Posting Group");
                        if not (VATPostingSetup."VAT Calculation Type" in ["Tax Calculation Type"::"Normal VAT", "Tax Calculation Type"::"Reverse Charge VAT"]) then
                            VATPostingSetup.FieldError("VAT Calculation Type");

                        Rec."VAT %" := VATPostingSetup."VAT %";
                        Rec."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
                        if Rec."VAT Calculation Type" = Rec."VAT Calculation Type"::"Reverse Charge VAT" then
                            Rec."VAT %" := 0;

                        UpdateAmounts();
                    end;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies VAT %.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        UpdateAmounts();
                    end;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT amount.';

                    trigger OnValidate()
                    begin
                        ValidateVATAmount();
                    end;
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT base amount.';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        GetCurrency(CurrencyCode);

                        Rec.TestField(Amount);
                        Rec.TestField("VAT Calculation Type", Rec."VAT Calculation Type"::"Normal VAT");
                        Rec."VAT Base Amount" := Round(Rec."VAT Base Amount", Currency."Amount Rounding Precision");
                        Rec."VAT Amount" := Rec.Amount - Rec."VAT Base Amount";
                        ValidateVATAmount();
                    end;
                }
                field("Amount (ACY)"; Rec."Amount (ACY)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount (LCY)';
                    ToolTip = 'Specifies amount (LCY).';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        GetCurrency('');

                        Rec.TestField(Amount);
                        Rec."Amount (ACY)" := Round(Rec."Amount (ACY)");
                        case Rec."VAT Calculation Type" of
                            Rec."VAT Calculation Type"::"Normal VAT":
                                Rec."VAT Amount (ACY)" :=
                                  Round(Rec."Amount (ACY)" * Rec."VAT %" / (100 + Rec."VAT %"),
                                    Currency."Amount Rounding Precision",
                                    Currency.VATRoundingDirection());
                            Rec."VAT Calculation Type"::"Reverse Charge VAT":
                                Rec."VAT Amount" := 0;
                        end;

                        Rec."VAT Base Amount (ACY)" := Rec."Amount (ACY)" - Rec."VAT Amount (ACY)";
                    end;
                }
                field("VAT Amount (ACY)"; Rec."VAT Amount (ACY)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Amount (LCY)';
                    ToolTip = 'Specifies VAT amount (LCY).';
                    Editable = CurrencyCode <> '';

                    trigger OnValidate()
                    begin
                        ValidateVATAmountLCY();
                    end;
                }
                field("VAT Base Amount (ACY)"; Rec."VAT Base Amount (ACY)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Base Amount (LCY)';
                    ToolTip = 'Specifies VAT base amount (LCY).';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        GetCurrency('');

                        Rec.TestField("Amount (ACY)");
                        Rec.TestField("VAT Calculation Type", Rec."VAT Calculation Type"::"Normal VAT");
                        Rec."VAT Base Amount (ACY)" := Round(Rec."VAT Base Amount (ACY)", Currency."Amount Rounding Precision");
                        Rec."VAT Amount (ACY)" := Rec."Amount (ACY)" - Rec."VAT Base Amount (ACY)";
                        ValidateVATAmountLCY();
                    end;
                }
            }
        }
    }

    var
        Currency: Record Currency;
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        MustBeNegativeErr: label '%1 must be negative.', Comment = '%1 = field caption';
        MustBePositiveErr: label '%1 must be positive.', Comment = '%1 = field caption';
        MustNotBeMoreErr: label 'The VAT Differnce must not be more than %1.', Comment = '%1 = value';

    local procedure UpdateAmounts()
    begin
        Rec.TestField("VAT Prod. Posting Group");

        GetCurrency(CurrencyCode);

        Rec.Amount := Round(Rec.Amount, Currency."Amount Rounding Precision");
        case Rec."VAT Calculation Type" of
            Rec."VAT Calculation Type"::"Normal VAT":
                Rec."VAT Amount" :=
                  Round(Rec.Amount * Rec."VAT %" / (100 + Rec."VAT %"),
                    Currency."Amount Rounding Precision",
                    Currency.VATRoundingDirection());
            Rec."VAT Calculation Type"::"Reverse Charge VAT":
                Rec."VAT Amount" := 0;
        end;

        Rec."VAT Base Amount" := Rec.Amount - Rec."VAT Amount";

        Rec.UpdateLCYAmounts(CurrencyCode, CurrencyFactor);
    end;

    procedure InitDocumentLines(NewCurrencyCode: Code[10]; NewCurrencyFactor: Decimal; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        CurrencyCode := NewCurrencyCode;
        CurrencyFactor := NewCurrencyFactor;

        if AdvancePostingBufferCZZ.FindSet() then
            repeat
                Rec := AdvancePostingBufferCZZ;
                Rec.Insert();
            until AdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure GetCurrency(NewCurrencyCode: Code[10])
    begin
        if NewCurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(NewCurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    procedure GetDocumentLines(var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        if Rec.FindSet() then
            repeat
                AdvancePostingBufferCZZ := Rec;
                AdvancePostingBufferCZZ.Insert();
            until Rec.Next() = 0;
    end;

    procedure UpdateCurrencyFactor(NewCurrencyFactor: Decimal)
    begin
        CurrencyFactor := NewCurrencyFactor;

        if Rec.FindSet() then
            repeat
                Rec.UpdateLCYAmounts(CurrencyCode, CurrencyFactor);
                Rec.Modify();
            until Rec.Next() = 0;
    end;

    local procedure ValidateVATAmount()
    var
        CalcVATAmount: Decimal;
    begin
        GetCurrency(CurrencyCode);

        Rec.TestField(Amount);
        Rec.TestField("VAT Calculation Type", Rec."VAT Calculation Type"::"Normal VAT");
        Rec."VAT Amount" := Round(Rec."VAT Amount", Currency."Amount Rounding Precision");

        if Rec."VAT Amount" * Rec.Amount < 0 then
            if Rec."VAT Amount" > 0 then
                Error(MustBeNegativeErr, Rec.FieldCaption("VAT Amount"))
            else
                Error(MustBePositiveErr, Rec.FieldCaption("VAT Amount"));

        CalcVATAmount := Round(Rec.Amount * Rec."VAT %" / (100 + Rec."VAT %"), Currency."Amount Rounding Precision", Currency.VATRoundingDirection());
        if Abs(CalcVATAmount - Rec."VAT Amount") > Currency."Max. VAT Difference Allowed" then
            Error(MustNotBeMoreErr, Currency."Max. VAT Difference Allowed");

        Rec."VAT Base Amount" := Rec.Amount - Rec."VAT Amount";

        Rec.UpdateLCYAmounts(CurrencyCode, CurrencyFactor);
    end;

    local procedure ValidateVATAmountLCY()
    var
        CalcAdvancePostingBuffer: Record "Advance Posting Buffer CZZ";
    begin
        GetCurrency('');

        Rec.TestField(Amount);
        Rec.TestField("VAT Calculation Type", Rec."VAT Calculation Type"::"Normal VAT");
        Rec."VAT Amount (ACY)" := Round(Rec."VAT Amount (ACY)", Currency."Amount Rounding Precision");

        CalcAdvancePostingBuffer := Rec;
        CalcAdvancePostingBuffer.UpdateLCYAmounts(CurrencyCode, CurrencyFactor);

        if Rec."VAT Amount (ACY)" * Rec."Amount (ACY)" < 0 then
            if Rec."VAT Amount (ACY)" > 0 then
                Error(MustBeNegativeErr, Rec.FieldCaption("VAT Amount (ACY)"))
            else
                Error(MustBePositiveErr, Rec.FieldCaption("VAT Amount (ACY)"));

        if Abs(CalcAdvancePostingBuffer."VAT Amount (ACY)" - Rec."VAT Amount (ACY)") > Currency."Max. VAT Difference Allowed" then
            Error(MustNotBeMoreErr, Currency."Max. VAT Difference Allowed");

        Rec."VAT Base Amount (ACY)" := Rec."Amount (ACY)" - Rec."VAT Amount (ACY)";
    end;
}
