namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.Dimension;
using Microsoft.Sales.History;
using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.NoSeries;

report 30118 "Shpfy Suggest Payments"
{
    Caption = 'Suggest Shopify Payments';
    ProcessingOnly = true;

    dataset
    {
        dataitem(OrderTransaction; "Shpfy Order Transaction")
        {
            RequestFilterFields = "Created At";
            DataItemTableView = sorting(Type) where(Type = filter(Capture | Sale | Refund));

            trigger OnAfterGetRecord()
            begin
                if Used then
                    if not IgnorePostedTransactions then
                        exit;

                GetOrderTransactions(OrderTransaction);
            end;

            trigger OnPreDataItem()
            begin
                SetAutoCalcFields("Payment Method", Used);
                if PostingDate = 0D then
                    Error(NoPostingDateErr);
                if this.Gateway <> '' then
                    SetRange(Gateway, this.Gateway);
            end;

            trigger OnPostDataItem()
            begin
                CreateGeneralJournalLines();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                field(JnlTemplateName; GenJournalLine."Journal Template Name")
                {
                    ApplicationArea = Suite;
                    Caption = 'Journal Template Name';
                    TableRelation = "Gen. Journal Template" where("Page ID" = const(Page::"Cash Receipt Journal"), Type = const("Gen. Journal Template Type"::"Cash Receipts"));
                    ToolTip = 'Specifies the name of the journal template that is used for the posting.';
                    Visible = not IsGenJournalLineSet;
                    Editable = not IsJournalTemplateFound;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                        ValidatePostingDate();
                    end;
                }
                field(JnlBatchName; GenJournalLine."Journal Batch Name")
                {
                    ApplicationArea = Suite;
                    Caption = 'Journal Batch Name';
                    Lookup = true;
                    ToolTip = 'Specifies the name of the journal batch that is used for the posting.';
                    Visible = not IsGenJournalLineSet;
                    ShowMandatory = true;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GenJnlManagement: Codeunit GenJnlManagement;
                    begin
                        GenJnlManagement.SetJnlBatchName(GenJournalLine);
                    end;

                    trigger OnValidate()
                    begin
                        if GenJournalLine."Journal Batch Name" <> '' then begin
                            GenJournalLine.TestField("Journal Template Name");
                            ValidatePostingDate();
                        end;
                    end;
                }
                field("Posting Date"; PostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    Importance = Promoted;
                    ToolTip = 'Specifies the date for the posting of this batch job. By default, the working date is entered, but you can change it.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        ValidatePostingDate();
                    end;
                }
                field("Starting Document No."; NextDocNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Starting Document No.';
                    ToolTip = 'Specifies the next available number in the number series for the journal batch that is linked to the cash receipt journal. When you run the batch job, this is the document number that appears on the first cash receipt journal line. You can also fill in this field manually.';

                    trigger OnValidate()
                    begin
                        if NextDocNo <> '' then
                            if IncStr(NextDocNo) = '' then
                                Error(StartingDocumentNoErr);
                    end;
                }
                field("New Doc. No. Per Line"; DocNoPerLine)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'New Document No. per Line';
                    Importance = Additional;
                    ToolTip = 'Specifies if you want the batch job to fill in the cash receipt journal lines with consecutive document numbers, starting with the document number specified in the Starting Document No. field.';
                }
                field("Transaction Gateway"; Gateway)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gateway';
                    ToolTip = 'Specifies the gateway of the Shopify Order Transaction.';
                    TableRelation = "Shpfy Transaction Gateway";
                }
            }
        }

        trigger OnOpenPage()
        var
            GenJnlTemplate: Record "Gen. Journal Template";
        begin
            if not IsGenJournalLineSet then begin
                GenJnlTemplate.SetRange("Page ID", Page::"Cash Receipt Journal");
                GenJnlTemplate.SetRange(Type, "Gen. Journal Template Type"::"Cash Receipts");
                if GenJnlTemplate.Count = 1 then begin
                    GenJnlTemplate.FindFirst();
                    GenJournalLine."Journal Template Name" := GenJnlTemplate.Name;
                    IsJournalTemplateFound := true;
                end;
            end;

            if PostingDate = 0D then
                PostingDate := WorkDate();
            ValidatePostingDate();
            EntryNo := 0;
        end;
    }

    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        TempSuggestPayment: Record "Shpfy Suggest Payment" temporary;
        EntryNo: Integer;
        PostingDate: Date;
        NextDocNo: Code[20];
        GeneralJournalTemplateName: Code[10];
        GeneralJournalBatchName: Code[10];
        DocNoPerLine: Boolean;
        IsGenJournalLineSet: Boolean;
        IgnorePostedTransactions: Boolean;
        IsJournalTemplateFound: Boolean;
        Gateway: Text[30];
        ShopifyTransactionLbl: Label 'Shopify order %1 %2 %3', Comment = '%1=Shopify Order No., %2=Shopify Gateway, %3=Shopify Gift Card Id';
        NoPostingDateErr: Label 'In the Posting Date field, specify the date that will be used as the posting date for the journal entries.';
        StartingDocumentNoErr: Label 'The value in the Starting Document No. field must have a number.';

    trigger OnPreReport()
    begin
        GeneralJournalTemplateName := GenJournalLine."Journal Template Name";
        GeneralJournalBatchName := GenJournalLine."Journal Batch Name";
    end;

    trigger OnPostReport()
    var
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        if not IsGenJournalLineSet then begin
            GenJournalBatch.Get(GeneralJournalTemplateName, GeneralJournalBatchName);
            GenJnlManagement.TemplateSelectionFromBatch(GenJournalBatch);
        end;
    end;

    internal procedure SetGenJournalLine(NewGenJournalLine: Record "Gen. Journal Line")
    begin
        IsGenJournalLineSet := true;
        GenJournalLine := NewGenJournalLine;
    end;

    internal procedure SetIgnorePostedTransactions(NewIgnorePostedTransactions: Boolean)
    begin
        IgnorePostedTransactions := NewIgnorePostedTransactions;
    end;

    local procedure ValidatePostingDate()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name") then
            if GenJournalBatch."No. Series" = '' then
                NextDocNo := ''
            else
                NextDocNo := NoSeries.PeekNextNo(GenJournalBatch."No. Series", PostingDate);
    end;

    internal procedure GetOrderTransactions(OrderTransaction: Record "Shpfy Order Transaction")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        RefundHeader: Record "Shpfy Refund Header";
        AmountToApply: Decimal;
        Applied: Boolean;
    begin
        AmountToApply := OrderTransaction.Amount;

        case OrderTransaction.Type of
            OrderTransaction.Type::Capture, OrderTransaction.Type::Sale:
                begin
                    SalesInvoiceHeader.SetLoadFields("No.", "Shpfy Order Id");
                    SalesInvoiceHeader.SetRange("Shpfy Order Id", OrderTransaction."Shopify Order Id");
                    if SalesInvoiceHeader.FindSet() then begin
                        repeat
                            CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
                            CustLedgerEntry.SetRange("Open", true);
                            CustLedgerEntry.SetRange("Applies-to ID", '');
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                            CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
                            if CustLedgerEntry.FindSet() then begin
                                Applied := true;
                                repeat
                                    CreateSuggestPaymentDocument(CustLedgerEntry, AmountToApply, true);
                                until CustLedgerEntry.Next() = 0;
                            end;
                        until SalesInvoiceHeader.Next() = 0;

                        if Applied and (AmountToApply > 0) then
                            CreateSuggestPaymentGLAccount(AmountToApply, true);
                    end;
                end;
            OrderTransaction.Type::Refund:
                begin
                    RefundHeader.SetLoadFields("Order Id", "Refund Id");
                    RefundHeader.SetRange("Order Id", OrderTransaction."Shopify Order Id");
                    if RefundHeader.FindSet() then begin
                        repeat
                            SalesCreditMemoHeader.SetLoadFields("Shpfy Refund Id", "No.");
                            SalesCreditMemoHeader.SetRange("Shpfy Refund Id", RefundHeader."Refund Id");
                            if SalesCreditMemoHeader.FindSet() then
                                repeat
                                    CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
                                    CustLedgerEntry.SetRange("Open", true);
                                    CustLedgerEntry.SetRange("Applies-to ID", '');
                                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                                    CustLedgerEntry.SetRange("Document No.", SalesCreditMemoHeader."No.");
                                    if CustLedgerEntry.FindSet() then begin
                                        Applied := true;
                                        repeat
                                            CreateSuggestPaymentDocument(CustLedgerEntry, AmountToApply, false);
                                        until CustLedgerEntry.Next() = 0;
                                    end;
                                until SalesCreditMemoHeader.Next() = 0;
                        until RefundHeader.Next() = 0;

                        if Applied and (AmountToApply > 0) then
                            CreateSuggestPaymentGLAccount(AmountToApply, false);
                    end;
                end;
        end;
    end;

    local procedure CreateSuggestPaymentDocument(var CustLedgerEntry: Record "Cust. Ledger Entry"; var AmountToApply: Decimal; IsInvoice: Boolean)
    begin
        TempSuggestPayment.Init();
        EntryNo += 1;
        TempSuggestPayment."Entry No." := EntryNo;
        TempSuggestPayment."Shop Code" := OrderTransaction."Shop Code";
        TempSuggestPayment."Shpfy Transaction Id" := OrderTransaction."Shopify Transaction Id";
        TempSuggestPayment."Customer Ledger Entry No." := CustLedgerEntry."Entry No.";
        TempSuggestPayment."Customer No." := CustLedgerEntry."Customer No.";

        if IsInvoice then begin
            TempSuggestPayment."Invoice No." := CustLedgerEntry."Document No.";
            if CustLedgerEntry."Remaining Amount" > AmountToApply then
                TempSuggestPayment.Amount := AmountToApply
            else
                TempSuggestPayment.Amount := CustLedgerEntry."Remaining Amount";
            AmountToApply -= TempSuggestPayment.Amount
        end else begin
            TempSuggestPayment."Credit Memo No." := CustLedgerEntry."Document No.";
            if CustLedgerEntry."Remaining Amount" < -AmountToApply then
                TempSuggestPayment.Amount := -AmountToApply
            else
                TempSuggestPayment.Amount := CustLedgerEntry."Remaining Amount";
            AmountToApply += TempSuggestPayment.Amount;
        end;

        TempSuggestPayment."Currency Code" := CustLedgerEntry."Currency Code";
        TempSuggestPayment.Gateway := OrderTransaction.Gateway;
        TempSuggestPayment."Cust. Ledger Entry Dim. Set Id" := CustLedgerEntry."Dimension Set ID";
        TempSuggestPayment."Shpfy Order Id" := OrderTransaction."Shopify Order Id";
        TempSuggestPayment."Shpfy Gift Card Id" := OrderTransaction."Gift Card Id";
        TempSuggestPayment."Payment Method Code" := OrderTransaction."Payment Method";
        TempSuggestPayment.Insert();
    end;

    local procedure CreateSuggestPaymentGLAccount(AmountToApply: Decimal; IsInvoice: Boolean)
    begin
        TempSuggestPayment.Init();
        EntryNo += 1;
        TempSuggestPayment."Entry No." := EntryNo;
        TempSuggestPayment."Shop Code" := OrderTransaction."Shop Code";
        TempSuggestPayment."Shpfy Transaction Id" := OrderTransaction."Shopify Transaction Id";
        if IsInvoice then
            TempSuggestPayment.Amount := AmountToApply
        else
            TempSuggestPayment.Amount := -AmountToApply;
        TempSuggestPayment.Gateway := OrderTransaction.Gateway;
        TempSuggestPayment."Shpfy Order Id" := OrderTransaction."Shopify Order Id";
        TempSuggestPayment."Shpfy Gift Card Id" := OrderTransaction."Gift Card Id";
        TempSuggestPayment."Payment Method Code" := OrderTransaction."Payment Method";
        TempSuggestPayment.Insert();
    end;

    internal procedure CreateGeneralJournalLines()
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
        LastLineNo: Integer;
    begin
        GenJournalLine.LockTable();
        GenJournalLine.SetRange("Journal Template Name", GeneralJournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", GeneralJournalBatchName);
        if GenJournalLine.FindLast() then
            LastLineNo := GenJournalLine."Line No.";

        TempSuggestPayment.SetAutoCalcFields("Shpfy Order No.");
        if TempSuggestPayment.FindSet() then
            repeat
                LastLineNo += 10000;
                GenJournalLine.Init();
                GenJournalLine."Journal Template Name" := GeneralJournalTemplateName;
                GenJournalLine."Journal Batch Name" := GeneralJournalBatchName;
                GenJournalLine."Line No." := LastLineNo;
                GenJournalLine.SetUpNewLine(GenJournalLine, GenJournalLine."Balance (LCY)", true);
                GenJournalLine.SetSuppressCommit(true);
                GenJournalLine."Document No." := NextDocNo;
                if TempSuggestPayment."Customer No." <> '' then begin
                    GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
                    GenJournalLine.Validate("Account No.", TempSuggestPayment."Customer No.");
                end else
                    GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
                GenJournalLine.Validate("Posting Date", PostingDate);
                SetGenJournalLineBalAccount(TempSuggestPayment."Payment Method Code");
                SetGenJournallLineDimension(TempSuggestPayment."Cust. Ledger Entry Dim. Set Id");
                if TempSuggestPayment."Shpfy Gift Card Id" <> 0 then
                    GenJournalLine.Description := CopyStr(
                        StrSubstNo(ShopifyTransactionLbl, TempSuggestPayment."Shpfy Order No.", TempSuggestPayment.Gateway, TempSuggestPayment."Shpfy Gift Card Id"), 1, MaxStrLen(GenJournalLine.Description))
                else
                    GenJournalLine.Description := CopyStr(
                        StrSubstNo(ShopifyTransactionLbl, TempSuggestPayment."Shpfy Order No.", TempSuggestPayment.Gateway, ''), 1, MaxStrLen(GenJournalLine.Description));
                GenJournalLine.Validate("Currency Code", TempSuggestPayment."Currency Code");
                GenJournalLine.Validate(Amount, -TempSuggestPayment.Amount);
                if TempSuggestPayment."Invoice No." <> '' then begin
                    GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
                    GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::Invoice;
                    GenJournalLine.Validate("Applies-to Doc. No.", TempSuggestPayment."Invoice No.");
                end;
                if TempSuggestPayment."Credit Memo No." <> '' then begin
                    GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Refund);
                    GenJournalLine."Applies-to Doc. Type" := GenJournalLine."Applies-to Doc. Type"::"Credit Memo";
                    GenJournalLine.Validate("Applies-to Doc. No.", TempSuggestPayment."Credit Memo No.");
                end;
                GenJournalLine."Shpfy Transaction Id" := TempSuggestPayment."Shpfy Transaction Id";
                GenJournalLine.SetSuppressCommit(false);
                GenJournalLine.Insert(true);

                if DocNoPerLine then
                    NextDocNo := NoSeriesBatch.SimulateGetNextNo(GenJournalBatch."No. Series", GenJournalLine."Posting Date", NextDocNo);
            until TempSuggestPayment.Next() = 0;
    end;

    local procedure SetGenJournallLineDimension(CustomerLedgerEntryDimensionSetId: Integer)
    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
    begin
        DimensionSetIDArr[1] := GenJournalLine."Dimension Set ID";
        DimensionSetIDArr[2] := CustomerLedgerEntryDimensionSetId;
        GenJournalLine."Dimension Set ID" := DimensionManagement.GetCombinedDimensionSetID(DimensionSetIDArr, GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code");
    end;

    local procedure SetGenJournalLineBalAccount(PaymentMethodCode: Code[10])
    var
        PaymentMethod: Record "Payment Method";
    begin
        if PaymentMethod.Get(PaymentMethodCode) then begin
            GenJournalLine.Validate("Payment Method Code", PaymentMethodCode);
            if PaymentMethod."Bal. Account No." <> '' then begin
                case PaymentMethod."Bal. Account Type" of
                    PaymentMethod."Bal. Account Type"::"Bank Account":
                        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
                    PaymentMethod."Bal. Account Type"::"G/L Account":
                        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
                end;
                GenJournalLine.Validate("Bal. Account No.", PaymentMethod."Bal. Account No.");
            end;
        end;
    end;

    internal procedure GetTempSuggestPayment(var SuggestPayment: Record "Shpfy Suggest Payment")
    begin
        if TempSuggestPayment.FindSet() then
            repeat
                SuggestPayment := TempSuggestPayment;
                SuggestPayment.Insert();
            until TempSuggestPayment.Next() = 0;
    end;
}