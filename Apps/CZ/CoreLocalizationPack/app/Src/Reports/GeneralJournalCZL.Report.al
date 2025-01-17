// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.GeneralLedger.Ledger;
using System.Utilities;

report 11705 "General Journal CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GeneralJournal.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'General Journal';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Date; Date)
        {
            DataItemTableView = sorting("Period Type", "Period Start") where("Period Type" = const(Date));
            PrintOnlyIfDetail = true;
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(PostingDateFilter; PostingDateFilter)
            {
            }
            dataitem(GLEntry; "G/L Entry")
            {
                DataItemLink = "Posting Date" = field("Period Start");
                DataItemTableView = sorting("Posting Date", "G/L Account No.", "Dimension Set ID");

                trigger OnAfterGetRecord()
                begin
                    if Amount = 0 then
                        CurrReport.Skip();

                    if (RecordNo mod 100) = 0 then
                        WindowDialog.Update(2, Round(RecordNo / NoOfRecords * 10000, 1));
                    RecordNo := RecordNo + 1;

                    TempGLEntry.SetRange("Document No.", GLEntry."Document No.");
                    TempGLEntry.SetRange("G/L Account No.", GLEntry."G/L Account No.");
                    TempGLEntry.SetRange("Global Dimension 1 Code", GLEntry."Global Dimension 1 Code");
                    TempGLEntry.SetRange("Global Dimension 2 Code", GLEntry."Global Dimension 2 Code");
                    TempGLEntry.SetRange("Job No.", "Job No.");

                    if TempGLEntry.FindFirst() and SumGLAccounts then begin
                        TempGLEntry."Debit Amount" += GLEntry."Debit Amount";
                        TempGLEntry."Credit Amount" += GLEntry."Credit Amount";
                        TempGLEntry.Modify();
                    end else begin
                        TempGLEntry.Init();
                        TempGLEntry.TransferFields(GLEntry);
                        TempGLEntry.Insert();
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Clear(RecordNo);
                    NoOfRecords := Count;
                end;
            }
            dataitem(BufferedGLEntry; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));

                column(TempGLEntry_PostingDate; TempGLEntry."Posting Date")
                {
                }
                column(TempGLEntry_DocumentNo; TempGLEntry."Document No.")
                {
                }
                column(TempGLEntry_ExternalDocumentNo; TempGLEntry."External Document No.")
                {
                }
                column(TempGLEntry_GLAccountNo; TempGLEntry."G/L Account No.")
                {
                }
                column(TempGLEntry_Description; TempGLEntry.Description)
                {
                }
                column(TempGLEntry_DebitAmount; TempGLEntry."Debit Amount")
                {
                }
                column(TempGLEntry_CreditAmount; TempGLEntry."Credit Amount")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempGLEntry.FindSet()
                    else
                        TempGLEntry.Next();
                end;

                trigger OnPostDataItem()
                begin
                    TempGLEntry.DeleteAll();
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.Reset();
                    TempGLEntry.SetCurrentKey("Document No.", "Posting Date");

                    SetRange(Number, 1, TempGLEntry.Count);
                end;
            }
            trigger OnAfterGetRecord()
            begin
                WindowDialog.Update(1, "Period Start");
                WindowDialog.Update(2, 0);
            end;

            trigger OnPostDataItem()
            begin
                WindowDialog.Close();
            end;

            trigger OnPreDataItem()
            var
                PostingDateFilterTok: Label '%1: %2', Locked = true;
            begin
                SetRange("Period Start", FromDate, ToDate);

                PostingDateFilter := '';
                if GetFilter("Period Start") <> '' then
                    PostingDateFilter := StrSubstNo(PostingDateFilterTok,
                        TempGLEntry.FieldCaption("Posting Date"), GetFilter("Period Start"));

                WindowDialog.Open(ProcessingDateMsg + ProgressMsg);
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
                group(Options)
                {
                    Caption = 'Options';
                    field(FromDateField; FromDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'From Date';
                        ToolTip = 'Specifies the first date of period.';
                    }
                    field(ToDateField; ToDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'To Date';
                        ToolTip = 'Specifies report to date';
                    }
                    field(SumGLAccountsField; SumGLAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sum Identical G/L Account';
                        ToolTip = 'Specifies if the identical G/L account have to be sumed.';
                    }
                }
            }
        }
    }

    labels
    {
        PageLbl = 'Page';
        ReportNameLbl = 'General Journal';
        CreditAmountLbl = 'Credit Amount';
        DebitAmountLbl = 'Debit Amount';
        DescriptionLbl = 'Description';
        GLAccountNoLbl = 'G/L Account No.';
        ExternalDocumentNoLbl = 'External Document No.';
        DocumentNoLbl = 'Document No.';
        PostingDateLbl = 'Posting Date';
    }

    trigger OnPreReport()
    begin
        if FromDate = 0D then
            Error(FromDateErr);
    end;

    var
        TempGLEntry: Record "G/L Entry" temporary;
        FromDateErr: Label 'Enter the value "From Date".';
        ProcessingDateMsg: Label 'Processing Date #1#########\\', Comment = '#1 = date of period';
        ProgressMsg: Label 'Progress @2@@@@@@@@@@@@@';
        WindowDialog: Dialog;
        PostingDateFilter: Text;
        RecordNo: Integer;
        NoOfRecords: Integer;
        SumGLAccounts: Boolean;
        FromDate: Date;
        ToDate: Date;
}
