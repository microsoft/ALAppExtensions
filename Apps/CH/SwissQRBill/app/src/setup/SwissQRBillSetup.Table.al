// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using System.IO;

table 11512 "Swiss QR-Bill Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary key"; Code[10]) { }
        field(2; "Swiss-Cross Image"; Media)
        {
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
            ObsoleteReason = 'Use W1 codeunit 4113 "Swiss QR Code Helper"';
        }
        field(3; "Address Type"; enum "Swiss QR-Bill Address Type")
        {
            Caption = 'Address Type';
        }
        field(6; "Umlaut Chars Encode Mode"; Enum "Swiss QR-Bill Umlaut Encoding")
        {
            Caption = 'German Umlaut Chars Encoding Mode';
            ObsoleteReason = 'No need to convert umlauts, because encoding was changed to UTF-8.';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }
        field(8; "Default Layout"; Code[20])
        {
            Caption = 'Default QR-Bill Layout';
            TableRelation = "Swiss QR-Bill Layout";
            NotBlank = true;
        }
        field(9; "Last Used Reference No."; BigInteger)
        {
            Caption = 'Last Used Payment Reference No.';
            Editable = false;
        }
        field(10; "Journal Template"; Code[10])
        {
            Caption = 'Journal Template';
            TableRelation = "Gen. Journal Template";

            trigger OnValidate()
            begin
                "Journal Batch" := '';
            end;
        }
        field(11; "Journal Batch"; Code[10])
        {
            Caption = 'Journal Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template"));
        }
        field(12; "SEPA CT Setup"; Boolean)
        {
            CalcFormula = exist("Bank Export/Import Setup" where(Direction = const(Export), "Processing Codeunit ID" = const(11520), "Processing XMLport ID" = const(1000), "Check Export Codeunit" = const(1223)));
            Caption = 'SEPA Credit Transfer';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "SEPA DD Setup"; Boolean)
        {
            CalcFormula = exist("Bank Export/Import Setup" where(Direction = const(Export), "Processing Codeunit ID" = const(11530), "Processing XMLport ID" = const(11501), "Check Export Codeunit" = const(1233)));
            Caption = 'SEPA Direct Debit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "SEPA CAMT 054 Setup"; Boolean)
        {
            CalcFormula = exist("Bank Export/Import Setup" where(Direction = const(Import), "Processing Codeunit ID" = const(1270), "Processing XMLport ID" = const(0), "Check Export Codeunit" = const(0), "Data Exch. Def. Code" = field("SEPA CAMT 054 DataExchDef Code")));
            Caption = 'SEPA CAMT 054';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "SEPA CAMT 054 DataExchDef Code"; Code[20])
        {
            CalcFormula = lookup("Data Exch. Mapping"."Data Exch. Def Code" where("Table ID" = const(274), "Mapping Codeunit" = const(11522)));
            Caption = 'SEPA CAMT 054 Data Exch. Def. Code';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; "Primary key")
        {
            Clustered = true;
        }
    }

    internal procedure InitDefaultJournalSetup()
    var
        GenJournalTemplateType: Enum "Gen. Journal Template Type";
    begin
        if "Journal Template" = '' then
            InitDefaultJournalSetupForGivenType(GenJournalTemplateType::Purchases);
    end;

    local procedure InitDefaultJournalSetupForGivenType(GenJournalTemplateType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplateType);
        if GenJournalTemplate.FindFirst() then begin
            "Journal Template" := GenJournalTemplate.Name;
            GenJournalBatch.SetRange("Journal Template Name", "Journal Template");
            GenJournalBatch.SetRange("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
            if not GenJournalBatch.FindFirst() then begin
                GenJournalBatch.SetRange("Bal. Account Type");
                if GenJournalBatch.FindFirst() then;
            end;
            "Journal Batch" := GenJournalBatch.Name;
        end;
    end;
}
