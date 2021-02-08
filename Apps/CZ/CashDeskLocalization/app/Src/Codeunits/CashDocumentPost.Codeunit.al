#pragma warning disable AL0432
codeunit 11729 "Cash Document-Post CZP"
{
    Permissions = TableData "Posted Cash Document Hdr. CZP" = i,
                  TableData "Posted Cash Document Line CZP" = im;
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    var
        CashDeskCZP: Record "Cash Desk CZP";
        NoCheckCashDocument: Boolean;
        ThreePlaceholdersTok: Label '%1 %2 %3', Locked = true;
    begin
        OnBeforePostCashDoc(Rec);
        if not PreviewMode then
            Rec.OnCheckCashDocPostRestrictions();

        CashDocumentHeaderCZP := Rec;
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."No.");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."Posting Date");
        CashDocumentHeaderCZP.TestField(CashDocumentHeaderCZP."VAT Date");
        if GenJnlCheckLine.DateNotAllowed(CashDocumentHeaderCZP."Posting Date") then
            CashDocumentHeaderCZP.FieldError(CashDocumentHeaderCZP."Posting Date", PostingDateOutRangeErr);

        if CashDocumentHeaderCZP.Status <> CashDocumentHeaderCZP.Status::Released then begin
            Codeunit.Run(Codeunit::"Cash Document-Release CZP", CashDocumentHeaderCZP);
            NoCheckCashDocument := true;
        end;
        // test cash desk
        CashDeskCZP.Get(CashDocumentHeaderCZP."Cash Desk No.");
        CashDeskCZP.TestField(Blocked, false);
        CashDocumentHeaderCZP.CalcFields(CashDocumentHeaderCZP."Amount Including VAT", CashDocumentHeaderCZP."Amount Including VAT (LCY)");
        if CashDocumentHeaderCZP."Amount Including VAT" <> CashDocumentHeaderCZP."Released Amount" then
            Error(IsNotEqualErr, CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Amount Including VAT"), CashDocumentHeaderCZP.FieldCaption(CashDocumentHeaderCZP."Released Amount"));

        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Cash Desk CZP");
        if not NoCheckCashDocument then
            CashDocumentReleaseCZP.CheckCashDocument(Rec);

        if CashDocumentHeaderCZP.RecordLevelLocking then begin
            CashDocumentLineCZP.LockTable();
            GLEntry.LockTable();
            if GLEntry.FindLast() then;
        end;

        Window.Open(DialogMsg);
        // Insert posted cash document header
        Window.Update(1, StrSubstNo(ThreePlaceholdersTok, CashDocumentHeaderCZP."Cash Desk No.", CashDocumentHeaderCZP."Document Type", CashDocumentHeaderCZP."No."));

        PostedCashDocumentHdrCZP.Init();
        PostedCashDocumentHdrCZP.TransferFields(CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP."Posted ID" := CopyStr(UserId(), 1, MaxStrLen(PostedCashDocumentHdrCZP."Posted ID"));
        PostedCashDocumentHdrCZP."No. Printed" := 0;
        OnBeforePostedCashDocHeaderInsert(PostedCashDocumentHdrCZP, CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP.Insert();
        OnAfterPostedCashDocHeaderInsert(PostedCashDocumentHdrCZP, CashDocumentHeaderCZP);

        GenJnlPostLine.SetPostFromCashReq(true);
        PostHeader();
        PostLines();
#if not CLEAN18
        PostAdvances();
#endif

        FinalizePosting(CashDocumentHeaderCZP);
        OnAfterPostCashDoc(CashDocumentHeaderCZP, GenJnlPostLine, PostedCashDocumentHdrCZP."No.");
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimensionManagement: Codeunit DimensionManagement;
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        Window: Dialog;
        DialogMsg: Label 'Posting Document #1#################################\\Posting Lines #2######\', Comment = '%1 = Cash Desk No. & "Cash Document Type & No., %2 = Line Count';
        PostingDateOutRangeErr: Label 'is not within your range of allowed posting dates';
        IsNotEqualErr: Label '%1 is not equal %2.', Comment = '%1 = Amount Including VAT FieldCaption, %2 = Released Amount FieldCaption)';
        CheckDimErr: Label 'A dimension used in %1 %2, %3, %4 has caused an error.\\%5.', Comment = '%1 = TableCaption, %2 = Cash Desk No., %3 = Cash Document No., %4 = Cash Document Line No., %5 = Error Text';
        PreviewMode: Boolean;

    local procedure PostHeader()
    var
        Sign: Integer;
    begin
        Sign := CashDocumentHeaderCZP.SignAmount();
        CashDocumentHeaderCZP.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");

        TempGenJnlLine.Init();
        TempGenJnlLine."Document No." := CashDocumentHeaderCZP."No.";
        TempGenJnlLine."External Document No." := CashDocumentHeaderCZP."External Document No.";
        TempGenJnlLine.Description := CashDocumentHeaderCZP."Payment Purpose";
        TempGenJnlLine."Posting Date" := CashDocumentHeaderCZP."Posting Date";
        TempGenJnlLine."Document Date" := CashDocumentHeaderCZP."Document Date";
        TempGenJnlLine."VAT Date CZL" := CashDocumentHeaderCZP."VAT Date";
        TempGenJnlLine."Original Doc. VAT Date CZL" := CashDocumentHeaderCZP."VAT Date";
        TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::"Bank Account";
        TempGenJnlLine."Account No." := CashDocumentHeaderCZP."Cash Desk No.";
        TempGenJnlLine."Currency Code" := CashDocumentHeaderCZP."Currency Code";
        TempGenJnlLine.Amount := CashDocumentHeaderCZP."Amount Including VAT" * -Sign;
        TempGenJnlLine."Amount (LCY)" := CashDocumentHeaderCZP."Amount Including VAT (LCY)" * -Sign;
        TempGenJnlLine."Salespers./Purch. Code" := CashDocumentHeaderCZP."Salespers./Purch. Code";
        TempGenJnlLine."Source Currency Code" := TempGenJnlLine."Currency Code";
        TempGenJnlLine."Source Currency Amount" := TempGenJnlLine.Amount;
        TempGenJnlLine."Source Curr. VAT Base Amount" := TempGenJnlLine."VAT Base Amount";
        TempGenJnlLine."Source Curr. VAT Amount" := TempGenJnlLine."VAT Amount";
        TempGenJnlLine."System-Created Entry" := true;
        TempGenJnlLine."Shortcut Dimension 1 Code" := CashDocumentHeaderCZP."Shortcut Dimension 1 Code";
        TempGenJnlLine."Shortcut Dimension 2 Code" := CashDocumentHeaderCZP."Shortcut Dimension 2 Code";
        TempGenJnlLine."Dimension Set ID" := CashDocumentHeaderCZP."Dimension Set ID";
        TempGenJnlLine."Source Code" := SourceCodeSetup."Cash Desk CZP";
        TempGenJnlLine."Reason Code" := CashDocumentHeaderCZP."Reason Code";
        TempGenJnlLine."VAT Registration No." := CashDocumentHeaderCZP."VAT Registration No.";

        OnBeforePostCashDocHeader(TempGenJnlLine, CashDocumentHeaderCZP, GenJnlPostLine);
        GenJnlPostLine.RunWithCheck(TempGenJnlLine);
    end;

    local procedure PostLines()
    var
        LineCount: Integer;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        CashDocumentLineCZP.Reset();
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        LineCount := 0;

        if CashDocumentLineCZP.FindSet() then
            repeat
                LineCount += 1;
                Window.Update(2, LineCount);

                // Insert posted cash order line
                PostedCashDocumentLineCZP.Init();
                PostedCashDocumentLineCZP.TransferFields(CashDocumentLineCZP);
                OnBeforePostedCashDocLineInsert(PostedCashDocumentLineCZP, PostedCashDocumentHdrCZP, CashDocumentLineCZP);
                PostedCashDocumentLineCZP.Insert();
                OnAfterPostedCashDocLineInsert(PostedCashDocumentLineCZP, PostedCashDocumentHdrCZP, CashDocumentLineCZP);

                // Post cash order lines
                if CashDocumentLineCZP.Amount <> 0 then begin
                    CashDocumentLineCZP.TestField("Account Type");
                    CashDocumentLineCZP.TestField("Account No.");

                    InitGenJnlLine(CashDocumentHeaderCZP, CashDocumentLineCZP);

                    case CashDocumentLineCZP."Account Type" of
                        CashDocumentLineCZP."Account Type"::"G/L Account":
                            TableID[1] := Database::"G/L Account";
                        CashDocumentLineCZP."Account Type"::Customer:
                            TableID[1] := Database::Customer;
                        CashDocumentLineCZP."Account Type"::Vendor:
                            TableID[1] := Database::Vendor;
                        CashDocumentLineCZP."Account Type"::"Bank Account":
                            TableID[1] := Database::"Bank Account";
                        CashDocumentLineCZP."Account Type"::"Fixed Asset":
                            TableID[1] := Database::"Fixed Asset";
                        CashDocumentLineCZP."Account Type"::Employee:
                            TableID[1] := Database::Employee;
                    end;
                    No[1] := CashDocumentLineCZP."Account No.";
                    TableID[2] := Database::"Salesperson/Purchaser";
                    No[2] := CashDocumentLineCZP."Salespers./Purch. Code";
                    TableID[3] := Database::"Responsibility Center";
                    No[3] := CashDocumentLineCZP."Responsibility Center";
                    TableID[4] := Database::"Cash Desk Event CZP";
                    No[4] := CashDocumentLineCZP."Cash Desk Event";

                    if not DimensionManagement.CheckDimValuePosting(TableID, No, CashDocumentLineCZP."Dimension Set ID") then begin
                        if CashDocumentLineCZP."Line No." <> 0 then
                            Error(
                              CheckDimErr,
                              CashDocumentHeaderCZP.TableCaption, CashDocumentHeaderCZP."Cash Desk No.", CashDocumentHeaderCZP."No.", CashDocumentLineCZP."Line No.",
                              DimensionManagement.GetDimValuePostingErr());
                        Error(DimensionManagement.GetDimValuePostingErr());
                    end;
                    OnBeforePostCashDocLine(TempGenJnlLine, CashDocumentLineCZP, GenJnlPostLine);
                    GenJnlPostLine.RunWithCheck(TempGenJnlLine);
                end;
            until CashDocumentLineCZP.Next() = 0;
    end;

    procedure InitGenJnlLine(CashDocumentHeaderCZP2: Record "Cash Document Header CZP"; CashDocumentLineCZP2: Record "Cash Document Line CZP")
    var
        Sign: Integer;
    begin
        TempGenJnlLine.Init();
        case CashDocumentLineCZP2."Gen. Document Type" of
            CashDocumentLineCZP2."Gen. Document Type"::Payment:
                TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Payment;
            CashDocumentLineCZP2."Gen. Document Type"::Refund:
                TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Refund;
        end;
        TempGenJnlLine."Document No." := CashDocumentHeaderCZP2."No.";
        TempGenJnlLine."External Document No." := CashDocumentLineCZP2."External Document No.";
        TempGenJnlLine."Posting Date" := CashDocumentHeaderCZP2."Posting Date";
        TempGenJnlLine.Validate("VAT Date CZL", CashDocumentHeaderCZP2."VAT Date");
        TempGenJnlLine.Validate("Original Doc. VAT Date CZL", CashDocumentHeaderCZP2."VAT Date");
        TempGenJnlLine."Posting Group" := CashDocumentLineCZP2."Posting Group";
        TempGenJnlLine.Description := CashDocumentLineCZP2.Description;
        case CashDocumentLineCZP2."Account Type" of
            CashDocumentLineCZP2."Account Type"::"G/L Account":
                TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::"G/L Account";
            CashDocumentLineCZP2."Account Type"::Customer:
                begin
                    TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::Customer;
                    TempGenJnlLine.Validate(TempGenJnlLine."Bill-to/Pay-to No.", CashDocumentLineCZP2."Account No.");
                    TempGenJnlLine.Validate(TempGenJnlLine."Sell-to/Buy-from No.", CashDocumentLineCZP2."Account No.");
                end;
            CashDocumentLineCZP2."Account Type"::Vendor:
                begin
                    TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::Vendor;
                    TempGenJnlLine.Validate(TempGenJnlLine."Bill-to/Pay-to No.", CashDocumentLineCZP2."Account No.");
                    TempGenJnlLine.Validate(TempGenJnlLine."Sell-to/Buy-from No.", CashDocumentLineCZP2."Account No.");
                end;
            CashDocumentLineCZP2."Account Type"::"Bank Account":
                TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::"Bank Account";
            CashDocumentLineCZP2."Account Type"::"Fixed Asset":
                TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::"Fixed Asset";
            CashDocumentLineCZP2."Account Type"::Employee:
                TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::Employee;
        end;
        TempGenJnlLine."Account No." := CashDocumentLineCZP2."Account No.";

        Sign := CashDocumentLineCZP2.SignAmount();

        TempGenJnlLine."VAT Bus. Posting Group" := CashDocumentLineCZP2."VAT Bus. Posting Group";
        TempGenJnlLine."VAT Prod. Posting Group" := CashDocumentLineCZP2."VAT Prod. Posting Group";
        TempGenJnlLine."VAT Calculation Type" := CashDocumentLineCZP2."VAT Calculation Type";
        TempGenJnlLine."VAT Base Amount" := CashDocumentLineCZP2."VAT Base Amount" * Sign;
        TempGenJnlLine."VAT Base Amount (LCY)" := CashDocumentLineCZP2."VAT Base Amount (LCY)" * Sign;
        TempGenJnlLine."VAT Amount" := CashDocumentLineCZP2."VAT Amount" * Sign;
        TempGenJnlLine."VAT Amount (LCY)" := CashDocumentLineCZP2."VAT Amount (LCY)" * Sign;
        TempGenJnlLine.Amount := CashDocumentLineCZP2."Amount Including VAT" * Sign;
        TempGenJnlLine."Amount (LCY)" := CashDocumentLineCZP2."Amount Including VAT (LCY)" * Sign;
        TempGenJnlLine."VAT Difference" := CashDocumentLineCZP2."VAT Difference" * Sign;
        TempGenJnlLine."Gen. Posting Type" := CashDocumentLineCZP2."Gen. Posting Type";
        TempGenJnlLine."Applies-to Doc. Type" := CashDocumentLineCZP2."Applies-To Doc. Type";
        TempGenJnlLine."Applies-to Doc. No." := CashDocumentLineCZP2."Applies-To Doc. No.";
        TempGenJnlLine."Applies-to ID" := CashDocumentLineCZP2."Applies-to ID";
        TempGenJnlLine."Currency Code" := CashDocumentHeaderCZP2."Currency Code";
        TempGenJnlLine."Currency Factor" := CashDocumentHeaderCZP2."Currency Factor";
        if TempGenJnlLine."Account Type" = TempGenJnlLine."Account Type"::"Fixed Asset" then begin
            TempGenJnlLine.Validate(TempGenJnlLine."Depreciation Book Code", CashDocumentLineCZP2."Depreciation Book Code");
            TempGenJnlLine.Validate(TempGenJnlLine."FA Posting Type", CashDocumentLineCZP2."FA Posting Type");
            TempGenJnlLine.Validate(TempGenJnlLine."Maintenance Code", CashDocumentLineCZP2."Maintenance Code");
            TempGenJnlLine.Validate(TempGenJnlLine."Duplicate in Depreciation Book", CashDocumentLineCZP2."Duplicate in Depreciation Book");
            TempGenJnlLine.Validate(TempGenJnlLine."Use Duplication List", CashDocumentLineCZP2."Use Duplication List");
        end;
        TempGenJnlLine."Source Currency Code" := TempGenJnlLine."Currency Code";
        TempGenJnlLine."Source Currency Amount" := TempGenJnlLine.Amount;
        TempGenJnlLine."Source Curr. VAT Base Amount" := TempGenJnlLine."VAT Base Amount";
        TempGenJnlLine."Source Curr. VAT Amount" := TempGenJnlLine."VAT Amount";
        TempGenJnlLine."System-Created Entry" := true;
        TempGenJnlLine."Shortcut Dimension 1 Code" := CashDocumentLineCZP2."Shortcut Dimension 1 Code";
        TempGenJnlLine."Shortcut Dimension 2 Code" := CashDocumentLineCZP2."Shortcut Dimension 2 Code";
        TempGenJnlLine."Dimension Set ID" := CashDocumentLineCZP2."Dimension Set ID";
        TempGenJnlLine."Source Code" := SourceCodeSetup."Cash Desk CZP";
        TempGenJnlLine."Reason Code" := CashDocumentLineCZP2."Reason Code";
#if not CLEAN18
        TempGenJnlLine.Validate(Prepayment, CashDocumentLineCZP2."Advance Letter Link Code" <> '');
        TempGenJnlLine."Advance Letter Link Code" := CashDocumentLineCZP2."Advance Letter Link Code";
#endif
        TempGenJnlLine."VAT Registration No." := CashDocumentHeaderCZP2."VAT Registration No.";
        OnAfterInitGenJnlLine(TempGenJnlLine, CashDocumentHeaderCZP2, CashDocumentLineCZP2);
    end;

    procedure GetGenJnlLine(var TempNewGenJnlLine: Record "Gen. Journal Line" temporary)
    begin
        TempNewGenJnlLine := TempGenJnlLine;
    end;

    local procedure FinalizePosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        if PreviewMode then begin
            Window.Close();
            OnAfterFinalizePostingPreview(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP, GenJnlPostLine);
            GenJnlPostPreview.ThrowError();
        end;
        DeleteAfterPosting(CashDocumentHeaderCZP);
        Window.Close();
        OnAfterFinalizePosting(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP, GenJnlPostLine);
    end;

    local procedure DeleteAfterPosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        OnBeforeDeleteAfterPosting(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP);
        if CashDocumentHeaderCZP.HasLinks then
            CashDocumentHeaderCZP.DeleteLinks();
        CashDocumentHeaderCZP.Delete();

        CashDocumentLineCZP.Reset();
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        if CashDocumentLineCZP.FindFirst() then
            repeat
                if CashDocumentLineCZP.HasLinks then
                    CashDocumentLineCZP.DeleteLinks();
            until CashDocumentLineCZP.Next() = 0;
        CashDocumentLineCZP.DeleteAll();
    end;

    procedure DeleteCashDocumentHeader(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        SourceCode: Record "Source Code";
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Deleted Document");
        SourceCode.Get(SourceCodeSetup."Deleted Document");

        // create posted document header
        PostedCashDocumentHdrCZP.Init();
        PostedCashDocumentHdrCZP.TransferFields(CashDocumentHeaderCZP);
        PostedCashDocumentHdrCZP."Canceled Document" := true;
        PostedCashDocumentHdrCZP."Posting Date" := Today;
        PostedCashDocumentHdrCZP."Created ID" := CopyStr(UserId(), 1, MaxStrLen(PostedCashDocumentHdrCZP."Created ID"));
        PostedCashDocumentHdrCZP."Payment Purpose" := SourceCode.Description;
        PostedCashDocumentHdrCZP.Insert();

        // create posted document line
        PostedCashDocumentLineCZP.Init();
        PostedCashDocumentLineCZP."Cash Desk No." := PostedCashDocumentHdrCZP."Cash Desk No.";
        PostedCashDocumentLineCZP."Document Type" := PostedCashDocumentHdrCZP."Document Type";
        PostedCashDocumentLineCZP."Cash Document No." := PostedCashDocumentHdrCZP."No.";
        PostedCashDocumentLineCZP."Line No." := 0;
        PostedCashDocumentLineCZP.Description := SourceCode.Description;
        if not PostedCashDocumentLineCZP.Insert() then
            PostedCashDocumentLineCZP.Modify();
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    procedure SetGenJnlPostLine(var GenJnlPostLineNew: Codeunit "Gen. Jnl.-Post Line")
    begin
        GenJnlPostLine := GenJnlPostLineNew;
    end;

#if not CLEAN18
    [Obsolete('Remove after Advance Payment Localization for Czech will be implemented.', '18.0')]
    internal procedure PostAdvances();
    var
        TempPurchAdvanceLetterHeader: Record "Purch. Advance Letter Header" temporary;
        TempSalesAdvanceLetterHeader: Record "Sales Advance Letter Header" temporary;
        PurchasePostAdvances: Codeunit "Purchase-Post Advances";
        SalesPostAdvances: Codeunit "Sales-Post Advances";
    begin
        GenJnlPostLine.SetPostAdvInvAfterBatch(true);
        GenJnlPostLine.xGetSalesLetterHeader(TempSalesAdvanceLetterHeader);
        if not TempSalesAdvanceLetterHeader.IsEmpty() then begin
            SalesPostAdvances.SetLetterHeader(TempSalesAdvanceLetterHeader);
            SalesPostAdvances.SetGenJnlPostLine(GenJnlPostLine);
            SalesPostAdvances.AutoPostAdvanceInvoices();
        end;

        GenJnlPostLine.xGetPurchLetterHeader(TempPurchAdvanceLetterHeader);
        if not TempPurchAdvanceLetterHeader.IsEmpty() then begin
            PurchasePostAdvances.SetLetterHeader(TempPurchAdvanceLetterHeader);
            PurchasePostAdvances.SetGenJnlPostLine(GenJnlPostLine);
            PurchasePostAdvances.AutoPostAdvanceInvoices();
        end;
    end;
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckCashDeskOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        BankAccount: Record "Bank Account";
    begin
        SourceCodeSetup.Get();
        if GenJournalLine."Source Code" <> SourceCodeSetup."Cash Desk CZP" then
            exit;
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
            if BankAccount.Get(GenJournalLine."Account No.") then
                BankAccount.TestField("Account Type CZP", BankAccount."Account Type CZP"::"Cash Desk");
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
            if BankAccount.Get(GenJournalLine."Bal. Account No.") then
                BankAccount.TestField("Account Type CZP", BankAccount."Account Type CZP"::"Cash Desk");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePostingPreview(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostCashDoc(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostedCashDocumentHeaderNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedCashDocHeaderInsert(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedCashDocLineInsert(var PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteAfterPosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashDoc(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashDocHeader(var GenJnlLine: Record "Gen. Journal Line"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCashDocLine(var GenJnlLine: Record "Gen. Journal Line"; var CashDocumentLineCZP: Record "Cash Document Line CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedCashDocHeaderInsert(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedCashDocLineInsert(var PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;
}
