// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using System.Utilities;

report 31131 "Inventory Account To Date CZA"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/InventoryAccountToDate.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Inventory Account to Date';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = where("Account Type" = const(Posting));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter";
            column(PeriodGLDtFilter; StrSubstNo(ToDateTxt, ToDate))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(PageGroupNo; PageGroupNo)
            {
            }
            column(GLAccTableCaption; TableCaption() + ': ' + GLFilter)
            {
            }
            column(GLFilter; GLFilter)
            {
            }
            column(No_GLAcc; "No.")
            {
            }
            column(Dim1Caption; FieldCaption("Global Dimension 1 Code"))
            {
            }
            column(Dim2Caption; FieldCaption("Global Dimension 2 Code"))
            {
            }
            dataitem(PageCounter; "Integer")
            {
                DataItemTableView = sorting(Number);
                MaxIteration = 1;
                column(Name_GLAcc; "G/L Account".Name)
                {
                }
                dataitem("G/L Entry"; "G/L Entry")
                {
                    DataItemLink = "G/L Account No." = field("No."), "Posting Date" = field("Date Filter");
                    DataItemLinkReference = "G/L Account";
                    DataItemTableView = sorting("G/L Account No.", "Posting Date");
                    column(Amount_GLE; Amount)
                    {
                    }
                    column(RemainingAmount_GLE; RemAmount)
                    {
                    }
                    column(AppliedAmount_GLE; "Applied Amount CZA")
                    {
                    }
                    column(PostingDate_GLE; Format("Posting Date"))
                    {
                    }
                    column(DocumentType_GLE; Format("Document Type"))
                    {
                    }
                    column(DocumentNo_GLE; "Document No.")
                    {
                    }
                    column(Description_GLE; Description)
                    {
                    }
                    column(Glob1Dim_GLE; "Global Dimension 1 Code")
                    {
                    }
                    column(Glob2Dim_GLE; "Global Dimension 2 Code")
                    {
                    }
                    dataitem("Detailed G/L Entry CZA"; "Detailed G/L Entry CZA")
                    {
                        DataItemLink = "G/L Entry No." = field("Entry No.");
                        DataItemTableView = sorting("G/L Entry No.", "Posting Date") where(Unapplied = const(false));
                        dataitem(AppliedGLEntry; "G/L Entry")
                        {
                            DataItemLink = "Entry No." = field("Applied G/L Entry No.");
                            DataItemTableView = sorting("Entry No.");
                            column(EntryNo_AGLE; "G/L Entry"."Entry No.")
                            {
                            }
                            column(AppliedAmount_AGLE; "Detailed G/L Entry CZA".Amount)
                            {
                            }
                            column(PostingDate_AGLE; Format("Posting Date"))
                            {
                            }
                            column(DocumentType_AGLE; Format("Document Type"))
                            {
                            }
                            column(DocumentNo_AGLE; "Document No.")
                            {
                            }
                            column(Description_AGLE; Description)
                            {
                            }
                            column(Glob1Dim_AGLE; "Global Dimension 1 Code")
                            {
                            }
                            column(Glob2Dim_AGLE; "Global Dimension 2 Code")
                            {
                            }
                            column(RepCount_AGLE; RepCount)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                RepCount += 1;
                                if RepCount > 1 then
                                    RemAmount := 0;
                            end;
                        }

                        trigger OnPreDataItem()
                        begin
                            if not ShowApplyEntries then
                                CurrReport.Break();

                            SetFilter("Posting Date", '..%1', ToDate);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        CalcFields("Applied Amount CZA");
                        RemAmount := Amount - "Applied Amount CZA";
                        if (RemAmount = 0) and (not ShowZeroRemainAmt) then
                            CurrReport.Skip();
                        Clear(RepCount);
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter("Date Filter CZA", '..%1', ToDate);
                    end;
                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(Name1_GLEntry; "G/L Account".Name)
                    {
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                if PrintOnlyOnePerPage then begin
                    GLEntry.Reset();
                    GLEntry.SetCurrentKey("G/L Account No.");
                    GLEntry.SetRange("G/L Account No.", "No.");
                    if not GLEntry.IsEmpty() then
                        PageGroupNo += 1;
                end;
            end;

            trigger OnPreDataItem()
            begin
                PageGroupNo := 1;
                if GetFilter("Date Filter") <> '' then
                    ToDate := GetRangeMax("Date Filter");
                if ToDate = 0D then
                    ToDate := WorkDate();
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
                    field(NewPageperGLAcc; PrintOnlyOnePerPage)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Page per G/L Acc.';
                        ToolTip = 'Specifies if you want each G/L account to be printed on a separate page.';
                    }
                    field(NewShowApplyEntries; ShowApplyEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Applied Entries';
                        MultiLine = true;
                        ToolTip = 'Specifies when the applied entries is to be shown.';
                    }
                    field(NewShowZeroRemainAmt; ShowZeroRemainAmt)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Entries with zero Remainig Amt.';
                        ToolTip = 'Specifies when the entries with zero remainig amount is to be shown.';
                    }
                }
            }
        }
    }

    labels
    {
        ReportCaptionLbl = 'Inventory Account to the date';
        PageCaptionLbl = 'Page';
        PostingDateCaptionLbl = 'Posting Date';
        DocTypeCaptionLbl = 'Document Type';
        DocNoCaptionLbl = 'Document No.';
        DescritpionCaptionLbl = 'Description';
        EntryNoCaptionLbl = 'Entry No.';
        AmountCaptionLbl = 'Amount';
        RemAmountCaptionLbl = 'Remaining Amount';
        GLAccNoCaptionLbl = 'Account No.';
        GLAccDescCaptionLbl = 'Account Name';
    }

    trigger OnPreReport()
    begin
        GLFilter := "G/L Account".GetFilters();
    end;

    var
        GLEntry: Record "G/L Entry";
        GLFilter: Text;
        ToDate: Date;
        PrintOnlyOnePerPage: Boolean;
        ShowApplyEntries: Boolean;
        PageGroupNo: Integer;
        RemAmount: Decimal;
        RepCount: Integer;
        ShowZeroRemainAmt: Boolean;
        ToDateTxt: Label 'To Date: %1', Comment = '%1 = To Date';

    procedure InitializeRequest(NewPrintOnlyOnePerPage: Boolean; NewShowApplyEntries: Boolean)
    begin
        PrintOnlyOnePerPage := NewPrintOnlyOnePerPage;
        ShowApplyEntries := NewShowApplyEntries;
    end;

    procedure InitializeRequest(NewPrintOnlyOnePerPage: Boolean; NewShowApplyEntries: Boolean; NewShowZeroRemainAmt: Boolean)
    begin
        InitializeRequest(NewPrintOnlyOnePerPage, NewShowApplyEntries);
        ShowZeroRemainAmt := NewShowZeroRemainAmt;
    end;
}
