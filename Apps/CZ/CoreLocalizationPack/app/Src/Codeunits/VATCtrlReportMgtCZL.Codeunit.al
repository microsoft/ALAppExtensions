// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Intrastat;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Utilities;
using System.IO;
using System.Reflection;
using System.Utilities;

codeunit 31102 "VAT Ctrl. Report Mgt. CZL"
{
    Permissions = tabledata "VAT Entry" = rm,
                  tabledata "VAT Posting Setup" = r,
                  tabledata "VAT Ctrl. Report Header CZL" = rimd,
                  tabledata "VAT Ctrl. Report Line CZL" = rimd,
                  tabledata "VAT Ctrl. Report Section CZL" = r;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        TempVATEntryBudgetBuffer: Record "Budget Buffer" temporary;
        TempDocumentBudgetBuffer: Record "Budget Buffer" temporary;
        TempErrorBuffer: Record "Error Buffer" temporary;
        TempGlobalVATEntry: Record "VAT Entry" temporary;
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        WindowDialog: Dialog;
        ProgressDialogMsg: Label 'VAT Statement Line Progress     #1######## #2######## #3########', Comment = '%1 = Statement Template Name; %2 = Statement Name; %3 = Line No.';
        BufferCreateDialogMsg: Label 'VAT Control Report     #1########', Comment = '%1 = Statement Template Name';
        LineCreatedMsg: Label '%1 Lines have been created.', Comment = '%1 = Number of created lines';
        CloseVATControlRepHeaderQst: Label 'Really close lines of VAT Control Report No. %1?', Comment = '%1 = VAT Control Report No.';
        LinesNotExistErr: Label 'There is nothing to close for VAT Control Report No. %1.', Comment = '%1 = VAT Control Report No.';
        IsInitialized: Boolean;
        GlobalLineNo: Integer;
        InternalDocCheckMsg: Label 'There is nothing internal document to exclusion in VAT Control Report No. %1.', Comment = '%1 = VAT Control Report No.';
        AmountTxt: Label 'Amount';
        AdditionalCurrencyAmountTxt: Label 'Additional-Currency Amount';

    procedure GetVATCtrlReportLines(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date; VATStmTemplCode: Code[10]; VATStmName: Code[10]; ProcessType: Option Add,Rewrite; ShowMessage: Boolean; UseMergeVATEntries: Boolean)
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
        TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary;
        Temp1VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary;
        Temp2VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary;
        TempVATEntry: Record "VAT Entry" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        VATStatementLine: Record "VAT Statement Line";
        DocumentAmount: Decimal;
        i: Integer;
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;

        GeneralLedgerSetup.Get();
        StatutoryReportingSetupCZL.Get();
        if ProcessType = ProcessType::Rewrite then
            DeleteVATCtrlReportLines(VATCtrlReportHeaderCZL, StartDate, EndDate);

        Temp1VATCtrlReportEntLinkCZL.SetCurrentKey("VAT Entry No.");
        Temp2VATCtrlReportEntLinkCZL.SetCurrentKey("VAT Entry No.");

        if ShowMessage then
            WindowDialog.Open(ProgressDialogMsg);

        VATStatementLine.SetRange("Statement Template Name", VATStmTemplCode);
        VATStatementLine.SetRange("Statement Name", VATStmName);
        VATStatementLine.SetFilter("VAT Ctrl. Report Section CZL", '<>%1', '');
        if VATStatementLine.FindSet(false) then
            repeat
                if ShowMessage then begin
                    WindowDialog.Update(1, VATStatementLine."Statement Template Name");
                    WindowDialog.Update(2, VATStatementLine."Statement Name");
                    WindowDialog.Update(3, VATStatementLine."Line No.");
                end;

                GetVATEntryBufferForVATStatementLine(TempVATEntry, VATStatementLine, VATCtrlReportHeaderCZL, StartDate, EndDate);

                TempVATEntry.Reset();
                if TempVATEntry.FindSet() then
                    repeat
                        Temp1VATCtrlReportEntLinkCZL.SetRange("VAT Entry No.", TempVATEntry."Entry No.");
                        // exist in used VAT Entries
                        Temp2VATCtrlReportEntLinkCZL.SetRange("VAT Entry No.", TempVATEntry."Entry No.");
                        // exist in merged VAT Entries
                        if (not Temp1VATCtrlReportEntLinkCZL.FindFirst()) and
                           (not Temp2VATCtrlReportEntLinkCZL.FindFirst())
                        then begin
                            if (TempVATEntry."VAT Bus. Posting Group" <> VATPostingSetup."VAT Bus. Posting Group") or
                               (TempVATEntry."VAT Prod. Posting Group" <> VATPostingSetup."VAT Prod. Posting Group")
                            then begin
                                VATPostingSetup.Get(TempVATEntry."VAT Bus. Posting Group", TempVATEntry."VAT Prod. Posting Group");
                                VATPostingSetup.TestField("VAT Rate CZL");
                            end;

                            if VATCtrlReportSectionCZL.Code <> VATStatementLine."VAT Ctrl. Report Section CZL" then
                                VATCtrlReportSectionCZL.Get(VATStatementLine."VAT Ctrl. Report Section CZL");

                            if UseMergeVATEntries then
                                MergeVATEntry(TempVATEntry, Temp2VATCtrlReportEntLinkCZL);

                            DocumentAmount := GetDocumentAmount(
                                TempVATEntry, VATCtrlReportSectionCZL."Group By" = VATCtrlReportSectionCZL."Group By"::"External Document No.");
                            if (TempVATEntry."VAT Calculation Type" <> TempVATEntry."VAT Calculation Type"::"Reverse Charge VAT") and
                               (Abs(DocumentAmount) <= StatutoryReportingSetupCZL."Simplified Tax Document Limit") and
                               (VATPostingSetup."Corrections Bad Receivable CZL" = VATPostingSetup."Corrections Bad Receivable CZL"::" ") and
                               (VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" <> '') and
                               (not VATStatementLine."Ignore Simpl. Doc. Limit CZL")
                            then
                                VATCtrlReportSectionCZL.Get(VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code");

                            OnGetVATCtrlReportLinesOnBeforeAddVATEntryToBuffer(VATStatementLine, VATPostingSetup, VATCtrlReportSectionCZL, TempVATEntry);
                            AddVATEntryToBuffer(TempVATEntry, VATPostingSetup, VATCtrlReportSectionCZL, Temp1VATCtrlReportEntLinkCZL, Temp2VATCtrlReportEntLinkCZL, TempVATCtrlReportBufferCZL);
                        end;
                    until TempVATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        if not VATCtrlReportLineCZL.FindLast() then
            Clear(VATCtrlReportLineCZL);

        TempVATCtrlReportBufferCZL.Reset();
        Temp1VATCtrlReportEntLinkCZL.Reset();
        Temp2VATCtrlReportEntLinkCZL.Reset();
        Temp1VATCtrlReportEntLinkCZL.SetCurrentKey("Line No.");
        Temp2VATCtrlReportEntLinkCZL.SetCurrentKey("Line No.");
        if TempVATCtrlReportBufferCZL.FindSet() then
            repeat
                // line
                VATCtrlReportLineCZL.Init();
                VATCtrlReportLineCZL."VAT Ctrl. Report No." := VATCtrlReportHeaderCZL."No.";
                VATCtrlReportLineCZL."Line No." += 1;
                CopyBufferToLine(TempVATCtrlReportBufferCZL, VATCtrlReportLineCZL);
                if (VATCtrlReportLineCZL.Base <> 0) or (VATCtrlReportLineCZL.Amount <> 0) then begin
                    VATCtrlReportLineCZL.Insert();
                    i += 1;

                    // link to VAT Entries
                    Temp1VATCtrlReportEntLinkCZL.SetRange("Line No.", TempVATCtrlReportBufferCZL."Line No.");
                    if Temp1VATCtrlReportEntLinkCZL.FindSet() then
                        repeat
                            // VAT Control Line to VAT Entry Link
                            VATCtrlReportEntLinkCZL.Init();
                            VATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := VATCtrlReportLineCZL."VAT Ctrl. Report No.";
                            VATCtrlReportEntLinkCZL."Line No." := VATCtrlReportLineCZL."Line No.";
                            VATCtrlReportEntLinkCZL."VAT Entry No." := Temp1VATCtrlReportEntLinkCZL."VAT Entry No.";
                            VATCtrlReportEntLinkCZL.Insert();

                            // VAT Entry Merge Link
                            Temp2VATCtrlReportEntLinkCZL.SetRange("Line No.", Temp1VATCtrlReportEntLinkCZL."VAT Entry No.");
                            if Temp2VATCtrlReportEntLinkCZL.FindSet() then
                                repeat
                                    VATCtrlReportEntLinkCZL.Init();
                                    VATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := VATCtrlReportLineCZL."VAT Ctrl. Report No.";
                                    VATCtrlReportEntLinkCZL."Line No." := VATCtrlReportLineCZL."Line No.";
                                    VATCtrlReportEntLinkCZL."VAT Entry No." := Temp2VATCtrlReportEntLinkCZL."VAT Entry No.";
                                    VATCtrlReportEntLinkCZL.Insert();
                                until Temp2VATCtrlReportEntLinkCZL.Next() = 0;
                        until Temp1VATCtrlReportEntLinkCZL.Next() = 0;
                end;
            until TempVATCtrlReportBufferCZL.Next() = 0;

        if ShowMessage then begin
            WindowDialog.Close();
            Message(LineCreatedMsg, i);
        end;
    end;

    local procedure AddVATEntryToBuffer(
        TempVATEntry: Record "VAT Entry" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        var Temp1VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary;
        var Temp2VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary;
        var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    var
        TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary;
        TempActualVATEntry: Record "VAT Entry" temporary;
    begin
        case VATCtrlReportSectionCZL.Code of
            'A1', 'B1':
                begin
                    MergeVATEntry(TempVATEntry, Temp2VATCtrlReportEntLinkCZL);
                    GetBufferFromDocument(TempVATEntry, TempDropShptPostBuffer, VATCtrlReportSectionCZL.Code);
                    TempDropShptPostBuffer.Reset();
                    TempActualVATEntry := TempVATEntry;
                    if TempDropShptPostBuffer.FindSet() then
                        repeat
                            TempVATEntry.Base := TempDropShptPostBuffer.Quantity;
                            TempVATEntry.Amount := TempDropShptPostBuffer."Quantity (Base)";
                            InsertVATCtrlReportBuffer(TempVATEntry, VATCtrlReportSectionCZL, VATPostingSetup, TempDropShptPostBuffer."Order No.", Temp1VATCtrlReportEntLinkCZL, TempVATCtrlReportBufferCZL);
                        until TempDropShptPostBuffer.Next() = 0;
                end;
            else
                InsertVATCtrlReportBuffer(TempVATEntry, VATCtrlReportSectionCZL, VATPostingSetup, '', Temp1VATCtrlReportEntLinkCZL, TempVATCtrlReportBufferCZL);
        end;
    end;

    local procedure MergeVATEntry(var TempVATEntry: Record "VAT Entry" temporary; var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary)
    begin
        TempVATEntryBudgetBuffer.Reset();
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."G/L Account No.", TempVATEntry."Document No.");
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."Dimension Value Code 1", Format(TempVATEntry."VAT Calculation Type", 0, '<Number>'));
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."Dimension Value Code 2", TempVATEntry."VAT Bus. Posting Group");
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."Dimension Value Code 3", TempVATEntry."VAT Prod. Posting Group");
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."Dimension Value Code 4", Format(TempVATEntry.Type, 0, '<Number>'));
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."Dimension Value Code 5", TempVATEntry."VAT Registration No.");
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."Dimension Value Code 6", CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempVATEntryBudgetBuffer."Dimension Value Code 6")));
        if StrLen(TempVATEntry."External Document No.") > MaxStrLen(TempVATEntryBudgetBuffer."Dimension Value Code 6") then
            TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer."Dimension Value Code 7", CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempVATEntryBudgetBuffer."Dimension Value Code 6") + 1));
        TempVATEntryBudgetBuffer.SetRange(TempVATEntryBudgetBuffer.Date, TempVATEntry."Posting Date");
        OnMergeVATEntryOnBeforeTempVATEntryBudgetBufferFindFirst(TempVATEntry, TempVATEntryBudgetBuffer);
        if not TempVATEntryBudgetBuffer.FindFirst() then begin
            TempGlobalVATEntry.Reset();
            TempGlobalVATEntry.SetCurrentKey("Document No.");
            TempGlobalVATEntry.SetRange("Document No.", TempVATEntry."Document No.");
            TempGlobalVATEntry.SetRange("VAT Bus. Posting Group", TempVATEntry."VAT Bus. Posting Group");
            TempGlobalVATEntry.SetRange("VAT Prod. Posting Group", TempVATEntry."VAT Prod. Posting Group");
            TempGlobalVATEntry.SetRange(Type, TempVATEntry.Type);
            TempGlobalVATEntry.SetRange("VAT Registration No.", TempVATEntry."VAT Registration No.");
            TempGlobalVATEntry.SetRange("External Document No.", TempVATEntry."External Document No.");
            TempGlobalVATEntry.SetRange("Posting Date", TempVATEntry."Posting Date");
            OnMergeVATEntryOnBeforeTempGlobalVATEntryFindSet(TempVATEntry, TempGlobalVATEntry);
            if TempGlobalVATEntry.FindSet() then begin
                TempVATEntryBudgetBuffer.Init();
                TempVATEntryBudgetBuffer."G/L Account No." := TempVATEntry."Document No.";
                TempVATEntryBudgetBuffer."Dimension Value Code 1" := Format(TempVATEntry."VAT Calculation Type", 0, '<Number>');
                TempVATEntryBudgetBuffer."Dimension Value Code 2" := TempVATEntry."VAT Bus. Posting Group";
                TempVATEntryBudgetBuffer."Dimension Value Code 3" := TempVATEntry."VAT Prod. Posting Group";
                TempVATEntryBudgetBuffer."Dimension Value Code 4" := Format(TempVATEntry.Type, 0, '<Number>');
                TempVATEntryBudgetBuffer."Dimension Value Code 5" := TempVATEntry."VAT Registration No.";
                TempVATEntryBudgetBuffer."Dimension Value Code 6" := CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempVATEntryBudgetBuffer."Dimension Value Code 6"));
                TempVATEntryBudgetBuffer."Dimension Value Code 7" := CopyStr(CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempVATEntryBudgetBuffer."Dimension Value Code 6") + 1),
                                                1, MaxStrLen(TempVATEntryBudgetBuffer."Dimension Value Code 7"));
                TempVATEntryBudgetBuffer.Date := TempVATEntry."Posting Date";

                TempVATEntry.Base := 0;
                TempVATEntry.Amount := 0;
                repeat
                    TempVATEntry.Base += TempGlobalVATEntry.Base;
                    TempVATEntry.Amount += TempGlobalVATEntry.Amount;
                    if TempGlobalVATEntry."Entry No." <> TempVATEntry."Entry No." then begin
                        TempVATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := '';
                        TempVATCtrlReportEntLinkCZL."Line No." := TempVATEntry."Entry No.";
                        TempVATCtrlReportEntLinkCZL."VAT Entry No." := TempGlobalVATEntry."Entry No.";
                        TempVATCtrlReportEntLinkCZL.Insert();
                    end;
                until TempGlobalVATEntry.Next() = 0;
                OnMergeVATEntryOnBeforeInsertTempVATEntryBudgetBuffer(TempVATEntry, TempVATEntryBudgetBuffer);
                TempVATEntryBudgetBuffer.Insert();
            end;
        end;
    end;

    local procedure GetDocumentAmount(var TempVATEntry: Record "VAT Entry" temporary; ExternalDocument: Boolean): Decimal
    begin
        TempDocumentBudgetBuffer.Reset();
        if not ExternalDocument or (TempVATEntry."External Document No." = '') then
            TempDocumentBudgetBuffer.SetRange(TempDocumentBudgetBuffer."G/L Account No.", TempVATEntry."Document No.")
        else begin
            TempDocumentBudgetBuffer.SetRange(TempDocumentBudgetBuffer."Dimension Value Code 6", CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempDocumentBudgetBuffer."Dimension Value Code 6")));
            TempDocumentBudgetBuffer.SetRange(TempDocumentBudgetBuffer."Dimension Value Code 7", CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempDocumentBudgetBuffer."Dimension Value Code 6") + 1));
        end;
        if not IsDocumentWithReverseChargeVAT(TempVATEntry."Document No.", TempVATEntry."Posting Date") then
            TempDocumentBudgetBuffer.SetRange(TempDocumentBudgetBuffer."Dimension Value Code 1", Format(TempVATEntry."VAT Calculation Type", 0, '<Number>'));
        TempDocumentBudgetBuffer.SetRange(TempDocumentBudgetBuffer."Dimension Value Code 2", Format(TempVATEntry.Type, 0, '<Number>'));
        TempDocumentBudgetBuffer.SetRange(TempDocumentBudgetBuffer."Dimension Value Code 3", TempVATEntry."Bill-to/Pay-to No.");
        TempDocumentBudgetBuffer.SetRange(TempDocumentBudgetBuffer.Date, TempVATEntry."Posting Date");
        OnGetDocumentAmountOnBeforeTempDocumentBudgetBufferFindFirst(TempVATEntry, TempDocumentBudgetBuffer);
        if not TempDocumentBudgetBuffer.FindFirst() then begin
            TempGlobalVATEntry.Reset();
            if not ExternalDocument or (TempVATEntry."External Document No." = '') then
                TempGlobalVATEntry.SetRange("Document No.", TempVATEntry."Document No.")
            else
                TempGlobalVATEntry.SetRange("External Document No.", TempVATEntry."External Document No.");
            TempGlobalVATEntry.SetRange("Bill-to/Pay-to No.", TempVATEntry."Bill-to/Pay-to No.");
            TempGlobalVATEntry.SetRange("Posting Date", TempVATEntry."Posting Date");
            TempGlobalVATEntry.SetRange(Type, TempVATEntry.Type);
            OnGetDocumentAmountOnBeforeTempGlobalVATEntryFindSet(TempVATEntry, TempGlobalVATEntry);
            if TempGlobalVATEntry.FindSet() then begin
                TempDocumentBudgetBuffer.Init();
                if not ExternalDocument or (TempVATEntry."External Document No." = '') then
                    TempDocumentBudgetBuffer."G/L Account No." := TempVATEntry."Document No."
                else begin
                    TempDocumentBudgetBuffer."Dimension Value Code 6" := CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempDocumentBudgetBuffer."Dimension Value Code 6"));
                    TempDocumentBudgetBuffer."Dimension Value Code 7" := CopyStr(CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempDocumentBudgetBuffer."Dimension Value Code 6") + 1),
                                                    1, MaxStrLen(TempDocumentBudgetBuffer."Dimension Value Code 7"));
                end;
                TempDocumentBudgetBuffer."Dimension Value Code 1" := Format(TempVATEntry."VAT Calculation Type", 0, '<Number>');
                TempDocumentBudgetBuffer."Dimension Value Code 2" := Format(TempVATEntry.Type, 0, '<Number>');
                TempDocumentBudgetBuffer."Dimension Value Code 3" := TempVATEntry."Bill-to/Pay-to No.";
                TempDocumentBudgetBuffer.Date := TempVATEntry."Posting Date";
                repeat
                    TempDocumentBudgetBuffer.Amount += GetAmount(TempGlobalVATEntry);
                until TempGlobalVATEntry.Next() = 0;
                OnGetDocumentAmountOnBeforeInsertTempDocumentBudgetBuffer(TempVATEntry, TempDocumentBudgetBuffer);
                TempDocumentBudgetBuffer.Insert();
            end;
        end;
        exit(TempDocumentBudgetBuffer.Amount);
    end;

    local procedure GetAmount(var TempVATEntry: Record "VAT Entry" temporary): Decimal
    var
        Base, Amount : Decimal;
    begin
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            Base := TempVATEntry."Additional-Currency Base";
            Amount := TempVATEntry."Additional-Currency Amount";
        end else begin
            Base := TempVATEntry.Base;
            Amount := TempVATEntry.Amount;
        end;

        if TempVATEntry."VAT Calculation Type" = TempVATEntry."VAT Calculation Type"::"Reverse Charge VAT" then
            exit(Base);
        exit(Base + Amount);
    end;

    local procedure IsDocumentWithReverseChargeVAT(DocumentNo: Code[20]; PostingDate: Date): Boolean
    begin
        TempGlobalVATEntry.Reset();
        TempGlobalVATEntry.SetCurrentKey("Document No.");
        TempGlobalVATEntry.SetRange("Document No.", DocumentNo);
        TempGlobalVATEntry.SetRange("Posting Date", PostingDate);
        TempGlobalVATEntry.SetRange("VAT Calculation Type", TempGlobalVATEntry."VAT Calculation Type"::"Reverse Charge VAT");
        exit(not TempGlobalVATEntry.IsEmpty());
    end;

    local procedure DeleteVATCtrlReportLines(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date)
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        if VATReportingDateMgt.IsVATDateEnabled() then begin
            VATCtrlReportLineCZL.SetCurrentKey("VAT Ctrl. Report No.", "VAT Date");
            VATCtrlReportLineCZL.SetRange("VAT Date", StartDate, EndDate);
        end else begin
            VATCtrlReportLineCZL.SetCurrentKey("VAT Ctrl. Report No.", "Posting Date");
            VATCtrlReportLineCZL.SetRange("Posting Date", StartDate, EndDate);
        end;
        VATCtrlReportLineCZL.SetFilter("Closed by Document No.", '%1', '');
        if not VATCtrlReportLineCZL.IsEmpty() then
            VATCtrlReportLineCZL.DeleteAll(true);
    end;

    local procedure InsertVATCtrlReportBuffer(
        TempVATEntry: Record "VAT Entry" temporary;
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        VATPostingSetup: Record "VAT Posting Setup";
        CommodityCode: Code[20];
        var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary;
        var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    var
        IsHandled: Boolean;
    begin
        OnBeforeInsertVATCtrlReportBuffer(TempVATEntry, VATCtrlReportSectionCZL, VATPostingSetup, CommodityCode, TempVATCtrlReportEntLinkCZL, TempVATCtrlReportBufferCZL, IsHandled);
        if IsHandled then
            exit;

        case VATCtrlReportSectionCZL."Group By" of
            VATCtrlReportSectionCZL."Group By"::"Document No.":
                InsertVATCtrlReportBufferDocNo(
                    TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL, TempVATEntry, VATPostingSetup, VATCtrlReportSectionCZL.Code, CommodityCode);
            VATCtrlReportSectionCZL."Group By"::"External Document No.":
                InsertVATCtrlReportBufferExtDocNo(
                    TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL, TempVATEntry, VATPostingSetup, VATCtrlReportSectionCZL.Code, CommodityCode);
            VATCtrlReportSectionCZL."Group By"::"Section Code":
                InsertVATCtrlReportBufferDocNo(
                    TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL, TempVATEntry, VATPostingSetup, VATCtrlReportSectionCZL.Code, CommodityCode);
        end;
    end;

    local procedure InsertVATCtrlReportBufferDocNo(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    begin
        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportBufferCZL.SetCurrentKey(TempVATCtrlReportBufferCZL."Document No.");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Document No.", VATEntry."Document No.");
        InsertVATCtrlReportBufferGroup(TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL,
          VATEntry, VATPostingSetup, SectionCode, CommodityCode);
    end;

    local procedure InsertVATCtrlReportBufferExtDocNo(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    begin
        TempVATCtrlReportBufferCZL.Reset();
        if VATEntry."External Document No." <> '' then begin
            TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."External Document No.", VATEntry."External Document No.");
            TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Original Document VAT Date", VATEntry."Original Doc. VAT Date CZL");
        end else begin
            TempVATCtrlReportBufferCZL.SetCurrentKey(TempVATCtrlReportBufferCZL."Document No.");
            TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Document No.", VATEntry."Document No.");
        end;
        InsertVATCtrlReportBufferGroup(TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL,
          VATEntry, VATPostingSetup, SectionCode, CommodityCode);
    end;

    local procedure InsertVATCtrlReportBufferGroup(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    begin
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code", SectionCode);
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."VAT Rate", VATPostingSetup."VAT Rate CZL");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Commodity Code", CommodityCode);
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."VAT Registration No.", VATEntry."VAT Registration No.");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Supplies Mode Code", VATPostingSetup."Supplies Mode Code CZL");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Corrections for Bad Receivable", VATPostingSetup."Corrections Bad Receivable CZL");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Ratio Use", VATPostingSetup."Ratio Coefficient CZL");
        OnInsertVATCtrlReportBufferGroupOnBeforeTempVATCtrlReportBufferCZLFindFirst(VATEntry, VATPostingSetup, TempVATCtrlReportBufferCZL);
        if not TempVATCtrlReportBufferCZL.FindFirst() then
            InsertVATCtrlReportBuffer(TempVATCtrlReportBufferCZL, VATEntry, VATPostingSetup, SectionCode, CommodityCode)
        else begin
            TempVATCtrlReportBufferCZL."Total Base" += VATEntry.Base;
            TempVATCtrlReportBufferCZL."Total Amount" += VATEntry.Amount;
            TempVATCtrlReportBufferCZL."Add.-Currency Total Base" += VATEntry."Additional-Currency Base";
            TempVATCtrlReportBufferCZL."Add.-Currency Total Amount" += VATEntry."Additional-Currency Amount";
            TempVATCtrlReportBufferCZL.Modify();
        end;
        InsertVATCtrlReportEntryLink(TempVATCtrlReportEntLinkCZL, TempVATCtrlReportBufferCZL."Line No.", VATEntry."Entry No.");
    end;

    local procedure InsertVATCtrlReportBuffer(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        TempVATCtrlReportBufferCZL.Init();
        TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code" := SectionCode;
        GlobalLineNo += 1;
        TempVATCtrlReportBufferCZL."Line No." := GlobalLineNo;
        TempVATCtrlReportBufferCZL."Posting Date" := VATEntry."Posting Date";
        TempVATCtrlReportBufferCZL."VAT Date" := VATEntry."VAT Reporting Date";
        TempVATCtrlReportBufferCZL."Original Document VAT Date" := VATEntry."Original Doc. VAT Date CZL";
        TempVATCtrlReportBufferCZL."Bill-to/Pay-to No." := VATEntry."Bill-to/Pay-to No.";
        TempVATCtrlReportBufferCZL."VAT Registration No." := VATEntry."VAT Registration No.";
        case VATEntry.Type of
            VATEntry.Type::Purchase:
                if Vendor.Get(TempVATCtrlReportBufferCZL."Bill-to/Pay-to No.") then begin
                    TempVATCtrlReportBufferCZL."Tax Registration No." := Vendor."Tax Registration No. CZL";
                    TempVATCtrlReportBufferCZL."Registration No." := Vendor.GetRegistrationNoTrimmedCZL();
                end;
            VATEntry.Type::Sale:
                if Customer.Get(TempVATCtrlReportBufferCZL."Bill-to/Pay-to No.") then begin
                    TempVATCtrlReportBufferCZL."Tax Registration No." := Customer."Tax Registration No. CZL";
                    TempVATCtrlReportBufferCZL."Registration No." := Customer.GetRegistrationNoTrimmedCZL();
                end;
        end;
        TempVATCtrlReportBufferCZL."Document No." := VATEntry."Document No.";
        TempVATCtrlReportBufferCZL."External Document No." := VATEntry."External Document No.";
        TempVATCtrlReportBufferCZL.Type := VATEntry.Type.AsInteger();
        TempVATCtrlReportBufferCZL."VAT Bus. Posting Group" := VATEntry."VAT Bus. Posting Group";
        TempVATCtrlReportBufferCZL."VAT Prod. Posting Group" := VATEntry."VAT Prod. Posting Group";
        TempVATCtrlReportBufferCZL."VAT Calculation Type" := VATEntry."VAT Calculation Type";
        TempVATCtrlReportBufferCZL."VAT Rate" := VATPostingSetup."VAT Rate CZL".AsInteger();
        TempVATCtrlReportBufferCZL."Commodity Code" := CopyStr(CommodityCode, 1, MaxStrLen(TempVATCtrlReportBufferCZL."Commodity Code"));
        TempVATCtrlReportBufferCZL."Supplies Mode Code" := VATPostingSetup."Supplies Mode Code CZL".AsInteger();
        TempVATCtrlReportBufferCZL."Corrections for Bad Receivable" := VATPostingSetup."Corrections Bad Receivable CZL";
        TempVATCtrlReportBufferCZL."Ratio Use" := VATPostingSetup."Ratio Coefficient CZL";
        TempVATCtrlReportBufferCZL."Total Base" := VATEntry.Base;
        TempVATCtrlReportBufferCZL."Total Amount" := VATEntry.Amount;
        TempVATCtrlReportBufferCZL."Add.-Currency Total Base" := VATEntry."Additional-Currency Base";
        TempVATCtrlReportBufferCZL."Add.-Currency Total Amount" := VATEntry."Additional-Currency Amount";
        OnInsertVATCtrlReportBufferOnBeforeInsert(VATEntry, VATPostingSetup, TempVATCtrlReportBufferCZL);
        TempVATCtrlReportBufferCZL.Insert();
    end;

    local procedure InsertVATCtrlReportEntryLink(var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary; LineNo: Integer; VATEntryNo: Integer): Boolean
    begin
        TempVATCtrlReportEntLinkCZL."Line No." := LineNo;
        TempVATCtrlReportEntLinkCZL."VAT Entry No." := VATEntryNo;
        exit(TempVATCtrlReportEntLinkCZL.Insert()); // vat entry split
    end;

    local procedure SkipVATEntry(VATEntry: Record "VAT Entry"): Boolean
    begin
        if VATEntry."VAT Ctrl. Report Line No. CZL" <> 0 then
            exit(true);
        if VATEntry.Base <> 0 then
            exit(false);
        if VATEntry."Unrealized Base" = 0 then
            exit(false);
        exit(IsVATEntryCorrected(VATEntry));
    end;

    local procedure IsVATEntryCorrected(VATEntry: Record "VAT Entry") IsCorrected: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeIsVATEntryCorrected(VATEntry, TempGlobalVATEntry, IsCorrected, IsHandled);
        if IsHandled then
            exit;

        TempGlobalVATEntry.Reset();
        TempGlobalVATEntry.SetCurrentKey("Document No.");
        TempGlobalVATEntry.SetRange("Document No.", VATEntry."Document No.");
        TempGlobalVATEntry.SetRange("Document Type", VATEntry."Document Type");
        TempGlobalVATEntry.SetRange(Type, VATEntry.Type);
        TempGlobalVATEntry.SetRange(Base, VATEntry."Unrealized Base");
        TempGlobalVATEntry.SetRange(Amount, VATEntry."Unrealized Amount");
        IsCorrected := not TempGlobalVATEntry.IsEmpty();
    end;

    local procedure GetBufferFromDocument(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; SectionCode: Code[20])
    var
        IsHandled: Boolean;
    begin
        OnBeforeGetBufferFromDocument(VATEntry, SectionCode, TempDropShptPostBuffer, IsHandled);
        if IsHandled then
            exit;

        TempDropShptPostBuffer.Reset();
        TempDropShptPostBuffer.DeleteAll();

        if VATEntry.Base <> 0 then
            case SectionCode of
                'A1':
                    begin
                        VATEntry.TestField(Type, VATEntry.Type::Sale);
                        case VATEntry."Document Type" of
                            VATEntry."Document Type"::Invoice:
                                SplitFromSalesInvLine(VATEntry, TempDropShptPostBuffer);
                            VATEntry."Document Type"::"Credit Memo":
                                SplitFromSalesCrMemoLine(VATEntry, TempDropShptPostBuffer);
                        end;
                    end;
                'B1':
                    begin
                        if VATEntry.Amount = 0 then
                            exit;

                        VATEntry.TestField(Type, VATEntry.Type::Purchase);
                        case VATEntry."Document Type" of
                            VATEntry."Document Type"::Invoice:
                                SplitFromPurchInvLine(VATEntry, TempDropShptPostBuffer);
                            VATEntry."Document Type"::"Credit Memo":
                                SplitFromPurchCrMemoLine(VATEntry, TempDropShptPostBuffer);
                        end;
                    end;
                else
                    exit;
            end;

        if not TempDropShptPostBuffer.FindFirst() then begin
            TempDropShptPostBuffer.Init();
            TempDropShptPostBuffer."Order No." := '';
            TempDropShptPostBuffer.Quantity := VATEntry.Base;
            TempDropShptPostBuffer."Quantity (Base)" := VATEntry.Amount;
            TempDropShptPostBuffer.Insert();
        end;
    end;

    local procedure SplitFromSalesInvLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        IsHandled: Boolean;
    begin
        SalesInvoiceLine.SetRange(SalesInvoiceLine."Document No.", VATEntry."Document No.");
        SalesInvoiceLine.SetRange(SalesInvoiceLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        SalesInvoiceLine.SetRange(SalesInvoiceLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        SalesInvoiceLine.SetFilter(SalesInvoiceLine.Type, '<>%1', SalesInvoiceLine.Type::" ");
        SalesInvoiceLine.SetFilter(SalesInvoiceLine.Quantity, '<>0');
        SalesInvoiceLine.SetRange("Prepayment Line", false);
        if SalesInvoiceLine.FindSet(false) then begin
            if SalesInvoiceHeader."No." <> SalesInvoiceLine."Document No." then
                SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
            repeat
                IsHandled := false;
                OnSplitFromSalesInvLineOnBeforeUpdateTempDropShptPostBuffer(SalesInvoiceHeader, SalesInvoiceLine, TempDropShptPostBuffer, IsHandled);
                if not IsHandled then
                    UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, SalesInvoiceLine."Tariff No. CZL",
                        SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group", -SalesInvoiceLine."VAT Base Amount",
                        SalesInvoiceHeader."Currency Code", SalesInvoiceHeader."VAT Currency Factor CZL", SalesInvoiceHeader."VAT Reporting Date",
                        false, -SalesInvoiceLine.Amount);
            until SalesInvoiceLine.Next() = 0;
        end;
    end;

    local procedure SplitFromSalesCrMemoLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        IsHandled: Boolean;
    begin
        SalesCrMemoLine.SetRange(SalesCrMemoLine."Document No.", VATEntry."Document No.");
        SalesCrMemoLine.SetRange(SalesCrMemoLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        SalesCrMemoLine.SetRange(SalesCrMemoLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        SalesCrMemoLine.SetFilter(SalesCrMemoLine.Type, '<>%1', SalesCrMemoLine.Type::" ");
        SalesCrMemoLine.SetFilter(SalesCrMemoLine.Quantity, '<>0');
        if SalesCrMemoLine.FindSet(false) then begin
            if SalesCrMemoHeader."No." <> SalesCrMemoLine."Document No." then
                SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.");
            repeat
                IsHandled := false;
                OnSplitFromSalesCrMemoLineOnBeforeUpdateTempDropShptPostBuffer(SalesCrMemoHeader, SalesCrMemoLine, TempDropShptPostBuffer, IsHandled);
                if not IsHandled then
                    UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, SalesCrMemoLine."Tariff No. CZL",
                        SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group", SalesCrMemoLine."VAT Base Amount",
                        SalesCrMemoHeader."Currency Code", SalesCrMemoHeader."VAT Currency Factor CZL", SalesCrMemoHeader."VAT Reporting Date",
                        false, SalesCrMemoLine.Amount);
            until SalesCrMemoLine.Next() = 0;
        end;
    end;

    local procedure SplitFromPurchInvLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        IsHandled: Boolean;
    begin
        PurchInvLine.SetRange(PurchInvLine."Document No.", VATEntry."Document No.");
        PurchInvLine.SetRange(PurchInvLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        PurchInvLine.SetRange(PurchInvLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        PurchInvLine.SetFilter(PurchInvLine.Type, '<>%1', PurchInvLine.Type::" ");
        PurchInvLine.SetFilter(PurchInvLine.Quantity, '<>0');
        PurchInvLine.SetRange("Prepayment Line", false);
        if PurchInvLine.FindSet(false) then begin
            if PurchInvHeader."No." <> PurchInvLine."Document No." then
                PurchInvHeader.Get(PurchInvLine."Document No.");
            repeat
                IsHandled := false;
                OnSplitFromPurchInvLineOnBeforeUpdateTempDropShptPostBuffer(PurchInvHeader, PurchInvLine, TempDropShptPostBuffer, IsHandled);
                if not IsHandled then
                    UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, PurchInvLine."Tariff No. CZL",
                        PurchInvLine."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group", PurchInvLine."VAT Base Amount",
                        PurchInvHeader."Currency Code", PurchInvHeader."VAT Currency Factor CZL", PurchInvHeader."VAT Reporting Date",
                        true, PurchInvLine.Amount);
            until PurchInvLine.Next() = 0;
        end;
    end;

    local procedure SplitFromPurchCrMemoLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        IsHandled: Boolean;
    begin
        PurchCrMemoLine.SetRange(PurchCrMemoLine."Document No.", VATEntry."Document No.");
        PurchCrMemoLine.SetRange(PurchCrMemoLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        PurchCrMemoLine.SetRange(PurchCrMemoLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        PurchCrMemoLine.SetFilter(PurchCrMemoLine.Type, '<>%1', PurchCrMemoLine.Type::" ");
        PurchCrMemoLine.SetFilter(PurchCrMemoLine.Quantity, '<>0');
        if PurchCrMemoLine.FindSet(false) then begin
            if PurchCrMemoHdr."No." <> PurchCrMemoLine."Document No." then
                PurchCrMemoHdr.Get(PurchCrMemoLine."Document No.");
            repeat
                IsHandled := false;
                OnSplitFromPurchCrMemoLineOnBeforeUpdateTempDropShptPostBuffer(PurchCrMemoHdr, PurchCrMemoLine, TempDropShptPostBuffer, IsHandled);
                if not IsHandled then
                    UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, PurchCrMemoLine."Tariff No. CZL",
                        PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group", -PurchCrMemoLine."VAT Base Amount",
                        PurchCrMemoHdr."Currency Code", PurchCrMemoHdr."VAT Currency Factor CZL", PurchCrMemoHdr."VAT Reporting Date",
                        true, -PurchCrMemoLine.Amount);
            until PurchCrMemoLine.Next() = 0;
        end;
    end;

    local procedure UpdateTempDropShptPostBuffer(var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; TariffNo: Code[20]; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; VATBaseAmount: Decimal; CurrencyCode: Code[10]; VATCurrencyFactor: Decimal; VATDate: Date; CalcQtyBase: Boolean; LineAmount: Decimal)
    var
        TariffNumber: Record "Tariff Number";
    begin
        if not TariffNumber.Get(TariffNo) then
            TariffNumber.Init();
        if not TempDropShptPostBuffer.Get(TariffNumber."Statement Code CZL") then begin
            TempDropShptPostBuffer.Init();
            TempDropShptPostBuffer."Order No." := TariffNumber."Statement Code CZL";
            TempDropShptPostBuffer.Insert();
        end;
        TempDropShptPostBuffer.Quantity += CalcVATBaseAmtLCY(
            VATBusPostingGroup,
            VATProdPostingGroup,
            VATBaseAmount,
            CurrencyCode,
            VATCurrencyFactor,
            VATDate);
        if CalcQtyBase then
            TempDropShptPostBuffer."Quantity (Base)" += CalcVATAmtLCY(
                CalcVATAmt(VATBusPostingGroup, VATProdPostingGroup, LineAmount),
                CurrencyCode,
                VATCurrencyFactor,
                VATDate)
        else
            TempDropShptPostBuffer."Quantity (Base)" := 0;
        TempDropShptPostBuffer.Modify();
    end;

    local procedure CalcVATBaseAmtLCY(VATBusPstGroup: Code[20]; VATProdPstGroup: Code[20]; VATBaseAmt: Decimal; CurrCode: Code[10]; CurrFactor: Decimal; PostingDate: Date) VATBaseAmtLCY: Decimal
    var
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
    begin
        VATBaseAmtLCY := 0;

        if CurrCode = '' then
            VATBaseAmtLCY := VATBaseAmt
        else begin
            TempGenJournalLine.Init();
            TempGenJournalLine.Validate("VAT Bus. Posting Group", VATBusPstGroup);
            TempGenJournalLine.Validate("VAT Prod. Posting Group", VATProdPstGroup);
            TempGenJournalLine.Validate("Posting Date", PostingDate);
            TempGenJournalLine.Validate("Currency Code", CurrCode);
            TempGenJournalLine.Validate("Currency Factor", CurrFactor);
            TempGenJournalLine.Validate("VAT Base Amount", VATBaseAmt);
            VATBaseAmtLCY := TempGenJournalLine."VAT Base Amount (LCY)";
        end;
    end;

    local procedure CalcVATAmtLCY(VATAmt: Decimal; CurrCode: Code[10]; CurrFactor: Decimal; PostingDate: Date) VATAmtLCY: Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        VATAmtLCY := 0;

        if CurrCode = '' then
            VATAmtLCY := VATAmt
        else
            VATAmtLCY := CurrencyExchangeRate.ExchangeAmtFCYToLCY(PostingDate, CurrCode, VATAmt, CurrFactor);
    end;

    local procedure CalcVATAmt(VATBusPstGroup: Code[20]; VATProdPstGroup: Code[20]; Amt: Decimal): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.Get(VATBusPstGroup, VATProdPstGroup);
        exit(Amt * VATPostingSetup."VAT %" / 100);
    end;

    procedure CreateBufferForStatistics(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; ShowMessage: Boolean)
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;

        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportBufferCZL.DeleteAll();

        if ShowMessage then begin
            WindowDialog.Open(BufferCreateDialogMsg);
            WindowDialog.Update(1, VATCtrlReportHeaderCZL."No.");
        end;

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Exclude from Export", false);
        if VATCtrlReportLineCZL.FindSet() then
            repeat
                if not TempVATCtrlReportBufferCZL.Get(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code") then begin
                    TempVATCtrlReportBufferCZL.Init();
                    TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code" := VATCtrlReportLineCZL."VAT Ctrl. Report Section Code";
                    TempVATCtrlReportBufferCZL.Insert();
                end;
                case VATCtrlReportLineCZL."VAT Rate" of
                    VATCtrlReportLineCZL."VAT Rate"::Base:
                        begin
                            TempVATCtrlReportBufferCZL."Base 1" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 1" += VATCtrlReportLineCZL.Amount;
                            TempVATCtrlReportBufferCZL."Add.-Currency Base 1" += VATCtrlReportLineCZL."Additional-Currency Base";
                            TempVATCtrlReportBufferCZL."Add.-Currency Amount 1" += VATCtrlReportLineCZL."Additional-Currency Amount";
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::Reduced:
                        begin
                            TempVATCtrlReportBufferCZL."Base 2" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 2" += VATCtrlReportLineCZL.Amount;
                            TempVATCtrlReportBufferCZL."Add.-Currency Base 2" += VATCtrlReportLineCZL."Additional-Currency Base";
                            TempVATCtrlReportBufferCZL."Add.-Currency Amount 2" += VATCtrlReportLineCZL."Additional-Currency Amount";
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::"Reduced 2":
                        begin
                            TempVATCtrlReportBufferCZL."Base 3" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 3" += VATCtrlReportLineCZL.Amount;
                            TempVATCtrlReportBufferCZL."Add.-Currency Base 3" += VATCtrlReportLineCZL."Additional-Currency Base";
                            TempVATCtrlReportBufferCZL."Add.-Currency Amount 3" += VATCtrlReportLineCZL."Additional-Currency Amount";
                        end;
                end;
                if VATCtrlReportLineCZL."VAT Rate" > VATCtrlReportLineCZL."VAT Rate"::" " then begin
                    TempVATCtrlReportBufferCZL."Total Base" += VATCtrlReportLineCZL.Base;
                    TempVATCtrlReportBufferCZL."Total Amount" += VATCtrlReportLineCZL.Amount;
                    TempVATCtrlReportBufferCZL."Add.-Currency Total Base" += VATCtrlReportLineCZL."Additional-Currency Base";
                    TempVATCtrlReportBufferCZL."Add.-Currency Total Amount" += VATCtrlReportLineCZL."Additional-Currency Amount";
                end;
                OnBeforeModifyVATCtrlReportBufferForStatistics(TempVATCtrlReportBufferCZL, VATCtrlReportLineCZL);
                TempVATCtrlReportBufferCZL.Modify();
            until VATCtrlReportLineCZL.Next() = 0;

        if ShowMessage then
            WindowDialog.Close();
    end;

    procedure CreateBufferForExport(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; ShowMessage: Boolean; EntriesSelection: Enum "VAT Statement Report Selection")
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        LineNo: Integer;
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;

        GeneralLedgerSetup.Get();

        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportBufferCZL.DeleteAll();

        if ShowMessage then begin
            WindowDialog.Open(BufferCreateDialogMsg);
            WindowDialog.Update(1, VATCtrlReportHeaderCZL."No.");
        end;

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Exclude from Export", false);
        case EntriesSelection of
            EntriesSelection::Open:
                VATCtrlReportLineCZL.SetFilter("Closed by Document No.", '%1', '');
            EntriesSelection::Closed:
                VATCtrlReportLineCZL.SetFilter("Closed by Document No.", '<>%1', '');
            EntriesSelection::"Open and Closed":
                VATCtrlReportLineCZL.SetRange("Closed by Document No.");
        end;
        if VATCtrlReportLineCZL.FindSet() then
            repeat
                if VATCtrlReportSectionCZL.Code <> VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" then
                    VATCtrlReportSectionCZL.Get(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code");

                TempVATCtrlReportBufferCZL.Reset();
                TempVATCtrlReportBufferCZL.SetCurrentKey("Document No.", "Posting Date");
                TempVATCtrlReportBufferCZL.SetRange("VAT Ctrl. Report Section Code", VATCtrlReportLineCZL."VAT Ctrl. Report Section Code");

                if not (VATCtrlReportSectionCZL.Code in ['A5', 'B3']) then begin
                    TempVATCtrlReportBufferCZL.SetRange("Commodity Code", VATCtrlReportLineCZL."Commodity Code");
                    TempVATCtrlReportBufferCZL.SetRange("Supplies Mode Code", VATCtrlReportLineCZL."Supplies Mode Code");
                    TempVATCtrlReportBufferCZL.SetRange("Corrections for Bad Receivable", VATCtrlReportLineCZL."Corrections for Bad Receivable");
                    TempVATCtrlReportBufferCZL.SetRange("Ratio Use", VATCtrlReportLineCZL."Ratio Use");

                    case VATCtrlReportSectionCZL."Group By" of
                        VATCtrlReportSectionCZL."Group By"::"Document No.":
                            begin
                                TempVATCtrlReportBufferCZL.SetRange("Document No.", VATCtrlReportLineCZL."Document No.");
                                TempVATCtrlReportBufferCZL.SetRange("Bill-to/Pay-to No.", VATCtrlReportLineCZL."Bill-to/Pay-to No.");
                            end;
                        VATCtrlReportSectionCZL."Group By"::"External Document No.":
                            begin
                                TempVATCtrlReportBufferCZL.SetRange("Document No.", VATCtrlReportLineCZL."External Document No.");
                                TempVATCtrlReportBufferCZL.SetRange("Bill-to/Pay-to No.", VATCtrlReportLineCZL."Bill-to/Pay-to No.");
                            end;
                    end;

                    if VATCtrlReportSectionCZL."Group By" <> VATCtrlReportSectionCZL."Group By"::"Section Code" then
                        if VATReportingDateMgt.IsVATDateEnabled() then
                            TempVATCtrlReportBufferCZL.SetRange("Posting Date", VATCtrlReportLineCZL."VAT Date")
                        else
                            TempVATCtrlReportBufferCZL.SetRange("Posting Date", VATCtrlReportLineCZL."Posting Date");
                end;

                OnCreateBufferForExportOnBeforeTempVATCtrlReportBufferCZLFindFirst(VATCtrlReportLineCZL, VATCtrlReportSectionCZL, TempVATCtrlReportBufferCZL);
                if not TempVATCtrlReportBufferCZL.FindFirst() then begin
                    CopyLineToBuffer(VATCtrlReportLineCZL, TempVATCtrlReportBufferCZL);
                    LineNo += 1;
                    TempVATCtrlReportBufferCZL."Line No." := LineNo;
                    if VATReportingDateMgt.IsVATDateEnabled() then begin
                        TempVATCtrlReportBufferCZL."VAT Date" := VATCtrlReportLineCZL."VAT Date";
                        TempVATCtrlReportBufferCZL."Posting Date" := VATCtrlReportLineCZL."VAT Date";
                        TempVATCtrlReportBufferCZL."Original Document VAT Date" := VATCtrlReportLineCZL."Original Document VAT Date";
                    end else begin
                        TempVATCtrlReportBufferCZL."VAT Date" := VATCtrlReportLineCZL."Posting Date";
                        TempVATCtrlReportBufferCZL."Posting Date" := VATCtrlReportLineCZL."Posting Date";
                        TempVATCtrlReportBufferCZL."Original Document VAT Date" := VATCtrlReportLineCZL."Original Document VAT Date";
                    end;
                    TempVATCtrlReportBufferCZL.Insert();
                end;

                case VATCtrlReportLineCZL."VAT Rate" of
                    VATCtrlReportLineCZL."VAT Rate"::Base:
                        begin
                            TempVATCtrlReportBufferCZL."Base 1" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 1" += VATCtrlReportLineCZL.Amount;
                            TempVATCtrlReportBufferCZL."Add.-Currency Base 1" += VATCtrlReportLineCZL."Additional-Currency Base";
                            TempVATCtrlReportBufferCZL."Add.-Currency Amount 1" += VATCtrlReportLineCZL."Additional-Currency Amount";
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::Reduced:
                        begin
                            TempVATCtrlReportBufferCZL."Base 2" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 2" += VATCtrlReportLineCZL.Amount;
                            TempVATCtrlReportBufferCZL."Add.-Currency Base 2" += VATCtrlReportLineCZL."Additional-Currency Base";
                            TempVATCtrlReportBufferCZL."Add.-Currency Amount 2" += VATCtrlReportLineCZL."Additional-Currency Amount";
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::"Reduced 2":
                        begin
                            TempVATCtrlReportBufferCZL."Base 3" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 3" += VATCtrlReportLineCZL.Amount;
                            TempVATCtrlReportBufferCZL."Add.-Currency Base 3" += VATCtrlReportLineCZL."Additional-Currency Base";
                            TempVATCtrlReportBufferCZL."Add.-Currency Amount 3" += VATCtrlReportLineCZL."Additional-Currency Amount";
                        end;
                end;

                if (VATCtrlReportSectionCZL.Code in ['A4', 'B2']) and
                   (VATCtrlReportLineCZL."Corrections for Bad Receivable" = "VAT Ctrl. Report Corect. CZL"::"Insolvency Proceedings (p.44)")
                then begin
                    TempVATCtrlReportBufferCZL."Base 1" := 0;
                    TempVATCtrlReportBufferCZL."Base 2" := 0;
                    TempVATCtrlReportBufferCZL."Base 3" := 0;
                end;

                OnBeforeModifyVATCtrlReportBufferForExport(TempVATCtrlReportBufferCZL, VATCtrlReportLineCZL);
                TempVATCtrlReportBufferCZL.Modify();
            until VATCtrlReportLineCZL.Next() = 0;

        if ShowMessage then
            WindowDialog.Close();
    end;

    procedure RoundVATCtrlReportBufferAmounts(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; Precision: Decimal)
    begin
        if not TempVATCtrlReportBufferCZL.FindSet() then
            exit;
        repeat
            TempVATCtrlReportBufferCZL."Base 1" := Round(TempVATCtrlReportBufferCZL."Base 1", Precision);
            TempVATCtrlReportBufferCZL."Base 2" := Round(TempVATCtrlReportBufferCZL."Base 2", Precision);
            TempVATCtrlReportBufferCZL."Base 3" := Round(TempVATCtrlReportBufferCZL."Base 3", Precision);
            TempVATCtrlReportBufferCZL."Amount 1" := Round(TempVATCtrlReportBufferCZL."Amount 1", Precision);
            TempVATCtrlReportBufferCZL."Amount 2" := Round(TempVATCtrlReportBufferCZL."Amount 2", Precision);
            TempVATCtrlReportBufferCZL."Amount 3" := Round(TempVATCtrlReportBufferCZL."Amount 3", Precision);
            TempVATCtrlReportBufferCZL."Total Base" := Round(TempVATCtrlReportBufferCZL."Total Base", Precision);
            TempVATCtrlReportBufferCZL."Total Amount" := Round(TempVATCtrlReportBufferCZL."Total Amount", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Base 1" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Base 1", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Base 2" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Base 2", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Base 3" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Base 3", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Amount 1" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Amount 1", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Amount 2" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Amount 2", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Amount 3" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Amount 3", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Total Base" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Total Base", Precision);
            TempVATCtrlReportBufferCZL."Add.-Currency Total Amount" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Total Amount", Precision);
            TempVATCtrlReportBufferCZL.Modify();
        until TempVATCtrlReportBufferCZL.Next() = 0;
        TempVATCtrlReportBufferCZL.FindSet();
    end;

    local procedure IsMandatoryField(SectionCode: Code[20]; FieldNo: Integer): Boolean
    begin
        InitializationMandatoryFields();

        if not TempErrorBuffer.Get(FieldNo) then
            exit(false);

        exit(StrPos(TempErrorBuffer."Error Text", SectionCode) <> 0);
    end;

    [TryFunction]
    procedure CheckMandatoryField(FieldNo: Integer; VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL")
    var
        "Field": Record "Field";
        TypeHelper: Codeunit "Type Helper";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        case FieldNo of
            0:
                begin
                    RecordRef.GetTable(VATCtrlReportLineCZL);
                    field.SetRange(Class, field.Class::Normal);
                    field.SetRange(TableNo, RecordRef.Number);
                    field.SetFilter(ObsoleteState, '<>%1', field.ObsoleteState::Removed);
                    if field.FindSet() then
                        repeat
                            FieldRef := RecordRef.field(field."No.");
                            if IsMandatoryField(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", FieldRef.Number) then
                                FieldRef.TestField();
                        until field.Next() = 0;
                end;
            else
                if IsMandatoryField(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", FieldNo) then begin
                    RecordRef.GetTable(VATCtrlReportLineCZL);
                    if TypeHelper.GetField(RecordRef.Number, FieldNo, field) then begin
                        FieldRef := RecordRef.field(FieldNo);
                        if field.Class = field.Class::Normal then
                            FieldRef.TestField();
                    end;
                end;
        end;
    end;

    procedure CloseVATCtrlReportLine(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; NewCloseDocNo: Code[20]; NewCloseDate: Date)
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        GetDocumentNoandDateCZL: Page "Get Document No. and Date CZL";
    begin
        VATCtrlReportHeaderCZL.TestField(Status, VATCtrlReportHeaderCZL.Status::Released);
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(CloseVATControlRepHeaderQst, VATCtrlReportHeaderCZL."No."), true) then
            exit;

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        if VATCtrlReportLineCZL.IsEmpty() then
            Error(LinesNotExistErr, VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.FindSet();

        if NewCloseDate = 0D then
            NewCloseDate := WorkDate();
        if NewCloseDocNo = '' then begin
            GetDocumentNoandDateCZL.SetValues(NewCloseDocNo, NewCloseDate);
            if GetDocumentNoandDateCZL.RunModal() = Action::OK then
                GetDocumentNoandDateCZL.GetValues(NewCloseDocNo, NewCloseDate)
            else
                exit;
        end;
        if NewCloseDate = 0D then
            NewCloseDate := WorkDate();
        if NewCloseDocNo = '' then
            NewCloseDocNo := GenerateCloseDocNo(NewCloseDate);

        repeat
            VATCtrlReportLineCZL.TestField("VAT Ctrl. Report Section Code");
            if VATCtrlReportLineCZL."Closed by Document No." = '' then begin
                VATCtrlReportLineCZL."Closed by Document No." := NewCloseDocNo;
                VATCtrlReportLineCZL."Closed Date" := NewCloseDate;
                VATCtrlReportLineCZL.Modify();
            end;
        until VATCtrlReportLineCZL.Next() = 0;
    end;

    local procedure GenerateCloseDocNo(CloseDate: Date): Code[20]
    begin
        if CloseDate = 0D then
            CloseDate := WorkDate();
        exit(Format(CloseDate, 0, '<Year4><Month,2><Day,2>') + '_' + Format(Time, 0, '<Hours24><Minutes,2>'));
    end;

    procedure ExportInternalDocCheckToExcel(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; ShowMessage: Boolean)
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        Temp1VATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary;
        Temp2VATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary;
        Temp3VATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        i: Integer;
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;

        GeneralLedgerSetup.Get();

        Temp1VATCtrlReportBufferCZL.Reset();
        Temp1VATCtrlReportBufferCZL.DeleteAll();

        if ShowMessage then begin
            WindowDialog.Open(BufferCreateDialogMsg);
            WindowDialog.Update(1, VATCtrlReportHeaderCZL."No.");
        end;

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Exclude from Export", false);
        if VATCtrlReportLineCZL.FindSet() then
            repeat
                Temp1VATCtrlReportBufferCZL.Reset();
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Ctrl. Report Section Code", VATCtrlReportLineCZL."VAT Ctrl. Report Section Code");
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Registration No.", VATCtrlReportLineCZL."VAT Registration No.");
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Date", VATCtrlReportLineCZL."VAT Date");
                Temp1VATCtrlReportBufferCZL.SetRange("Bill-to/Pay-to No.", VATCtrlReportLineCZL."Bill-to/Pay-to No.");
                Temp1VATCtrlReportBufferCZL.SetRange("Document No.", VATCtrlReportLineCZL."Document No.");
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Bus. Posting Group", VATCtrlReportLineCZL."VAT Bus. Posting Group");
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Prod. Posting Group", VATCtrlReportLineCZL."VAT Prod. Posting Group");
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Rate", VATCtrlReportLineCZL."VAT Rate");
                Temp1VATCtrlReportBufferCZL.SetRange("Commodity Code", VATCtrlReportLineCZL."Commodity Code");
                Temp1VATCtrlReportBufferCZL.SetRange("Supplies Mode Code", VATCtrlReportLineCZL."Supplies Mode Code");
                OnExportInternalDocCheckToExcelOnBeforeTempVATCtrlReportBufferCZLFindFirst(VATCtrlReportLineCZL, Temp1VATCtrlReportBufferCZL);
                if not Temp1VATCtrlReportBufferCZL.FindFirst() then begin
                    Temp1VATCtrlReportBufferCZL.Init();
                    Temp1VATCtrlReportBufferCZL."VAT Ctrl. Report Section Code" := VATCtrlReportLineCZL."VAT Ctrl. Report Section Code";
                    i += 1;
                    Temp1VATCtrlReportBufferCZL."Line No." := i;
                    Temp1VATCtrlReportBufferCZL."VAT Registration No." := VATCtrlReportLineCZL."VAT Registration No.";
                    Temp1VATCtrlReportBufferCZL."VAT Date" := VATCtrlReportLineCZL."VAT Date";
                    Temp1VATCtrlReportBufferCZL."Bill-to/Pay-to No." := VATCtrlReportLineCZL."Bill-to/Pay-to No.";
                    Temp1VATCtrlReportBufferCZL."Document No." := VATCtrlReportLineCZL."Document No.";
                    Temp1VATCtrlReportBufferCZL."VAT Bus. Posting Group" := VATCtrlReportLineCZL."VAT Bus. Posting Group";
                    Temp1VATCtrlReportBufferCZL."VAT Prod. Posting Group" := VATCtrlReportLineCZL."VAT Prod. Posting Group";
                    Temp1VATCtrlReportBufferCZL."VAT Rate" := VATCtrlReportLineCZL."VAT Rate";
                    Temp1VATCtrlReportBufferCZL."Commodity Code" := VATCtrlReportLineCZL."Commodity Code";
                    Temp1VATCtrlReportBufferCZL."Supplies Mode Code" := VATCtrlReportLineCZL."Supplies Mode Code";
                    OnExportInternalDocCheckToExcelOnBeforeInsertTempVATCtrlReportBufferCZL(VATCtrlReportLineCZL, Temp1VATCtrlReportBufferCZL);
                    Temp1VATCtrlReportBufferCZL.Insert();
                end;
                Temp1VATCtrlReportBufferCZL."Total Amount" += VATCtrlReportLineCZL.Base + VATCtrlReportLineCZL.Amount;
                Temp1VATCtrlReportBufferCZL.Modify();
            until VATCtrlReportLineCZL.Next() = 0;

        Temp1VATCtrlReportBufferCZL.Reset();
        if Temp1VATCtrlReportBufferCZL.FindFirst() then
            repeat
                Temp2VATCtrlReportBufferCZL := Temp1VATCtrlReportBufferCZL;
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Ctrl. Report Section Code", Temp2VATCtrlReportBufferCZL."VAT Ctrl. Report Section Code");
                Temp1VATCtrlReportBufferCZL.SetRange("VAT Registration No.", Temp2VATCtrlReportBufferCZL."VAT Registration No.");
                Temp1VATCtrlReportBufferCZL.SetFilter("Document No.", '<>%1', Temp2VATCtrlReportBufferCZL."Document No.");
                Temp1VATCtrlReportBufferCZL.SetFilter("Total Amount", '%1', -Temp2VATCtrlReportBufferCZL."Total Amount");
                if Temp1VATCtrlReportBufferCZL.FindFirst() then begin
                    Temp3VATCtrlReportBufferCZL := Temp2VATCtrlReportBufferCZL;
                    Temp3VATCtrlReportBufferCZL."External Document No." := Temp1VATCtrlReportBufferCZL."Document No.";
                    Temp3VATCtrlReportBufferCZL."Total Base" := Temp1VATCtrlReportBufferCZL."Total Amount";
                    Temp3VATCtrlReportBufferCZL."Add.-Currency Total Base" := Temp1VATCtrlReportBufferCZL."Add.-Currency Total Amount";
                    Temp3VATCtrlReportBufferCZL.Insert();

                    Temp1VATCtrlReportBufferCZL.Delete();
                end;
                Temp1VATCtrlReportBufferCZL := Temp2VATCtrlReportBufferCZL;
                Temp1VATCtrlReportBufferCZL.Delete();

                Temp1VATCtrlReportBufferCZL.Reset();
            until not Temp1VATCtrlReportBufferCZL.FindFirst();

        Temp3VATCtrlReportBufferCZL.Reset();
        if Temp3VATCtrlReportBufferCZL.FindSet() then begin
            i := 1;
            AddToExcelBuffer(TempExcelBuffer, i, 1, CopyStr(Temp1VATCtrlReportBufferCZL.FieldCaption("Bill-to/Pay-to No."), 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 2, CopyStr(Temp1VATCtrlReportBufferCZL.FieldCaption("VAT Registration No."), 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 3, CopyStr(Temp1VATCtrlReportBufferCZL.FieldCaption("Document No."), 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 4, CopyStr(Temp1VATCtrlReportBufferCZL.FieldCaption("Document No.") + ' 2', 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 5, AmountTxt);
            AddToExcelBuffer(TempExcelBuffer, i, 6, AmountTxt + ' 2');
            if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
                AddToExcelBuffer(TempExcelBuffer, i, 7, AdditionalCurrencyAmountTxt);
                AddToExcelBuffer(TempExcelBuffer, i, 8, AdditionalCurrencyAmountTxt + ' 2');
            end;
            repeat
                i += 1;
                AddToExcelBuffer(TempExcelBuffer, i, 1, Temp3VATCtrlReportBufferCZL."Bill-to/Pay-to No.");
                AddToExcelBuffer(TempExcelBuffer, i, 2, Temp3VATCtrlReportBufferCZL."VAT Registration No.");
                AddToExcelBuffer(TempExcelBuffer, i, 3, Temp3VATCtrlReportBufferCZL."Document No.");
                AddToExcelBuffer(TempExcelBuffer, i, 4, Temp3VATCtrlReportBufferCZL."External Document No.");
                AddToExcelBuffer(TempExcelBuffer, i, 5, Format(Temp3VATCtrlReportBufferCZL."Total Amount"));
                AddToExcelBuffer(TempExcelBuffer, i, 6, Format(Temp3VATCtrlReportBufferCZL."Total Base"));
                if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
                    AddToExcelBuffer(TempExcelBuffer, i, 7, Format(Temp3VATCtrlReportBufferCZL."Add.-Currency Total Amount"));
                    AddToExcelBuffer(TempExcelBuffer, i, 8, Format(Temp3VATCtrlReportBufferCZL."Add.-Currency Total Base"));
                end;
                OnExportInternalDocCheckToExcelOnAfterFillExcelLine(TempExcelBuffer, Temp3VATCtrlReportBufferCZL);
            until Temp3VATCtrlReportBufferCZL.Next() = 0;
            TempExcelBuffer.CreateNewBook('KH1');
            TempExcelBuffer.WriteSheet(
              PadStr(StrSubstNo(TwoPlaceholdersTok, VATCtrlReportHeaderCZL."No.", VATCtrlReportHeaderCZL.Description), 30),
              CompanyName,
              UserId());
            TempExcelBuffer.CloseBook();
            TempExcelBuffer.SetFriendlyFilename(StrSubstNo(TwoPlaceholdersTok, VATCtrlReportHeaderCZL."No.", VATCtrlReportHeaderCZL.Description));
            TempExcelBuffer.OpenExcel();
        end else
            Message(InternalDocCheckMsg, VATCtrlReportHeaderCZL."No.");

        if ShowMessage then
            WindowDialog.Close();
    end;

    local procedure SetVATEntryFilters(var VATEntry: Record "VAT Entry"; VATStatementLine: Record "VAT Statement Line"; VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date)
    begin
        VATEntry.SetVATStatementLineFiltersCZL(VATStatementLine);
        VATEntry.SetRange(Reversed, false);
        VATEntry.SetDateFilterCZL(StartDate, EndDate, VATReportingDateMgt.IsVATDateEnabled());
        OnAfterSetVATEntryFilters(VATEntry, VATStatementLine, VATCtrlReportHeaderCZL);
    end;

    procedure CopyBufferToLine(TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL")
    begin
        VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" := TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code";
        VATCtrlReportLineCZL."Posting Date" := TempVATCtrlReportBufferCZL."Posting Date";
        VATCtrlReportLineCZL."VAT Date" := TempVATCtrlReportBufferCZL."VAT Date";
        VATCtrlReportLineCZL."Original Document VAT Date" := TempVATCtrlReportBufferCZL."Original Document VAT Date";
        VATCtrlReportLineCZL."Bill-to/Pay-to No." := TempVATCtrlReportBufferCZL."Bill-to/Pay-to No.";
        VATCtrlReportLineCZL."VAT Registration No." := TempVATCtrlReportBufferCZL."VAT Registration No.";
        VATCtrlReportLineCZL."Registration No." := TempVATCtrlReportBufferCZL."Registration No.";
        VATCtrlReportLineCZL."Tax Registration No." := TempVATCtrlReportBufferCZL."Tax Registration No.";
        VATCtrlReportLineCZL."Document No." := CopyStr(TempVATCtrlReportBufferCZL."Document No.", 1, MaxStrLen(VATCtrlReportLineCZL."Document No."));
        VATCtrlReportLineCZL."External Document No." := TempVATCtrlReportBufferCZL."External Document No.";
        VATCtrlReportLineCZL.Type := TempVATCtrlReportBufferCZL.Type;
        VATCtrlReportLineCZL."VAT Bus. Posting Group" := TempVATCtrlReportBufferCZL."VAT Bus. Posting Group";
        VATCtrlReportLineCZL."VAT Prod. Posting Group" := TempVATCtrlReportBufferCZL."VAT Prod. Posting Group";
        VATCtrlReportLineCZL.Base := Round(TempVATCtrlReportBufferCZL."Total Base", 0.01);
        VATCtrlReportLineCZL.Amount := Round(TempVATCtrlReportBufferCZL."Total Amount", 0.01);
        VATCtrlReportLineCZL."Additional-Currency Base" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Total Base", 0.01);
        VATCtrlReportLineCZL."Additional-Currency Amount" := Round(TempVATCtrlReportBufferCZL."Add.-Currency Total Amount", 0.01);
        VATCtrlReportLineCZL."VAT Rate" := TempVATCtrlReportBufferCZL."VAT Rate";
        VATCtrlReportLineCZL."Commodity Code" := TempVATCtrlReportBufferCZL."Commodity Code";
        VATCtrlReportLineCZL."Supplies Mode Code" := TempVATCtrlReportBufferCZL."Supplies Mode Code";
        VATCtrlReportLineCZL."Corrections for Bad Receivable" := TempVATCtrlReportBufferCZL."Corrections for Bad Receivable";
        VATCtrlReportLineCZL."Ratio Use" := TempVATCtrlReportBufferCZL."Ratio Use";
        OnAfterCopyBufferToLine(TempVATCtrlReportBufferCZL, VATCtrlReportLineCZL);
    end;

    procedure CopyLineToBuffer(VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        TempVATCtrlReportBufferCZL.Init();
        TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code" := VATCtrlReportLineCZL."VAT Ctrl. Report Section Code";
        TempVATCtrlReportBufferCZL."Line No." := VATCtrlReportLineCZL."Line No.";
        TempVATCtrlReportBufferCZL."Posting Date" := VATCtrlReportLineCZL."Posting Date";
        TempVATCtrlReportBufferCZL."VAT Date" := VATCtrlReportLineCZL."VAT Date";
        TempVATCtrlReportBufferCZL."Original Document VAT Date" := VATCtrlReportLineCZL."Original Document VAT Date";
        TempVATCtrlReportBufferCZL."Bill-to/Pay-to No." := VATCtrlReportLineCZL."Bill-to/Pay-to No.";
        TempVATCtrlReportBufferCZL."VAT Registration No." := VATCtrlReportLineCZL."VAT Registration No.";
        TempVATCtrlReportBufferCZL."Registration No." := VATCtrlReportLineCZL."Registration No.";
        TempVATCtrlReportBufferCZL."Tax Registration No." := VATCtrlReportLineCZL."Tax Registration No.";
        TempVATCtrlReportBufferCZL.Type := VATCtrlReportLineCZL.Type;
        TempVATCtrlReportBufferCZL."VAT Bus. Posting Group" := VATCtrlReportLineCZL."VAT Bus. Posting Group";
        TempVATCtrlReportBufferCZL."VAT Prod. Posting Group" := VATCtrlReportLineCZL."VAT Prod. Posting Group";
        TempVATCtrlReportBufferCZL."VAT Rate" := VATCtrlReportLineCZL."VAT Rate";
        TempVATCtrlReportBufferCZL."Commodity Code" := VATCtrlReportLineCZL."Commodity Code";
        TempVATCtrlReportBufferCZL."Supplies Mode Code" := VATCtrlReportLineCZL."Supplies Mode Code";
        TempVATCtrlReportBufferCZL."Corrections for Bad Receivable" := VATCtrlReportLineCZL."Corrections for Bad Receivable";
        TempVATCtrlReportBufferCZL."Ratio Use" := VATCtrlReportLineCZL."Ratio Use";
        TempVATCtrlReportBufferCZL.Name := VATCtrlReportLineCZL.Name;
        TempVATCtrlReportBufferCZL."Birth Date" := VATCtrlReportLineCZL."Birth Date";
        TempVATCtrlReportBufferCZL."Place of stay" := VATCtrlReportLineCZL."Place of stay";

        if TempVATCtrlReportBufferCZL."Original Document VAT Date" = 0D then
            TempVATCtrlReportBufferCZL."Original Document VAT Date" := TempVATCtrlReportBufferCZL."VAT Date";

        if (TempVATCtrlReportBufferCZL."VAT Registration No." = '') and
           (TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code" = 'A4')
        then
            TempVATCtrlReportBufferCZL."VAT Registration No." := TempVATCtrlReportBufferCZL."Tax Registration No.";

        VATCtrlReportSectionCZL.Get(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code");
        case VATCtrlReportSectionCZL."Group By" of
            VATCtrlReportSectionCZL."Group By"::"Document No.":
                begin
                    TempVATCtrlReportBufferCZL."Document No." := VATCtrlReportLineCZL."Document No.";
                    TempVATCtrlReportBufferCZL."External Document No." := VATCtrlReportLineCZL."Document No.";
                end;
            VATCtrlReportSectionCZL."Group By"::"External Document No.":
                begin
                    TempVATCtrlReportBufferCZL."Document No." := VATCtrlReportLineCZL."External Document No.";
                    TempVATCtrlReportBufferCZL."External Document No." := VATCtrlReportLineCZL."External Document No.";
                end;
            VATCtrlReportSectionCZL."Group By"::"Section Code":
                begin
                    TempVATCtrlReportBufferCZL."Document No." := VATCtrlReportLineCZL."Document No.";
                    TempVATCtrlReportBufferCZL."External Document No." := VATCtrlReportLineCZL."External Document No.";
                end;
        end;
        OnAfterCopyLineToBuffer(VATCtrlReportLineCZL, TempVATCtrlReportBufferCZL);
    end;

    local procedure AddToExcelBuffer(var TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer; Value: Text[250])
    begin
        TempExcelBuffer.Validate("Row No.", RowNo);
        TempExcelBuffer.Validate("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := Value;
        TempExcelBuffer.Insert();
    end;

    local procedure InitializationMandatoryFields()
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        ClearMandatoryFields();

        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."VAT Registration No."), 'A1,A2,A3,A4,B1,B2');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Document No."), 'A1,A2,A3,A4,B1,B2');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Posting Date"), 'A1,A2,A3,A4,B1,B2');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL.Base), 'A1,A2,A3,A4,A5,B1,B2,B3');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Commodity Code"), 'A1,B1');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL.Amount), 'A2,A4,A5,B2,B3');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."VAT Rate"), 'A2,A4,A5,B2,B3');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL.Name), 'A3');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Birth Date"), 'A3');
        AddMandatoryFieldToBuffer(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Place of stay"), 'A3');
    end;

    local procedure AddMandatoryFieldToBuffer(FieldNo: Integer; SectionCodes: Text[250])
    begin
        TempErrorBuffer.Init();
        TempErrorBuffer."Error No." := FieldNo;
        TempErrorBuffer."Error Text" := SectionCodes;
        TempErrorBuffer.Insert();
    end;

    local procedure ClearMandatoryFields()
    begin
        TempErrorBuffer.Reset();
        TempErrorBuffer.DeleteAll();
    end;

    local procedure GetVATEntryBufferForPeriod(var TempVATEntry: Record "VAT Entry" temporary; StartDate: Date; EndDate: Date)
    var
        VATEntry: Record "VAT Entry";
    begin
        if VATEntryBufferExist(TempVATEntry) then
            exit;

        DeleteVATEntryBuffer(TempVATEntry);
        VATEntry.SetDateFilterCZL(StartDate, EndDate, VATReportingDateMgt.IsVATDateEnabled());
        if VATEntry.FindSet(false) then
            repeat
                TempVATEntry.Init();
                TempVATEntry := VATEntry;
                if TempVATEntry."Original VAT Entry No. CZL" <> 0 then begin
                    TempVATEntry.Base := TempVATEntry."Original VAT Base CZL";
                    TempVATEntry.Amount := TempVATEntry."Original VAT Amount CZL";
                end;
                OnBeforeInsertTempVATEntryForForPeriod(TempVATEntry);
                TempVATEntry.Insert();
            until VATEntry.Next() = 0;
    end;

    local procedure GetVATEntryBufferForVATStatementLine(var TempVATEntry: Record "VAT Entry" temporary; VATStatementLine: Record "VAT Statement Line"; VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date)
    var
        TempGlobalCopyVATEntry: Record "VAT Entry" temporary;
    begin
        DeleteVATEntryBuffer(TempVATEntry);
        GetVATEntryBufferForPeriod(TempGlobalVATEntry, StartDate, EndDate);

        TempGlobalCopyVATEntry.Copy(TempGlobalVATEntry, true);
        TempGlobalCopyVATEntry.Reset();
        SetVATEntryFilters(TempGlobalCopyVATEntry, VATStatementLine, VATCtrlReportHeaderCZL, StartDate, EndDate);
        TempGlobalCopyVATEntry.SetAutoCalcFields("VAT Ctrl. Report Line No. CZL");
        if TempGlobalCopyVATEntry.FindSet() then
            repeat
                if not SkipVATEntry(TempGlobalCopyVATEntry) then begin
                    TempVATEntry.Init();
                    TempVATEntry := TempGlobalCopyVATEntry;
                    OnBeforeInsertTempVATEntryForStatementLine(TempVATEntry, VATStatementLine);
                    TempVATEntry.Insert();
                end;
            until TempGlobalCopyVATEntry.Next() = 0;
    end;

    local procedure DeleteVATEntryBuffer(var TempVATEntry: Record "VAT Entry" temporary)
    begin
        TempVATEntry.Reset();
        TempVATEntry.DeleteAll();
    end;

    local procedure VATEntryBufferExist(var TempVATEntry: Record "VAT Entry" temporary): Boolean
    begin
        TempVATEntry.Reset();
        exit(TempVATEntry.Count() <> 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetVATEntryFilters(var VATEntry: Record "VAT Entry"; VATStatementLine: Record "VAT Statement Line"; VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyBufferToLine(TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyLineToBuffer(VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyVATCtrlReportBufferForStatistics(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyVATCtrlReportBufferForExport(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTempVATEntryForForPeriod(var TempVATEntry: Record "VAT Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTempVATEntryForStatementLine(var TempVATEntry: Record "VAT Entry" temporary; VATStatementLine: Record "VAT Statement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVATCtrlReportBuffer(VATEntry: Record "VAT Entry"; VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL"; VATPostingSetup: Record "VAT Posting Setup"; CommodityCode: Code[20]; var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetVATCtrlReportLinesOnBeforeAddVATEntryToBuffer(VATStatementLine: Record "VAT Statement Line"; VATPostingSetup: Record "VAT Posting Setup"; var VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL"; var TempVATEntry: Record "VAT Entry" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMergeVATEntryOnBeforeTempVATEntryBudgetBufferFindFirst(VATEntry: Record "VAT Entry"; var TempDocumentBudgetBuffer: Record "Budget Buffer" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMergeVATEntryOnBeforeTempGlobalVATEntryFindSet(VATEntry: Record "VAT Entry"; var TempGlobalVATEntry: Record "VAT Entry" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMergeVATEntryOnBeforeInsertTempVATEntryBudgetBuffer(VATEntry: Record "VAT Entry"; var TempDocumentBudgetBuffer: Record "Budget Buffer" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDocumentAmountOnBeforeTempDocumentBudgetBufferFindFirst(VATEntry: Record "VAT Entry"; var TempDocumentBudgetBuffer: Record "Budget Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDocumentAmountOnBeforeTempGlobalVATEntryFindSet(VATEntry: Record "VAT Entry"; var TempGlobalVATEntry: Record "VAT Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDocumentAmountOnBeforeInsertTempDocumentBudgetBuffer(VATEntry: Record "VAT Entry"; var TempDocumentBudgetBuffer: Record "Budget Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertVATCtrlReportBufferGroupOnBeforeTempVATCtrlReportBufferCZLFindFirst(VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertVATCtrlReportBufferOnBeforeInsert(VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsVATEntryCorrected(VATEntry: Record "VAT Entry"; var TempGlobalVATEntry: Record "VAT Entry" temporary; var IsCorrected: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBufferFromDocument(VATEntry: Record "VAT Entry"; SectionCode: Code[20]; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSplitFromSalesInvLineOnBeforeUpdateTempDropShptPostBuffer(SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceLine: Record "Sales Invoice Line"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSplitFromSalesCrMemoLineOnBeforeUpdateTempDropShptPostBuffer(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSplitFromPurchInvLineOnBeforeUpdateTempDropShptPostBuffer(PurchInvHeader: Record "Purch. Inv. Header"; PurchInvLine: Record "Purch. Inv. Line"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSplitFromPurchCrMemoLineOnBeforeUpdateTempDropShptPostBuffer(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateBufferForExportOnBeforeTempVATCtrlReportBufferCZLFindFirst(VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"; VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportInternalDocCheckToExcelOnBeforeTempVATCtrlReportBufferCZLFindFirst(VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportInternalDocCheckToExcelOnBeforeInsertTempVATCtrlReportBufferCZL(VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExportInternalDocCheckToExcelOnAfterFillExcelLine(var TempExcelBuffer: Record "Excel Buffer" temporary; TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
    end;
}
