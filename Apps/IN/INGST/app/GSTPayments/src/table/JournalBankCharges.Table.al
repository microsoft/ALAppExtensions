// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

table 18247 "Journal Bank Charges"
{
    Caption = 'Journal Bank Charges';
    DataCaptionFields = "Bank Charge";

    fields
    {
        field(1; "Journal Template Name"; code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template";
            Editable = false;
        }
        field(2; "Journal Batch Name"; code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where(
                "Journal Template Name" = field("Journal Template Name"));
            Editable = false;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Line No.';
            Editable = false;
        }
        field(4; "Bank Charge"; code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Bank Charge';
            TableRelation = "Bank Charge";
        }
        field(5; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(6; "External Document No."; code[40])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(7; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; LCY; Boolean)
        {
            Caption = 'LCY';
            DataClassification = CustomerContent;
        }
        field(9; "GST Document Type"; Enum "BankCharges DocumentType")
        {
            Caption = 'GST Document Type';
            DataClassification = CustomerContent;
        }
        field(10; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(11; "Foreign Exchange"; Boolean)
        {
            Caption = 'Foreign Exchange';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "GST Group Code"; code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group" where(
                "GST Group Type" = filter(Service),
                "Reverse Charge" = filter(false));
        }
        field(13; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(14; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(15; "GST Inv. Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;
        }
        field(16; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(18; "GST Bill to/Buy From State"; Code[10])
        {
            Caption = 'GST Bill to/Buy From State';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(19; "GST Registration Status"; Enum "Bank Registration Status")
        {
            Caption = 'GST Registration Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Journal Template Name", "Journal Batch Name", "Line No.", "Bank Charge")
        {
        }
    }

    procedure GETGSTBaseAmount(BankChargeRecordID: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", BankChargeRecordID);
        TaxTransactionValue.SetRange("Value ID", 10);
        if TaxTransactionValue.FindFirst() then
            exit(TaxTransactionValue.Amount)
    end;

    procedure CheckBankChargeAmountSign(
        GenJournalLine: Record "Gen. Journal Line";
        JnlBankCharges: Record "Journal Bank Charges"): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;
        if JnlBankCharges."GST Document Type" = JnlBankCharges."GST Document Type"::Invoice then
            Sign := 1
        else
            if JnlBankCharges."GST Document Type" = JnlBankCharges."GST Document Type"::"Credit Memo" then
                Sign := -1;

        if JnlBankCharges."GST Document Type" = JnlBankCharges."GST Document Type"::" " then begin
            if ((GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account") and
                (GenJournalLine.Amount > 0)) or
               ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account") and
                (GenJournalLine.Amount < 0))
            then
                Sign := 1
            else
                if ((GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account") and
                    (GenJournalLine.Amount < 0)) or
                   ((GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account") and
                    (GenJournalLine.Amount > 0))
                then
                    Sign := -1;
            if JnlBankCharges.Amount <> 0 then
                JnlBankCharges.TestField(Amount, Abs(JnlBankCharges.Amount) * Sign);
        end;
        exit(Sign);
    end;

    procedure GSTInvoiceRoundingDirection(): Text[1]
    begin
        case "GST Inv. Rounding Type" of
            "GST Inv. Rounding Type"::Nearest:
                exit('=');
            "GST Inv. Rounding Type"::Up:
                exit('>');
            "GST Inv. Rounding Type"::Down:
                exit('<');
        end;
    end;
}
