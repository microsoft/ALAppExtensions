// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.GeneralLedger.Ledger;
using System.Utilities;

report 11714 "Joining G/L Account Adj. CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/JoiningGLAccountAdj.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Joining G/L Account Adjustment';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(GLEntryFilter; "G/L Entry")
        {
            DataItemTableView = sorting("G/L Account No.", "Posting Date");
            RequestFilterFields = "G/L Account No.", "Document No.", "External Document No.";

            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(GLEntry_Filters; GLEntryFilters)
            {
            }

            trigger OnAfterGetRecord()
            var
                DocumentNo: Code[20];
            begin
                j := j + 1;
                WindowDialog.Update(1, Round((9999 / i) * j, 1));

                DocumentNo := GetDocumentNoBySortingType(GLEntryFilter);
                if TempGLAccountAdjustBufferCZL.Get(DocumentNo) then begin
                    TempGLAccountAdjustBufferCZL.Amount += GLEntryFilter.Amount;
                    TempGLAccountAdjustBufferCZL."Debit Amount" += GLEntryFilter."Debit Amount";
                    TempGLAccountAdjustBufferCZL."Credit Amount" += GLEntryFilter."Credit Amount";
                    if ShowPostingDate and (TempGLAccountAdjustBufferCZL."Posting Date" = 0D) and (GLEntryFilter."Posting Date" <> 0D) then
                        TempGLAccountAdjustBufferCZL."Posting Date" := GLEntryFilter."Posting Date";
                    if ShowDescription and (TempGLAccountAdjustBufferCZL.Description = '') and (GLEntryFilter.Description <> '') then
                        TempGLAccountAdjustBufferCZL.Description := GLEntryFilter.Description;
                    TempGLAccountAdjustBufferCZL.Modify();
                end else begin
                    TempGLAccountAdjustBufferCZL.Init();
                    TempGLAccountAdjustBufferCZL."Document No." := DocumentNo;
                    TempGLAccountAdjustBufferCZL.Amount := GLEntryFilter.Amount;
                    TempGLAccountAdjustBufferCZL."Debit Amount" := GLEntryFilter."Debit Amount";
                    TempGLAccountAdjustBufferCZL."Credit Amount" := GLEntryFilter."Credit Amount";
                    if ShowPostingDate then
                        TempGLAccountAdjustBufferCZL."Posting Date" := GLEntryFilter."Posting Date";
                    if ShowDescription then
                        TempGLAccountAdjustBufferCZL.Description := GLEntryFilter.Description;
                    TempGLAccountAdjustBufferCZL.Insert();
                end;
            end;

            trigger OnPreDataItem()
            begin
                i := Count;
                j := 0;
                WindowDialog.Open(ProcessingEntriesMsg);
            end;
        }
        dataitem(EntryBuffer; "Integer")
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));
            column(EntryBuffer_DocumentNo; TempGLAccountAdjustBufferCZL."Document No.")
            {
            }
            column(EntryBuffer_Amount; TempGLAccountAdjustBufferCZL.Amount)
            {
            }
            column(EntryBuffer_DebitAmount; TempGLAccountAdjustBufferCZL."Debit Amount")
            {
            }
            column(EntryBuffer_CreditAmount; TempGLAccountAdjustBufferCZL."Credit Amount")
            {
            }
            column(EntryBuffer_Description; TempGLAccountAdjustBufferCZL.Description)
            {
            }
            column(EntryBuffer_PostingDate; TempGLAccountAdjustBufferCZL."Posting Date")
            {
            }
            dataitem(GLEntry; "G/L Entry")
            {
                DataItemTableView = sorting("Entry No.");
                column(GLEntry_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(GLEntry_DebitAmount; "Debit Amount")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_CreditAmount; "Credit Amount")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(GLEntry_PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(GLEntry_EntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }
                trigger OnPreDataItem()
                begin
                    if not ShowDetail then
                        CurrReport.Break();

                    GLEntry.CopyFilters(GLEntryFilter);
                    if SortingType = 0 then begin
                        GLEntry.SetCurrentKey("Document No.");
                        GLEntry.SetRange("Document No.", TempGLAccountAdjustBufferCZL."Document No.");
                    end else
                        GLEntry.SetRange("External Document No.", TempGLAccountAdjustBufferCZL."Document No.");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if EntryBuffer.Number <> 1 then
                    if TempGLAccountAdjustBufferCZL.Next() = 0 then
                        CurrReport.Break();

                if TempGLAccountAdjustBufferCZL.Amount = 0 then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                if not TempGLAccountAdjustBufferCZL.FindSet() then
                    CurrReport.Quit();
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
                    field(SortingTypeField; SortingType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'By';
                        OptionCaption = 'Document No.,External Document No.,Combination';
                        ToolTip = 'Specifies type of sorting';
                    }
                    field(ShowDescriptionField; ShowDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Description';
                        ToolTip = 'Specifies when the currency is to be show';
                    }
                    field(ShowPostingDateField; ShowPostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Posting Date';
                        ToolTip = 'Specifies when the posting date is to be show';
                    }
                    field(ShowDetailField; ShowDetail)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Detail';
                        ToolTip = 'Specifies when the detail is to be show';
                    }
                }
            }
        }
    }

    labels
    {
        PageLbl = 'Page';
        ReportNameLbl = 'Joining G/L Account Adjustment';
        DocumentNoLbl = 'Document No.';
        TotalLbl = 'Total';
    }

    trigger OnPreReport()
    begin
        if GLEntryFilter.GetFilter("G/L Account No.") = '' then
            Error(EmptyAccountNoFilterErr);
        if GLEntryFilter.GetFilters() <> '' then
            GLEntryFilters := GLEntryFilter.GetFilters();
    end;

    var
        TempGLAccountAdjustBufferCZL: Record "G/L Account Adjust. Buffer CZL" temporary;
        WindowDialog: Dialog;
        GLEntryFilters: Text;
        SortingType: Option DocumentNo,ExternalDocumentNo,Combination;
        i: Integer;
        j: Integer;
        ShowDetail: Boolean;
        ShowDescription: Boolean;
        ShowPostingDate: Boolean;
        EmptyAccountNoFilterErr: Label 'Please enter a Filter to Account No..';
        ProcessingEntriesMsg: Label 'Processing Entries @1@@@@@@@@@@@@';

    local procedure GetDocumentNoBySortingType(GLEntry: Record "G/L Entry"): Code[20]
    begin
        case SortingType of
            SortingType::DocumentNo:
                exit(GLEntry."Document No.");
            SortingType::ExternalDocumentNo:
                exit(CopyStr(GLEntry."External Document No.", 1, MaxStrLen(GLEntry."Document No.")));
            SortingType::Combination:
                begin
                    if GLEntry."External Document No." <> '' then
                        exit(CopyStr(GLEntry."External Document No.", 1, MaxStrLen(GLEntry."Document No.")));
                    exit(GLEntry."Document No.");
                end;
        end;
    end;
}
