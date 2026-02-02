// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

report 10850 "Suggest Vend. Payments"
{
    Caption = 'Suggest Vendor Payments';
    Permissions = TableData "Vendor Ledger Entry" = rm;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Payment Method Code";

            trigger OnAfterGetRecord()
            begin
                if StopPayments then
                    CurrReport.Break();
                Window.Update(1, "No.");
                GetVendLedgEntries(true, false);
                GetVendLedgEntries(false, false);
                CheckAmounts(false);
            end;

            trigger OnPostDataItem()
            begin
                if UsePriority and not StopPayments then begin
                    Reset();
                    CopyFilters(Vend2);
                    SetCurrentKey(Priority);
                    SetRange(Priority, 0);
                    if Find('-') then
                        repeat
                            Window.Update(1, "No.");
                            GetVendLedgEntries(true, false);
                            GetVendLedgEntries(false, false);
                            CheckAmounts(false);
                        until (Next() = 0) or StopPayments;
                end;

                if UsePaymentDisc and not StopPayments then begin
                    Reset();
                    CopyFilters(Vend2);
                    Window.Open(Text007Lbl);
                    if Find('-') then
                        repeat
                            Window.Update(1, "No.");
                            TempPayableVendLedgEntry.SetRange("Vendor No.", "No.");
                            GetVendLedgEntries(true, true);
                            GetVendLedgEntries(false, true);
                            CheckAmounts(true);
                        until (Next() = 0) or StopPayments;
                end;

                GenPayLine.LockTable();
                GenPayLine.SetRange("No.", GenPayLine."No.");
                if GenPayLine.FindLast() then begin
                    LastLineNo := GenPayLine."Line No.";
                    GenPayLine.Init();
                end;

                Window.Open(Text008Lbl);

                TempPayableVendLedgEntry.Reset();
                TempPayableVendLedgEntry.SetRange(Priority, 1, 2147483647);
                MakeGenPayLines();
                TempPayableVendLedgEntry.Reset();
                TempPayableVendLedgEntry.SetRange(Priority, 0);
                MakeGenPayLines();
                TempPayableVendLedgEntry.Reset();
                TempPayableVendLedgEntry.DeleteAll();

                Window.Close();
                ShowMessage(MessageText);
            end;

            trigger OnPreDataItem()
            begin
                if LastDueDateToPayReq = 0D then
                    Error(Text000Lbl);
                if PostingDate = 0D then
                    Error(Text001Lbl);

                GenPayLineInserted := false;
                MessageText := '';

                if UsePaymentDisc and (LastDueDateToPayReq < WorkDate()) then
                    if not
                       Confirm(
                         Text003Lbl +
                         Text004Lbl, false,
                         WorkDate())
                    then
                        Error(Text005Lbl);

                Vend2.CopyFilters(Vendor);

                OriginalAmtAvailable := AmountAvailable;
                if UsePriority then begin
                    SetCurrentKey(Priority);
                    SetRange(Priority, 1, 2147483647);
                    UsePriority := true;
                end;
                Window.Open(Text006Lbl);

                NextEntryNo := 1;
            end;
        }
    }

    requestpage
    {
        SaveValues = false;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(LastPaymentDate; LastDueDateToPayReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Last Payment Date';
                        ToolTip = 'Specifies the latest payment date that can appear on the vendor ledger entries to include in the batch job. ';
                    }
                    field(UsePayment_Disc; UsePaymentDisc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Find Payment Discounts';
                        MultiLine = true;
                        ToolTip = 'Specifies whether to include vendor ledger entries for which you can receive a payment discount.';
                    }
                    field(Summarize_Per; SummarizePer)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Summarize per';
                        OptionCaption = ' ,Vendor,Due date';
                        ToolTip = 'Specifies how to summarize. Choose the Vendor option for one summarized line per vendor for open ledger entries. Choose the Due Date option for one summarized line per due date per vendor for open ledger entries. Choose the empty option if you want each open vendor ledger entry to result in an individual payment line.';
                    }
                    field(Use_Priority; UsePriority)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Vendor Priority';
                        ToolTip = 'Specifies whether to order suggested payments based on the priority that is specified for the vendor on the Vendor card.';

                        trigger OnValidate()
                        begin
                            if not UsePriority and (AmountAvailable <> 0) then
                                Error(Text011Lbl);
                        end;
                    }
                    field(AvailableAmountLCY; AmountAvailable)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Available Amount (LCY)';
                        AutoFormatType = 1;
                        AutoFormatExpression = VendLedgEntry."Currency Code";
                        ToolTip = 'Specifies a maximum amount available in local currency for payments. ';

                        trigger OnValidate()
                        begin
                            AmountAvailableOnAfterValidate();
                        end;
                    }
                    field(Currency_Filter; CurrencyFilter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Currency Filter';
                        Editable = false;
                        TableRelation = Currency;
                        ToolTip = 'Specifies the currencies to include in the transfer. To see the available currencies, choose the Filter field.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Vend2: Record Vendor;
        GenPayHead: Record "Payment Header FR";
        GenPayLine: Record "Payment Line FR";
        VendLedgEntry: Record "Vendor Ledger Entry";
        TempPayableVendLedgEntry: Record "Payable Vendor Ledger Entry" temporary;
        TempPaymentPostBuffer: Record "Payment Post. Buffer FR" temporary;
        TempOldTempPaymentPostBuffer: Record "Payment Post. Buffer FR" temporary;
        PaymentClass: Record "Payment Class FR";
        Window: Dialog;
        UsePaymentDisc: Boolean;
        PostingDate: Date;
        LastDueDateToPayReq: Date;
        NextDocNo: Code[20];
        AmountAvailable: Decimal;
        OriginalAmtAvailable: Decimal;
        UsePriority: Boolean;
        SummarizePer: Option " ",Vendor,"Due date";
        LastLineNo: Integer;
        NextEntryNo: Integer;
        StopPayments: Boolean;
        MessageText: Text;
        GenPayLineInserted: Boolean;
        CurrencyFilter: Code[10];
        Text000Lbl: Label 'Please enter the last payment date.';
        Text001Lbl: Label 'Please enter the posting date.';
        Text003Lbl: Label 'The selected last due date is earlier than %1.\\', Comment = '%1 = work date';
        Text004Lbl: Label 'Do you still want to run the batch job?';
        Text005Lbl: Label 'The batch job was interrupted.';
        Text006Lbl: Label 'Processing vendors     #1##########', Comment = '%1=';
        Text007Lbl: Label 'Processing vendors for payment discounts #1##########', Comment = '%1=';
        Text008Lbl: Label 'Inserting payment journal lines #1##########', Comment = '%1=';
        Text011Lbl: Label 'Use Vendor Priority must be activated when the value in the Amount Available field is not 0.';
        Text016Lbl: Label ' is already applied to %1 %2 for vendor %3.', Comment = '%1 = Document Type, %2 = No., %3 = No.';

    procedure SetGenPayLine(NewGenPayLine: Record "Payment Header FR")
    begin
        GenPayHead := NewGenPayLine;
        GenPayLine."No." := NewGenPayLine."No.";
        PaymentClass.Get(GenPayHead."Payment Class");
        PostingDate := GenPayHead."Posting Date";
        CurrencyFilter := GenPayHead."Currency Code";
    end;


    procedure GetVendLedgEntries(Positive: Boolean; Future: Boolean)
    begin
        VendLedgEntry.Reset();
        VendLedgEntry.SetCurrentKey("Vendor No.", Open, Positive, "Due Date");
        VendLedgEntry.SetRange("Vendor No.", Vendor."No.");
        VendLedgEntry.SetRange(Open, true);
        VendLedgEntry.SetRange(Positive, Positive);
        VendLedgEntry.SetRange("Currency Code", CurrencyFilter);
        VendLedgEntry.SetRange("Applies-to ID", '');
        if Future then begin
            VendLedgEntry.SetRange("Due Date", LastDueDateToPayReq + 1, 99991231D);
            VendLedgEntry.SetRange("Pmt. Discount Date", PostingDate, LastDueDateToPayReq);
            VendLedgEntry.SetFilter("Original Pmt. Disc. Possible", '<0');
        end else
            VendLedgEntry.SetRange("Due Date", 0D, LastDueDateToPayReq);
        VendLedgEntry.SetRange("On Hold", '');
        if VendLedgEntry.Find('-') then
            repeat
                SaveAmount();
            until VendLedgEntry.Next() = 0;
    end;

    local procedure SaveAmount()
    begin
        GenPayLine."Account Type" := GenPayLine."Account Type"::Vendor;
        GenPayLine.Validate("Account No.", VendLedgEntry."Vendor No.");
        GenPayLine."Posting Date" := VendLedgEntry."Posting Date";
        GenPayLine."Currency Factor" := VendLedgEntry."Adjusted Currency Factor";
        if GenPayLine."Currency Factor" = 0 then
            GenPayLine."Currency Factor" := 1;
        GenPayLine.Validate("Currency Code", VendLedgEntry."Currency Code");
        VendLedgEntry.CalcFields("Remaining Amount");
        if ((VendLedgEntry."Document Type" = VendLedgEntry."Document Type"::"Credit Memo") and
            (VendLedgEntry."Remaining Pmt. Disc. Possible" <> 0) or
            (VendLedgEntry."Document Type" = VendLedgEntry."Document Type"::Invoice)) and
           (PostingDate <= VendLedgEntry."Pmt. Discount Date")
        then
            GenPayLine.Amount := -(VendLedgEntry."Remaining Amount" - VendLedgEntry."Original Pmt. Disc. Possible")
        else
            GenPayLine.Amount := -VendLedgEntry."Remaining Amount";
        GenPayLine.Validate(Amount);

        if UsePriority then
            TempPayableVendLedgEntry.Priority := Vendor.Priority
        else
            TempPayableVendLedgEntry.Priority := 0;
        TempPayableVendLedgEntry."Vendor No." := VendLedgEntry."Vendor No.";
        TempPayableVendLedgEntry."Entry No." := NextEntryNo;
        TempPayableVendLedgEntry."Vendor Ledg. Entry No." := VendLedgEntry."Entry No.";
        TempPayableVendLedgEntry.Amount := GenPayLine.Amount;
        TempPayableVendLedgEntry."Amount (LCY)" := GenPayLine."Amount (LCY)";
        TempPayableVendLedgEntry.Positive := (TempPayableVendLedgEntry.Amount > 0);
        TempPayableVendLedgEntry.Future := (VendLedgEntry."Due Date" > LastDueDateToPayReq);
        TempPayableVendLedgEntry."Currency Code" := VendLedgEntry."Currency Code";
        TempPayableVendLedgEntry."Due Date" := VendLedgEntry."Due Date";
        TempPayableVendLedgEntry.Insert();
        NextEntryNo := NextEntryNo + 1;
    end;


    procedure CheckAmounts(Future: Boolean)
    var
        CurrencyBalance: Decimal;
        PrevCurrency: Code[10];
    begin
        CurrencyBalance := 0;
        TempPayableVendLedgEntry.SetRange("Vendor No.", Vendor."No.");
        TempPayableVendLedgEntry.SetRange(Future, Future);
        if TempPayableVendLedgEntry.Find('-') then begin
            PrevCurrency := TempPayableVendLedgEntry."Currency Code";
            repeat
                if TempPayableVendLedgEntry."Currency Code" <> PrevCurrency then begin
                    if CurrencyBalance < 0 then begin
                        TempPayableVendLedgEntry.SetRange("Currency Code", PrevCurrency);
                        TempPayableVendLedgEntry.DeleteAll();
                        TempPayableVendLedgEntry.SetRange("Currency Code");
                    end else
                        AmountAvailable := AmountAvailable - CurrencyBalance;
                    CurrencyBalance := 0;
                    PrevCurrency := TempPayableVendLedgEntry."Currency Code";
                end;
                if (OriginalAmtAvailable = 0) or
                   (AmountAvailable >= CurrencyBalance + TempPayableVendLedgEntry."Amount (LCY)")
                then
                    CurrencyBalance := CurrencyBalance + TempPayableVendLedgEntry."Amount (LCY)"
                else
                    TempPayableVendLedgEntry.Delete();
            until TempPayableVendLedgEntry.Next() = 0;
            if CurrencyBalance < 0 then begin
                TempPayableVendLedgEntry.SetRange("Currency Code", PrevCurrency);
                TempPayableVendLedgEntry.DeleteAll();
                TempPayableVendLedgEntry.SetRange("Currency Code");
            end else
                if OriginalAmtAvailable > 0 then
                    AmountAvailable := AmountAvailable - CurrencyBalance;
            if (OriginalAmtAvailable > 0) and (AmountAvailable <= 0) then
                StopPayments := true;
        end;
        TempPayableVendLedgEntry.Reset();
    end;

    local procedure InsertTempPaymentPostBuffer(var PaymentPostBufferTemp: Record "Payment Post. Buffer FR" temporary; var VendorLedgEntry: Record "Vendor Ledger Entry")
    begin
        PaymentPostBufferTemp."Applies-to Doc. Type" := VendorLedgEntry."Document Type";
        PaymentPostBufferTemp."Applies-to Doc. No." := VendorLedgEntry."Document No.";
        PaymentPostBufferTemp."Currency Factor" := VendorLedgEntry."Adjusted Currency Factor";
        PaymentPostBufferTemp.Amount := TempPayableVendLedgEntry.Amount;
        PaymentPostBufferTemp."Amount (LCY)" := TempPayableVendLedgEntry."Amount (LCY)";
        PaymentPostBufferTemp."Global Dimension 1 Code" := VendorLedgEntry."Global Dimension 1 Code";
        PaymentPostBufferTemp."Global Dimension 2 Code" := VendorLedgEntry."Global Dimension 2 Code";
        PaymentPostBufferTemp."Auxiliary Entry No." := VendorLedgEntry."Entry No.";
        PaymentPostBufferTemp.Insert();
    end;

    local procedure MakeGenPayLines()
    var
        GenPayLine3: Record "Gen. Journal Line";
        NoSeries: Codeunit "No. Series";
    begin
        TempPaymentPostBuffer.DeleteAll();

        if TempPayableVendLedgEntry.Find('-') then
            repeat
                TempPayableVendLedgEntry.SetRange("Vendor No.", TempPayableVendLedgEntry."Vendor No.");
                TempPayableVendLedgEntry.Find('-');
                repeat
                    VendLedgEntry.Get(TempPayableVendLedgEntry."Vendor Ledg. Entry No.");
                    TempPaymentPostBuffer."Account No." := VendLedgEntry."Vendor No.";
                    TempPaymentPostBuffer."Currency Code" := VendLedgEntry."Currency Code";
                    if SummarizePer = SummarizePer::"Due date" then
                        TempPaymentPostBuffer."Due Date" := VendLedgEntry."Due Date";

                    TempPaymentPostBuffer."Dimension Entry No." := 0;
                    TempPaymentPostBuffer."Global Dimension 1 Code" := '';
                    TempPaymentPostBuffer."Global Dimension 2 Code" := '';

                    if SummarizePer in [SummarizePer::Vendor, SummarizePer::"Due date"] then begin
                        TempPaymentPostBuffer."Auxiliary Entry No." := 0;
                        if TempPaymentPostBuffer.Find() then begin
                            TempPaymentPostBuffer.Amount := TempPaymentPostBuffer.Amount + TempPayableVendLedgEntry.Amount;
                            TempPaymentPostBuffer."Amount (LCY)" := TempPaymentPostBuffer."Amount (LCY)" + TempPayableVendLedgEntry."Amount (LCY)";
                            TempPaymentPostBuffer.Modify();
                        end else begin
                            LastLineNo := LastLineNo + 10000;
                            TempPaymentPostBuffer."Payment Line No." := LastLineNo;
                            if PaymentClass."Line No. Series" = '' then begin
                                NextDocNo := CopyStr(GenPayHead."No." + '/' + Format(LastLineNo), 1, MaxStrLen(NextDocNo));
                                TempPaymentPostBuffer."Applies-to ID" := NextDocNo;
                            end else begin
                                NextDocNo := NoSeries.GetNextNo(PaymentClass."Line No. Series", PostingDate);
                                TempPaymentPostBuffer."Applies-to ID" := GenPayHead."No." + '/' + NextDocNo;
                            end;
                            TempPaymentPostBuffer."Document No." := NextDocNo;
                            NextDocNo := IncStr(NextDocNo);
                            TempPaymentPostBuffer.Amount := TempPayableVendLedgEntry.Amount;
                            TempPaymentPostBuffer."Amount (LCY)" := TempPayableVendLedgEntry."Amount (LCY)";
                            Window.Update(1, VendLedgEntry."Vendor No.");
                            TempPaymentPostBuffer.Insert();
                        end;
                        VendLedgEntry."Applies-to ID" := TempPaymentPostBuffer."Applies-to ID";
                        CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);
                    end else begin
                        GenPayLine3.Reset();
                        GenPayLine3.SetCurrentKey(
                          "Account Type", "Account No.", "Applies-to Doc. Type", "Applies-to Doc. No.");
                        GenPayLine3.SetRange("Account Type", GenPayLine3."Account Type"::Vendor);
                        GenPayLine3.SetRange("Account No.", VendLedgEntry."Vendor No.");
                        GenPayLine3.SetRange("Applies-to Doc. Type", VendLedgEntry."Document Type");
                        GenPayLine3.SetRange("Applies-to Doc. No.", VendLedgEntry."Document No.");
                        if GenPayLine3.FindFirst() then
                            GenPayLine3.FieldError(
                              "Applies-to Doc. No.",
                              StrSubstNo(
                                Text016Lbl,
                                VendLedgEntry."Document Type", VendLedgEntry."Document No.",
                                VendLedgEntry."Vendor No."));
                        InsertTempPaymentPostBuffer(TempPaymentPostBuffer, VendLedgEntry);
                        Window.Update(1, VendLedgEntry."Vendor No.");
                    end;
                    VendLedgEntry.CalcFields("Remaining Amount");
                    VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
                    CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);
                until TempPayableVendLedgEntry.Next() = 0;
                TempPayableVendLedgEntry.SetFilter("Vendor No.", '>%1', TempPayableVendLedgEntry."Vendor No.");
            until not TempPayableVendLedgEntry.FindFirst();

        Clear(TempOldTempPaymentPostBuffer);
        TempPaymentPostBuffer.SetCurrentKey("Document No.");
        if TempPaymentPostBuffer.Find('-') then
            repeat
                GenPayLine.Init();
                Window.Update(1, TempPaymentPostBuffer."Account No.");
                if SummarizePer = SummarizePer::" " then begin
                    LastLineNo := LastLineNo + 10000;
                    GenPayLine."Line No." := LastLineNo;
                    if PaymentClass."Line No. Series" = '' then begin
                        NextDocNo := CopyStr(GenPayHead."No." + '/' + Format(GenPayLine."Line No."), 1, MaxStrLen(NextDocNo));
                        GenPayLine."Applies-to ID" := NextDocNo;
                    end else begin
                        NextDocNo := NoSeries.GetNextNo(PaymentClass."Line No. Series", PostingDate);
                        GenPayLine."Applies-to ID" := GenPayHead."No." + '/' + NextDocNo;
                    end;
                end else begin
                    GenPayLine."Line No." := TempPaymentPostBuffer."Payment Line No.";
                    NextDocNo := TempPaymentPostBuffer."Document No.";
                    GenPayLine."Applies-to ID" := TempPaymentPostBuffer."Applies-to ID";
                end;
                GenPayLine."Document No." := NextDocNo;
                TempOldTempPaymentPostBuffer := TempPaymentPostBuffer;
                TempOldTempPaymentPostBuffer."Document No." := GenPayLine."Document No.";
                if SummarizePer = SummarizePer::" " then begin
                    VendLedgEntry.Get(TempPaymentPostBuffer."Auxiliary Entry No.");
                    VendLedgEntry."Applies-to ID" := GenPayLine."Applies-to ID";
                    VendLedgEntry.Modify();
                end;
                GenPayLine."Account Type" := GenPayLine."Account Type"::Vendor;
                GenPayLine.Validate("Account No.", TempPaymentPostBuffer."Account No.");
                GenPayLine."Currency Code" := TempPaymentPostBuffer."Currency Code";
                GenPayLine."Currency Factor" := GenPayHead."Currency Factor";
                if GenPayLine."Currency Factor" = 0 then
                    GenPayLine."Currency Factor" := 1;
                GenPayLine.Validate(Amount, TempPaymentPostBuffer.Amount);
                Vend2.Get(GenPayLine."Account No.");
                GenPayLine.Validate("Bank Account Code", Vend2."Preferred Bank Account Code");
                GenPayLine."Payment Class" := GenPayHead."Payment Class";
                GenPayLine.Validate("Status No.");
                GenPayLine."Posting Date" := PostingDate;
                if SummarizePer = SummarizePer::" " then begin
                    GenPayLine."Applies-to Doc. Type" := VendLedgEntry."Document Type";
                    GenPayLine."Applies-to Doc. No." := VendLedgEntry."Document No.";
                    GenPayLine."Dimension Set ID" := VendLedgEntry."Dimension Set ID";
                end;
                case SummarizePer of
                    SummarizePer::" ":
                        GenPayLine."Due Date" := VendLedgEntry."Due Date";
                    SummarizePer::Vendor:
                        begin
                            if GenPayLine.Amount = 0 then
                                SetAppliesToIDBlank(VendLedgEntry, TempPayableVendLedgEntry, TempPaymentPostBuffer);
                            TempPayableVendLedgEntry.SetCurrentKey("Vendor No.", "Due Date");
                            TempPayableVendLedgEntry.SetRange("Vendor No.", TempPaymentPostBuffer."Account No.");
                            TempPayableVendLedgEntry.Find('-');
                            GenPayLine."Due Date" := TempPayableVendLedgEntry."Due Date";
                            TempPayableVendLedgEntry.DeleteAll();
                        end;
                    SummarizePer::"Due date":
                        GenPayLine."Due Date" := TempPaymentPostBuffer."Due Date";
                end;
                if GenPayLine.Amount <> 0 then begin
                    if GenPayLine."Dimension Set ID" = 0 then
                        // per "Customer", per "Due Date"
                        GenPayLine.DimensionSetup();
                    GenPayLine.Insert(true);
                end;
                GenPayLineInserted := true;
            until TempPaymentPostBuffer.Next() = 0;
    end;

    local procedure ShowMessage(Text: Text)
    begin
        if (Text <> '') and GenPayLineInserted then
            Message(Text);
    end;

    local procedure AmountAvailableOnAfterValidate()
    begin
        if AmountAvailable <> 0 then
            UsePriority := true;
    end;

    local procedure SetAppliesToIDBlank(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var TempPayableVendorLedgEntry: Record "Payable Vendor Ledger Entry" temporary; TempPmtPostBuffer: Record "Payment Post. Buffer FR" temporary)
    begin
        TempPayableVendorLedgEntry.SetRange("Vendor No.", TempPmtPostBuffer."Account No.");
        if TempPayableVendorLedgEntry.FindSet() then
            repeat
                VendorLedgerEntry.Get(TempPayableVendorLedgEntry."Vendor Ledg. Entry No.");
                VendorLedgerEntry."Applies-to ID" := '';
                VendorLedgerEntry.Modify();
            until TempPayableVendorLedgEntry.Next() = 0;
        TempPayableVendorLedgEntry.SetRange("Vendor No.");
    end;
}

