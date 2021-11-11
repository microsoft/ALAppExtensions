codeunit 18689 "TDS Entry Update Mgt."
{
    SingleInstance = true;

    var
        TempTDSEntry: Record "TDS Entry" temporary;
        TempInteger: Record Integer temporary;
        IsSuggestVendorPayment: Boolean;
        VendorLedgerEntryNo: Integer;
        TransactionNo: Integer;
        AppliedAmount: Decimal;

    procedure SetTDSEntryForUpdate(TDSEntryToUpdate: Record "TDS Entry")
    begin
        TempTDSEntry := TDSEntryToUpdate;
    end;

    procedure IsTDSEntryUpdateStarted(EntryNo: Integer): Boolean
    begin
        if TempTDSEntry."Entry No." = EntryNo then
            exit(true);
    end;

    procedure GetTDSEntryToUpdateInitialInvoiceAmount(EntryNo: Integer): Decimal
    begin
        if TempTDSEntry."Entry No." = EntryNo then
            exit(TempTDSEntry."Invoice Amount");
    end;

    procedure GetTempTDSEntry(var TDSEntry: Record "TDS Entry")
    begin
        TDSEntry := TempTDSEntry;
    end;

    procedure ResetTempTDSEntry()
    begin
        TempTDSEntry.Reset();
        TempTDSEntry.DeleteAll();
    end;

    procedure SetSuggetVendorPayment()
    begin
        IsSuggestVendorPayment := true;
    end;

    procedure GetSuggetVendorPayment(var VenodrPayment: Boolean)
    begin
        VenodrPayment := IsSuggestVendorPayment;
    end;

    procedure ClearVendorPayment()
    begin
        Clear(IsSuggestVendorPayment);
    end;

    procedure SetVendLedgerEntryNo(VendLedgerEntryNo: Integer; TransNo: Integer)
    begin
        VendorLedgerEntryNo := VendLedgerEntryNo;
        TransactionNo := TransNo;
        AppliedAmount := 0;
        TempInteger.Reset();
        TempInteger.DeleteAll();
    end;

    procedure GetVendLedgerEntryNo(var VendLedgerEntryNo: Integer; var TransNo: Integer)
    begin
        VendLedgerEntryNo := VendorLedgerEntryNo;
        TransNo := TransactionNo;
    end;

    procedure SetAppliedAmount(DetailedVendorLedgeEntry: Record "Detailed Vendor Ledg. Entry")
    begin
        if TempInteger.Get(DetailedVendorLedgeEntry."Entry No.") then
            exit;

        TempInteger.Init();
        TempInteger.Number := DetailedVendorLedgeEntry."Entry No.";
        TempInteger.Insert();
        AppliedAmount += DetailedVendorLedgeEntry.Amount;
    end;

    procedure GetAppliedAmount(var TransNo: Integer; var ApplAmt: Decimal)
    begin
        TransNo := TransactionNo;
        ApplAmt := AppliedAmount;
    end;
}