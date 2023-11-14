// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using System.Utilities;

report 11721 "G/L Acc. Group Post. Check CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GLAccGroupPostCheck.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L Account Group Posting Check';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Date; Date)
        {
            DataItemTableView = sorting("Period Type", "Period Start") where("Period Type" = const(Date));
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(GLAccGroupPostingCheckCaption; GLAccGroupPostingCheckCaptionLbl)
            {
            }
            column(PostingDateFilter; TempGLEntry.FieldCaption("Posting Date") + ': ' + GetFilter("Period Start"))
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(PostingDate_Caption; TempGLEntry.FieldCaption("Posting Date"))
            {
            }
            column(DocumentNo_Caption; TempGLEntry.FieldCaption("Document No."))
            {
            }
            column(ExternalDocumentNo_Caption; TempGLEntry.FieldCaption("External Document No."))
            {
            }
            column(GLAccountNo_Caption; TempGLEntry.FieldCaption("G/L Account No."))
            {
            }
            column(Description_Caption; TempGLEntry.FieldCaption(Description))
            {
            }
            column(DebitAmount_Caption; TempGLEntry.FieldCaption("Debit Amount"))
            {
            }
            column(CreditAmount_Caption; TempGLEntry.FieldCaption("Credit Amount"))
            {
            }
            column(GLAccGroupCZL_Caption; GLAccount.FieldCaption("G/L Account Group CZL"))
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "Posting Date" = field("Period Start");
                DataItemTableView = sorting("Document No.", "Posting Date");

                trigger OnAfterGetRecord()
                var
                    GLEntryLocal: Record "G/L Entry";
                    GLAccountLocal2: Record "G/L Account";
                    GLAccountLocal1: Record "G/L Account";
                    DifferentGLAccountGroup: Boolean;
                begin
                    if (RecordNo mod 100) = 0 then
                        WindowDialog.Update(2, Round(RecordNo / NoOfRecords * 10000, 1));
                    RecordNo := RecordNo + 1;

                    if PrevDocumentNo = "Document No." then
                        CurrReport.Skip()
                    else
                        PrevDocumentNo := "Document No.";

                    GLAccountLocal1.Get("G/L Account No.");
                    DifferentGLAccountGroup := false;

                    TempGLEntry.SetRange("Document No.", "Document No.");
                    TempGLEntry.SetRange("Posting Date", "Posting Date");
                    if TempGLEntry.IsEmpty() then begin
                        GLEntryLocal.Reset();
                        GLEntryLocal.SetCurrentKey("Document No.", "Posting Date");
                        GLEntryLocal.SetRange("Document No.", "Document No.");
                        GLEntryLocal.SetRange("Posting Date", "Posting Date");
                        if GLEntryLocal.FindSet() then
                            repeat
                                GLAccountLocal2.Get(GLEntryLocal."G/L Account No.");
                                if GLAccountLocal1."G/L Account Group CZL" <> GLAccountLocal2."G/L Account Group CZL" then
                                    DifferentGLAccountGroup := true;
                            until (GLEntryLocal.Next() = 0) or DifferentGLAccountGroup;

                    end;

                    if DifferentGLAccountGroup then begin
                        GLEntryLocal.Reset();
                        GLEntryLocal.SetCurrentKey("Document No.", "Posting Date");
                        GLEntryLocal.SetRange("Document No.", "Document No.");
                        GLEntryLocal.SetRange("Posting Date", "Posting Date");
                        if GLEntryLocal.FindSet() then
                            repeat
                                TempGLEntry.Init();
                                TempGLEntry.TransferFields(GLEntryLocal);
                                TempGLEntry.Insert();
                            until GLEntryLocal.Next() = 0;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Clear(RecordNo);
                    NoOfRecords := Count;
                end;
            }
            trigger OnAfterGetRecord()
            begin
                WindowDialog.Update(1, "Period Start");
                WindowDialog.Update(2, 0);

                Clear(PrevDocumentNo);
            end;

            trigger OnPostDataItem()
            begin
                WindowDialog.Close();
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Period Start", FromDate, ToDate);

                WindowDialog.Open(Text000Msg + Text001Msg);
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number);
            column(PostingDate_TempGLEntry; format(TempGLEntry."Posting Date"))
            {
            }
            column(DocumentNo_TempGLEntry; TempGLEntry."Document No.")
            {
            }
            column(ExternalDocumentNo_TempGLEntry; TempGLEntry."External Document No.")
            {
            }
            column(GLAccountNo_TempGLEntry; TempGLEntry."G/L Account No.")
            {
            }
            column(Description_TempGLEntry; TempGLEntry.Description)
            {
            }
            column(DebitAmount_TempGLEntry; TempGLEntry."Debit Amount")
            {
            }
            column(CreditAmount_TempGLEntry; TempGLEntry."Credit Amount")
            {
            }
            column(GLAccGroupCZL_GLAccount; GLAccount."G/L Account Group CZL")
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempGLEntry.FindSet()
                else
                    TempGLEntry.Next();

                GLAccount.Get(TempGLEntry."G/L Account No.");
            end;

            trigger OnPreDataItem()
            begin
                TempGLEntry.Reset();
                TempGLEntry.SetCurrentKey("Document No.", "Posting Date");

                SetRange(Number, 1, TempGLEntry.Count());
            end;
        }
    }
    requestpage
    {

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
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        if FromDate = 0D then
            Error(FromDateErr);
    end;

    var
        GLAccount: Record "G/L Account";
        TempGLEntry: Record "G/L Entry" temporary;
        FromDate: Date;
        ToDate: Date;
        FromDateErr: Label 'Enter the value "From Date".';
        WindowDialog: Dialog;
        RecordNo: Integer;
        NoOfRecords: Integer;
        Text000Msg: Label 'Processing Date #1#########\\', Comment = '#1######### = PeriodText';
        Text001Msg: Label 'Progress @2@@@@@@@@@@@@@', Comment = '@2@@@@@@@@@@@@@ = Progress';
        PrevDocumentNo: Code[20];
        GLAccGroupPostingCheckCaptionLbl: Label 'G/L Account Group posting check';
        CurrReportPageNoCaptionLbl: Label 'Page';
}
