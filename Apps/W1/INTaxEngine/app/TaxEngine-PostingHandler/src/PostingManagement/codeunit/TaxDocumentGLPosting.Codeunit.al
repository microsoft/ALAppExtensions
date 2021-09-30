codeunit 20341 "Tax Document GL Posting"
{
    procedure UpdateTaxPostingBuffer(
        var TempTaxTransactionValue: Record "Tax Transaction Value" temporary;
        RecID: RecordId;
        TaxTransactionID: Guid;
        DimensionSetID: Integer;
        GenBusPostingGroup: Code[20];
        GenProdPostingGroup: Code[20];
        DocumentQty: Decimal;
        InvoiceQty: Decimal;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal;
        PostedDocNo: Code[20];
        PostedDocLineNo: Integer)
    var
        TempTaxTransactionValue2: Record "Tax Transaction Value" temporary;
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        CaseIDList: List of [Guid];
        CaseID: Guid;
    begin
        GetUseCaseIDList(TempTaxTransactionValue, CaseIDList);
        foreach CaseID in CaseIdList do begin
            CopyTransactionValue(CaseID, TempTaxTransactionValue, TempTaxTransactionValue2);

            UpdateUseCasePostingBuffer(
                TempTaxTransactionValue2,
                RecID,
                TaxTransactionID,
                DimensionSetID,
                GenBusPostingGroup,
                GenProdPostingGroup,
                DocumentQty,
                InvoiceQty,
                CurrencyCode,
                CurrencyFactor,
                PostedDocNo,
                PostedDocLineNo);

            TaxPostingBufferMgmt.ClearLineBuffers(TaxTransactionID);
        end;
    end;

    procedure TransferTransactionValue(
        FromRecID: RecordId;
        ToRecID: RecordId;
        var FromTaxTransactionValue: Record "Tax Transaction Value" temporary)
    var
        ToTaxTransactionValue: Record "Tax Transaction Value";
    begin
        FromTaxTransactionValue.Reset();
        FromTaxTransactionValue.SetRange("Tax Record ID", FromRecID);
        if FromTaxTransactionValue.FindSet() then
            repeat
                ToTaxTransactionValue.Init();
                ToTaxTransactionValue := FromTaxTransactionValue;
                ToTaxTransactionValue."Tax Record ID" := ToRecID;
                ToTaxTransactionValue.ID := 0;
                ToTaxTransactionValue.Insert();
            until FromTaxTransactionValue.Next() = 0;
    end;

    procedure PrepareTransactionValueToPost(
        RecID: RecordId;
        Quantity: Decimal;
        QtyToInvoice: Decimal;
        CurrCode: Code[20];
        CurrFactor: Decimal;
        var TempTaxTransactionValue: Record "Tax Transaction Value" temporary)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        IsModified: Boolean;
    begin
        if QtyToInvoice = 0 then
            exit;

        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        if TaxTransactionValue.FindSet() then
            repeat
                if TaxTransactionValue."Value Type" = TaxTransactionValue."Value Type"::COMPONENT then
                    TaxPostingBufferMgmt.DivideComponentAmount(
                        TaxTransactionValue,
                        Quantity,
                        QtyToInvoice,
                        CurrCode,
                        CurrFactor);

                TempTaxTransactionValue := TaxTransactionValue;
                TempTaxTransactionValue.Insert();

                IsModified := false;
                OnPrepareTransValueToPost(TempTaxTransactionValue, IsModified);
                if IsModified then
                    TempTaxTransactionValue.Modify();
            until TaxTransactionValue.Next() = 0;
    end;

    local procedure UpdateUseCasePostingBuffer(
        var TempTaxTransactionValue2: Record "Tax Transaction Value" temporary;
        RecID: RecordId;
        TaxTransactionID: Guid;
        DimensionSetID: Integer;
        GenBusPostingGroup: Code[20];
        GenProdPostingGroup: Code[20];
        DocumentQty: Decimal;
        InvoiceQty: Decimal;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal;
        PostedDocNo: Code[20];
        PostedDocLineNo: Integer)
    var
        TempSymbols: Record "Script Symbol Value" temporary;
        UseCase: Record "Tax Use Case";
        TaxComponent: Record "Tax Component";
        TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        RecRef: RecordRef;
        GLAccNo: Code[20];
        ReversaleGlAcc: Code[20];
        ReverseCharge: Boolean;
        PostingImpact: Option Debit,Credit;
    begin
        UpdatePostingSymbols(TempTaxTransactionValue2, TempSymbols, CurrencyCode, CurrencyFactor);

        RecRef.Get(RecID);
        TempTaxTransactionValue2.Reset();
        TempTaxTransactionValue2.SetRange("Value Type", TempTaxTransactionValue2."Value Type"::COMPONENT);
        if TempTaxTransactionValue2.FindSet() then
            repeat
                UseCase.Get(TempTaxTransactionValue2."Case ID");
                TaxComponent.Get(TempTaxTransactionValue2."Tax Type", TempTaxTransactionValue2."Value ID");
                if (not TaxComponent."Skip Posting") and (TempTaxTransactionValue2.Amount <> 0) then
                    TaxPostingExecution.ExecuteGetTaxPostingSetup(
                        TempTaxTransactionValue2."Value ID",
                        RecRef,
                        UseCase,
                        TempSymbols,
                        GLAccNo,
                        PostingImpact,
                        ReverseCharge,
                        ReversaleGlAcc);

                TaxPostingBufferMgmt.FillTaxBuffer(
                    TaxTransactionID,
                    DimensionSetID,
                    GenBusPostingGroup,
                    GenProdPostingGroup,
                    RecID,
                    TempTaxTransactionValue2,
                    CurrencyCode,
                    CurrencyFactor,
                    GLAccNo,
                    PostingImpact,
                    ReverseCharge,
                    ReversaleGlAcc,
                    DocumentQty,
                    InvoiceQty,
                    PostedDocNo,
                    PostedDocLineNo);
            until TempTaxTransactionValue2.Next() = 0;

        TaxPostingBufferMgmt.GetComponentTaxJournal(TaxTransactionID, TempTaxPostingBuffer, RecID);
        OnAfterPrepareTaxTransaction(TempTaxPostingBuffer, TempSymbols, TempTaxTransactionValue2);
    end;

    local procedure AdjustTaxAmountOnGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; Balancing: Boolean)
    var
        CurrencyExchRate: Record "Currency Exchange Rate";
        TaxJnlMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        AmountLCYToAdjust: Decimal;
        CommitSupresed: Boolean;
    begin
        AmountLCYToAdjust := TaxJnlMgmt.GetTaxAmount(GenJnlLine."Tax ID");

        if IsTaxAdjustmentLine(GenJnlLine, AmountLCYToAdjust) then
            if AmountLCYToAdjust <> 0 then begin
                if Balancing then
                    GenJnlLine."Amount Before Adjustment" := GenJnlLine."Amount (LCY)";

                CommitSupresed := SupressCommitIfRequired(GenJnlLine);
                if GenJnlLine."Currency Code" = '' then
                    GenJnlLine.Validate("Amount (LCY)", GenJnlLine."Amount (LCY)" - AmountLCYToAdjust)
                else begin
                    GenJnlLine."Amount (LCY)" := GenJnlLine."Amount (LCY)" - AmountLCYToAdjust;
                    GenJnlLine.Amount := CurrencyExchRate.ExchangeAmtLCYToFCY(
                        GenJnlLine."Posting Date",
                        GenJnlLine."Currency Code",
                        GenJnlLine."Amount (LCY)",
                        GenJnlLine."Currency Factor");
                end;
                GenJnlLine."Sales/Purch. (LCY)" := TaxJnlMgmt.GetSalesPurchLcy();
                if CommitSupresed then
                    GenJnlLine.SetSuppressCommit(false);
            end;
    end;

    local procedure RevertGenJnlLineAmount(var GenJnlLine: Record "Gen. Journal Line"; Balancing: Boolean)
    var
        CurrencyExchRate: Record "Currency Exchange Rate";
        CommitSupresed: Boolean;
    begin
        if not Balancing then
            exit;

        if GenJnlLine."Amount Before Adjustment" <> 0 then begin
            CommitSupresed := SupressCommitIfRequired(GenJnlLine);
            if GenJnlLine."Currency Code" = '' then
                GenJnlLine.Validate("Amount (LCY)", GenJnlLine."Amount Before Adjustment")
            else begin
                GenJnlLine."Amount (LCY)" := GenJnlLine."Amount Before Adjustment";
                GenJnlLine.Amount := CurrencyExchRate.ExchangeAmtLCYToFCY(
                    GenJnlLine."Posting Date",
                    GenJnlLine."Currency Code",
                    GenJnlLine."Amount (LCY)",
                    GenJnlLine."Currency Factor");
            end;
            if CommitSupresed then
                GenJnlLine.SetSuppressCommit(false);
        end;
    end;

    local procedure SupressCommitIfRequired(var GenJnlLine: Record "Gen. Journal Line") CommitSupresed: Boolean
    begin
        CommitSupresed := (GenJnlLine."Applies-to Doc. No." <> '') or (GenJnlLine."Document No." <> '***'); //This is to ensure that normal posting doest not call commit on payment Tolerance from Amount validate
        GenJnlLine.SetSuppressCommit(CommitSupresed);
    end;

    local procedure IsTaxAdjustmentLine(GenJnlLine: Record "Gen. Journal Line"; AmountToAdjust: Decimal) AdjustEntry: Boolean
    var
        IsHandled: Boolean;
    begin
        OnBeforeGenJnlLineAdjustEntry(GenJnlLine, AdjustEntry, IsHandled);
        if IsHandled then
            exit;

        if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment then begin
            if GetAmountSign(AmountToAdjust) = GetAmountSign(GenJnlLine.Amount) then
                AdjustEntry := true;
        end else
            if GenJnlLine."Account Type" in [
                GenJnlLine."Account Type"::Customer,
                GenJnlLine."Account Type"::Vendor,
                GenJnlLine."Account Type"::Employee,
                GenJnlLine."Account Type"::"Fixed Asset"]
            then
                AdjustEntry := true;

        if GenJnlLine."Adjust Tax Amount" then
            AdjustEntry := true;

        OnAfterGenJnlLineAdjustEntry(GenJnlLine, AdjustEntry);
    end;

    local procedure GetAmountSign(Amount: Decimal) Sign: Integer
    begin
        if Amount < 0 then
            Sign := -1
        else
            Sign := 1;
    end;

    local procedure GetUseCaseIDList(var TempTransactionValue: Record "Tax Transaction Value" temporary; var CaseIDList: List of [Guid])
    begin
        TempTransactionValue.Reset();
        TempTransactionValue.SetCurrentKey("Case ID");
        if TempTransactionValue.FindSet() then
            repeat
                CaseIDList.Add(TempTransactionValue."Case ID");

                TempTransactionValue.SetRange("Case ID", TempTransactionValue."Case ID");
                TempTransactionValue.FindLast();
                TempTransactionValue.SetRange("Case ID");
            until TempTransactionValue.Next() = 0;
    end;

    local procedure CopyTransactionValue(
        CaseID: Guid;
        var FromTransactionValue: Record "Tax Transaction Value" temporary;
        var ToTransactionValue: Record "Tax Transaction Value" temporary)
    begin
        ToTransactionValue.Reset();
        ToTransactionValue.DeleteAll();

        FromTransactionValue.Reset();
        FromTransactionValue.SetRange("Case ID", CaseID);
        if FromTransactionValue.FindSet() then
            repeat
                ToTransactionValue := FromTransactionValue;
                ToTransactionValue.Insert();
            until FromTransactionValue.Next() = 0;
    end;

    local procedure UpdatePostingSymbols(
        var TempTransactionValue: Record "Tax Transaction Value" temporary;
        var TempSymbols: Record "Script Symbol Value" temporary;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal)
    var
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
    begin
        TempTransactionValue.Reset();
        if TempTransactionValue.FindSet() then
            repeat
                TaxPostingBufferMgmt.UpdateUseCaseVariables(TempTransactionValue, TempSymbols);

                TaxPostingBufferMgmt.UpdateFormulaComponent(
                    TempTransactionValue,
                    TempSymbols,
                    CurrencyCode,
                    CurrencyFactor);
            until TempTransactionValue.Next() = 0;
    end;

    local procedure PostTaxJournal(
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        var GenJournalLine: Record "Gen. Journal Line")
    var
        TaxGenJnlLine: Record "Gen. Journal Line";
        TransactionPostingBuffer: Record "Transaction Posting Buffer" temporary;
        TempTransactionValue: Record "Tax Transaction Value" temporary;
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        DimensionManagement: Codeunit DimensionManagement;
        ReversalAmount: Decimal;
        ReversalAmountLCY: Decimal;
        DocumentRecord: Variant;
    begin
        TaxPostingBufferMgmt.GetGroupTaxJournal(GenJournalLine."Tax ID", TransactionPostingBuffer);
        if TransactionPostingBuffer.FindSet() then
            repeat
                if TransactionPostingBuffer."Account No." <> '' then begin
                    TaxGenJnlLine.init();
                    TaxGenJnlLine."Journal Template Name" := GenJournalLine."Journal Template Name";
                    TaxGenJnlLine."Journal Batch Name" := GenJournalLine."Journal Batch Name";
                    TaxGenJnlLine."Source Code" := GenJournalLine."Source Code";
                    TaxGenJnlLine."System-Created Entry" := true;
                    TaxGenJnlLine.Validate("Document Type", GenJournalLine."Document Type");
                    TaxGenJnlLine.Validate("Document No.", GenJournalLine."Document No.");
                    TaxGenJnlLine.Validate("Posting Date", GenJournalLine."Posting Date");
                    TaxGenJnlLine.Validate("Account type", TaxGenJnlLine."Account Type"::"G/L Account");
                    TaxGenJnlLine.Validate("Account No.", TransactionPostingBuffer."Account No.");
                    TaxGenJnlLine.Validate("Currency Code", TransactionPostingBuffer."Currency Code");
                    TaxGenJnlLine.Validate("Currency Factor", TransactionPostingBuffer."Currency Factor");
                    UpdateSourceOnGenJnlLine(TaxGenJnlLine, GenJournalLine);
                    TaxGenJnlLine."Dimension Set ID" := TransactionPostingBuffer."Dimension Set ID";

                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                        TaxGenJnlLine."Dimension Set ID",
                        TaxGenJnlLine."Shortcut Dimension 1 Code",
                        TaxGenJnlLine."Shortcut Dimension 2 Code");
                    TaxGenJnlLine."Posting No. Series" := GenJournalLine."Posting No. Series";

                    if TransactionPostingBuffer."Amount (LCY)" <> 0 then begin
                        TaxGenJnlLine.Validate("Amount", TransactionPostingBuffer.Amount);
                        TaxGenJnlLine.Validate("Amount (LCY)", TransactionPostingBuffer."Amount (LCY)");
                    end;

                    if TaxGenJnlLine.Amount <> 0 then
                        TransactionPostingBuffer."G/L Entry No" := GenJnlPostLine.RunWithCheck(TaxGenJnlLine);
                end;
                TransactionPostingBuffer."G/L Entry Transaction No." := GenJnlPostLine.GetNextTransactionNo();
                TransactionPostingBuffer.Modify();
                TaxPostingBufferMgmt.GetDocument(DocumentRecord);
                TaxPostingBufferMgmt.GetTransactionValues(TransactionPostingBuffer."Group ID", TempTransactionValue);

                OnAfterPostTaxGLEntry(TransactionPostingBuffer, TempTransactionValue, DocumentRecord);

                if (TransactionPostingBuffer."Reverse Charge") and (TaxGenJnlLine.Amount <> 0) and (TransactionPostingBuffer."Account No." <> '') then begin
                    ReversalAmount := -TaxGenJnlLine.Amount;
                    ReversalAmountLCY := -TaxGenJnlLine."Amount (LCY)";
                    TaxGenJnlLine.Validate("Account No.", TransactionPostingBuffer."Reverse Charge G/L Account");
                    TaxGenJnlLine.Validate("Currency Code", TransactionPostingBuffer."Currency Code");
                    TaxGenJnlLine.Validate("Currency Factor", TransactionPostingBuffer."Currency Factor");
                    TaxGenJnlLine.Validate(Amount, ReversalAmount);
                    TaxGenJnlLine.Validate("Amount (LCY)", ReversalAmountLCY);
                    TaxGenJnlLine."System-Created Entry" := true;
                    UpdateSourceOnGenJnlLine(TaxGenJnlLine, GenJournalLine);
                    TaxGenJnlLine."Dimension Set ID" := TransactionPostingBuffer."Dimension Set ID";

                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                        TaxGenJnlLine."Dimension Set ID",
                        TaxGenJnlLine."Shortcut Dimension 1 Code",
                        TaxGenJnlLine."Shortcut Dimension 2 Code");

                    TaxGenJnlLine."Posting No. Series" := GenJournalLine."Posting No. Series";
                    GenJnlPostLine.RunWithCheck(TaxGenJnlLine);
                end;
                TaxPostingBufferMgmt.ClearGroupingBuffers(TransactionPostingBuffer, TempTransactionValue);
            until TransactionPostingBuffer.Next() = 0;
        TaxPostingBufferMgmt.ClearNonGlComponents(GenJournalLine."Tax ID");
    end;

    local procedure UpdateSourceOnGenJnlLine(var TaxGenJnlLine: Record "Gen. Journal Line"; GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."Source No." = '' then begin
            GenJnlLine."Source Type" := GenJnlLine."Account Type";
            GenJnlLine."Source No." := GenJnlLine."Account No.";
        end;

        TaxGenJnlLine."Source Type" := GenJnlLine."Account Type";
        TaxGenJnlLine."Source No." := GenJnlLine."Account No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure OnAfterRunWithoutCheck(
        sender: Codeunit "Gen. Jnl.-Post Line";
        var
            GenJnlLine: Record "Gen. Journal Line")
    begin
        if not IsNullGuid(GenJnlLine."Tax ID") then
            PostTaxJournal(sender, GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithCheck', '', false, false)]
    local procedure OnAfterRunWithCheck(
        sender: Codeunit "Gen. Jnl.-Post Line";
        var GenJnlLine: Record "Gen. Journal Line")
    begin
        if not IsNullGuid(GenJnlLine."Tax ID") then
            PostTaxJournal(sender, GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure OnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; Balancing: Boolean; sender: Codeunit "Gen. Jnl.-Post Line")
    begin
        if not IsNullGuid(GenJournalLine."Tax ID") then
            AdjustTaxAmountOnGenJnlLine(GenJournalLine, Balancing);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostGenJnlLine', '', false, false)]
    local procedure OnAfterPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; Balancing: Boolean)
    var
    begin
        if not IsNullGuid(GenJournalLine."Tax ID") then
            RevertGenJnlLineAmount(GenJournalLine, Balancing);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPrepareTaxTransaction(
        var TaxPostingBuffer: Record "Transaction Posting Buffer";
        var TempSymbols: Record "Script Symbol Value" temporary;
        var TempTransactionValue: Record "Tax Transaction Value" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPostTaxGLEntry(var TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary; var TempTransactionValue: Record "Tax Transaction Value" temporary; var Record: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterGenJnlLineAdjustEntry(var GenJnlLine: Record "Gen. Journal Line"; var AdjustEntry: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeGenJnlLineAdjustEntry(var GenJnlLine: Record "Gen. Journal Line"; var AdjustEntry: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPrepareTransValueToPost(var TempTransValue: Record "Tax Transaction Value" temporary; var IsModified: Boolean)
    begin
    end;

    var
        TaxPostingExecution: Codeunit "Tax Posting Execution";
}