codeunit 20112 "AMC Bank Exp. CT Pre-Map"
{
    Permissions = TableData "Payment Export Data" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    begin
        FillExportBuffer("Entry No.");
    end;

    var
        ProgressMsg: Label 'Pre-processing line no. #1######.', Comment = '#1=Line number';
        WindowDialog: Dialog;

    local procedure FillExportBuffer(DataExchEntryNo: Integer)
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        PerBnkAccGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        PaymentExportData: Record "Payment Export Data";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        BankAccount: Record "Bank Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        Employee: Record Employee;
        MessageID: Text[20];
        LineNo: Integer;
        SpecLineNo: Integer;
        PrevBankAccount: Code[20];
    begin
        PrevBankAccount := '';
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();

        CreditTransferRegister.SetRange("Data Exch. Entry No.", DataExchEntryNo);
        CreditTransferRegister.FindLast();

        PerBnkAccGenJournalLine.SetCurrentKey("Data Exch. Entry No.", "Bal. Account No.");
        PerBnkAccGenJournalLine.SetRange("Data Exch. Entry No.", DataExchEntryNo);
        PerBnkAccGenJournalLine.SetRange("Data Exch. Entry No.", DataExchEntryNo);
        if (PerBnkAccGenJournalLine.FindSet()) then
            repeat
                if (PrevBankAccount <> PerBnkAccGenJournalLine."Bal. Account No.") then begin
                    PrevBankAccount := PerBnkAccGenJournalLine."Bal. Account No.";
                    GenJournalLine.SetRange("Data Exch. Entry No.", DataExchEntryNo);
                    GenJournalLine.SetRange("Bal. Account No.", PrevBankAccount);
                    with PaymentExportData do begin
                        GenJournalLine.FindSet();
                        GenJournalLine.TestField("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account".AsInteger());
                        BankAccount.Get(GenJournalLine."Bal. Account No.");
                        BankAccount.TestField("AMC Bank Name");
                        BankAccount.GetBankExportImportSetup(BankExportImportSetup);
                        MessageID := BankAccount.GetCreditTransferMessageNo();
                        WindowDialog.Open(ProgressMsg);

                        repeat
                            Clear(PaymentExportData);
                            Init();
                            SetPreserveNonLatinCharacters(BankExportImportSetup."Preserve Non-Latin Characters");
                            LineNo += 1;
                            "Line No." := LineNo;
                            "Data Exch Entry No." := DataExchEntryNo;
                            "Creditor No." := BankAccount."Creditor No.";
                            "Transit No." := BankAccount."Transit No.";
                            "General Journal Template" := GenJournalLine."Journal Template Name";
                            "General Journal Batch Name" := GenJournalLine."Journal Batch Name";
                            "General Journal Line No." := GenJournalLine."Line No.";

                            if (CreditTransferRegister."AMC Bank XTL Journal" <> '') then
                                "Importing Description" := CreditTransferRegister."AMC Bank XTL Journal"
                            else
                                "Importing Description" := '';

                            "Recipient ID" := GenJournalLine."Account No.";
                            "Message ID" := MessageID;
                            "Document No." := GenJournalLine."Document No.";
                            "End-to-End ID" := "Message ID" + 'L' + Format("Line No.") + 'US'; // Making uniq key we added US, because we want to use the same for Payment Information Id for later use.
                            "Payment Information ID" := "Message ID" + 'L' + FORMAT("Line No.") + 'TH'; // Making uniq key we added TH, because we want to use the same for End-to-end Id for later use.
                            "Applies-to Ext. Doc. No." := GenJournalLine."Applies-to Ext. Doc. No.";
                            "Short Advice" := GenJournalLine."Document No.";
                            "Recipient Creditor No." := GenJournalLine."Creditor No.";

                            "Invoice Amount" := ABS(GenJournalLine.Amount);
                            "Invoice Date" := GenJournalLine."Posting Date";

                            case GenJournalLine."Account Type" of
                                GenJournalLine."Account Type"::Customer:
                                    begin
                                        Customer.Get(GenJournalLine."Account No.");
                                        if CustomerBankAccount.Get(Customer."No.", GenJournalLine."Recipient Bank Account") then begin
                                            SetCustomerAsRecipient(Customer, CustomerBankAccount);
                                            PaymentExportData."AMC Recip. Bank Acc. Currency" := GeneralLedgerSetup.GetCurrencyCode(CustomerBankAccount."Currency Code");
                                        end;
                                        if CustLedgerEntry.Get(GenJournalLine.GetAppliesToDocEntryNo()) then begin
                                            CustLedgerEntry.CalcFields("Original Amount");
                                            "Invoice Amount" := Abs(CustLedgerEntry."Original Amount");
                                            "Invoice Date" := CustLedgerEntry."Document Date";
                                        end
                                    end;
                                GenJournalLine."Account Type"::Vendor:
                                    begin
                                        Vendor.Get(GenJournalLine."Account No.");
                                        if VendorBankAccount.Get(Vendor."No.", GenJournalLine."Recipient Bank Account") then begin
                                            SetVendorAsRecipient(Vendor, VendorBankAccount);
                                            PaymentExportData."AMC Recip. Bank Acc. Currency" := GeneralLedgerSetup.GetCurrencyCode(VendorBankAccount."Currency Code");
                                        end;
                                        if VendorLedgerEntry.Get(GenJournalLine.GetAppliesToDocEntryNo()) then begin
                                            VendorLedgerEntry.CalcFields("Original Amount");
                                            "Invoice Amount" := Abs(VendorLedgerEntry."Original Amount");
                                            "Invoice Date" := VendorLedgerEntry."Document Date";
                                        end
                                    end;
                                GenJournalLine."Account Type"::Employee:
                                    begin
                                        Employee.Get(GenJournalLine."Account No.");
                                        SetEmployeeAsRecipient(Employee);
                                        PaymentExportData."AMC Recip. Bank Acc. Currency" := GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code");
                                    end;
                            end;

                            GenJournalLine.TestField("Payment Method Code");
                            PaymentMethod.Get(GenJournalLine."Payment Method Code");
                            "Data Exch. Line Def Code" := PaymentMethod."Pmt. Export Line Definition";
                            "Payment Type" := PaymentMethod."AMC Bank Pmt. Type";
                            "Payment Reference" := GenJournalLine."Payment Reference";
                            "Message to Recipient 1" := CopyStr(GenJournalLine."Message to Recipient", 1, 35);
                            "Message to Recipient 2" := CopyStr(GenJournalLine."Message to Recipient", 36, 70);
                            Amount := GenJournalLine.Amount;
                            if (GenJournalLine."Currency Code" <> '') then // This is to handle BC users that by mistake has set CurrencyCode to the same as GeneralLedgerSetup."LCY Code"
                                "Currency Code" := GenJournalLine."Currency Code"
                            else
                                "Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code");

                            "Transfer Date" := GenJournalLine."Posting Date";
                            "Costs Distribution" := 'Shared';
                            "Message Structure" := 'auto';
                            "Own Address Info." := 'frombank';
                            SetBankAsSenderBank(BankAccount);
                            "Sender Bank Name - Data Conv." := BankAccount."AMC Bank Name"; // Moved here from above function SetBankAsSenderBank
                            "Sender Bank Country/Region" := CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code");
                            "Sender Bank Account Currency" := GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code");
                            "Importing Code" := 'FALSE'; //Never send chequeinfo in data export, only used for Positive Pay
                            SetIsoCodeValues(PaymentExportData);

                            OnBeforeInsertPaymentExoprtData(PaymentExportData, GenJournalLine, GeneralLedgerSetup);

                            Insert(true);
                            MakeBankSpecTrans(PaymentExportData, GenJournalLine, SpecLineNo); // Make banktransspec in Table 1206 for use in data export
                            WindowDialog.Update(1, LineNo);
                        until GenJournalLine.Next() = 0;
                    end;
                end;
            until PerBnkAccGenJournalLine.Next() = 0;


        WindowDialog.Close();
    end;

    local procedure MakeBankSpecTrans(PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; VAR SpecLineNo: Integer)
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        CreditTransferEntry: Record "Credit Transfer Entry";
        TempCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary;
    begin
        CreditTransferRegister.SETRANGE("Data Exch. Entry No.", GenJournalLine."Data Exch. Entry No.");
        CreditTransferRegister.FindLast();
        if (GenJournalLine.IsApplied()) then begin
            GetCVLedgerEntry(GenJournalLine, TempCVLedgerEntryBuffer);
            if (TempCVLedgerEntryBuffer.FindSet()) then
                repeat
                    SpecLineNo += 1;
                    CreditTransferEntry.CreateNew(CreditTransferRegister."No.", SpecLineNo,
                        GenJournalLine."Account Type", GenJournalLine."Account No.", TempCVLedgerEntryBuffer."Entry No.",
                        GenJournalLine."Posting Date", GenJournalLine."Currency Code", TempCVLedgerEntryBuffer."Amount to Apply", CopyStr(PaymentExportData."Payment Information ID", 1, 35),
                        GenJournalLine."Recipient Bank Account", TempCVLedgerEntryBuffer."External Document No."); //V17.5

                    //Update CreditTransferEntry with Data Exch. Entry No. and any discount for banktransspec
                    CreditTransferEntry.SetRange("Credit Transfer Register No.", CreditTransferRegister."No.");
                    CreditTransferEntry.SetRange("Applies-to Entry No.", TempCVLedgerEntryBuffer."Entry No.");
                    CreditTransferEntry.SetRange("Transaction ID", PaymentExportData."Payment Information ID");
                    if (CreditTransferEntry.FindFirst()) then begin
                        CreditTransferEntry."Data Exch. Entry No." := GenJournalLine."Data Exch. Entry No.";
                        CreditTransferEntry."Pmt. Disc. Possible" := TempCVLedgerEntryBuffer."Remaining Pmt. Disc. Possible";
                        CreditTransferEntry.Modify();
                        OnAfterMakeBankSpecTrans(PaymentExportData, GenJournalLine, SpecLineNo, CreditTransferRegister, CreditTransferEntry, TempCVLedgerEntryBuffer);
                    end;
                    TempCVLedgerEntryBuffer.Delete(false);
                until TempCVLedgerEntryBuffer.Next() = 0;
        end
        else begin //Only one banktransspec
            SpecLineNo += 1;
            CreditTransferEntry.CreateNew(CreditTransferRegister."No.", SpecLineNo,
                GenJournalLine."Account Type", GenJournalLine."Account No.", GenJournalLine.GetAppliesToDocEntryNo(),
                GenJournalLine."Posting Date", GenJournalLine."Currency Code", GenJournalLine.Amount, CopyStr(PaymentExportData."Payment Information ID", 1, 35),
                GenJournalLine."Recipient Bank Account", GenJournalLine."Message to Recipient");

            //Update CreditTransferEntry with Data Exch. Entry No. and any discount for banktransspec
            CreditTransferEntry.SetRange("Credit Transfer Register No.", CreditTransferRegister."No.");
            CreditTransferEntry.SetRange("Applies-to Entry No.", GenJournalLine.GetAppliesToDocEntryNo());
            CreditTransferEntry.SetRange("Transaction ID", PaymentExportData."Payment Information ID");
            if (CreditTransferEntry.FindFirst()) then begin
                CreditTransferEntry."Data Exch. Entry No." := GenJournalLine."Data Exch. Entry No.";
                CreditTransferEntry."Pmt. Disc. Possible" := 0;
                CreditTransferEntry.Modify();
                OnAfterMakeBankSpecTrans(PaymentExportData, GenJournalLine, SpecLineNo, CreditTransferRegister, CreditTransferEntry, TempCVLedgerEntryBuffer);
            end;
        end;
    end;

    local procedure GetCVLedgerEntry(GenJournalLine: Record "Gen. Journal Line"; var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
    begin

        Clear(CVLedgerEntryBuffer);
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) then begin
            VendorLedgerEntry.SETRANGE("Vendor No.", GenJournalLine."Account No.");
            VendorLedgerEntry.SetRange(Open, true);
            if GenJournalLine."Applies-to Doc. No." <> '' then begin
                VendorLedgerEntry.SETRANGE("Document Type", GenJournalLine."Applies-to Doc. Type");
                VendorLedgerEntry.SETRANGE("Document No.", GenJournalLine."Applies-to Doc. No.");
            end else
                if GenJournalLine."Applies-to ID" <> '' then
                    VendorLedgerEntry.SETRANGE("Applies-to ID", GenJournalLine."Applies-to ID");

            VendorLedgerEntry.SetAutoCalcFields("Remaining Amount");
            if VendorLedgerEntry.FindSet() then
                REPEAT
                    CVLedgerEntryBuffer.CopyFromVendLedgEntry(VendorLedgerEntry);
                    CVLedgerEntryBuffer."Amount to Apply" := -(VendorLedgerEntry."Amount to Apply");
                    if PaymentToleranceManagement.CheckCalcPmtDiscGenJnlVend(GenJournalLine, VendorLedgerEntry, 0, false) then begin
                        CVLedgerEntryBuffer."Remaining Amount" := -(VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."Remaining Pmt. Disc. Possible");
                        CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := -(VendorLedgerEntry."Remaining Pmt. Disc. Possible");
                        if ((VendorLedgerEntry."Remaining Amount" - VendorLedgerEntry."Remaining Pmt. Disc. Possible") >= VendorLedgerEntry."Amount to Apply") then
                            CVLedgerEntryBuffer."Amount to Apply" := -(VendorLedgerEntry."Amount to Apply" - VendorLedgerEntry."Remaining Pmt. Disc. Possible");
                    end
                    else begin
                        CVLedgerEntryBuffer."Remaining Amount" := -VendorLedgerEntry."Remaining Amount";
                        CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := 0;
                    end;
                    CVLedgerEntryBuffer.Insert(false);
                until VendorLedgerEntry.Next() = 0;
        end
        else
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) then begin
                CustLedgerEntry.SETRANGE("Customer No.", GenJournalLine."Account No.");
                CustLedgerEntry.SetRange(Open, true);
                if GenJournalLine."Applies-to Doc. No." <> '' then begin
                    CustLedgerEntry.SETRANGE("Document Type", GenJournalLine."Applies-to Doc. Type");
                    CustLedgerEntry.SETRANGE("Document No.", GenJournalLine."Applies-to Doc. No.");
                end else
                    if GenJournalLine."Applies-to ID" <> '' then
                        CustLedgerEntry.SETRANGE("Applies-to ID", GenJournalLine."Applies-to ID");

                CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
                if CustLedgerEntry.FindSet() then
                    REPEAT
                        CustLedgerEntry.CalcFields("Remaining Amount");
                        CVLedgerEntryBuffer.CopyFromCustLedgEntry(CustLedgerEntry);
                        CVLedgerEntryBuffer."Amount to Apply" := -(CustLedgerEntry."Amount to Apply");
                        if PaymentToleranceManagement.CheckCalcPmtDiscGenJnlCust(GenJournalLine, CustLedgerEntry, 0, false) then begin
                            CVLedgerEntryBuffer."Remaining Amount" := -(CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Remaining Pmt. Disc. Possible");
                            CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := -(CustLedgerEntry."Remaining Pmt. Disc. Possible")
                        end
                        else begin
                            CVLedgerEntryBuffer."Remaining Amount" := -CustLedgerEntry."Remaining Amount";
                            CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := 0;
                        end;
                        CVLedgerEntryBuffer.Insert(false);
                    until CustLedgerEntry.Next() = 0;
            end
            else
                if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) then begin
                    EmployeeLedgerEntry.SetRange("Employee No.", GenJournalLine."Account No.");
                    EmployeeLedgerEntry.SetRange(Open, true);
                    if EmployeeLedgerEntry."Applies-to Doc. No." <> '' then begin
                        EmployeeLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
                        EmployeeLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
                    end else
                        if EmployeeLedgerEntry."Applies-to ID" <> '' then
                            EmployeeLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");

                    EmployeeLedgerEntry.SetAutoCalcFields("Remaining Amount");
                    if EmployeeLedgerEntry.findSet() then;
                    repeat
                        EmployeeLedgerEntry.CalcFields("Remaining Amount");
                        CVLedgerEntryBuffer.CopyFromEmplLedgEntry(EmployeeLedgerEntry);
                        CVLedgerEntryBuffer."Amount to Apply" := -(EmployeeLedgerEntry."Amount to Apply");
                        CVLedgerEntryBuffer."Remaining Amount" := -EmployeeLedgerEntry."Remaining Amount";
                        CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := 0;
                        CVLedgerEntryBuffer.Insert(false);
                    until EmployeeLedgerEntry.Next() = 0;
                end;
    end;

    //Always use Isocode as value for Country/Region and Currency
    local procedure SetIsoCodeValues(var PaymentExportData: Record "Payment Export Data")
    var
        Currency: Record Currency;
        CountryRegion: Record "Country/Region";
    begin

        Clear(Currency);
        if (PaymentExportData."Currency Code" <> '') then
            if (Currency.get(PaymentExportData."Currency Code")) then
                PaymentExportData."Currency Code" := Currency."ISO Code";

        Clear(Currency);
        if (PaymentExportData."Sender Bank Account Currency" <> '') then
            if (Currency.get(PaymentExportData."Sender Bank Account Currency")) then
                PaymentExportData."Sender Bank Account Currency" := Currency."ISO Code";

        Clear(Currency);
        if (PaymentExportData."AMC Recip. Bank Acc. Currency" <> '') then
            if (Currency.get(PaymentExportData."AMC Recip. Bank Acc. Currency")) then
                PaymentExportData."Sender Bank Account Currency" := Currency."ISO Code";


        Clear(CountryRegion);
        if (PaymentExportData."Sender Bank Country/Region" <> '') then
            if (CountryRegion.Get(PaymentExportData."Sender Bank Country/Region")) then
                PaymentExportData."Sender Bank Country/Region" := CountryRegion."ISO Code";

        Clear(CountryRegion);
        if (PaymentExportData."Recipient Country/Region Code" <> '') then
            if (CountryRegion.Get(PaymentExportData."Recipient Country/Region Code")) then
                PaymentExportData."Recipient Country/Region Code" := CountryRegion."ISO Code";

        Clear(CountryRegion);
        if (PaymentExportData."Recipient Bank Country/Region" <> '') then
            if (CountryRegion.Get(PaymentExportData."Recipient Bank Country/Region")) then
                PaymentExportData."Recipient Bank Country/Region" := CountryRegion."ISO Code";
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPaymentExoprtData(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterMakeBankSpecTrans(PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; SpecLineNo: Integer; CreditTransferRegister: Record "Credit Transfer Register"; VAR CreditTransferEntry: Record "Credit Transfer Entry"; CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary)
    begin
    end;
}

