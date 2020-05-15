codeunit 20107 "AMC Bank Exp. CT Valid."
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: record "Payment Method";
        PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check";
        TestedBankAccount: Boolean;
    begin
        DeletePaymentFileBatchErrors();
        DeletePaymentFileErrors();

        GenJnlLine.CopyFilters(Rec);
        if GenJnlLine.FindSet() then
            repeat
                CODEUNIT.Run(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);
                if "Payment Method Code" <> '' then
                    if (PaymentMethod.Get(GenJnlLine."Payment Method Code")) then
                        if (PaymentMethod."AMC Bank Pmt. Type" = '') then
                            PaymentExportGenJnlCheck.AddFieldEmptyError(GenJnlLine, PaymentMethod.TableCaption, PaymentMethod.FieldCaption("AMC Bank Pmt. Type"), '');

                CheckIsoCodeValues(GenJnlLine, PaymentExportGenJnlCheck, TestedBankAccount);

            until GenJnlLine.Next() = 0;

        if GenJnlLine.HasPaymentFileErrorsInBatch() then begin
            Commit();
            Error(HasErrorsErr);
        end;
    end;

    local procedure CheckIsoCodeValues(GenJnlLine: Record "Gen. Journal Line"; PaymentExportGenJnlCheck: Codeunit "Payment Export Gen. Jnl Check"; var TestedBankAccount: Boolean)
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
            if (BankAccount.Get(GenJnlLine."Bal. Account No.")) then begin
                PaymentExportData.SetBankAsSenderBank(BankAccount);
                PaymentExportData."Sender Bank Country/Region" := CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code");
                PaymentExportData."Sender Bank Account Currency" := GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code");
            end;
            TestedBankAccount := true;
        end;

        case GenJnlLine."Account Type" of
            GenJnlLine."Account Type"::Customer:
                begin
                    Customer.Get(GenJnlLine."Account No.");
                    if CustomerBankAccount.Get(Customer."No.", GenJnlLine."Recipient Bank Account") then
                        PaymentExportData.SetCustomerAsRecipient(Customer, CustomerBankAccount);
                end;
            GenJnlLine."Account Type"::Vendor:
                begin
                    Vendor.Get(GenJnlLine."Account No.");
                    if VendorBankAccount.Get(Vendor."No.", GenJnlLine."Recipient Bank Account") then
                        PaymentExportData.SetVendorAsRecipient(Vendor, VendorBankAccount);
                end;
            GenJnlLine."Account Type"::Employee:
                begin
                    Employee.Get(GenJnlLine."Account No.");
                    PaymentExportData.SetEmployeeAsRecipient(Employee);
                end;
        end;

        if (PaymentExportData."Sender Bank Country/Region" <> '') then
            if (CountryRegion.Get(PaymentExportData."Sender Bank Country/Region")) then
                if (CountryRegion."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJnlLine, CountryRegion.TableCaption, CountryRegion.FieldCaption("ISO Code"), '');

        if (PaymentExportData."Recipient Country/Region Code" <> '') then
            if (CountryRegion.Get(PaymentExportData."Recipient Country/Region Code")) then
                if (CountryRegion."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJnlLine, CountryRegion.TableCaption, CountryRegion.FieldCaption("ISO Code"), '');

        if (PaymentExportData."Recipient Bank Country/Region" <> '') then
            if (CountryRegion.Get(PaymentExportData."Recipient Bank Country/Region")) then
                if (CountryRegion."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJnlLine, CountryRegion.TableCaption, CountryRegion.FieldCaption("ISO Code"), '');

        if (PaymentExportData."Sender Bank Account Currency" <> '') then
            if (Currency.get(PaymentExportData."Sender Bank Account Currency")) then
                if (Currency."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJnlLine, Currency.TableCaption, Currency.FieldCaption("ISO Code"), '');

        if (GenJnlLine."Currency Code" <> '') then // This is to handle BC users that by mistake has set CurrencyCode to the same as GeneralLedgerSetup."LCY Code"
            PaymentExportData."Currency Code" := GenJnlLine."Currency Code"
        else
            PaymentExportData."Currency Code" := GeneralLedgerSetup.GetCurrencyCode(GenJnlLine."Currency Code");


        if (PaymentExportData."Currency Code" <> '') then
            if (Currency.get(PaymentExportData."Currency Code")) then
                if (Currency."ISO Code" = '') then
                    PaymentExportGenJnlCheck.AddFieldEmptyError(GenJnlLine, Currency.TableCaption, Currency.FieldCaption("ISO Code"), '');

        Clear(PaymentExportData);
    end;

    var
        HasErrorsErr: Label 'The file export has one or more errors.\\For each line to be exported, resolve the errors displayed to the right and then try to export again.';
}

