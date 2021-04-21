codeunit 18688 "TDS Validations"
{
    var
        TANNoErr: Label 'T.A.N. No must have a value in TDS Entry';
        PANNOErr: Label 'The deductee P.A.N. No. is invalid.';
        PANReferenceNoErr: Label 'The P.A.N. Reference No. field must be filled for the Vendor No. %1', Comment = '%1 = Vendor No.';
        PANReferenceCustomerErr: Label 'The P.A.N. Reference No. field must be filled for the Customer No. %1', Comment = '%1 = Customer No.';
        AccountingPeriodErr: Label 'The Posting Date doesn''t lie in Tax Accounting Period', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure CheckPANNoValidations(var GenJournalLine: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        Location: Record Location;
        CompanyInformation: Record "Company Information";
    begin
        if GenJournalLine."TDS Section Code" <> '' then begin
            if GenJournalLine."T.A.N. No." = '' then
                Error(TANNoErr);

            CompanyInformation.Get();
            CompanyInformation.TestField("T.A.N. No.");
            if GenJournalLine."Location Code" <> '' then begin
                Location.Get(GenJournalLine."Location Code");
                if Location."T.A.N. No." = '' then
                    Location.TestField("T.A.N. No.");
            end;

            if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
                Vendor.Get(GenJournalLine."Account No.");
                if (Vendor."P.A.N. No." = '') and (Vendor."P.A.N. Status" = Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. Reference No." = '') then
                    Error(PANNOErr);
                if (Vendor."P.A.N. No." = '') or (Vendor."P.A.N. Status" <> Vendor."P.A.N. Status"::" ") then
                    if (Vendor."P.A.N. Status" <> Vendor."P.A.N. Status"::" ") and (Vendor."P.A.N. Reference No." = '') then
                        Error(PANReferenceNoErr, Vendor."No.");
            end
            else
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer then begin
                    Customer.Get(GenJournalLine."Account No.");
                    if (Customer."P.A.N. No." = '') and (Customer."P.A.N. Status" = Customer."P.A.N. Status"::" ") and (Customer."P.A.N. Reference No." = '') then
                        Error(PANNOErr);
                    if (Customer."P.A.N. No." = '') or (Customer."P.A.N. Status" <> Customer."P.A.N. Status"::" ") then
                        if (Customer."P.A.N. Status" <> Customer."P.A.N. Status"::" ") and (Customer."P.A.N. Reference No." = '') then
                            Error(PANReferenceCustomerErr, Customer."No.");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure CheckCompanyInforDetails(var GenJournalLine: Record "Gen. Journal Line")
    var
        CompanyInformation: Record "Company Information";
        DeductorCategory: Record "Deductor Category";
    begin
        if GenJournalLine."TDS Section Code" = '' then
            exit;

        CompanyInformation.Get();
        CompanyInformation.TestField("Deductor Category");
        DeductorCategory.Get(CompanyInformation."Deductor Category");
        if DeductorCategory."DDO Code Mandatory" then begin
            CompanyInformation.TestField("DDO Code");
            CompanyInformation.TestField("DDO Registration No.");
        end;

        if DeductorCategory."PAO Code Mandatory" then begin
            CompanyInformation.TestField("PAO Code");
            CompanyInformation.TestField("PAO Registration No.");
        end;

        if DeductorCategory."Ministry Details Mandatory" then begin
            CompanyInformation.TestField("Ministry Type");
            CompanyInformation.TestField("Ministry Code");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostGenJnlLine', '', false, false)]
    local procedure CheckTaxAccountingPeriod(var GenJournalLine: Record "Gen. Journal Line")
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        TDSSetup: Record "TDS Setup";
        TaxType: Record "Tax Type";
        AccountingStartDate: Date;
        AccountingEndDate: Date;
    begin
        if GenJournalLine."TDS Section Code" = '' then
            exit;

        if not TDSSetup.Get() then
            exit;

        TDSSetup.TestField("Tax Type");

        TaxType.Get(TDSSetup."Tax Type");

        TaxAccountingPeriod.SetCurrentKey("Starting Date");
        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetRange(Closed, false);
        if TaxAccountingPeriod.FindFirst() then
            AccountingStartDate := TaxAccountingPeriod."Starting Date";

        if TaxAccountingPeriod.FindLast() then
            AccountingEndDate := TaxAccountingPeriod."Ending Date";

        if (GenJournalLine."Posting Date" < AccountingStartDate) or (GenJournalLine."Posting Date" > AccountingEndDate) then
            Error(AccountingPeriodErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"TDS Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure GSTAmountInTDSEntry(var Rec: Record "TDS Entry"; RunTrigger: Boolean)
    var
        TDSEntry: Record "TDS Entry";
        TaxBaseSubscribers: Codeunit "Tax Base Subscribers";
        TDSEntryUpdateMgt: Codeunit "TDS Entry Update Mgt.";
        TDSPreviewHandler: Codeunit "TDS Preview Handler";
        InitialInvoiceAmount: Decimal;
        GSTAmount: Decimal;
    begin
        if not TDSEntry.Get(Rec."Entry No.") then
            exit;

        if TDSEntry.Reversed or TDSEntry.Adjusted or (not TDSEntry."Include GST in TDS Base") then
            exit;

        if not TDSEntryUpdateMgt.IsTDSEntryUpdateStarted(TDSEntry."Entry No.") then
            TDSEntryUpdateMgt.SetTDSEntryForUpdate(TDSEntry);

        TaxBaseSubscribers.GetGSTAmountFromTransNo(Rec."Transaction No.", TDSEntry."Document No.", GSTAmount);
        InitialInvoiceAmount := TDSEntryUpdateMgt.GetTDSEntryToUpdateInitialInvoiceAmount(TDSEntry."Entry No.");
        TDSEntry."Invoice Amount" := InitialInvoiceAmount + Abs(GSTAmount);
        TDSEntry.Modify();
        TDSPreviewHandler.UpdateInvoiceAmountOnTempTDSEntry(TDSEntry);
    end;
}