// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

report 31132 "G/L Entry Applying CZA"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GLEntryApplying.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L Entry Applying';
    Permissions = tabledata "G/L Entry" = rm;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            RequestFilterFields = "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(AccFilter; AccFilter)
            {
            }
            column(GLEntryFilter; GLEntryFilter)
            {
            }
            column(GLAccount_No; "No.")
            {
            }
            dataitem(OriginalEntry; "G/L Entry")
            {
                CalcFields = "Applied Amount CZA";
                DataItemLink = "G/L Account No." = field("No.");
                DataItemTableView = sorting("G/L Account No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date") where("Closed CZA" = const(false));
                RequestFilterFields = "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date", "Document Type", "Document No.";
                column(OriginalGLEntry_EntryNo; "Entry No.")
                {
                }
                dataitem(AppliedEntry; "G/L Entry")
                {
                    CalcFields = "Applied Amount CZA";
                    DataItemLink = "G/L Account No." = field("G/L Account No.");
                    DataItemTableView = sorting("G/L Account No.", "Posting Date") where("Closed CZA" = const(false));

                    trigger OnAfterGetRecord()
                    begin
                        if (Applying = Applying::Free) and ByAmount then begin
                            TempGLEntry.Init();
                            TempGLEntry."Entry No." := "Entry No.";
                            TempGLEntry.Amount := Amount - "Applied Amount CZA";
                            TempGLEntry.Insert();
                            TotalAmount := TotalAmount + TempGLEntry.Amount;
                        end else begin
                            "Applies-to ID CZA" := OriginalEntry."Document No.";
                            "Amount to Apply CZA" := (Amount - "Applied Amount CZA");
                            TotalAmount := TotalAmount + "Amount to Apply CZA";
                            if Abs(TotalAmount) > Abs(OriginalAmount) then begin
                                "Amount to Apply CZA" := "Amount to Apply CZA" - (TotalAmount + OriginalAmount);
                                TotalAmount := -OriginalAmount;
                            end;
                            Modify();
                            Apply := true;
                            if TotalAmount = -OriginalAmount then
                                CurrReport.Break();
                        end;
                    end;

                    trigger OnPostDataItem()
                    var
                        ApplyGLEntry: Record "G/L Entry";
                    begin
                        if (Applying = Applying::Free) and ByAmount then
                            if TotalAmount = -(OriginalEntry.Amount - OriginalEntry."Applied Amount CZA") then begin
                                TempGLEntry.FindSet();
                                repeat
                                    ApplyGLEntry.Get(TempGLEntry."Entry No.");
                                    ApplyGLEntry."Applies-to ID CZA" := OriginalEntry."Document No.";
                                    ApplyGLEntry."Amount to Apply CZA" := TempGLEntry.Amount;
                                    ApplyGLEntry.Modify();
                                until TempGLEntry.Next() = 0;
                                Apply := true;
                            end;
                        AppliedAmount := 0;

                        TempGLEntry.Reset();
                        TempGLEntry.DeleteAll();
                        Clear(TempGLEntry);
                        TempDetailedGLEntryCZA.Reset();
                        TempDetailedGLEntryCZA.DeleteAll();
                        Clear(TempDetailedGLEntryCZA);

                        if Apply then begin
                            OriginalEntry."Applies-to ID CZA" := OriginalEntry."Document No.";
                            OriginalEntry."Amount to Apply CZA" := OriginalEntry.Amount - OriginalEntry."Applied Amount CZA";
                            OriginalEntry.Modify();
                            Clear(GLEntryPostApplicationCZA);

                            DetailedGLEntryCZA.Reset();
                            if DetailedGLEntryCZA.FindLast() then
                                LastEntry := DetailedGLEntryCZA."Entry No.";

                            GLEntryPostApplicationCZA.NotUseRequestPage();
                            GLEntryPostApplicationCZA.PostApplyGLEntry(OriginalEntry);
                            Clear(GLEntryPostApplicationCZA);

                            DetailedGLEntryCZA.Reset();
                            DetailedGLEntryCZA.SetFilter("Entry No.", '>%1', LastEntry);
                            if DetailedGLEntryCZA.FindSet() then
                                repeat
                                    if (DetailedGLEntryCZA."Applied G/L Entry No." = OriginalEntry."Entry No.") and
                                       (DetailedGLEntryCZA."G/L Entry No." <> OriginalEntry."Entry No.")
                                    then begin
                                        TempDetailedGLEntryCZA := DetailedGLEntryCZA;
                                        TempDetailedGLEntryCZA.Insert();
                                        AppliedAmount := AppliedAmount + DetailedGLEntryCZA.Amount;
                                    end;
                                until DetailedGLEntryCZA.Next() = 0;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        TotalAmount := 0;
                        Apply := false;

                        SetRange("Entry No.");
                        SetRange("G/L Account No.", OriginalEntry."G/L Account No.");
                        if OriginalEntry.Amount < 0 then
                            SetFilter(Amount, '>0')
                        else
                            SetFilter(Amount, '<0');
                        if ByBusUnit then
                            SetRange("Business Unit Code", OriginalEntry."Business Unit Code");
                        if ByPostingDate then
                            SetRange("Posting Date", OriginalEntry."Posting Date");
                        if ByDocNo then
                            SetRange("Document No.", OriginalEntry."Document No.");
                        if ByExtDocNo then
                            SetRange("External Document No.", OriginalEntry."External Document No.");
                        if (Applying = Applying::Unicate) and ByAmount then
                            SetRange(Amount, -(OriginalEntry.Amount - OriginalEntry."Applied Amount CZA"));

                        if Applying = Applying::Unicate then
                            if Count() <> 1 then
                                CurrReport.Break();
                    end;
                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(AppliedAmount; -AppliedAmount)
                    {
                    }
                    column(OriginalEntry_CreditAmount; OriginalEntry."Credit Amount")
                    {
                    }
                    column(OriginalEntry_DebitAmount; OriginalEntry."Debit Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(OriginalEntry_Amount; OriginalEntry.Amount)
                    {
                        IncludeCaption = true;
                    }
                    column(OriginalEntry_Description; OriginalEntry.Description)
                    {
                        IncludeCaption = true;
                    }
                    column(OriginalEntry_PostingDate; OriginalEntry."Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(OriginalEntry_DocumentNo; OriginalEntry."Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(OriginalEntry_EntryNo; OriginalEntry."Entry No.")
                    {
                        IncludeCaption = true;
                    }
                    column(DetailedGLEntryCZA_Amount; TempDetailedGLEntryCZA.Amount)
                    {
                    }
                    column(GLEntry_CreditAmount; GLEntry."Credit Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(GLEntry_DebitAmount; GLEntry."Debit Amount")
                    {
                    }
                    column(GLEntry_Description; GLEntry.Description)
                    {
                    }
                    column(GLEntry_PostingDate; GLEntry."Posting Date")
                    {
                    }
                    column(GLEntry_DocumentNo; GLEntry."Document No.")
                    {
                    }
                    column(DetailedGLEntryCZA_GLEntryNo; TempDetailedGLEntryCZA."G/L Entry No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempDetailedGLEntryCZA.FindSet()
                        else
                            TempDetailedGLEntryCZA.Next();

                        GLEntry.Get(TempDetailedGLEntryCZA."G/L Entry No.");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempDetailedGLEntryCZA.Count());
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    OriginalAmount := Amount - "Applied Amount CZA";
                end;
            }
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
                    group("Close by")
                    {
                        Caption = 'Close by';
                        field(ByBusUnitField; ByBusUnit)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Business Unit Code';
                            ToolTip = 'Specifies if the G/L entries have to be according to the business unit code applied.';
                        }
                        field(ColumnDimField; ColumnDim)
                        {
                            ApplicationArea = Dimensions;
                            Caption = 'Dimensions';
                            Editable = false;
                            ToolTip = 'Specifies if the G/L entries have to be according to the dimensions applied.';
                            Visible = false;

                            trigger OnAssistEdit()
                            begin
                                DimensionSelectionBuffer.SetDimSelectionMultiple(3, Report::"Close Income Statement CZL", ColumnDim);
                            end;
                        }
                        field(ByDocNoField; ByDocNo)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Document No.';
                            ToolTip = 'Specifies if the G/L entries have to be according to the document number applied.';
                        }
                        field(ByExtDocNoField; ByExtDocNo)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'External Document No.';
                            ToolTip = 'Specifies if the G/L entries have to be according to the external document number applied.';
                        }
                        field(ByPostingDateField; ByPostingDate)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Posting Date';
                            ToolTip = 'Specifies if the G/L entries have to be according to the posting date applied.';
                        }
                        field(ByAmountField; ByAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Amount';
                            ToolTip = 'Specifies if the G/L entries have to be according to the amount applied.';
                        }
                    }
                    field(ApplyingField; Applying)
                    {
                        ApplicationArea = Basic, Suite;
                        OptionCaption = 'Free Applying,Unicate Applying';
                        ToolTip = 'Specifies if the G/L entries have to be free or unicate applied.';
                    }
                }
            }
        }
    }

    labels
    {
        PageLbl = 'Page';
        AppliedAmountLbl = 'Applied Amount';
        GLEntryApplyingLbl = 'G/L Entry Applying';
    }

    trigger OnPreReport()
    begin
        AccFilter := "G/L Account".GetFilters;
        GLEntryFilter := OriginalEntry.GetFilters;
    end;

    var
        GLEntry: Record "G/L Entry";
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        DimensionSelectionBuffer: Record "Dimension Selection Buffer";
        TempDetailedGLEntryCZA: Record "Detailed G/L Entry CZA" temporary;
        TempGLEntry: Record "G/L Entry" temporary;
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
        Applying: Option Free,Unicate;
        ByBusUnit: Boolean;
        ByDocNo: Boolean;
        ByExtDocNo: Boolean;
        ByAmount: Boolean;
        ByPostingDate: Boolean;
        Apply: Boolean;
        ColumnDim: Text[250];
        AccFilter: Text;
        GLEntryFilter: Text;
        LastEntry: Integer;
        TotalAmount: Decimal;
        OriginalAmount: Decimal;
        AppliedAmount: Decimal;
}
