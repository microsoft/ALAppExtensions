codeunit 20107 "AMC Bank Exp. CT Valid."
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: record "Payment Method";
        PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check";
        TestedBankAccount: Boolean;
    begin
        DeletePaymentFileBatchErrors();
        DeletePaymentFileErrors();

        GenJournalLine.CopyFilters(Rec);
        if GenJournalLine.FindSet() then
            repeat
                CODEUNIT.Run(CODEUNIT::"Payment Export Gen. Jnl Check", GenJournalLine);
                if "Payment Method Code" <> '' then
                    if (PaymentMethod.Get(GenJournalLine."Payment Method Code")) then
                        if (PaymentMethod."AMC Bank Pmt. Type" = '') then
                            PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, PaymentMethod.TableCaption, PaymentMethod.FieldCaption("AMC Bank Pmt. Type"), '');

                CheckIsoCodeValues(GenJournalLine, PaymentExportGenJnlCheck, TestedBankAccount);

            until GenJournalLine.Next() = 0;

        if GenJournalLine.HasPaymentFileErrorsInBatch() then begin
            Commit();
            Error(HasErrorsErr);
        end;
    end;

    local procedure CheckIsoCodeValues(GenJournalLine: Record "Gen. Journal Line"; PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check"; var TestedBankAccount: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        BankAccount: Record "Bank Account";
        CountryRegion: Record "Country/Region";
        Currency: Record Currency;
        PaymentExportData: Record "Payment Export Data";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        Employee: Record Employee;
    begin
        GeneralLedgerSetup.Get();
        if (not TestedBankAccount) then begin
            CompanyInformation.Get();
            if (BankAccount.Get(GenJournalLine."Bal. Account No.")) then begin
                PaymentExportData.SetBankAsSenderBank(BankAccount);
                PaymentExportData."Sender Bank Country/Region" := CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code");
                PaymentExportData."Sender Bank Account Currency" := GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code");
            end;
            TestedBankAccount := true;
        end;

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                begin
                    Customer.Get(GenJournalLine."Account No.");
                    if CustomerBankAccount.Get(Customer."No.", GenJournalLine."Recipient Bank Account") then
                        PaymentExportData.SetCustomerAsRecipient(Customer, CustomerBankAccount);
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    Vendor.Get(GenJournalLine."Account No.");
                    if VendorBankAccount.Get(Vendor."No.", GenJournalLine."Recipient Bank Account") then
                        PaymentExportData.SetVendorAsRecipient(Vendor, VendorBankAccount);
                end;
            GenJournalLine."Account Type"::Employee:
                begin
                    Employee.Get(GenJournalLine."Account No.");
                    PaymentExportData.SetEmployeeAsRecipient(Employee);
                end;
        end;

        if (PaymentExportData."Sender Bank Country/Region" <> '') then
            if (CountryRegion.Get(PaymentExportData."Sender Bank Country/Region")) then
                if (CountryRegion."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, CountryRegion.TableCaption, CountryRegion.FieldCaption("ISO Code"), '');

        if (PaymentExportData."Recipient Country/Region Code" <> '') then
            if (CountryRegion.Get(PaymentExportData."Recipient Country/Region Code")) then
                if (CountryRegion."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, CountryRegion.TableCaption, CountryRegion.FieldCaption("ISO Code"), '');

        if (PaymentExportData."Recipient Bank Country/Region" <> '') then
            if (CountryRegion.Get(PaymentExportData."Recipient Bank Country/Region")) then
                if (CountryRegion."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, CountryRegion.TableCaption, CountryRegion.FieldCaption("ISO Code"), '');

        if (PaymentExportData."Sender Bank Account Currency" <> '') then
            if (Currency.get(PaymentExportData."Sender Bank Account Currency")) then
                if (Currency."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, Currency.TableCaption, Currency.FieldCaption("ISO Code"), '');

        if (GenJournalLine."Currency Code" <> '') then // This is to handle BC users that by mistake has set CurrencyCode to the same as GeneralLedgerSetup."LCY Code"
            PaymentExportData."Currency Code" := GenJournalLine."Currency Code"
        else
            PaymentExportData."Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code");


        if (PaymentExportData."Currency Code" <> '') then
            if (Currency.get(PaymentExportData."Currency Code")) then
                if (Currency."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJournalLine, Currency.TableCaption, Currency.FieldCaption("ISO Code"), '');

        Clear(PaymentExportData);
    end;

    var
        HasErrorsErr: Label 'The file export has one or more errors.\\For each line to be exported, resolve the errors displayed to the right and then try to export again.';
}

