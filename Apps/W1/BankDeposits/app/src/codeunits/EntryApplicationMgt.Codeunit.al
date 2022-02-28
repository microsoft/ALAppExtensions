codeunit 1696 "Entry Application Mgt"
{

    trigger OnRun()
    begin
    end;

    [Scope('OnPrem')]
    procedure GetAppliedCustEntries(var AppliedCustLedgerEntry: Record "Cust. Ledger Entry" temporary; CustLedgerEntry: Record "Cust. Ledger Entry"; UseLCY: Boolean)
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        PmtDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        PmtCustLedgerEntry: Record "Cust. Ledger Entry";
        ClosingCustLedgerEntry: Record "Cust. Ledger Entry";
        AmountToApply: Decimal;
    begin
        // Temporary Table, AppliedCustLedgerEntry, to be filled in with everything that CustLedgerEntry applied to.
        // Note that within AppliedCustLedgerEntry, the "Amount to Apply" field will be filled in with the Amount Applied.
        // IF UseLCY is TRUE, Amount Applied will be in LCY, else it will be in the application currency
        AppliedCustLedgerEntry.Reset();
        AppliedCustLedgerEntry.DeleteAll();

        DetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.");
        DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
        DetailedCustLedgEntry.SetRange(Unapplied, false);
        if DetailedCustLedgEntry.Find('-') then
            repeat
                PmtDetailedCustLedgEntry.SetFilter("Cust. Ledger Entry No.", '<>%1', CustLedgerEntry."Entry No.");
                PmtDetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
                PmtDetailedCustLedgEntry.SetRange("Transaction No.", DetailedCustLedgEntry."Transaction No.");
                PmtDetailedCustLedgEntry.SetRange("Application No.", DetailedCustLedgEntry."Application No.");
                PmtDetailedCustLedgEntry.SetRange("Customer No.", DetailedCustLedgEntry."Customer No.");
                OnGetAppliedCustEntriesOnAfterFilterPmtDetailedCustLedgEntry(DetailedCustLedgEntry, PmtDetailedCustLedgEntry);
                PmtDetailedCustLedgEntry.FindSet();
                repeat
                    if UseLCY then
                        AmountToApply := -PmtDetailedCustLedgEntry."Amount (LCY)"
                    else
                        AmountToApply := -PmtDetailedCustLedgEntry.Amount;
                    PmtCustLedgerEntry.Get(PmtDetailedCustLedgEntry."Cust. Ledger Entry No.");
                    AppliedCustLedgerEntry := PmtCustLedgerEntry;
                    if AppliedCustLedgerEntry.Find() then begin
                        AppliedCustLedgerEntry."Amount to Apply" += AmountToApply;
                        AppliedCustLedgerEntry.Modify();
                    end else begin
                        AppliedCustLedgerEntry := PmtCustLedgerEntry;
                        AppliedCustLedgerEntry."Amount to Apply" := AmountToApply;
                        if CustLedgerEntry."Closed by Entry No." <> 0 then begin
                            ClosingCustLedgerEntry.Get(PmtDetailedCustLedgEntry."Cust. Ledger Entry No.");
                            if ClosingCustLedgerEntry."Closed by Entry No." <> AppliedCustLedgerEntry."Entry No." then
                                AppliedCustLedgerEntry."Pmt. Disc. Given (LCY)" := 0;
                        end;
                        AppliedCustLedgerEntry.Insert();
                    end;
                until PmtDetailedCustLedgEntry.Next() = 0;
            until DetailedCustLedgEntry.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure GetAppliedVendEntries(var AppliedVendorLedgerEntry: Record "Vendor Ledger Entry" temporary; VendorLedgerEntry: Record "Vendor Ledger Entry"; UseLCY: Boolean)
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        PmtDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        PmtVendorLedgerEntry: Record "Vendor Ledger Entry";
        ClosingVendorLedgerEntry: Record "Vendor Ledger Entry";
        AmountToApply: Decimal;
        PaymentDiscount: Decimal;
        IsHandled: Boolean;
    begin
        // Temporary Table, AppliedVendorLedgerEntry, to be filled in with everything that VendorLedgerEntry applied to.
        // Note that within AppliedVendorLedgerEntry, the "Amount to Apply" field will be filled in with the Amount Applied.
        // IF UseLCY is TRUE, Amount Applied will be in LCY, else it will be in the application currency
        AppliedVendorLedgerEntry.Reset();
        AppliedVendorLedgerEntry.DeleteAll();

        DetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.");
        DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
        DetailedVendorLedgEntry.SetRange(Unapplied, false);
        if DetailedVendorLedgEntry.Find('-') then
            repeat
                PmtDetailedVendorLedgEntry.SetFilter("Vendor Ledger Entry No.", '<>%1', VendorLedgerEntry."Entry No.");
                PmtDetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
                PmtDetailedVendorLedgEntry.SetRange("Transaction No.", DetailedVendorLedgEntry."Transaction No.");
                PmtDetailedVendorLedgEntry.SetRange("Application No.", DetailedVendorLedgEntry."Application No.");
                PmtDetailedVendorLedgEntry.SetRange("Vendor No.", DetailedVendorLedgEntry."Vendor No.");
                PmtDetailedVendorLedgEntry.FindSet();
                repeat
                    IsHandled := false;
                    OnGetAppliedVendEntriesOnBeforePrepareAppliedVendorLedgerEntry(AppliedVendorLedgerEntry, VendorLedgerEntry, UseLCY, PmtDetailedVendorLedgEntry, IsHandled);
                    if not IsHandled then begin
                        PaymentDiscount := 0;
                        if PmtDetailedVendorLedgEntry."Posting Date" <= PmtDetailedVendorLedgEntry."Initial Entry Due Date" then
                            PaymentDiscount := PmtDetailedVendorLedgEntry."Remaining Pmt. Disc. Possible";
                        if UseLCY then
                            AmountToApply := -PmtDetailedVendorLedgEntry."Amount (LCY)" - PaymentDiscount
                        else
                            AmountToApply := -PmtDetailedVendorLedgEntry.Amount - PaymentDiscount;
                        PmtVendorLedgerEntry.Get(PmtDetailedVendorLedgEntry."Vendor Ledger Entry No.");
                        AppliedVendorLedgerEntry := PmtVendorLedgerEntry;
                        if AppliedVendorLedgerEntry.Find() then begin
                            AppliedVendorLedgerEntry."Amount to Apply" += AmountToApply;
                            AppliedVendorLedgerEntry.Modify();
                        end else begin
                            AppliedVendorLedgerEntry := PmtVendorLedgerEntry;
                            AppliedVendorLedgerEntry."Amount to Apply" := AmountToApply;
                            if VendorLedgerEntry."Closed by Entry No." <> 0 then begin
                                ClosingVendorLedgerEntry.Get(PmtDetailedVendorLedgEntry."Vendor Ledger Entry No.");
                                if ClosingVendorLedgerEntry."Closed by Entry No." <> AppliedVendorLedgerEntry."Entry No." then
                                    AppliedVendorLedgerEntry."Pmt. Disc. Rcd.(LCY)" := 0;
                            end;
                            AppliedVendorLedgerEntry.Insert();
                        end;
                    end;
                until PmtDetailedVendorLedgEntry.Next() = 0;
            until DetailedVendorLedgEntry.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAppliedCustEntriesOnAfterFilterPmtDetailedCustLedgEntry(DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var PmtDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAppliedVendEntriesOnBeforePrepareAppliedVendorLedgerEntry(var AppliedVendorLedgerEntry: Record "Vendor Ledger Entry" temporary; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var UseLCY: Boolean; var PmtDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var IsHandled: Boolean)
    begin
    end;
}

