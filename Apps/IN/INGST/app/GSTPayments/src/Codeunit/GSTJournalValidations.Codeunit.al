// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 18246 "GST Journal Validations"
{
    var
        LowerLimitErr: Label 'Lower Limit %1 must be present as an Upper Limit in any Record of Bank Charge Code %2 in Bank Charges Deemed Value Setup.', Comment = '%1 =Lower Limit ,%2 =Bank Charge Code';
        UpperLimitErr: Label 'Upper Limit must be greater than Lower Limit %1.', Comment = '%1 = Lower Limit';
        LowerLimitZeroErr: Label 'Only one Record for Bank Charge Code %1 can have Zero as Lower Limit.', Comment = '%1 = Bank Charge Code';
        DeleteErr: Label 'There is Record having Higher Lower Limit than %1 of Bank Charge', Comment = '%1 =Upper Limit';
        UpperLimitSmallModifyErr: Label 'There must not be any Record of Bank Charge Code %1 Where Lower Limit is Smaller than %2.', Comment = '%1 = Bank Charge Code , %2 = Upper Limit';
        UpperLimitBigModifyErr: Label 'There is no Record of Bank Charge Code %1 , Where Lower Limit is same as %2 .', Comment = '%1 = Bank Charge Code, %2 = Upper Limit';
        GSTBankChargeBoolErr: Label 'You Can not have multiple Bank Charges, when Bank Charge Boolean in General Journal Line is True.';

    //Bank Charge - Definition
    procedure GSTGroupCodeBankCharge(var BankCharge: Record "Bank Charge")
    begin
        BankCharge."HSN/SAC Code" := '';
    end;

    //Bank Charge Deemed Value Setup - Definition
    procedure LowerLimit(var BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup")
    begin
        BankChargeDeemedValueSetup.TestField("Bank Charge Code");
        CheckUpperLowerLimit(BankChargeDeemedValueSetup);
    end;

    procedure Upperlimit(
        var BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup";
        var XBankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup")
    begin
        if BankChargeDeemedValueSetup."Upper Limit" <> 0 then
            if BankChargeDeemedValueSetup."Upper Limit" <= BankChargeDeemedValueSetup."Lower Limit" then
                Error(UpperLimitErr, BankChargeDeemedValueSetup."Lower Limit");
        if BankChargeDeemedValueSetup."Upper Limit" <> xBankChargeDeemedValueSetup."Upper Limit" then
            CheckOtherUpperLowerLimits(BankChargeDeemedValueSetup);
    end;

    procedure BankChargeDeemedDelete(var BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup")
    begin
        UpperLimitCheckOnDelete(BankChargeDeemedValueSetup);
    end;

    procedure DeleteBankValueDeemedSetup(var BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup")
    begin
        UpperLimitCheckOnDelete(BankChargeDeemedValueSetup);
    end;

    procedure UpperLimitCheckOnDelete(var BankChargeDeemedVal: Record "Bank Charge Deemed Value Setup")
    var
        BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup";
    begin
        BankChargeDeemedValueSetup.Reset();
        BankChargeDeemedValueSetup.SetRange("Bank Charge Code", BankChargeDeemedVal."Bank Charge Code");
        BankChargeDeemedValueSetup.SetFilter("Lower Limit", '>=%1', BankChargeDeemedVal."Upper Limit");
        if not BankChargeDeemedValueSetup.IsEmpty() then
            Error(DeleteErr, BankChargeDeemedVal."Upper Limit");
    end;

    //Journal Bank Charges - Definition
    procedure JnlBankCharge(var JnlBankCharges: Record "Journal Bank Charges")
    var
        GenJnlLine: Record "Gen. Journal Line";
        BankCharge: Record "Bank Charge";
    begin
        Clearfields(JnlBankCharges);
        GetGenJnlLine(GenJnlLine, JnlBankCharges."Journal Template Name", JnlBankCharges."Journal Batch Name", JnlBankCharges."Line No.");
        if GenJnlLine."Bal. Account No." <> '' then
            GenJnlLine.TestField("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");

        if GenJnlLine."Bal. Account No." = '' then
            GenJnlLine.TestField("Account Type", GenJnlLine."Account Type"::"Bank Account");

        if GenJnlLine."Currency Code" = '' then begin
            BankCharge.Get(JnlBankCharges."Bank Charge");
            if BankCharge."Foreign Exchange" then
                GenJnlLine.TestField("Currency Code");
        end;

        BankCharge.Get(JnlBankCharges."Bank Charge");
        if BankCharge."Foreign Exchange" then
            GenJnlLine.TestField("Bank Charge", false);

        JnlBankCharges.Validate("GST Group Code", BankCharge."GST Group Code");
        JnlBankCharges.Validate("GST Credit", BankCharge."GST Credit");
        PopulateGSTInformation(JnlBankCharges, false);
    end;

    procedure JnlBankChargeGSTGroupCode(var JnlBankCharges: Record "Journal Bank Charges")
    var
        GstGroup: Record "GST Group";
        bankCharge: Record "Bank Charge";
        genJnlLIne: Record "Gen. Journal Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        GeneralLedgerSetup.Get();
        if JnlBankCharges."GST Group Code" <> '' then begin
            PopulateGSTInformation(JnlBankCharges, true);
            GSTGroup.Get(JnlBankCharges."GST Group Code");

            GetGenJnlLine(genJnlLIne, JnlBankCharges."Journal Template Name", JnlBankCharges."Journal Batch Name", JnlBankCharges."Line No.");
            BankCharge.Get(JnlBankCharges."Bank Charge");
            if GenJnlLine."Bank Charge" then
                BankCharge.TestField(Account, GenJnlLine."Account No.")
            else
                BankCharge.TestField(Account);

        end else begin
            JnlBankCharges.TestField("GST Document Type", JnlBankCharges."GST Document Type"::" ");
            JnlBankCharges."GST Inv. Rounding Precision" := 0;
            JnlBankCharges."GST Inv. Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum((GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest));
        end;
    end;

    procedure JnlBankChargeAmount(var JnlBankCharges: Record "Journal Bank Charges")
    var
        GenJnlLine: Record "Gen. Journal Line";
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if JnlBankCharges."GST Group Code" <> '' then
            GetRoundingPrecision(JnlBankCharges);

        JnlBankCharges.TestField("Foreign Exchange", false);
        GetGenJnlLine(GenJnlLine, JnlBankCharges."Journal Template Name", JnlBankCharges."Journal Batch Name", JnlBankCharges."Line No.");
        CheckBankChargeAmountSign(GenJnlLine, JnlBankCharges);
        GenJnlLine.TestField("Bank Charge", false);
        if (GenJnlLine."Currency Code" <> '') and not JnlBankCharges.LCY then
            JnlBankCharges."Amount (LCY)" := Round(CurrExchRate.ExchangeAmtFCYToLCY(GenJnlLine."Posting Date",
                  GenJnlLine."Currency Code", JnlBankCharges.Amount, GenJnlLine."Currency Factor"))
        else
            JnlBankCharges."Amount (LCY)" := JnlBankCharges.Amount;

        if JnlBankCharges."GST Document Type" <> "GST Document Type"::" " then
            if JnlBankCharges.Amount > 0 then
                JnlBankCharges.TestField("GST Document Type", JnlBankCharges."GST Document Type"::Invoice)
            else
                if JnlBankCharges.Amount < 0 then
                    JnlBankCharges.TestField("GST Document Type", JnlBankCharges."GST Document Type"::"Credit Memo");

        if JnlBankCharges."GST Group Code" <> '' then
            JnlBankCharges.TestField("GST Document Type");
    end;

    procedure JnlBankChargeGSTDocumentType(var JnlBankCharges: Record "Journal Bank Charges")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Sign: Integer;
    begin
        GetGenJnlLine(GenJournalLine, JnlBankCharges."Journal Template Name", JnlBankCharges."Journal Batch Name", JnlBankCharges."Line No.");
        GenJournalLine.TestField("Bank Charge", false);
        if (JnlBankCharges."GST Document Type" <> "GST Document Type"::" ") and (JnlBankCharges."Foreign Exchange") then begin
            Sign := CheckBankChargeAmountSign(GenJournalLine, JnlBankCharges);
            JnlBankCharges.Amount := Abs(JnlBankCharges.Amount) * Sign;
            JnlBankCharges."Amount (LCY)" := Abs(JnlBankCharges."Amount (LCY)") * Sign;
            JnlBankCharges.Modify();
        end;

        if (JnlBankCharges."GST Document Type" <> "GST Document Type"::" ") then
            if JnlBankCharges.Amount > 0 then
                JnlBankCharges.TestField("GST Document Type", JnlBankCharges."GST Document Type"::Invoice)
            else
                if JnlBankCharges.Amount < 0 then
                    JnlBankCharges.TestField("GST Document Type", JnlBankCharges."GST Document Type"::"Credit Memo");

        if JnlBankCharges."GST Document Type" in [
            JnlBankCharges."GST Document Type"::Invoice,
            JnlBankCharges."GST Document Type"::"Credit Memo"]
        then
            JnlBankCharges.TestField("GST Group Code");
    end;

    procedure Clearfields(var JnlBankCharges: Record "Journal Bank Charges")
    begin
        Clear(JnlBankCharges.Amount);
        Clear(JnlBankCharges."Amount (LCY)");
        Clear(JnlBankCharges."GST Group Code");
        Clear(JnlBankCharges."Foreign Exchange");
        Clear(JnlBankCharges.Exempted);
        Clear(JnlBankCharges."GST Credit");
        Clear(JnlBankCharges."External Document No.");
        Clear(JnlBankCharges.LCY);
    end;

    procedure GetGenJnlLine(
        var GenJnlLine: Record "Gen. Journal Line";
        JournalTemplateName: Code[10];
        journalbatchname: Code[10];
        LineNo: Integer)
    begin
        if (journalbatchname = '') or (JournalTemplateName = '') then
            exit;

        GenJnlLine.Get(JournalTemplateName, journalbatchname, LineNo);
    end;

    procedure CheckMultipleBankCharge(JournalBankCharges: Record "Journal Bank Charges")
    var
        GenJournalLine: Record "Gen. Journal Line";
        JournalBankChargesCountCheck: Record "Journal Bank Charges";
    begin
        GenJournalLine.Get(JournalBankCharges."Journal Template Name", JournalBankCharges."Journal Batch Name", JournalBankCharges."Line No.");
        if not GenJournalLine."Bank Charge" then
            exit;

        JournalBankChargesCountCheck.SetRange("Journal Template Name", JournalBankCharges."Journal Template Name");
        JournalBankChargesCountCheck.SetRange("Journal Batch Name", JournalBankCharges."Journal Batch Name");
        JournalBankChargesCountCheck.SetRange("Line No.", JournalBankCharges."Line No.");
        if JournalBankChargesCountCheck.Count > 1 then
            Error(GSTBankChargeBoolErr);
    end;

    local procedure CheckOtherUpperLowerLimits(var BankChargeDeemedValueSetup2: Record "Bank Charge Deemed Value Setup")
    var
        BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup";
        SameLower: Boolean;
        HigherLower: Boolean;
        SmallerLower: Boolean;
    begin
        BankChargeDeemedValueSetup.Reset();
        BankChargeDeemedValueSetup.SetRange("Bank Charge Code", BankChargeDeemedValueSetup2."Bank Charge Code");
        BankChargeDeemedValueSetup.SetFilter("Lower Limit", '>%1', BankChargeDeemedValueSetup2."Upper Limit");
        if not BankChargeDeemedValueSetup.IsEmpty() then
            HigherLower := true;

        BankChargeDeemedValueSetup.SetFilter("Lower Limit", '%1..%2', BankChargeDeemedValueSetup2."Lower Limit" + 1, BankChargeDeemedValueSetup2."Upper Limit" - 1);
        if not BankChargeDeemedValueSetup.IsEmpty() then
            SmallerLower := true;

        BankChargeDeemedValueSetup.SetRange("Lower Limit", BankChargeDeemedValueSetup2."Upper Limit");
        if not BankChargeDeemedValueSetup.IsEmpty() then
            SameLower := true;

        if SmallerLower then
            Error(UpperLimitSmallModifyErr, BankChargeDeemedValueSetup2."Bank Charge Code", BankChargeDeemedValueSetup2."Upper Limit");

        if HigherLower and not SameLower then
            Error(UpperLimitBigModifyErr, BankChargeDeemedValueSetup2."Bank Charge Code", BankChargeDeemedValueSetup2."Upper Limit");
    end;

    local procedure CheckUpperLowerLimit(var BankChargeDeemedValueSetup2: Record "Bank Charge Deemed Value Setup")
    var
        BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup";
    begin
        if BankChargeDeemedValueSetup2."Lower Limit" <> 0 then begin
            BankChargeDeemedValueSetup.Reset();
            BankChargeDeemedValueSetup.SetRange("Bank Charge Code", BankChargeDeemedValueSetup2."Bank Charge Code");
            BankChargeDeemedValueSetup.SetRange("Upper Limit", BankChargeDeemedValueSetup2."Lower Limit");
            if BankChargeDeemedValueSetup.IsEmpty() then
                Error(LowerLimitErr, BankChargeDeemedValueSetup2."Lower Limit", BankChargeDeemedValueSetup2."Bank Charge Code");
        end else begin
            BankChargeDeemedValueSetup.Reset();
            BankChargeDeemedValueSetup.SetRange("Bank Charge Code", BankChargeDeemedValueSetup2."Bank Charge Code");
            BankChargeDeemedValueSetup.SetRange("Lower Limit", 0);
            if not BankChargeDeemedValueSetup.IsEmpty() then
                Error(LowerLimitZeroErr, BankChargeDeemedValueSetup2."Bank Charge Code");
        end;
    end;

    local procedure PopulateGSTInformation(var JnlBankCharge: Record "Journal Bank Charges"; Calculation: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        GSTGroup: Record "GST Group";
        BankCharge: Record "Bank Charge";
        Sign: Integer;
    begin
        BankCharge.Get(JnlBankCharge."Bank Charge");
        GenJnlLine.Get(JnlBankCharge."Journal Template Name", JnlBankCharge."Journal Batch Name", JnlBankCharge."Line No.");
        if GenJnlLine."Bal. Account No." <> '' then
            BankAccount.Get(GenJnlLine."Bal. Account No.")
        else
            BankAccount.Get(GenJnlLine."Account No.");

        if GSTGroup.Get(JnlBankCharge."GST Group Code") then;
        JnlBankCharge."GST Group Type" := GSTGroup."GST Group Type";
        if not Calculation then begin
            JnlBankCharge."Foreign Exchange" := BankCharge."Foreign Exchange";
            JnlBankCharge."HSN/SAC Code" := BankCharge."HSN/SAC Code";
            JnlBankCharge.Exempted := BankCharge.Exempted;
        end;

        JnlBankCharge."GST Bill to/Buy From State" := BankAccount."State Code";
        JnlBankCharge."GST Registration Status" := BankAccount."GST Registration Status";

        Sign := CheckBankChargeAmountSign(GenJnlLine, JnlBankCharge);
        if JnlBankCharge."Foreign Exchange" then begin
            JnlBankCharge.Amount := Abs(CalculateDeemedValue(JnlBankCharge."Bank Charge", GenJnlLine."Amount (LCY)")) * Sign;
            JnlBankCharge."Amount (LCY)" := Abs(CalculateDeemedValue(JnlBankCharge."Bank Charge", GenJnlLine."Amount (LCY)")) * Sign;
        end;
    end;

    local procedure CheckBankChargeAmountSign(GenJournalLine: Record "Gen. Journal Line"; JnlBankCharges: Record "Journal Bank Charges"): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;
        if JnlBankCharges."GST Document Type" = JnlBankCharges."GST Document Type"::Invoice then
            Sign := 1
        else
            if JnlBankCharges."GST Document Type" = JnlBankCharges."GST Document Type"::"Credit Memo" then
                Sign := -1;

        if jnlbankcharges."GST Document Type" = jnlbankcharges."GST Document Type"::" " then begin
            if ((GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account") and
                (GenJournalLine.Amount > 0)) or ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account") and (GenJournalLine.Amount < 0))
            then
                Sign := 1
            else
                if ((GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account") and
                    (GenJournalLine.Amount < 0)) or ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account") and (GenJournalLine.Amount > 0))
                then
                    Sign := -1;

            if JnlBankCharges.Amount <> 0 then
                JnlBankCharges.TestField(Amount, Abs(JnlBankCharges.Amount) * Sign);
        end;
        exit(Sign);
    end;

    local procedure CalculateDeemedValue(BankCharge: Code[10]; LineAmount: Decimal): Decimal
    var
        BankChargeDeemedValueSetup: Record "Bank Charge Deemed Value Setup";
        DeemedPctAmount, DeemedAmount : Decimal;
    begin
        LineAmount := Abs(LineAmount);
        BankChargeDeemedValueSetup.SetRange("Bank Charge Code", BankCharge);
        BankChargeDeemedValueSetup.SetFilter("Lower Limit", '<%1', LineAmount);
        BankChargeDeemedValueSetup.SetFilter("Upper Limit", '>=%1', LineAmount);
        if BankChargeDeemedValueSetup.FindFirst() then begin
            DeemedPctAmount := ((LineAmount - BankChargeDeemedValueSetup."Lower Limit") * BankChargeDeemedValueSetup."Deemed %") / 100;

            case BankChargeDeemedValueSetup.Formula of
                BankChargeDeemedValueSetup.Formula::"Deemed %":
                    DeemedAmount := DeemedPctAmount;
                BankChargeDeemedValueSetup.Formula::Fixed:
                    DeemedAmount := BankChargeDeemedValueSetup."Fixed Amount";
                BankChargeDeemedValueSetup.Formula::Comparative:
                    if DeemedPctAmount < BankChargeDeemedValueSetup."Min. Deemed Value" then
                        DeemedAmount := BankChargeDeemedValueSetup."Min. Deemed Value"
                    else
                        if ((DeemedPctAmount > BankChargeDeemedValueSetup."Min. Deemed Value") and (BankChargeDeemedValueSetup."Max. Deemed Value" = 0)) or
                           ((DeemedPctAmount > BankChargeDeemedValueSetup."Min. Deemed Value") and (DeemedPctAmount < BankChargeDeemedValueSetup."Max. Deemed Value"))
                        then
                            DeemedAmount := DeemedPctAmount
                        else
                            DeemedAmount := BankChargeDeemedValueSetup."Max. Deemed Value";

                BankChargeDeemedValueSetup.Formula::"Fixed + Deemed %":
                    DeemedAmount := DeemedPctAmount + BankChargeDeemedValueSetup."Fixed Amount";
                BankChargeDeemedValueSetup.Formula::"Fixed + Comparative":
                    if DeemedPctAmount < BankChargeDeemedValueSetup."Min. Deemed Value" then
                        DeemedAmount := BankChargeDeemedValueSetup."Min. Deemed Value" + BankChargeDeemedValueSetup."Fixed Amount"
                    else
                        if ((DeemedPctAmount > BankChargeDeemedValueSetup."Min. Deemed Value") and (BankChargeDeemedValueSetup."Max. Deemed Value" = 0)) or
                           ((DeemedPctAmount > BankChargeDeemedValueSetup."Min. Deemed Value") and (DeemedPctAmount < BankChargeDeemedValueSetup."Max. Deemed Value"))
                        then
                            DeemedAmount := DeemedPctAmount + BankChargeDeemedValueSetup."Fixed Amount"
                        else
                            DeemedAmount := BankChargeDeemedValueSetup."Max. Deemed Value" + BankChargeDeemedValueSetup."Fixed Amount";
            end;
        end;
        exit(DeemedAmount);
    end;

    local procedure GetRoundingPrecision(var JournalBankCharges: Record "Journal Bank Charges"): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxRecordID: RecordID;
        GSTInvRoundingType: Enum "GST Inv Rounding Type";
    begin
        TaxRecordID := JournalBankCharges.RecordId();
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");

        // Assuming rounding precision for GST Tax Components are the same.
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetLoadFields("Tax Type", "Tax Record ID", "Value Type", "Value ID");
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", TaxRecordId);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        if TaxTransactionValue.FindFirst() then
            if TaxComponent.Get(GSTSetup."GST Tax Type", TaxTransactionValue."Value ID") then begin
                GSTInvRoundingType := TaxComponentDirections2DetailedGSTLedgerDirection(TaxComponent.Direction);
                JournalBankCharges."GST Inv. Rounding Precision" := TaxComponent."Rounding Precision";
                JournalBankCharges."GST Inv. Rounding Type" := GSTInvRoundingType;
            end;
    end;

    local procedure TaxComponentDirections2DetailedGSTLedgerDirection(TaxComponentDirection: Enum "Rounding Direction"): Enum "GST Inv Rounding Type"
    var
        ConversionErr: Label 'Rounding Type %1 is not a valid option.', Comment = '%1 = GST Ledger Transaction Type';
    begin
        case TaxComponentDirection of
            TaxComponentDirection::Nearest:
                exit("GST Inv Rounding Type"::nearest);
            TaxComponentDirection::Up:
                exit("GST Inv Rounding Type"::Up);
            TaxComponentDirection::Down:
                exit("GST Inv Rounding Type"::Down);
            else
                Error(ConversionErr, TaxComponentDirection);
        end;
    end;
}
