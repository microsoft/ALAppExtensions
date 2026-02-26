// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

tableextension 31052 "CV Ledger Entry Buffer CZL" extends "CV Ledger Entry Buffer"
{
    fields
    {
        field(11730; "Orig. Pmt. Disc. CZL"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = Rec."Currency Code";
            Caption = 'Pmt. Disc.';
            DataClassification = SystemMetadata;
        }
        field(11731; "Orig. Pmt. Disc. (LCY) CZL"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            Caption = 'Pmt. Disc. (LCY)';
            DataClassification = SystemMetadata;
        }
        field(11732; "Corr. Pmt. Disc. (LCY) CZL"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = '';
            Caption = 'Corr. Pmt. Disc. (LCY)';
            DataClassification = SystemMetadata;
        }
    }

    internal procedure InsertFrom(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    var
        EntryNo: Integer;
    begin
        EntryNo := GetLastEntryNo();
        CVLedgerEntryBuffer.Reset();
        if CVLedgerEntryBuffer.FindSet() then
            repeat
                EntryNo += 1;
                Init();
                Rec := CVLedgerEntryBuffer;
                "Entry No." := EntryNo;
                Insert();
            until CVLedgerEntryBuffer.Next() = 0;
    end;

    local procedure GetLastEntryNo(): Integer
    begin
        if FindLast() then
            exit("Entry No.");
        exit(0);
    end;
}
