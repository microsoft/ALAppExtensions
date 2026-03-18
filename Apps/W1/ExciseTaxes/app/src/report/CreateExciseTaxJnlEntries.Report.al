// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Sustainability.ExciseTax;

report 7412 "Create Excise Tax Jnl. Entries"
{
    ProcessingOnly = true;
    Caption = 'Generate Excise Tax Journal Entries';
    ApplicationArea = Basic, Suite;

    dataset
    {
        dataitem("Excise Tax Type"; "Excise Tax Type")
        {
            RequestFilterFields = Code;
            DataItemTableView = where(Enabled = const(true));

            trigger OnAfterGetRecord()
            var
                ExciseJournalBatch: Record "Sust. Excise Journal Batch";
                ExciseTaxCalculation: Codeunit "Excise Tax Calculation";
            begin
                ExciseJournalBatch.Get(ExciseJournalLine."Journal Template Name", ExciseJournalLine."Journal Batch Name");
                ExciseJournalBatch.TestField(Type, ExciseJournalBatch.Type::Excises);
                if ExciseJournalBatch."Excise Tax Type Filter" <> '' then
                    if ExciseJournalBatch."Excise Tax Type Filter" <> "Excise Tax Type".Code then
                        exit;

                ExciseTaxCalculation.SetExciseJournalBatch(ExciseJournalBatch);
                ExciseTaxCalculation.CreateExciseJournalLineForItem("Excise Tax Type".Code, StartingDate, EndingDate, ItemFilter, PostingDate);
                ExciseTaxCalculation.CreateExciseJournalLineForFixedAsset("Excise Tax Type".Code, StartingDate, EndingDate, FixedAssetFilter, PostingDate);
                ProcessedTaxTypes += 1;
            end;

            trigger OnPreDataItem()
            begin
                LinesCountBefore := GetCurrentJournalLineCount();
            end;

            trigger OnPostDataItem()
            begin
                CountCreatedJournalLines();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group("Posting Information")
                {
                    Caption = 'Posting Information';

                    field("Posting Date"; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date for the generated journal lines.';

                        trigger OnValidate()
                        begin
                            if PostingDate = 0D then
                                Error(PostingDateRequiredErr);
                        end;
                    }
                }
                group("Date Filters")
                {
                    Caption = 'Date Filters';

                    field("Starting Date"; StartingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting date for filtering Item Ledger Entries and FA Ledger Entries. Only entries with posting dates from this date onwards will be included in the journal line generation.';

                        trigger OnValidate()
                        begin
                            ValidateDateRange();
                        end;
                    }
                    field("Ending Date"; EndingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the ending date for filtering Item Ledger Entries and FA Ledger Entries. Only entries with posting dates up to this date will be included in the journal line generation.';

                        trigger OnValidate()
                        begin
                            ValidateDateRange();
                        end;
                    }
                }
                group("Source Filters")
                {
                    Caption = 'Source Filters';

                    field("Item Filter"; ItemFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Item Filter';
                        ToolTip = 'Specifies the item filter. Leave blank to include all items.';
                        TableRelation = Item;
                    }
                    field("Fixed Asset Filter"; FixedAssetFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Fixed Asset Filter';
                        ToolTip = 'Specifies the fixed asset filter. Leave blank to include all fixed assets.';
                        TableRelation = "Fixed Asset";
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        if PostingDate = 0D then
            Error(PostingDateRequiredErr);

        if StartingDate = 0D then
            Error(StartingDateRequiredErr);

        if EndingDate = 0D then
            Error(EndingDateRequiredErr);

        if StartingDate > EndingDate then
            Error(StartingDateLaterErr);
    end;

    trigger OnPostReport()
    begin
        Message(ProcessingCompletedMsg, ProcessedTaxTypes, TotalJournalLines, StartingDate, EndingDate);
    end;

    var
        ExciseJournalLine: Record "Sust. Excise Jnl. Line";
        StartingDate: Date;
        EndingDate: Date;
        PostingDate: Date;
        ItemFilter: Text[250];
        FixedAssetFilter: Text[250];
        ProcessedTaxTypes: Integer;
        TotalJournalLines: Integer;
        LinesCountBefore: Integer;
        EndingDateEarlierErr: Label 'Ending Date cannot be earlier than Starting Date.';
        StartingDateLaterErr: Label 'Starting Date cannot be later than Ending Date.';
        PostingDateRequiredErr: Label 'Posting Date is required. Please specify a posting date.';
        StartingDateRequiredErr: Label 'Starting Date is required. Please specify a starting date.';
        EndingDateRequiredErr: Label 'Ending Date is required. Please specify an ending date.';
        ProcessingCompletedMsg: Label 'Processing completed successfully:\Tax Types Processed: %1\Journal Lines Created: %2\Date Range: %3 to %4', Comment = '%1 = Number of tax types processed, %2 = Number of journal lines created, %3 = Starting Date, %4 = Ending Date';

    procedure SetExciseJournalLine(var NewExciseJournalLine: Record "Sust. Excise Jnl. Line")
    begin
        ExciseJournalLine := NewExciseJournalLine;
    end;

    local procedure CountCreatedJournalLines()
    var
        LinesCountAfter: Integer;
    begin
        LinesCountAfter := GetCurrentJournalLineCount();
        TotalJournalLines := LinesCountAfter - LinesCountBefore;
    end;

    local procedure GetCurrentJournalLineCount(): Integer
    var
        ExciseJnlLine: Record "Sust. Excise Jnl. Line";
        TotalCount: Integer;
    begin
        TotalCount := 0;

        ExciseJnlLine.SetRange("Journal Template Name", ExciseJournalLine."Journal Template Name");
        ExciseJnlLine.SetRange("Journal Batch Name", ExciseJournalLine."Journal Batch Name");
        TotalCount += ExciseJnlLine.Count;

        exit(TotalCount);
    end;

    local procedure ValidateDateRange()
    begin
        if (EndingDate <> 0D) and (StartingDate <> 0D) and (EndingDate < StartingDate) then
            Error(EndingDateEarlierErr);
    end;
}