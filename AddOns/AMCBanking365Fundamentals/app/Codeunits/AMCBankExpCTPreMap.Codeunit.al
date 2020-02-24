codeunit 20112 "AMC Bank Exp. CT Pre-Map"
{
    Permissions = TableData "Payment Export Data" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    begin
        FillExportBuffer("Entry No.");
    end;

    var
        ProgressMsg: Label 'Pre-processing line no. #1######.';
        Window: Dialog;

    local procedure FillExportBuffer(DataExchEntryNo: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
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
    begin
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();

        GenJnlLine.SetRange("Data Exch. Entry No.", DataExchEntryNo);
        with PaymentExportData do begin
            GenJnlLine.FindSet();
            GenJnlLine.TestField("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
            BankAccount.Get(GenJnlLine."Bal. Account No.");
            BankAccount.TestField("AMC Bank Name");
            BankAccount.GetBankExportImportSetup(BankExportImportSetup);
            MessageID := BankAccount.GetCreditTransferMessageNo();
            Window.Open(ProgressMsg);

            repeat
                Clear(PaymentExportData);
                Init();
                SetPreserveNonLatinCharacters(BankExportImportSetup."Preserve Non-Latin Characters");
                LineNo += 1;
                "Line No." := LineNo;
                "Data Exch Entry No." := DataExchEntryNo;
                "Creditor No." := BankAccount."Creditor No.";
                "Transit No." := BankAccount."Transit No.";
                "General Journal Template" := GenJnlLine."Journal Template Name";
                "General Journal Batch Name" := GenJnlLine."Journal Batch Name";
                "General Journal Line No." := GenJnlLine."Line No.";
                "Recipient ID" := GenJnlLine."Account No.";
                "Message ID" := MessageID;
                "Document No." := GenJnlLine."Document No.";
                "End-to-End ID" := "Message ID" + '/' + Format("Line No.") + 'US'; // Making uniq key we added US, because we want to use the same for Payment Information Id for later use.
                "Payment Information ID" := "Message ID" + '/' + FORMAT("Line No.") + 'TH'; // Making uniq key we added TH, because we want to use the same for End-to-end Id for later use.
                "Applies-to Ext. Doc. No." := GenJnlLine."Applies-to Ext. Doc. No.";
                "Short Advice" := GenJnlLine."Document No.";
                "Recipient Creditor No." := GenJnlLine."Creditor No.";

                "Invoice Amount" := ABS(GenJnlLine.Amount);
                "Invoice Date" := GenJnlLine."Posting Date";

                case GenJnlLine."Account Type" of
                    GenJnlLine."Account Type"::Customer:
                        begin
                            Customer.Get(GenJnlLine."Account No.");
                            if CustomerBankAccount.Get(Customer."No.", GenJnlLine."Recipient Bank Account") then
                                SetCustomerAsRecipient(Customer, CustomerBankAccount);
                            if CustLedgEntry.Get(GenJnlLine.GetAppliesToDocEntryNo()) then begin
                                CustLedgEntry.CalcFields("Original Amount");
                                "Invoice Amount" := Abs(CustLedgEntry."Original Amount");
                                "Invoice Date" := CustLedgEntry."Document Date";
                            end
                        end;
                    GenJnlLine."Account Type"::Vendor:
                        begin
                            Vendor.Get(GenJnlLine."Account No.");
                            if VendorBankAccount.Get(Vendor."No.", GenJnlLine."Recipient Bank Account") then
                                SetVendorAsRecipient(Vendor, VendorBankAccount);
                            if VendLedgEntry.Get(GenJnlLine.GetAppliesToDocEntryNo()) then begin
                                VendLedgEntry.CalcFields("Original Amount");
                                "Invoice Amount" := Abs(VendLedgEntry."Original Amount");
                                "Invoice Date" := VendLedgEntry."Document Date";
                            end
                        end;
                    GenJnlLine."Account Type"::Employee:
                        begin
                            Employee.Get(GenJnlLine."Account No.");
                            SetEmployeeAsRecipient(Employee);
                        end;
                end;

                GenJnlLine.TestField("Payment Method Code");
                PaymentMethod.Get(GenJnlLine."Payment Method Code");
                "Data Exch. Line Def Code" := PaymentMethod."Pmt. Export Line Definition";
                "Payment Type" := PaymentMethod."AMC Bank Pmt. Type";
                "Payment Reference" := GenJnlLine."Payment Reference";
                "Message to Recipient 1" := CopyStr(GenJnlLine."Message to Recipient", 1, 35);
                "Message to Recipient 2" := CopyStr(GenJnlLine."Message to Recipient", 36, 70);
                Amount := GenJnlLine.Amount;
                if (GenJnlLine."Currency Code" <> '') then // This is to handle BC users that by mistake has set CurrencyCode to the same as GeneralLedgerSetup."LCY Code"
                    "Currency Code" := GenJnlLine."Currency Code"
                else
                    "Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJnlLine."Currency Code");

                "Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJnlLine."Currency Code");
                "Transfer Date" := GenJnlLine."Posting Date";
                "Costs Distribution" := 'Shared';
                "Message Structure" := 'auto';
                "Own Address Info." := 'frombank';
                SetBankAsSenderBank(BankAccount);
                "Sender Bank Name - Data Conv." := BankAccount."AMC Bank Name"; // Moved here from above function SetBankAsSenderBank
                "Sender Bank Country/Region" := CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code");
                "Sender Bank Account Currency" := GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code");
                "Importing Code" := 'FALSE'; //Never send chequeinfo in XMLPORT 20100, only used for Positive Pay

                OnBeforeInsertPaymentExoprtData(PaymentExportData, GenJnlLine, GeneralLedgerSetup);

                Insert(true);
                MakeBankSpecTrans(PaymentExportData, GenJnlLine, SpecLineNo); // Make banktransspec in Table 1206 for use in XMLPORT 51232
                Window.Update(1, LineNo);
            until GenJnlLine.Next() = 0;
        end;

        Window.Close();
    end;

    local procedure MakeBankSpecTrans(PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; VAR SpecLineNo: Integer)
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        CreditTransferEntry: Record "Credit Transfer Entry";
        CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary;
    begin
        // Make banktransspec in Table 1206 for use in XMLPORT 20100
        CreditTransferRegister.SETRANGE("From Bank Account No.", GenJournalLine."Bal. Account No.");
        CreditTransferRegister.FindLast();
        if (GenJournalLine.IsApplied()) then begin
            GetCVLedgerEntry(GenJournalLine, CVLedgerEntryBuffer);
            if (CVLedgerEntryBuffer.FindSet()) then
                repeat
                    SpecLineNo += 1;
                    CreditTransferEntry.CreateNew(CreditTransferRegister."No.", SpecLineNo,
                        GenJournalLine."Account Type", GenJournalLine."Account No.", CVLedgerEntryBuffer."Entry No.",
                        GenJournalLine."Posting Date", GenJournalLine."Currency Code", CVLedgerEntryBuffer."Remaining Amount", PaymentExportData."Payment Information ID",
                        GenJournalLine."Recipient Bank Account", CVLedgerEntryBuffer."External Document No.");

                    //Update CreditTransferEntry with Data Exch. Entry No. and any discount for banktransspec
                    CreditTransferEntry.SetRange("Credit Transfer Register No.", CreditTransferRegister."No.");
                    CreditTransferEntry.SetRange("Applies-to Entry No.", CVLedgerEntryBuffer."Entry No.");
                    CreditTransferEntry.SetRange("Transaction ID", PaymentExportData."Payment Information ID");
                    if (CreditTransferEntry.FindFirst()) then begin
                        CreditTransferEntry."Data Exch. Entry No." := GenJournalLine."Data Exch. Entry No.";
                        CreditTransferEntry."Pmt. Disc. Possible" := CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible";
                        CreditTransferEntry.Modify();
                    end;
                    CVLedgerEntryBuffer.Delete(false);
                until CVLedgerEntryBuffer.Next() = 0;
        end
        else begin //Only one banktransspec
            SpecLineNo += 1;
            CreditTransferEntry.CreateNew(CreditTransferRegister."No.", SpecLineNo,
                GenJournalLine."Account Type", GenJournalLine."Account No.", GenJournalLine.GetAppliesToDocEntryNo(),
                GenJournalLine."Posting Date", GenJournalLine."Currency Code", GenJournalLine.Amount, PaymentExportData."Payment Information ID",
                GenJournalLine."Recipient Bank Account", GenJournalLine."Message to Recipient");

            //Update CreditTransferEntry with Data Exch. Entry No. and any discount for banktransspec
            CreditTransferEntry.SetRange("Credit Transfer Register No.", CreditTransferRegister."No.");
            CreditTransferEntry.SetRange("Applies-to Entry No.", GenJournalLine.GetAppliesToDocEntryNo());
            CreditTransferEntry.SetRange("Transaction ID", PaymentExportData."Payment Information ID");
            if (CreditTransferEntry.FindFirst()) then begin
                CreditTransferEntry."Data Exch. Entry No." := GenJournalLine."Data Exch. Entry No.";
                CreditTransferEntry."Pmt. Disc. Possible" := 0;
                CreditTransferEntry.Modify();
            end;
        end;
    end;

    local procedure GetCVLedgerEntry(GenJournalLine: Record "Gen. Journal Line"; var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        EmplLedgEntry: Record "Employee Ledger Entry";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
    begin

        Clear(CVLedgerEntryBuffer);
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) then begin
            VendLedgEntry.SETRANGE("Vendor No.", GenJournalLine."Account No.");
            VendLedgEntry.SetRange(Open, true);
            if GenJournalLine."Applies-to Doc. No." <> '' then begin
                VendLedgEntry.SETRANGE("Document Type", GenJournalLine."Applies-to Doc. Type");
                VendLedgEntry.SETRANGE("Document No.", GenJournalLine."Applies-to Doc. No.");
            end else
                if GenJournalLine."Applies-to ID" <> '' then
                    VendLedgEntry.SETRANGE("Applies-to ID", GenJournalLine."Applies-to ID");

            VendLedgEntry.SetAutoCalcFields("Remaining Amount");
            if VendLedgEntry.FindSet() then
                REPEAT
                    CVLedgerEntryBuffer.CopyFromVendLedgEntry(VendLedgEntry);
                    if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlVend(GenJournalLine, VendLedgEntry, 0, false) then begin
                        CVLedgerEntryBuffer."Remaining Amount" := -(VendLedgEntry."Remaining Amount" - VendLedgEntry."Remaining Pmt. Disc. Possible");
                        CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := -(VendLedgEntry."Remaining Pmt. Disc. Possible")
                    end
                    else begin
                        CVLedgerEntryBuffer."Remaining Amount" := -VendLedgEntry."Remaining Amount";
                        CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := 0;
                    end;
                    CVLedgerEntryBuffer.Insert(false);
                until VendLedgEntry.Next() = 0;
        end
        else
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) then begin
                CustLedgEntry.SETRANGE("Customer No.", GenJournalLine."Account No.");
                CustLedgEntry.SetRange(Open, true);
                if GenJournalLine."Applies-to Doc. No." <> '' then begin
                    CustLedgEntry.SETRANGE("Document Type", GenJournalLine."Applies-to Doc. Type");
                    CustLedgEntry.SETRANGE("Document No.", GenJournalLine."Applies-to Doc. No.");
                end else
                    if GenJournalLine."Applies-to ID" <> '' then
                        CustLedgEntry.SETRANGE("Applies-to ID", GenJournalLine."Applies-to ID");

                CustLedgEntry.SetAutoCalcFields("Remaining Amount");
                if CustLedgEntry.FindSet() then
                    REPEAT
                        CustLedgEntry.CalcFields("Remaining Amount");
                        CVLedgerEntryBuffer.CopyFromCustLedgEntry(CustLedgEntry);
                        if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(GenJournalLine, CustLedgEntry, 0, false) then begin
                            CVLedgerEntryBuffer."Remaining Amount" := -(CustLedgEntry."Remaining Amount" - CustLedgEntry."Remaining Pmt. Disc. Possible");
                            CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := -(CustLedgEntry."Remaining Pmt. Disc. Possible")
                        end
                        else begin
                            CVLedgerEntryBuffer."Remaining Amount" := -CustLedgEntry."Remaining Amount";
                            CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := 0;
                        end;
                        CVLedgerEntryBuffer.Insert(false);
                    until CustLedgEntry.Next() = 0;
            end
            else
                if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) then begin
                    EmplLedgEntry.SetRange("Employee No.", GenJournalLine."Account No.");
                    EmplLedgEntry.SetRange(Open, true);
                    if EmplLedgEntry."Applies-to Doc. No." <> '' then begin
                        EmplLedgEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
                        EmplLedgEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
                    end else
                        if EmplLedgEntry."Applies-to ID" <> '' then
                            EmplLedgEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");

                    EmplLedgEntry.SetAutoCalcFields("Remaining Amount");
                    if EmplLedgEntry.findSet() then;
                    repeat
                        EmplLedgEntry.CalcFields("Remaining Amount");
                        CVLedgerEntryBuffer.CopyFromEmplLedgEntry(EmplLedgEntry);
                        CVLedgerEntryBuffer."Remaining Amount" := -EmplLedgEntry."Remaining Amount";
                        CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible" := 0;
                        CVLedgerEntryBuffer.Insert(false);
                    until EmplLedgEntry.Next() = 0;
                end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPaymentExoprtData(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup")
    begin
    end;
}

