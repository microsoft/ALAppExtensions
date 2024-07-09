// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using System.Utilities;

report 11749 "VAT Coeff. Correction CZL"
{
    Caption = 'VAT Coefficient Correction';
    DefaultLayout = RDLC;
    RDLCLayout = '.\Src\Reports\VATCoeffCorrection.rdl';
    AdditionalSearchTerms = 'VAT value added tax coefficient report,VAT value added tax coefficient correct';
    ApplicationArea = Basic, Suite;
    UsageCategory = ReportsAndAnalysis;
    Permissions = tabledata "VAT Entry" = rimd,
                  tabledata "G/L Register" = rimd;

    dataset
    {
        dataitem("VAT Entry"; "VAT Entry")
        {
            DataItemTableView = sorting("Original VAT Entry No. CZL")
                                where("Original VAT Entry No. CZL" = filter(<> 0),
                                      Type = const(Purchase),
                                      "Non-Deductible VAT %" = filter(> 0 & < 100));
            RequestFilterFields = "VAT Bus. Posting Group", "VAT Prod. Posting Group";

            trigger OnAfterGetRecord()
            var
                NonDeductibleVATSetupCZL: Record "Non-Deductible VAT Setup CZL";
                SettlementVATAmount: Decimal;
            begin
                if "Original VAT Entry No. CZL" <> "Entry No." then
                    exit;

                GetVATPostingSetup("VAT Bus. Posting Group", "VAT Prod. Posting Group");

                if not NonDeductibleVATSetupCZL.FindToDate("VAT Reporting Date") then
                    Error(NonDeductVATSetupNotFoundErr, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Reporting Date");

                LastVATEntry.FindLastByOriginalVATEntryCZL("Entry No.");
                if LastVATEntry."Non-Deductible VAT %" = NonDeductibleVATSetupCZL."Settlement Coefficient" then
                    exit;
                TempVATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group");
                TempVATPostingSetup.TestField("VAT Coeff. Corr. Account CZL");

                TempVATEntry := "VAT Entry";
                if UseDocumentNo <> '' then
                    TempVATEntry."Document No." := UseDocumentNo;
                if UsePostingDate <> 0D then begin
                    TempVATEntry."Posting Date" := UsePostingDate;
                    TempVATEntry."Document Date" := UsePostingDate;
                end;
                if UseVATDate <> 0D then
                    TempVATEntry."VAT Reporting Date" := UseVATDate;

                LastVATEntry.CalcSums(Amount);

                TempVATEntry."Non-Deductible VAT %" := NonDeductibleVATSetupCZL."Settlement Coefficient";
                SettlementVATAmount := "Original VAT Amount CZL" * ((100 - NonDeductibleVATSetupCZL."Settlement Coefficient") / 100);
                TempVATEntry.Amount := Round(SettlementVATAmount - LastVATEntry.Amount);
                TempVATEntry.Base := "Original VAT Base CZL" * (NonDeductibleVATSetupCZL."Settlement Coefficient" - LastVATEntry."Non-Deductible VAT %") / 100;
                TempVATEntry.Insert(false);
            end;

            trigger OnPreDataItem()
            begin
                SetRange("VAT Reporting Date", FromVATDate, ToVATDate);
            end;
        }
        dataitem(Loop; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = filter(1 ..));
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(DocumentNo_VATEntry; VATEntry."Document No.")
            {
            }
            column(VATBusPostingGroup_VATEntry; VATEntry."VAT Bus. Posting Group")
            {
            }
            column(VATProdPostingGroup_VATEntry; VATEntry."VAT Prod. Posting Group")
            {
            }
            column(VATDate_VATEntry; Format(VATEntry."VAT Reporting Date"))
            {
            }
            column(PostingDate_VATEntry; Format(VATEntry."Posting Date"))
            {
            }
            column(NonDeductibleVATPct_VATEntry; VATEntry."Non-Deductible VAT %")
            {
            }
            column(NonDeductibleVATPct_LastVATEntry; LastVATEntry."Non-Deductible VAT %")
            {
            }
            column(NonDeductibleVATPct_TempVATEntry; TempVATEntry."Non-Deductible VAT %")
            {
            }
            column(DeductibleVATBase_VATEntry; VATEntry.CalcDeductibleVATBaseCZL())
            {
            }
            column(Amount_VATEntry; VATEntry.Amount)
            {
            }
            column(Base_TempVATEntry; TempVATEntry.Base)
            {
            }
            column(Amount_TempVATEntry; TempVATEntry.Amount)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempVATEntry.FindSet()
                else
                    TempVATEntry.Next();

                VATEntry.Get(TempVATEntry."Entry No.");

                LastVATEntry.FindLastByOriginalVATEntryCZL(TempVATEntry."Entry No.");

                if Post then
                    PostVAT();
            end;

            trigger OnPreDataItem()
            begin
                if TempVATEntry.IsEmpty() then
                    Error(NothingToCorrectErr);

                SetRange(Number, 1, TempVATEntry.Count());
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
                group(Entries)
                {
                    Caption = 'Entries';
                    field(FromVATDateField; FromVATDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting VAT Date';
                        ToolTip = 'Specifies the first VAT date in the period.';
                    }
                    field(ToVATDateField; ToVATDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending VAT Date';
                        ToolTip = 'Specifies the last VAT date in the period.';
                    }
                }
                group(Posting)
                {
                    Caption = 'Posting';
                    field(PostField; Post)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post';
                        ToolTip = 'Specifies if the non-deductible VAT correction has to be posted.';
                    }
                    field(UseDimensionsField; UseDimensions)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Dimensions';
                        OptionCaption = 'From G/L Account,None';
                        ToolTip = 'Specifies the dimensions source of new entries.';
                    }
                    field(UseDocumentNoField; UseDocumentNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Document No';
                        ToolTip = 'Specifies document No. for new entries.';
                    }
                    field(UsePostingDateField; UsePostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Posting Date';
                        ToolTip = 'Specifies posting date for new entries.';
                    }
                    field(UseVATDateField; UseVATDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use VAT Date';
                        ToolTip = 'Specifies vat date for new entries.';
                    }
                }
            }
        }
    }
    labels
    {
        ReportNameLbl = 'VAT Coefficient Correction';
        PageLbl = 'Page';
        DocumentNoLbl = 'Document No.';
        PostingDateLbl = 'Posting Date';
        VATDateLbl = 'VAT Date';
        VATBusPostingGroupLbl = 'VAT Bus. Posting Group';
        VATProdPostingGroupLbl = 'VAT Prod. Posting Group';
        NonDeductibelVATPctLbl = 'Non-Deductible VAT %';
        NewNonDeductibleVATPctLbl = 'New Non-Deductible VAT %';
        LastNonDeductibleVATPctLbl = 'Last Non-Deductible VAT %';
        CorrectedVATBaseLbl = 'Corrected VAT Base';
        CorrectedVATAmountLbl = 'Corrected VAT Amount';
        DeductibleVATBaseLbl = 'Deductible VAT Base';
        VATAmountLbl = 'VAT Amount';
        TotalLbl = 'Total';
    }

    trigger OnInitReport()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnInitReport(IsHandled);
        if IsHandled then
            exit;
    end;

    trigger OnPreReport()
    begin
        if (FromVATDate = 0D) or (ToVATDate = 0D) then
            Error(NoPeriodSpecifiedErr);
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("VAT Coeff. Correction CZL");
    end;

    trigger OnPostReport()
    begin
        if FirstVATEntryNo > 0 then begin
            GLRegister.FindLast();
            GLRegister."From VAT Entry No." := FirstVATEntryNo;
            GLRegister."To VAT Entry No." := ModifyVATEntry."Entry No.";
            GLRegister.Modify(false);
        end;
    end;

    protected var
        TempVATEntry: Record "VAT Entry" temporary;
        FromVATDate, ToVATDate, UsePostingDate, UseVATDate : Date;
        Post: Boolean;
        UseDimensions: Option "From G/L Account","None";
        UseDocumentNo: Code[20];

    var
        TempVATPostingSetup: Record "VAT Posting Setup" temporary;
        VATEntry: Record "VAT Entry";
        ModifyVATEntry: Record "VAT Entry";
        LastVATEntry: Record "VAT Entry";
        SourceCodeSetup: Record "Source Code Setup";
        GLRegister: Record "G/L Register";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        FirstVATEntryNo: Integer;
        NonDeductVATSetupNotFoundErr: Label 'Non-Deductible VAT setup has not been found for %1 %2 <= %3.', Comment = '%1 = VAT Bus. Posting Group, %2 = VAT Prod. Posting Group, %3 = VAT Reporting Date';
        NothingToCorrectErr: Label 'No entries to correct have been found.';
        NoPeriodSpecifiedErr: Label 'You must fill Starting VAT Date and Ending VAT Date.';

    local procedure PostVAT()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        EntryNo: Integer;
    begin
        // Only G/L Account without VAT
        GetVATPostingSetup(TempVATEntry."VAT Bus. Posting Group", TempVATEntry."VAT Prod. Posting Group");
        GLAccount.Get(TempVATPostingSetup."VAT Coeff. Corr. Account CZL");
        GenJournalLine.Init();
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Account No." := GLAccount."No.";
        GenJournalLine."Bal. Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Bal. Account No." := TempVATPostingSetup."Purchase VAT Account";
        GenJournalLine.Description := GLAccount.Name;
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Source Code" := SourceCodeSetup."VAT Coeff. Correction CZL";
        GenJournalLine."Posting Date" := TempVATEntry."Posting Date";
        GenJournalLine."Document No." := TempVATEntry."Document No.";
        GenJournalLine."Tax Area Code" := TempVATEntry."Tax Area Code";
        GenJournalLine."Tax Liable" := TempVATEntry."Tax Liable";
        GenJournalLine."Tax Group Code" := TempVATEntry."Tax Group Code";
        GenJournalLine."VAT Registration No." := TempVATEntry."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := TempVATEntry."Registration No. CZL";
        GenJournalLine.Validate("VAT Reporting Date", TempVATEntry."VAT Reporting Date");
        GenJournalLine.Validate("Amount", -TempVATEntry.Amount);

        if UseDimensions = UseDimensions::"From G/L Account" then
            CreateDimensionFromGLAccount(GenJournalLine);

        OnPostVATOnBeforePostGenJournalLine(TempVATEntry, GenJournalLine);
        GenJnlPostLine.RunWithCheck(GenJournalLine);

        ModifyVATEntry.FindLast();
        EntryNo := ModifyVATEntry."Entry No.";
        ModifyVATEntry := TempVATEntry;
        ModifyVATEntry."Entry No." := EntryNo + 1;
        if FirstVATEntryNo = 0 then
            FirstVATEntryNo := ModifyVATEntry."Entry No.";
        ModifyVATEntry."Source Code" := SourceCodeSetup."VAT Coeff. Correction CZL";
        ModifyVATEntry."Original VAT Entry No. CZL" := TempVATEntry."Entry No.";
        ModifyVATEntry."Original VAT Amount CZL" := 0;
        ModifyVATEntry."Original VAT Base CZL" := 0;
        ModifyVATEntry.Base := -TempVATEntry.Base;
        ModifyVATEntry."Non-Deductible VAT Base" := TempVATEntry.Base;
        ModifyVATEntry."Non-Deductible VAT Amount" := -TempVATEntry.Amount;
        ModifyVATEntry."VAT Calculation Type" := ModifyVATEntry."VAT Calculation Type"::"Normal VAT";

        // Clear system fields
        ModifyVATEntry.Closed := false;
        ModifyVATEntry."Closed by Entry No." := 0;
        ModifyVATEntry."VAT Settlement No. CZL" := '';
        OnPostVATOnBeforeInsertVATEntry(GenJournalLine, ModifyVATEntry);
        ModifyVATEntry.Insert(false);

        OnAfterPostVAT(GenJournalLine, ModifyVATEntry);
    end;

    local procedure CreateDimensionFromGLAccount(var GenJournalLine: Record "Gen. Journal Line")
    var
        DimensionManagement: Codeunit "DimensionManagement";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", GenJournalLine."Account No.", false);
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", GenJournalLine."Bal. Account No.", false);
        GenJournalLine.CreateDim(DefaultDimSource);
    end;

    local procedure GetVATPostingSetup(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if TempVATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup) then
            exit;

        VATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup);
        TempVATPostingSetup := VATPostingSetup;
        TempVATPostingSetup.Insert();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnInitReport(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostVATOnBeforePostGenJournalLine(VATEntry: Record "VAT Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostVATOnBeforeInsertVATEntry(GenJournalLine: Record "Gen. Journal Line"; var VATEntry: Record "VAT Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterPostVAT(var GenJournalLine: Record "Gen. Journal Line"; var VATEntry: Record "VAT Entry")
    begin
    end;
}
