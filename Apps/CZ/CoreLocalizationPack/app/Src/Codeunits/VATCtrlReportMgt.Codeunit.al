codeunit 31102 "VAT Ctrl. Report Mgt. CZL"
{
    Permissions = TableData "VAT Entry" = rm,
                  TableData "VAT Posting Setup" = r,
                  TableData "VAT Ctrl. Report Header CZL" = rimd,
                  TableData "VAT Ctrl. Report Line CZL" = rimd,
                  TableData "VAT Ctrl. Report Section CZL" = r;

    var
        GeneralLedgerLSetup: Record "General Ledger Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        TempBudgetBufferVATEntry: Record "Budget Buffer" temporary;
        TempBudgetBufferDocument: Record "Budget Buffer" temporary;
        TempErrorBuffer: Record "Error Buffer" temporary;
        TempVATEntryGlobal: Record "VAT Entry" temporary;
        Window: Dialog;
        ProgressDialogMsg: Label 'VAT Statement Line Progress     #1######## #2######## #3########', Comment = '%1 = Statement Template Name; %2 = Statement Name; %3 = Line No.';
        BufferCreateDialogMsg: Label 'VAT Control Report     #1########', Comment = '%1 = Statement Template Name';
        LineCreatedMsg: Label '%1 Lines have been created.', Comment = '%1 = Number of created lines';
        CloseVATControlRepHeaderQst: Label 'Really close lines of VAT Control Report No. %1?', Comment = '%1 = VAT Control Report No.';
        LinesNotExistErr: Label 'There is nothing to close for VAT Control Report No. %1.', Comment = '%1 = VAT Control Report No.';
        IsInitialized: Boolean;
        GlobalLineNo: Integer;
        InternalDocCheckMsg: Label 'There is nothing internal document to exclusion in VAT Control Report No. %1.', Comment = '%1 = VAT Control Report No.';
        AmountTxt: Label 'Amount';

    procedure GetVATCtrlReportLines(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date; VATStmTemplCode: Code[10]; VATStmName: Code[10]; ProcessType: Option Add,Rewrite; ShowMessage: Boolean; UseMergeVATEntries: Boolean)
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
        TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary;
        TempVATCtrlReportEntLinkCZL1: Record "VAT Ctrl. Report Ent. Link CZL" temporary;
        TempVATCtrlReportEntLinkCZL2: Record "VAT Ctrl. Report Ent. Link CZL" temporary;
        TempVATEntry: Record "VAT Entry" temporary;
        TempVATEntryActual: Record "VAT Entry" temporary;
        TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        VATStatementLine: Record "VAT Statement Line";
        DocumentAmount: Decimal;
        i: Integer;
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;

        GeneralLedgerLSetup.Get();
        StatutoryReportingSetupCZL.Get();
        if ProcessType = ProcessType::Rewrite then
            DeleteVATCtrlReportLines(VATCtrlReportHeaderCZL, StartDate, EndDate);

        TempVATCtrlReportEntLinkCZL1.SetCurrentKey("VAT Entry No.");
        TempVATCtrlReportEntLinkCZL2.SetCurrentKey("VAT Entry No.");

        if ShowMessage then
            Window.Open(ProgressDialogMsg);

        VATStatementLine.SetRange("Statement Template Name", VATStmTemplCode);
        VATStatementLine.SetRange("Statement Name", VATStmName);
        VATStatementLine.SetFilter("VAT Ctrl. Report Section CZL", '<>%1', '');
        if VATStatementLine.FindSet(false, false) then
            repeat
                if ShowMessage then begin
                    Window.Update(1, VATStatementLine."Statement Template Name");
                    Window.Update(2, VATStatementLine."Statement Name");
                    Window.Update(3, VATStatementLine."Line No.");
                end;

                GetVATEntryBufferForVATStatementLine(TempVATEntry, VATStatementLine, VATCtrlReportHeaderCZL, StartDate, EndDate);

                TempVATEntry.Reset();
                if TempVATEntry.FindSet() then
                    repeat
                        TempVATCtrlReportEntLinkCZL1.SetRange("VAT Entry No.", TempVATEntry."Entry No.");
                        // exist in used VAT Entries
                        TempVATCtrlReportEntLinkCZL2.SetRange("VAT Entry No.", TempVATEntry."Entry No.");
                        // exist in merged VAT Entries
                        if (not TempVATCtrlReportEntLinkCZL1.FindFirst()) and
                           (not TempVATCtrlReportEntLinkCZL2.FindFirst())
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
                                MergeVATEntry(TempVATEntry, TempVATCtrlReportEntLinkCZL2);

                            DocumentAmount := GetDocumentAmount(
                                TempVATEntry, VATCtrlReportSectionCZL."Group By" = VATCtrlReportSectionCZL."Group By"::"External Document No.");
                            if (TempVATEntry."VAT Calculation Type" <> TempVATEntry."VAT Calculation Type"::"Reverse Charge VAT") and
                               (Abs(DocumentAmount) <= StatutoryReportingSetupCZL."Simplified Tax Document Limit") and
                               (VATPostingSetup."Corrections Bad Receivable CZL" = VATPostingSetup."Corrections Bad Receivable CZL"::" ") and
                               (VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" <> '') and
                               (not VATStatementLine."Ignore Simpl. Doc. Limit CZL")
                            then
                                VATCtrlReportSectionCZL.Get(VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code");

                            case VATCtrlReportSectionCZL.Code of
                                'A1', 'B1':
                                    begin
                                        MergeVATEntry(TempVATEntry, TempVATCtrlReportEntLinkCZL2);
                                        GetBufferFromDocument(TempVATEntry, TempDropShptPostBuffer, VATCtrlReportSectionCZL.Code);
                                        TempDropShptPostBuffer.Reset();
                                        TempVATEntryActual := TempVATEntry;
                                        if TempDropShptPostBuffer.FindSet() then
                                            repeat
                                                // VAT Entry Amount Set
                                                if TempDropShptPostBuffer.Count() > 1 then
                                                    if (TempVATEntryActual.Base + TempVATEntryActual.Amount) < 0 then begin
                                                        TempVATEntry.Base := -Abs(TempDropShptPostBuffer.Quantity);
                                                        TempVATEntry.Amount := -Abs(TempDropShptPostBuffer."Quantity (Base)");
                                                    end else begin
                                                        TempVATEntry.Base := Abs(TempDropShptPostBuffer.Quantity);
                                                        TempVATEntry.Amount := Abs(TempDropShptPostBuffer."Quantity (Base)");
                                                    end;

                                                case VATCtrlReportSectionCZL."Group By" of
                                                    VATCtrlReportSectionCZL."Group By"::"Document No.":
                                                        InsertVATCtrlReportBufferDocNo(TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL1, TempVATEntry,
                                                          VATPostingSetup, VATCtrlReportSectionCZL.Code, TempDropShptPostBuffer."Order No.");
                                                    VATCtrlReportSectionCZL."Group By"::"External Document No.":
                                                        InsertVATCtrlReportBufferExtDocNo(TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL1, TempVATEntry,
                                                          VATPostingSetup, VATCtrlReportSectionCZL.Code, TempDropShptPostBuffer."Order No.");
                                                    VATCtrlReportSectionCZL."Group By"::"Section Code":
                                                        InsertVATCtrlReportBufferDocNo(TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL1, TempVATEntry,
                                                          VATPostingSetup, VATCtrlReportSectionCZL.Code, TempDropShptPostBuffer."Order No.");
                                                end;
                                            until TempDropShptPostBuffer.Next() = 0;
                                    end;
                                else
                                    case VATCtrlReportSectionCZL."Group By" of
                                        VATCtrlReportSectionCZL."Group By"::"Document No.":
                                            InsertVATCtrlReportBufferDocNo(
                                              TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL1, TempVATEntry, VATPostingSetup, VATCtrlReportSectionCZL.Code, '');
                                        VATCtrlReportSectionCZL."Group By"::"External Document No.":
                                            InsertVATCtrlReportBufferExtDocNo(
                                              TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL1, TempVATEntry, VATPostingSetup, VATCtrlReportSectionCZL.Code, '');
                                        VATCtrlReportSectionCZL."Group By"::"Section Code":
                                            InsertVATCtrlReportBufferDocNo(
                                              TempVATCtrlReportBufferCZL, TempVATCtrlReportEntLinkCZL1, TempVATEntry, VATPostingSetup, VATCtrlReportSectionCZL.Code, '');
                                    end;
                            end;
                        end;
                    until TempVATEntry.Next() = 0;
            until VATStatementLine.Next() = 0;

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        if not VATCtrlReportLineCZL.FindLast() then
            Clear(VATCtrlReportLineCZL);

        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportEntLinkCZL1.Reset();
        TempVATCtrlReportEntLinkCZL2.Reset();
        TempVATCtrlReportEntLinkCZL1.SetCurrentKey("Line No.");
        TempVATCtrlReportEntLinkCZL2.SetCurrentKey("Line No.");
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
                    TempVATCtrlReportEntLinkCZL1.SetRange("Line No.", TempVATCtrlReportBufferCZL."Line No.");
                    if TempVATCtrlReportEntLinkCZL1.FindSet() then
                        repeat
                            // VAT Control Line to VAT Entry Link
                            VATCtrlReportEntLinkCZL.Init();
                            VATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := VATCtrlReportLineCZL."VAT Ctrl. Report No.";
                            VATCtrlReportEntLinkCZL."Line No." := VATCtrlReportLineCZL."Line No.";
                            VATCtrlReportEntLinkCZL."VAT Entry No." := TempVATCtrlReportEntLinkCZL1."VAT Entry No.";
                            VATCtrlReportEntLinkCZL.Insert();

                            // VAT Entry Merge Link
                            TempVATCtrlReportEntLinkCZL2.SetRange("Line No.", TempVATCtrlReportEntLinkCZL1."VAT Entry No.");
                            if TempVATCtrlReportEntLinkCZL2.FindSet() then
                                repeat
                                    VATCtrlReportEntLinkCZL.Init();
                                    VATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := VATCtrlReportLineCZL."VAT Ctrl. Report No.";
                                    VATCtrlReportEntLinkCZL."Line No." := VATCtrlReportLineCZL."Line No.";
                                    VATCtrlReportEntLinkCZL."VAT Entry No." := TempVATCtrlReportEntLinkCZL2."VAT Entry No.";
                                    VATCtrlReportEntLinkCZL.Insert();
                                until TempVATCtrlReportEntLinkCZL2.Next() = 0;
                        until TempVATCtrlReportEntLinkCZL1.Next() = 0;
                end;
            until TempVATCtrlReportBufferCZL.Next() = 0;

        if ShowMessage then begin
            Window.Close();
            Message(LineCreatedMsg, i);
        end;
    end;

    local procedure MergeVATEntry(var TempVATEntry: Record "VAT Entry" temporary; var TempVATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL" temporary)
    begin
        TempBudgetBufferVATEntry.Reset();
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."G/L Account No.", TempVATEntry."Document No.");
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."Dimension Value Code 1", Format(TempVATEntry."VAT Calculation Type", 0, '<Number>'));
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."Dimension Value Code 2", TempVATEntry."VAT Bus. Posting Group");
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."Dimension Value Code 3", TempVATEntry."VAT Prod. Posting Group");
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."Dimension Value Code 4", Format(TempVATEntry.Type, 0, '<Number>'));
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."Dimension Value Code 5", TempVATEntry."VAT Registration No.");
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."Dimension Value Code 6", CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempBudgetBufferVATEntry."Dimension Value Code 6")));
        if StrLen(TempVATEntry."External Document No.") > MaxStrLen(TempBudgetBufferVATEntry."Dimension Value Code 6") then
            TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry."Dimension Value Code 7", CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempBudgetBufferVATEntry."Dimension Value Code 6") + 1));
        TempBudgetBufferVATEntry.SetRange(TempBudgetBufferVATEntry.Date, TempVATEntry."Posting Date");
        if not TempBudgetBufferVATEntry.FindFirst() then begin
            TempVATEntryGlobal.Reset();
            TempVATEntryGlobal.SetCurrentKey("Document No.");
            TempVATEntryGlobal.SetRange("Document No.", TempVATEntry."Document No.");
            TempVATEntryGlobal.SetRange("VAT Bus. Posting Group", TempVATEntry."VAT Bus. Posting Group");
            TempVATEntryGlobal.SetRange("VAT Prod. Posting Group", TempVATEntry."VAT Prod. Posting Group");
            TempVATEntryGlobal.SetRange(Type, TempVATEntry.Type);
            TempVATEntryGlobal.SetRange("VAT Registration No.", TempVATEntry."VAT Registration No.");
            TempVATEntryGlobal.SetRange("External Document No.", TempVATEntry."External Document No.");
            TempVATEntryGlobal.SetRange("Posting Date", TempVATEntry."Posting Date");
            if TempVATEntry."VAT Calculation Type" <> TempVATEntry."VAT Calculation Type"::"Reverse Charge VAT" then
                TempVATEntryGlobal.SetFilter(Amount, '<>0');
            if TempVATEntryGlobal.FindSet() then begin
                TempBudgetBufferVATEntry.Init();
                TempBudgetBufferVATEntry."G/L Account No." := TempVATEntry."Document No.";
                TempBudgetBufferVATEntry."Dimension Value Code 1" := Format(TempVATEntry."VAT Calculation Type", 0, '<Number>');
                TempBudgetBufferVATEntry."Dimension Value Code 2" := TempVATEntry."VAT Bus. Posting Group";
                TempBudgetBufferVATEntry."Dimension Value Code 3" := TempVATEntry."VAT Prod. Posting Group";
                TempBudgetBufferVATEntry."Dimension Value Code 4" := Format(TempVATEntry.Type, 0, '<Number>');
                TempBudgetBufferVATEntry."Dimension Value Code 5" := TempVATEntry."VAT Registration No.";
                TempBudgetBufferVATEntry."Dimension Value Code 6" := CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempBudgetBufferVATEntry."Dimension Value Code 6"));
                TempBudgetBufferVATEntry."Dimension Value Code 7" := CopyStr(CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempBudgetBufferVATEntry."Dimension Value Code 6") + 1),
                                                1, MaxStrLen(TempBudgetBufferVATEntry."Dimension Value Code 7"));
                TempBudgetBufferVATEntry.Date := TempVATEntry."Posting Date";

                TempVATEntry.Base := 0;
                TempVATEntry.Amount := 0;
                TempVATEntry."Advance Base" := 0;
                repeat
                    TempVATEntry.Base += TempVATEntryGlobal.Base;
                    TempVATEntry.Amount += TempVATEntryGlobal.Amount;
                    TempVATEntry."Advance Base" += TempVATEntryGlobal."Advance Base";

                    if TempVATEntryGlobal."Entry No." <> TempVATEntry."Entry No." then begin
                        TempVATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := '';
                        TempVATCtrlReportEntLinkCZL."Line No." := TempVATEntry."Entry No.";
                        TempVATCtrlReportEntLinkCZL."VAT Entry No." := TempVATEntryGlobal."Entry No.";
                        TempVATCtrlReportEntLinkCZL.Insert();
                    end;
                until TempVATEntryGlobal.Next() = 0;
                TempBudgetBufferVATEntry.Insert();
            end;
        end;
    end;

    local procedure GetDocumentAmount(var TempVATEntry: Record "VAT Entry" temporary; ExternalDocument: Boolean): Decimal
    begin
        TempBudgetBufferDocument.Reset();
        if not ExternalDocument or (TempVATEntry."External Document No." = '') then
            TempBudgetBufferDocument.SetRange(TempBudgetBufferDocument."G/L Account No.", TempVATEntry."Document No.")
        else begin
            TempBudgetBufferDocument.SetRange(TempBudgetBufferDocument."Dimension Value Code 6", CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempBudgetBufferDocument."Dimension Value Code 6")));
            TempBudgetBufferDocument.SetRange(TempBudgetBufferDocument."Dimension Value Code 7", CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempBudgetBufferDocument."Dimension Value Code 6") + 1));
        end;
        if not IsDocumentWithReverseChargeVAT(TempVATEntry."Document No.", TempVATEntry."Posting Date") then
            TempBudgetBufferDocument.SetRange(TempBudgetBufferDocument."Dimension Value Code 1", Format(TempVATEntry."VAT Calculation Type", 0, '<Number>'));
        TempBudgetBufferDocument.SetRange(TempBudgetBufferDocument."Dimension Value Code 2", Format(TempVATEntry.Type, 0, '<Number>'));
        TempBudgetBufferDocument.SetRange(TempBudgetBufferDocument."Dimension Value Code 3", TempVATEntry."Bill-to/Pay-to No.");
        TempBudgetBufferDocument.SetRange(TempBudgetBufferDocument.Date, TempVATEntry."Posting Date");
        if not TempBudgetBufferDocument.FindFirst() then begin
            TempVATEntryGlobal.Reset();
            if not ExternalDocument or (TempVATEntry."External Document No." = '') then
                TempVATEntryGlobal.SetRange("Document No.", TempVATEntry."Document No.")
            else
                TempVATEntryGlobal.SetRange("External Document No.", TempVATEntry."External Document No.");
            TempVATEntryGlobal.SetRange("Bill-to/Pay-to No.", TempVATEntry."Bill-to/Pay-to No.");
            TempVATEntryGlobal.SetRange("Posting Date", TempVATEntry."Posting Date");
            TempVATEntryGlobal.SetRange(Type, TempVATEntry.Type);
            if TempVATEntryGlobal.FindSet() then begin
                TempBudgetBufferDocument.Init();
                if not ExternalDocument or (TempVATEntry."External Document No." = '') then
                    TempBudgetBufferDocument."G/L Account No." := TempVATEntry."Document No."
                else begin
                    TempBudgetBufferDocument."Dimension Value Code 6" := CopyStr(TempVATEntry."External Document No.", 1, MaxStrLen(TempBudgetBufferDocument."Dimension Value Code 6"));
                    TempBudgetBufferDocument."Dimension Value Code 7" := CopyStr(CopyStr(TempVATEntry."External Document No.", MaxStrLen(TempBudgetBufferDocument."Dimension Value Code 6") + 1),
                                                    1, MaxStrLen(TempBudgetBufferDocument."Dimension Value Code 7"));
                end;
                TempBudgetBufferDocument."Dimension Value Code 1" := Format(TempVATEntry."VAT Calculation Type", 0, '<Number>');
                TempBudgetBufferDocument."Dimension Value Code 2" := Format(TempVATEntry.Type, 0, '<Number>');
                TempBudgetBufferDocument."Dimension Value Code 3" := TempVATEntry."Bill-to/Pay-to No.";
                TempBudgetBufferDocument.Date := TempVATEntry."Posting Date";
                repeat
                    if TempVATEntryGlobal."VAT Calculation Type" = TempVATEntryGlobal."VAT Calculation Type"::"Reverse Charge VAT" then
                        TempBudgetBufferDocument.Amount += TempVATEntryGlobal.Base
                    else
                        if (TempVATEntryGlobal."Prepayment Type" = TempVATEntryGlobal."Prepayment Type"::Advance) and
                           (TempVATEntryGlobal."Advance Base" <> 0)
                        then
                            TempBudgetBufferDocument.Amount += (TempVATEntryGlobal."Advance Base" + TempVATEntryGlobal.Amount)
                        else
                            TempBudgetBufferDocument.Amount += (TempVATEntryGlobal.Base + TempVATEntryGlobal.Amount);
                until TempVATEntryGlobal.Next() = 0;
                TempBudgetBufferDocument.Insert();
            end;
        end;
        exit(TempBudgetBufferDocument.Amount);
    end;

    local procedure IsDocumentWithReverseChargeVAT(DocumentNo: Code[20]; PostingDate: Date): Boolean
    begin
        TempVATEntryGlobal.Reset();
        TempVATEntryGlobal.SetCurrentKey("Document No.");
        TempVATEntryGlobal.SetRange("Document No.", DocumentNo);
        TempVATEntryGlobal.SetRange("Posting Date", PostingDate);
        TempVATEntryGlobal.SetRange("VAT Calculation Type", TempVATEntryGlobal."VAT Calculation Type"::"Reverse Charge VAT");
        exit(not TempVATEntryGlobal.IsEmpty());
    end;

    local procedure DeleteVATCtrlReportLines(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date)
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        if GeneralLedgerLSetup."Use VAT Date CZL" then begin
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

    local procedure InsertVATCtrlReportBufferDocNo(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var TempVATCtrlRepVATEntryLink: Record "VAT Ctrl. Report Ent. Link CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    begin
        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportBufferCZL.SetCurrentKey(TempVATCtrlReportBufferCZL."Document No.");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Document No.", VATEntry."Document No.");
        InsertVATCtrlReportBufferGroup(TempVATCtrlReportBufferCZL, TempVATCtrlRepVATEntryLink,
          VATEntry, VATPostingSetup, SectionCode, CommodityCode);
    end;

    local procedure InsertVATCtrlReportBufferExtDocNo(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var TempVATCtrlRepVATEntryLink: Record "VAT Ctrl. Report Ent. Link CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    begin
        TempVATCtrlReportBufferCZL.Reset();
        if VATEntry."External Document No." <> '' then begin
            TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."External Document No.", VATEntry."External Document No.");
            TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Original Document VAT Date", VATEntry."Original Doc. VAT Date CZL");
        end else begin
            TempVATCtrlReportBufferCZL.SetCurrentKey(TempVATCtrlReportBufferCZL."Document No.");
            TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Document No.", VATEntry."Document No.");
        end;
        InsertVATCtrlReportBufferGroup(TempVATCtrlReportBufferCZL, TempVATCtrlRepVATEntryLink,
          VATEntry, VATPostingSetup, SectionCode, CommodityCode);
    end;

    local procedure InsertVATCtrlReportBufferGroup(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var TempVATCtrlRepVATEntryLink: Record "VAT Ctrl. Report Ent. Link CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    begin
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code", SectionCode);
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."VAT Rate", VATPostingSetup."VAT Rate CZL");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Commodity Code", CommodityCode);
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."VAT Registration No.", VATEntry."VAT Registration No.");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Supplies Mode Code", VATPostingSetup."Supplies Mode Code CZL");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Corrections for Bad Receivable", VATPostingSetup."Corrections Bad Receivable CZL");
        TempVATCtrlReportBufferCZL.SetRange(TempVATCtrlReportBufferCZL."Ratio Use", VATPostingSetup."Ratio Coefficient CZL");
        if not TempVATCtrlReportBufferCZL.FindFirst() then
            InsertVATCtrlReportBuffer(TempVATCtrlReportBufferCZL, VATEntry, VATPostingSetup, SectionCode, CommodityCode)
        else begin
            if VATEntry."Advance Base" <> 0 then
                VATEntry.Base += VATEntry."Advance Base";
            TempVATCtrlReportBufferCZL."Total Base" += VATEntry.Base;
            TempVATCtrlReportBufferCZL."Total Amount" += VATEntry.Amount;
            TempVATCtrlReportBufferCZL.Modify();
        end;
        InsertVATCtrlReportEntryLink(TempVATCtrlRepVATEntryLink, TempVATCtrlReportBufferCZL."Line No.", VATEntry."Entry No.");
    end;

    local procedure InsertVATCtrlReportBuffer(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; VATEntry: Record "VAT Entry"; VATPostingSetup2: Record "VAT Posting Setup"; SectionCode: Code[20]; CommodityCode: Code[20])
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        TempVATCtrlReportBufferCZL.Init();
        TempVATCtrlReportBufferCZL."VAT Ctrl. Report Section Code" := SectionCode;
        GlobalLineNo += 1;
        TempVATCtrlReportBufferCZL."Line No." := GlobalLineNo;
        TempVATCtrlReportBufferCZL."Posting Date" := VATEntry."Posting Date";
        TempVATCtrlReportBufferCZL."VAT Date" := VATEntry."VAT Date CZL";
        TempVATCtrlReportBufferCZL."Original Document VAT Date" := VATEntry."Original Doc. VAT Date CZL";
        TempVATCtrlReportBufferCZL."Bill-to/Pay-to No." := VATEntry."Bill-to/Pay-to No.";
        TempVATCtrlReportBufferCZL."VAT Registration No." := VATEntry."VAT Registration No.";
        case VATEntry.Type of
            VATEntry.Type::Purchase:
                if Vendor.Get(TempVATCtrlReportBufferCZL."Bill-to/Pay-to No.") then begin
                    TempVATCtrlReportBufferCZL."Tax Registration No." := Vendor."Tax Registration No. CZL";
                    TempVATCtrlReportBufferCZL."Registration No." := Vendor."Registration No. CZL";
                end;
            VATEntry.Type::Sale:
                if Customer.Get(TempVATCtrlReportBufferCZL."Bill-to/Pay-to No.") then begin
                    TempVATCtrlReportBufferCZL."Tax Registration No." := Customer."Tax Registration No. CZL";
                    TempVATCtrlReportBufferCZL."Registration No." := Customer."Registration No. CZL";
                end;
        end;
        TempVATCtrlReportBufferCZL."Document No." := VATEntry."Document No.";
        TempVATCtrlReportBufferCZL."External Document No." := VATEntry."External Document No.";
        TempVATCtrlReportBufferCZL.Type := VATEntry.Type.AsInteger();
        TempVATCtrlReportBufferCZL."VAT Bus. Posting Group" := VATEntry."VAT Bus. Posting Group";
        TempVATCtrlReportBufferCZL."VAT Prod. Posting Group" := VATEntry."VAT Prod. Posting Group";
        TempVATCtrlReportBufferCZL."VAT Calculation Type" := VATEntry."VAT Calculation Type";
        TempVATCtrlReportBufferCZL."VAT Rate" := VATPostingSetup2."VAT Rate CZL".AsInteger();
        TempVATCtrlReportBufferCZL."Commodity Code" := CopyStr(CommodityCode, 1, MaxStrLen(TempVATCtrlReportBufferCZL."Commodity Code"));
        TempVATCtrlReportBufferCZL."Supplies Mode Code" := VATPostingSetup2."Supplies Mode Code CZL".AsInteger();
        TempVATCtrlReportBufferCZL."Corrections for Bad Receivable" := VATPostingSetup2."Corrections Bad Receivable CZL";
        TempVATCtrlReportBufferCZL."Ratio Use" := VATPostingSetup2."Ratio Coefficient CZL";
        if VATEntry."Advance Base" <> 0 then
            VATEntry.Base += VATEntry."Advance Base";
        TempVATCtrlReportBufferCZL."Total Base" := VATEntry.Base;
        TempVATCtrlReportBufferCZL."Total Amount" := VATEntry.Amount;
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

    local procedure IsVATEntryCorrected(VATEntry: Record "VAT Entry"): Boolean
    begin
        TempVATEntryGlobal.Reset();
        TempVATEntryGlobal.SetCurrentKey("Document No.");
        TempVATEntryGlobal.SetRange("Document No.", VATEntry."Document No.");
        TempVATEntryGlobal.SetRange("Document Type", VATEntry."Document Type");
        TempVATEntryGlobal.SetRange(Type, VATEntry.Type);
        TempVATEntryGlobal.SetRange(Base, VATEntry."Unrealized Base");
        TempVATEntryGlobal.SetRange(Amount, VATEntry."Unrealized Amount");
        exit(not TempVATEntryGlobal.IsEmpty());
    end;

    local procedure GetBufferFromDocument(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary; SectionCode: Code[20])
    begin
        TempDropShptPostBuffer.Reset();
        TempDropShptPostBuffer.DeleteAll();

        if (VATEntry.Base <> 0) or (VATEntry.Amount <> 0) or (VATEntry."Advance Base" <> 0) then
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
            if VATEntry."Advance Base" <> 0 then
                TempDropShptPostBuffer.Quantity := VATEntry."Advance Base"
            else
                TempDropShptPostBuffer.Quantity := VATEntry.Base;
            TempDropShptPostBuffer."Quantity (Base)" := VATEntry.Amount;
            TempDropShptPostBuffer.Insert();
        end;
    end;

    local procedure SplitFromSalesInvLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange(SalesInvoiceLine."Document No.", VATEntry."Document No.");
        SalesInvoiceLine.SetRange(SalesInvoiceLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        SalesInvoiceLine.SetRange(SalesInvoiceLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        SalesInvoiceLine.SetFilter(SalesInvoiceLine.Type, '<>%1', SalesInvoiceLine.Type::" ");
        SalesInvoiceLine.SetFilter(SalesInvoiceLine.Quantity, '<>0');
        if SalesInvoiceLine.FindSet(false, false) then begin
            if SalesInvoiceHeader."No." <> SalesInvoiceLine."Document No." then
                SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
            repeat
                UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, SalesInvoiceLine."Tariff No. CZL",
                  SalesInvoiceLine."VAT Bus. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group", SalesInvoiceLine."VAT Base Amount",
                  SalesInvoiceHeader."Currency Code", SalesInvoiceHeader."VAT Currency Factor CZL", SalesInvoiceHeader."VAT Date CZL",
                  false, SalesInvoiceLine.Amount);
            until SalesInvoiceLine.Next() = 0;
        end;
    end;

    local procedure SplitFromSalesCrMemoLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetRange(SalesCrMemoLine."Document No.", VATEntry."Document No.");
        SalesCrMemoLine.SetRange(SalesCrMemoLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        SalesCrMemoLine.SetRange(SalesCrMemoLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        SalesCrMemoLine.SetFilter(SalesCrMemoLine.Type, '<>%1', SalesCrMemoLine.Type::" ");
        SalesCrMemoLine.SetFilter(SalesCrMemoLine.Quantity, '<>0');
        if SalesCrMemoLine.FindSet(false, false) then begin
            if SalesCrMemoHeader."No." <> SalesCrMemoLine."Document No." then
                SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.");
            repeat
                UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, SalesCrMemoLine."Tariff No. CZL",
                  SalesCrMemoLine."VAT Bus. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group", SalesCrMemoLine."VAT Base Amount",
                  SalesCrMemoHeader."Currency Code", SalesCrMemoHeader."VAT Currency Factor CZL", SalesCrMemoHeader."VAT Date CZL",
                  false, SalesCrMemoLine.Amount);
            until SalesCrMemoLine.Next() = 0;
        end;
    end;

    local procedure SplitFromPurchInvLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange(PurchInvLine."Document No.", VATEntry."Document No.");
        PurchInvLine.SetRange(PurchInvLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        PurchInvLine.SetRange(PurchInvLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        PurchInvLine.SetFilter(PurchInvLine.Type, '<>%1', PurchInvLine.Type::" ");
        PurchInvLine.SetFilter(PurchInvLine.Quantity, '<>0');
        if PurchInvLine.FindSet(false, false) then begin
            if PurchInvHeader."No." <> PurchInvLine."Document No." then
                PurchInvHeader.Get(PurchInvLine."Document No.");
            repeat
                UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, PurchInvLine."Tariff No. CZL",
                  PurchInvLine."VAT Bus. Posting Group", PurchInvLine."VAT Prod. Posting Group", PurchInvLine."VAT Base Amount",
                  PurchInvHeader."Currency Code", PurchInvHeader."VAT Currency Factor CZL", PurchInvHeader."VAT Date CZL",
                  true, PurchInvLine.Amount);
            until PurchInvLine.Next() = 0;
        end;
    end;

    local procedure SplitFromPurchCrMemoLine(VATEntry: Record "VAT Entry"; var TempDropShptPostBuffer: Record "Drop Shpt. Post. Buffer" temporary)
    var
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchCrMemoLine.SetRange(PurchCrMemoLine."Document No.", VATEntry."Document No.");
        PurchCrMemoLine.SetRange(PurchCrMemoLine."VAT Bus. Posting Group", VATEntry."VAT Bus. Posting Group");
        PurchCrMemoLine.SetRange(PurchCrMemoLine."VAT Prod. Posting Group", VATEntry."VAT Prod. Posting Group");
        PurchCrMemoLine.SetFilter(PurchCrMemoLine.Type, '<>%1', PurchCrMemoLine.Type::" ");
        PurchCrMemoLine.SetFilter(PurchCrMemoLine.Quantity, '<>0');
        if PurchCrMemoLine.FindSet(false, false) then begin
            if PurchCrMemoHeader."No." <> PurchCrMemoLine."Document No." then
                PurchCrMemoHeader.Get(PurchCrMemoLine."Document No.");
            repeat
                UpdateTempDropShptPostBuffer(TempDropShptPostBuffer, PurchCrMemoLine."Tariff No. CZL",
                  PurchCrMemoLine."VAT Bus. Posting Group", PurchCrMemoLine."VAT Prod. Posting Group", PurchCrMemoLine."VAT Base Amount",
                  PurchCrMemoHeader."Currency Code", PurchCrMemoHeader."VAT Currency Factor CZL", PurchCrMemoHeader."VAT Date CZL",
                  true, PurchCrMemoLine.Amount);
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
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        VATAmtLCY := 0;

        if CurrCode = '' then
            VATAmtLCY := VATAmt
        else
            VATAmtLCY := CurrExchRate.ExchangeAmtFCYToLCY(PostingDate, CurrCode, VATAmt, CurrFactor);
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
            Window.Open(BufferCreateDialogMsg);
            Window.Update(1, VATCtrlReportHeaderCZL."No.");
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
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::Reduced:
                        begin
                            TempVATCtrlReportBufferCZL."Base 2" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 2" += VATCtrlReportLineCZL.Amount;
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::"Reduced 2":
                        begin
                            TempVATCtrlReportBufferCZL."Base 3" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 3" += VATCtrlReportLineCZL.Amount;
                        end;
                end;
                if VATCtrlReportLineCZL."VAT Rate" > VATCtrlReportLineCZL."VAT Rate"::" " then begin
                    TempVATCtrlReportBufferCZL."Total Base" += VATCtrlReportLineCZL.Base;
                    TempVATCtrlReportBufferCZL."Total Amount" += VATCtrlReportLineCZL.Amount;
                end;
                OnBeforeModifyVATCtrlReportBufferForStatistics(TempVATCtrlReportBufferCZL, VATCtrlReportLineCZL);
                TempVATCtrlReportBufferCZL.Modify();
            until VATCtrlReportLineCZL.Next() = 0;

        if ShowMessage then
            Window.Close();
    end;

    procedure CreateBufferForExport(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; ShowMessage: Boolean; EntriesSelection: Enum "VAT Statement Report Selection")
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
        LineNo: Integer;
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;

        GeneralLedgerLSetup.Get();

        TempVATCtrlReportBufferCZL.Reset();
        TempVATCtrlReportBufferCZL.DeleteAll();

        if ShowMessage then begin
            Window.Open(BufferCreateDialogMsg);
            Window.Update(1, VATCtrlReportHeaderCZL."No.");
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
                        if GeneralLedgerLSetup."Use VAT Date CZL" then
                            TempVATCtrlReportBufferCZL.SetRange("Posting Date", VATCtrlReportLineCZL."VAT Date")
                        else
                            TempVATCtrlReportBufferCZL.SetRange("Posting Date", VATCtrlReportLineCZL."Posting Date");
                end;

                if not TempVATCtrlReportBufferCZL.FindFirst() then begin
                    CopyLineToBuffer(VATCtrlReportLineCZL, TempVATCtrlReportBufferCZL);
                    LineNo += 1;
                    TempVATCtrlReportBufferCZL."Line No." := LineNo;
                    if GeneralLedgerLSetup."Use VAT Date CZL" then begin
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
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::Reduced:
                        begin
                            TempVATCtrlReportBufferCZL."Base 2" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 2" += VATCtrlReportLineCZL.Amount;
                        end;
                    VATCtrlReportLineCZL."VAT Rate"::"Reduced 2":
                        begin
                            TempVATCtrlReportBufferCZL."Base 3" += VATCtrlReportLineCZL.Base;
                            TempVATCtrlReportBufferCZL."Amount 3" += VATCtrlReportLineCZL.Amount;
                        end;
                end;

                OnBeforeModifyVATCtrlReportBufferForExport(TempVATCtrlReportBufferCZL, VATCtrlReportLineCZL);
                TempVATCtrlReportBufferCZL.Modify();
            until VATCtrlReportLineCZL.Next() = 0;

        if ShowMessage then
            Window.Close();
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
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        case FieldNo of
            0:
                begin
                    RecRef.GetTable(VATCtrlReportLineCZL);
                    field.SetRange(Class, field.Class::Normal);
                    field.SetRange(TableNo, RecRef.Number);
                    field.SetFilter(ObsoleteState, '<>%1', field.ObsoleteState::Removed);
                    if field.FindSet() then
                        repeat
                            FieldRef := RecRef.field(field."No.");
                            if IsMandatoryField(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", FieldRef.Number) then
                                FieldRef.TestField();
                        until field.Next() = 0;
                end;
            else
                if IsMandatoryField(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", FieldNo) then begin
                    RecRef.GetTable(VATCtrlReportLineCZL);
                    if TypeHelper.GetField(RecRef.Number, FieldNo, field) then begin
                        FieldRef := RecRef.field(FieldNo);
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
        GetDocumentNoAndDateCZL: Page "Get Document No. and Date CZL";
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
            GetDocumentNoAndDateCZL.SetValues(NewCloseDocNo, NewCloseDate);
            if GetDocumentNoAndDateCZL.RunModal() = Action::OK then
                GetDocumentNoAndDateCZL.GetValues(NewCloseDocNo, NewCloseDate)
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
        TempVATCtrlReportBufferCZL1: Record "VAT Ctrl. Report Buffer CZL" temporary;
        TempVATCtrlReportBufferCZL2: Record "VAT Ctrl. Report Buffer CZL" temporary;
        TempVATCtrlReportBufferCZL3: Record "VAT Ctrl. Report Buffer CZL" temporary;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        i: Integer;
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;
    begin
        if VATCtrlReportHeaderCZL."No." = '' then
            exit;

        TempVATCtrlReportBufferCZL1.Reset();
        TempVATCtrlReportBufferCZL1.DeleteAll();

        if ShowMessage then begin
            Window.Open(BufferCreateDialogMsg);
            Window.Update(1, VATCtrlReportHeaderCZL."No.");
        end;

        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.SetRange("Exclude from Export", false);
        if VATCtrlReportLineCZL.FindSet() then
            repeat
                TempVATCtrlReportBufferCZL1.Reset();
                TempVATCtrlReportBufferCZL1.SetRange("VAT Ctrl. Report Section Code", VATCtrlReportLineCZL."VAT Ctrl. Report Section Code");
                TempVATCtrlReportBufferCZL1.SetRange("VAT Registration No.", VATCtrlReportLineCZL."VAT Registration No.");
                TempVATCtrlReportBufferCZL1.SetRange("VAT Date", VATCtrlReportLineCZL."VAT Date");
                TempVATCtrlReportBufferCZL1.SetRange("Bill-to/Pay-to No.", VATCtrlReportLineCZL."Bill-to/Pay-to No.");
                TempVATCtrlReportBufferCZL1.SetRange("Document No.", VATCtrlReportLineCZL."Document No.");
                TempVATCtrlReportBufferCZL1.SetRange("VAT Bus. Posting Group", VATCtrlReportLineCZL."VAT Bus. Posting Group");
                TempVATCtrlReportBufferCZL1.SetRange("VAT Prod. Posting Group", VATCtrlReportLineCZL."VAT Prod. Posting Group");
                TempVATCtrlReportBufferCZL1.SetRange("VAT Rate", VATCtrlReportLineCZL."VAT Rate");
                TempVATCtrlReportBufferCZL1.SetRange("Commodity Code", VATCtrlReportLineCZL."Commodity Code");
                TempVATCtrlReportBufferCZL1.SetRange("Supplies Mode Code", VATCtrlReportLineCZL."Supplies Mode Code");
                if not TempVATCtrlReportBufferCZL1.FindFirst() then begin
                    TempVATCtrlReportBufferCZL1.Init();
                    TempVATCtrlReportBufferCZL1."VAT Ctrl. Report Section Code" := VATCtrlReportLineCZL."VAT Ctrl. Report Section Code";
                    i += 1;
                    TempVATCtrlReportBufferCZL1."Line No." := i;
                    TempVATCtrlReportBufferCZL1."VAT Registration No." := VATCtrlReportLineCZL."VAT Registration No.";
                    TempVATCtrlReportBufferCZL1."VAT Date" := VATCtrlReportLineCZL."VAT Date";
                    TempVATCtrlReportBufferCZL1."Bill-to/Pay-to No." := VATCtrlReportLineCZL."Bill-to/Pay-to No.";
                    TempVATCtrlReportBufferCZL1."Document No." := VATCtrlReportLineCZL."Document No.";
                    TempVATCtrlReportBufferCZL1."VAT Bus. Posting Group" := VATCtrlReportLineCZL."VAT Bus. Posting Group";
                    TempVATCtrlReportBufferCZL1."VAT Prod. Posting Group" := VATCtrlReportLineCZL."VAT Prod. Posting Group";
                    TempVATCtrlReportBufferCZL1."VAT Rate" := VATCtrlReportLineCZL."VAT Rate";
                    TempVATCtrlReportBufferCZL1."Commodity Code" := VATCtrlReportLineCZL."Commodity Code";
                    TempVATCtrlReportBufferCZL1."Supplies Mode Code" := VATCtrlReportLineCZL."Supplies Mode Code";
                    TempVATCtrlReportBufferCZL1.Insert();
                end;
                TempVATCtrlReportBufferCZL1."Total Amount" += VATCtrlReportLineCZL.Base + VATCtrlReportLineCZL.Amount;
                TempVATCtrlReportBufferCZL1.Modify();
            until VATCtrlReportLineCZL.Next() = 0;

        TempVATCtrlReportBufferCZL1.Reset();
        if TempVATCtrlReportBufferCZL1.FindFirst() then
            repeat
                TempVATCtrlReportBufferCZL2 := TempVATCtrlReportBufferCZL1;
                TempVATCtrlReportBufferCZL1.SetRange("VAT Ctrl. Report Section Code", TempVATCtrlReportBufferCZL2."VAT Ctrl. Report Section Code");
                TempVATCtrlReportBufferCZL1.SetRange("VAT Registration No.", TempVATCtrlReportBufferCZL2."VAT Registration No.");
                TempVATCtrlReportBufferCZL1.SetFilter("Document No.", '<>%1', TempVATCtrlReportBufferCZL2."Document No.");
                TempVATCtrlReportBufferCZL1.SetFilter("Total Amount", '%1', -TempVATCtrlReportBufferCZL2."Total Amount");
                if TempVATCtrlReportBufferCZL1.FindFirst() then begin
                    TempVATCtrlReportBufferCZL3 := TempVATCtrlReportBufferCZL2;
                    TempVATCtrlReportBufferCZL3."External Document No." := TempVATCtrlReportBufferCZL1."Document No.";
                    TempVATCtrlReportBufferCZL3."Total Base" := TempVATCtrlReportBufferCZL1."Total Amount";
                    TempVATCtrlReportBufferCZL3.Insert();

                    TempVATCtrlReportBufferCZL1.Delete();
                end;
                TempVATCtrlReportBufferCZL1 := TempVATCtrlReportBufferCZL2;
                TempVATCtrlReportBufferCZL1.Delete();

                TempVATCtrlReportBufferCZL1.Reset();
            until not TempVATCtrlReportBufferCZL1.FindFirst();

        TempVATCtrlReportBufferCZL3.Reset();
        if TempVATCtrlReportBufferCZL3.FindSet() then begin
            i := 1;
            AddToExcelBuffer(TempExcelBuffer, i, 1, CopyStr(TempVATCtrlReportBufferCZL1.FieldCaption("Bill-to/Pay-to No."), 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 2, CopyStr(TempVATCtrlReportBufferCZL1.FieldCaption("VAT Registration No."), 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 3, CopyStr(TempVATCtrlReportBufferCZL1.FieldCaption("Document No."), 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 4, CopyStr(TempVATCtrlReportBufferCZL1.FieldCaption("Document No.") + ' 2', 1, 250));
            AddToExcelBuffer(TempExcelBuffer, i, 5, AmountTxt);
            AddToExcelBuffer(TempExcelBuffer, i, 6, AmountTxt + ' 2');
            repeat
                i += 1;
                AddToExcelBuffer(TempExcelBuffer, i, 1, TempVATCtrlReportBufferCZL3."Bill-to/Pay-to No.");
                AddToExcelBuffer(TempExcelBuffer, i, 2, TempVATCtrlReportBufferCZL3."VAT Registration No.");
                AddToExcelBuffer(TempExcelBuffer, i, 3, TempVATCtrlReportBufferCZL3."Document No.");
                AddToExcelBuffer(TempExcelBuffer, i, 4, TempVATCtrlReportBufferCZL3."External Document No.");
                AddToExcelBuffer(TempExcelBuffer, i, 5, Format(TempVATCtrlReportBufferCZL3."Total Amount"));
                AddToExcelBuffer(TempExcelBuffer, i, 6, Format(TempVATCtrlReportBufferCZL3."Total Base"));
            until TempVATCtrlReportBufferCZL3.Next() = 0;
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
            Window.Close();
    end;

    local procedure SetVATEntryFilters(var VATEntry: Record "VAT Entry"; VATStatementLine: Record "VAT Statement Line"; VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date)
    begin
        VATEntry.SetVATStatementLineFiltersCZL(VATStatementLine);
        VATEntry.SetRange(Reversed, false);
        VATEntry.SetDateFilterCZL(StartDate, EndDate, GeneralLedgerLSetup."Use VAT Date CZL");
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

    local procedure AddToExcelBuffer(var TempExcelBuf: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer; Value: Text[250])
    begin
        TempExcelBuf.Validate("Row No.", RowNo);
        TempExcelBuf.Validate("Column No.", ColumnNo);
        TempExcelBuf."Cell Value as Text" := Value;
        TempExcelBuf.Insert();
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
        VATEntry.SetDateFilterCZL(StartDate, EndDate, GeneralLedgerLSetup."Use VAT Date CZL");
        if VATEntry.FindSet(false, false) then
            repeat
                TempVATEntry.Init();
                TempVATEntry := VATEntry;
                TempVATEntry.Insert();
            until VATEntry.Next() = 0;
    end;

    local procedure GetVATEntryBufferForVATStatementLine(var TempVATEntry: Record "VAT Entry" temporary; VATStatementLine: Record "VAT Statement Line"; VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; StartDate: Date; EndDate: Date)
    var
        TempVATEntryGlobalCopy: Record "VAT Entry" temporary;
    begin
        DeleteVATEntryBuffer(TempVATEntry);

        GetVATEntryBufferForPeriod(TempVATEntryGlobal, StartDate, EndDate);

        TempVATEntryGlobalCopy.Copy(TempVATEntryGlobal, true);
        TempVATEntryGlobalCopy.Reset();
        SetVATEntryFilters(TempVATEntryGlobalCopy, VATStatementLine, VATCtrlReportHeaderCZL, StartDate, EndDate);
        TempVATEntryGlobalCopy.SetAutoCalcFields("VAT Ctrl. Report Line No. CZL");
        if TempVATEntryGlobalCopy.FindSet() then
            repeat
                if not SkipVATEntry(TempVATEntryGlobalCopy) then begin
                    TempVATEntry.Init();
                    TempVATEntry := TempVATEntryGlobalCopy;
                    TempVATEntry.Insert();
                end;
            until TempVATEntryGlobalCopy.Next() = 0;
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
}
