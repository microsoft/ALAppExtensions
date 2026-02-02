// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Journal;

xmlport 147630 "SL BC Gen. Journal Line Data"
{
    Caption = 'BC Gen. Journal Line data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Gen. Journal Line"; "Gen. Journal Line")
            {
                AutoSave = false;
                XmlName = 'GenJournalLine';
                UseTemporary = true;

                textelement(JournalTemplateName)
                {
                }
                textelement(JournalBatchName)
                {
                }
                textelement(LineNo)
                {
                }
                textelement(AccountType)
                {
                }
                textelement(AccountNo)
                {
                }
                textelement(PostingDate)
                {
                }
                textelement(DocumentType)
                {
                }
                textelement(DocumentNo)
                {
                }
                textelement(Description)
                {
                }
                textelement(BalAccountNo)
                {
                }
                textelement(Amount)
                {
                }
                textelement(DebitAmount)
                {
                }
                textelement(CreditAmount)
                {
                }
                textelement(PostingGroup)
                {
                }
                textelement(ShortcutDimension1Code)
                {
                }
                textelement(ShortcutDimension2Code)
                {
                }
                textelement(DueDate)
                {
                }
                textelement(PmtDiscountDate)
                {
                }
                textelement(PaymentDiscountPercent)
                {
                }
                textelement(Quantity)
                {
                }
                textelement(GenBusPostingGroup)
                {
                }
                textelement(GenProdPostingGroup)
                {
                }
                textelement(BalAccountType)
                {
                }
                textelement(DocumentDate)
                {
                }
                textelement(ExternalDocumentNo)
                {
                }
                textelement(TaxAreaCode)
                {
                }
                textelement(TaxLiable)
                {
                }
                textelement(DimensionSetID)
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    TempGenJournalLine."Journal Template Name" := JournalTemplateName;
                    TempGenJournalLine."Journal Batch Name" := JournalBatchName;
                    Evaluate(TempGenJournalLine."Line No.", LineNo);
                    Evaluate(TempGenJournalLine."Account Type", AccountType);
                    TempGenJournalLine."Account No." := AccountNo;
                    Evaluate(TempGenJournalLine."Posting Date", PostingDate);
                    if DocumentType <> '' then
                        Evaluate(TempGenJournalLine."Document Type", DocumentType);
                    TempGenJournalLine."Document No." := DocumentNo;
                    TempGenJournalLine.Description := Description;
                    TempGenJournalLine."Bal. Account No." := BalAccountNo;
                    Evaluate(TempGenJournalLine.Amount, Amount);
                    Evaluate(TempGenJournalLine."Debit Amount", DebitAmount);
                    Evaluate(TempGenJournalLine."Credit Amount", CreditAmount);
                    TempGenJournalLine."Posting Group" := PostingGroup;
                    TempGenJournalLine."Shortcut Dimension 1 Code" := ShortcutDimension1Code;
                    TempGenJournalLine."Shortcut Dimension 2 Code" := ShortcutDimension2Code;
                    if DueDate <> '' then
                        Evaluate(TempGenJournalLine."Due Date", DueDate);
                    if PmtDiscountDate <> '' then
                        Evaluate(TempGenJournalLine."Pmt. Discount Date", PmtDiscountDate);
                    Evaluate(TempGenJournalLine."Payment Discount %", PaymentDiscountPercent);
                    Evaluate(TempGenJournalLine.Quantity, Quantity);
                    TempGenJournalLine."Gen. Bus. Posting Group" := GenBusPostingGroup;
                    TempGenJournalLine."Gen. Prod. Posting Group" := GenProdPostingGroup;
                    if BalAccountType <> '' then
                        Evaluate(TempGenJournalLine."Bal. Account Type", BalAccountType);
                    if DocumentDate <> '' then
                        Evaluate(TempGenJournalLine."Document Date", DocumentDate);
                    TempGenJournalLine."External Document No." := ExternalDocumentNo;
                    TempGenJournalLine."Tax Area Code" := TaxAreaCode;
                    Evaluate(TempGenJournalLine."Tax Liable", TaxLiable);
                    if DimensionSetID <> '' then
                        Evaluate(TempGenJournalLine."Dimension Set ID", DimensionSetID);
                    TempGenJournalLine.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedGenJournalLines(var NewTempGenJournalLine: Record "Gen. Journal Line" temporary)
    begin
        if TempGenJournalLine.FindSet() then begin
            repeat
                NewTempGenJournalLine.Copy(TempGenJournalLine);
                NewTempGenJournalLine.Insert();
            until TempGenJournalLine.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
}