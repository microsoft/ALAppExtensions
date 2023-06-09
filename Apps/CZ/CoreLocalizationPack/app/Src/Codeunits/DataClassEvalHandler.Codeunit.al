codeunit 11710 "Data Class. Eval. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        AccScheduleLine: Record "Acc. Schedule Line";
        AccScheduleName: Record "Acc. Schedule Name";
        BankAccount: Record "Bank Account";
        Company: Record Company;
        CompanyInformation: Record "Company Information";
        Contact: Record Contact;
        CopyGenJournalParameters: Record "Copy Gen. Journal Parameters";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        DepreciationBook: Record "Depreciation Book";
#if not CLEAN22
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
#endif
        DirectTransHeader: Record "Direct Trans. Header";
        DirectTransLine: Record "Direct Trans. Line";
        EETEntryCZL: Record "EET Entry CZL";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GLAccount: Record "G/L Account";
#pragma warning disable AL0432
        GLAccountNetChange: Record "G/L Account Net Change";
#pragma warning restore AL0432
#if not CLEAN22
        GLEntry: Record "G/L Entry";
#endif
        InventoryPostingSetup: Record "Inventory Posting Setup";
        InventorySetup: Record "Inventory Setup";
#if not CLEAN20
#pragma warning disable AL0432
        InvoicePostBuffer: Record "Invoice Post. Buffer";
#pragma warning restore AL0432
#endif
        InvoicePostingBuffer: Record "Invoice Posting Buffer";
#if not CLEAN22
#pragma warning disable AL0432
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
#pragma warning restore AL0432
#endif
        InventoryReportEntry: Record "Inventory Report Entry";
        IsolatedCertificate: Record "Isolated Certificate";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedReminderHeader: Record "Issued Reminder Header";
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        ItemCharge: Record "Item Charge";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemLedgerEntry: Record "Item Ledger Entry";
        JobJournalLine: Record "Job Journal Line";
        JobLedgerEntry: Record "Job Ledger Entry";
        PhysInvtOrderLine: Record "Phys. Invt. Order Line";
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        PurchaseLine: Record "Purchase Line";
        PurchaseLineArchive: Record "Purchase Line Archive";
#if not CLEAN22
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
#endif
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        RegistrationLog: Record "Registration Log CZL";
        RegistrationLogDetail: Record "Registration Log Detail CZL";
        ReminderHeader: Record "Reminder Header";
        Resource: Record Resource;
        ResponsibilityCenter: Record "Responsibility Center";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        ReturnShipmentHeader: Record "Return Shipment Header";
        ReturnShipmentLine: Record "Return Shipment Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesHeader: Record "Sales Header";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        SalesLineArchive: Record "Sales Line Archive";
#if not CLEAN22
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
#endif
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceHeader: Record "Service Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceLine: Record "Service Line";
#if not CLEAN22
        ServiceMgtSetup: Record "Service Mgt. Setup";
#endif
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentLine: Record "Service Shipment Line";
        ShipmentMethod: Record "Shipment Method";
        SourceCodeSetup: Record "Source Code Setup";
        StockkeepingUnit: Record "Stockkeeping Unit";
        TariffNumber: Record "Tariff Number";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        UnitofMeasure: Record "Unit of Measure";
        UserSetup: Record "User Setup";
        ValueEntry: Record "Value Entry";
        VATAmountLine: Record "VAT Amount Line";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
        VATStatementTemplate: Record "VAT Statement Template";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorTempl: Record "Vendor Templ.";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Acc. Schedule Extension CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Acc. Schedule File Mapping CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Acc. Schedule Result Col. CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Acc. Schedule Result Hdr. CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Acc. Schedule Result Hist. CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Acc. Schedule Result Line CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Acc. Schedule Result Value CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Adj. Exchange Rate Buffer CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Certificate Code CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Commodity CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Commodity Setup CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Company Official CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Constant Symbol CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cross Application Buffer CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Document Footer CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"EET Service Setup CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"EET Business Premises CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"EET Cash Register CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"EET Entry CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"EET Entry Status Log CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Excel Template CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Intrastat Delivery Group CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Invt. Movement Template CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Registration Log CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Registration Log Detail CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Reg. No. Service Config CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Specific Movement CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Statistic Indication CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Statutory Reporting Setup CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Stockkeeping Unit Template CZL");
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Subst. Cust. Posting Group CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Subst. Vend. Posting Group CZL");
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Unreliable Payer Entry CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Unrel. Payer Service Setup CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"User Setup Line CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Attribute Code CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Ctrl. Report Buffer CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Ctrl. Report Ent. Link CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Ctrl. Report Header CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Ctrl. Report Line CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Ctrl. Report Section CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Period CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Statement Attachment CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VAT Statement Comment Line CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VIES Declaration Header CZL");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"VIES Declaration Line CZL");

        DataClassificationMgt.SetFieldToPersonal(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Created By"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log CZL", RegistrationLog.FieldNo("Verified City"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log CZL", RegistrationLog.FieldNo("Verified Post Code"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log CZL", RegistrationLog.FieldNo("Verified VAT Registration No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log CZL", RegistrationLog.FieldNo("Verified Address"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log CZL", RegistrationLog.FieldNo("Verified Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log CZL", RegistrationLog.FieldNo("User ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log CZL", RegistrationLog.FieldNo("Registration No."));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log Detail CZL", RegistrationLogDetail.FieldNo(Response));
        DataClassificationMgt.SetFieldToPersonal(Database::"Registration Log Detail CZL", RegistrationLogDetail.FieldNo("Current Value"));

        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Entry No."));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Cash Register Type"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Cash Register No."));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Business Premises Code"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Cash Register Code"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Document No."));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo(Description));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Applied Document Type"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Applied Document No."));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Created At"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Status"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Status Last Changed At"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Message UUID"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Taxpayer's Signature Code"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Taxpayer's Security Code"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Fiscal Identification Code"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Receipt Serial No."));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Total Sales Amount"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Amount Exempted From VAT"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("VAT Base (Basic)"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("VAT Amount (Basic)"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("VAT Base (Reduced)"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("VAT Amount (Reduced)"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("VAT Base (Reduced 2)"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("VAT Amount (Reduced 2)"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Amount - Art.89"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Amount (Basic) - Art.90"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Amount (Reduced) - Art.90"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Amount (Reduced 2) - Art.90"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Amt. For Subseq. Draw/Settle"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Amt. Subseq. Drawn/Settled"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Canceled By Entry No."));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"EET Entry CZL", EETEntryCZL.FieldNo("Simple Registration"));

        DataClassificationMgt.SetFieldToNormal(Database::"Acc. Schedule Line", AccScheduleLine.FieldNo("Calc CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Acc. Schedule Line", AccScheduleLine.FieldNo("Row Correction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Acc. Schedule Line", AccScheduleLine.FieldNo("Assets/Liabilities Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Acc. Schedule Line", AccScheduleLine.FieldNo("Source Table CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Acc. Schedule Name", AccScheduleName.FieldNo("Acc. Schedule Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Excl. from Exch. Rate Adj. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Company Information", CompanyInformation.FieldNo("Default Bank Account Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Company Information", CompanyInformation.FieldNo("Bank Account Format Check CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Company Information", CompanyInformation.FieldNo("Tax Registration No. CZL"));
#if not CLEAN23
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::Contact, Contact.FieldNo("Registration No. CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::Contact, Contact.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Copy Gen. Journal Parameters", CopyGenJournalParameters.FieldNo("Replace VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Cust. Ledger Entry", CustLedgerEntry.FieldNo("VAT Date CZL"));
#if not CLEAN23
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("Registration No. CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("Validate Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("Transaction Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("Transaction Specification CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Customer, Customer.FieldNo("Transport Method CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Customer Templ.", CustomerTempl.FieldNo("Validate Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Depreciation Book", DepreciationBook.FieldNo("Mark Reclass. as Correct. CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Detailed Cust. Ledg. Entry", DetailedCustLedgEntry.FieldNo("Customer Posting Group CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Detailed Cust. Ledg. Entry", DetailedCustLedgEntry.FieldNo("Appl. Across Post. Groups CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Detailed Vendor Ledg. Entry", DetailedVendorLedgEntry.FieldNo("Vendor Posting Group CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Detailed Vendor Ledg. Entry", DetailedVendorLedgEntry.FieldNo("Appl. Across Post. Groups CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Header", DirectTransHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Line", DirectTransLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Line", DirectTransLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Direct Trans. Line", DirectTransLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Finance Charge Memo Header", FinanceChargeMemoHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Allow VAT Posting From CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Allow VAT Posting To CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Use VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Do Not Check Dimensions CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Check Posting Debit/Credit CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Mark Neg. Qty as Correct. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Rounding Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Closed Per. Entry Pos.Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("User Checks Allowed CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Shared Account Schedule CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Acc. Schedule Results Nos. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Def. Orig. Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Posting Setup", GeneralPostingSetup.FieldNo("Invt. Rounding Adj. Acc. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Batch", GenJournalBatch.FieldNo("Allow Hybrid Document CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("VAT Delay CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Original Doc. Partner Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Original Doc. Partner No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("From Adjustment CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Template", GenJournalTemplate.FieldNo("Not Check Doc. Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account", GLAccount.FieldNo("G/L Account Group CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account", GLAccount.FieldNo("Net Change (VAT Date) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account", GLAccount.FieldNo("Debit Amount (VAT Date) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account", GLAccount.FieldNo("Credit Amount (VAT Date) CZL"));
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account Net Change", GLAccountNetChange.FieldNo("Account Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account Net Change", GLAccountNetChange.FieldNo("Account No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account Net Change", GLAccountNetChange.FieldNo("Net Change in Jnl. Curr. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account Net Change", GLAccountNetChange.FieldNo("Balance after Posting Curr.CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Account Net Change", GLAccountNetChange.FieldNo("Currency Code CZL"));
#pragma warning restore AL0432
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"G/L Entry", GLEntry.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Posting Setup", InventoryPostingSetup.FieldNo("Consumption Account CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Posting Setup", InventoryPostingSetup.FieldNo("Change In Inv.Of WIP Acc. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Posting Setup", InventoryPostingSetup.FieldNo("Change In Inv.OfProd. Acc. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Date Order Invt. Change CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Def.Tmpl. for Phys.Pos.Adj CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Def.Tmpl. for Phys.Neg.Adj CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Post Exp.Cost Conv.As Corr.CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Setup", InventorySetup.FieldNo("Post Neg.Transf. As Corr.CZL"));
#if not CLEAN20
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Post. Buffer", InvoicePostBuffer.FieldNo("Ext. Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Post. Buffer", InvoicePostBuffer.FieldNo("Ext. Amount Incl. VAT CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Post. Buffer", InvoicePostBuffer.FieldNo("VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Post. Buffer", InvoicePostBuffer.FieldNo("Correction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Post. Buffer", InvoicePostBuffer.FieldNo("Original Doc. VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Posting Buffer", InvoicePostingBuffer.FieldNo("Ext. Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Posting Buffer", InvoicePostingBuffer.FieldNo("Ext. Amount Incl. VAT CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Posting Buffer", InvoicePostingBuffer.FieldNo("VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Posting Buffer", InvoicePostingBuffer.FieldNo("Correction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Invoice Posting Buffer", InvoicePostingBuffer.FieldNo("Original Doc. VAT Date CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Batch", IntrastatJnlBatch.FieldNo("Declaration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Batch", IntrastatJnlBatch.FieldNo("Statement Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Additional Costs CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Source Entry Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Statistics Period CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Declaration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Statement Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Prev. Declaration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Prev. Declaration Line No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Specific Movement CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Supplem. UoM Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Supplem. UoM Quantity CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Supplem. UoM Net Weight CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Intrastat Jnl. Line", IntrastatJnlLine.FieldNo("Base Unit of Measure CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Report Entry", InventoryReportEntry.FieldNo("Change In Inv.Of Product CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Report Entry", InventoryReportEntry.FieldNo("Change In Inv.Of WIP CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Report Entry", InventoryReportEntry.FieldNo("Consumption CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Inventory Report Entry", InventoryReportEntry.FieldNo("Inv. Rounding Adj. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Isolated Certificate", IsolatedCertificate.FieldNo("Certificate Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Fin. Charge Memo Header", IssuedFinChargeMemoHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Issued Reminder Header", IssuedReminderHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Item, Item.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Item, Item.FieldNo("Specific Movement CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge", ItemCharge.FieldNo("Incl. in Intrastat Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge", ItemCharge.FieldNo("Incl. in Intrastat S.Value CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge Assignment (Purch)", ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge Assignment (Purch)", ItemChargeAssignmentPurch.FieldNo("Incl. in Intrastat S.Value CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge Assignment (Sales)", ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Charge Assignment (Sales)", ItemChargeAssignmentSales.FieldNo("Incl. in Intrastat S.Value CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Incl. in Intrastat Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Incl. in Intrastat S.Value CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Net Weight CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Intrastat Transaction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("Invt. Movement Template CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Journal Line", ItemJournalLine.FieldNo("G/L Correction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Net Weight CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Intrastat Transaction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Net Weight CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Intrastat Transaction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Invt. Movement Template CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Journal Line", JobJournalLine.FieldNo("Correction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Ledger Entry", JobLedgerEntry.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Ledger Entry", JobLedgerEntry.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Ledger Entry", JobLedgerEntry.FieldNo("Net Weight CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Ledger Entry", JobLedgerEntry.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Ledger Entry", JobLedgerEntry.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Job Ledger Entry", JobLedgerEntry.FieldNo("Intrastat Transaction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Phys. Invt. Order Line", PhysInvtOrderLine.FieldNo("Invt. Movement Template CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("VAT Delay CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Specific Symbol CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Variable Symbol CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Constant Symbol CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Bank Account Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Bank Account No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Transit No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("IBAN CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("SWIFT Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("VAT Currency Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Original Doc. Partner Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Original Doc. Partner No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Gen. Journal Line", PostedGenJournalLine.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("VAT Currency Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Last Unreliab. Check Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("VAT Unreliable Payer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Third Party Bank Account CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("EU 3-Party Trade CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header Archive", PurchaseHeaderArchive.FieldNo("EU 3-Party Trade CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Negative CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Ext. Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Ext. Amount Incl. VAT CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line", PurchaseLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Line Archive", PurchaseLineArchive.FieldNo("Physical Transfer CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Purchases & Payables Setup", PurchasesPayablesSetup.FieldNo("Default VAT Date CZL"));
#if not CLEAN20
        DataClassificationMgt.SetFieldToNormal(Database::"Purchases & Payables Setup", PurchasesPayablesSetup.FieldNo("Allow Alter Posting Groups CZL"));
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Purchases & Payables Setup", PurchasesPayablesSetup.FieldNo("Def. Orig. Doc. VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("EU 3-Party Trade CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Line", PurchCrMemoLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Line", PurchCrMemoLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Line", PurchCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("EU 3-Party Trade CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Line", PurchInvLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Line", PurchInvLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Line", PurchInvLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("EU 3-Party Trade CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Header", PurchRcptHeader.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Line", PurchRcptLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Rcpt. Line", PurchRcptLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Reminder Header", ReminderHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Reminder Header", ReminderHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Resource, Resource.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Responsibility Center", ResponsibilityCenter.FieldNo("Default Bank Account Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Header", ReturnReceiptHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Header", ReturnReceiptHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Header", ReturnReceiptHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Header", ReturnReceiptHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Header", ReturnReceiptHeader.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Line", ReturnReceiptLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Line", ReturnReceiptLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Receipt Line", ReturnReceiptLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Header", ReturnShipmentHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Header", ReturnShipmentHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Header", ReturnShipmentHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Header", ReturnShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Header", ReturnShipmentHeader.FieldNo("EU 3-Party Trade CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Line", ReturnShipmentLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Line", ReturnShipmentLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Return Shipment Line", ReturnShipmentLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Line", SalesCrMemoLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Line", SalesCrMemoLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Line", SalesCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Credit Memo Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header Archive", SalesHeaderArchive.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Line", SalesInvoiceLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Line", SalesInvoiceLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Line", SalesInvoiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("Negative CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line", SalesLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Line Archive", SalesLineArchive.FieldNo("Physical Transfer CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Sales & Receivables Setup", SalesReceivablesSetup.FieldNo("Default VAT Date CZL"));
#pragma warning restore AL0432
#endif
#if not CLEAN20
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Sales & Receivables Setup", SalesReceivablesSetup.FieldNo("Allow Alter Posting Groups CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Header", SalesShipmentHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Header", SalesShipmentHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Header", SalesShipmentHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Header", SalesShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Header", SalesShipmentHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Line", SalesShipmentLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Line", SalesShipmentLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Shipment Line", SalesShipmentLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Line", ServiceCrMemoLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Line", ServiceCrMemoLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Line", ServiceCrMemoLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Credit Memo Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("VAT Currency Factor CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("VAT Currency Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Line", ServiceInvoiceLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Line", ServiceInvoiceLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Line", ServiceInvoiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("Negative CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Line", ServiceLine.FieldNo("Country/Reg. of Orig. Code CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Service Mgt. Setup", ServiceMgtSetup.FieldNo("Default VAT Date CZL"));
#pragma warning restore AL0432
#endif
#if not CLEAN20
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"Service Mgt. Setup", ServiceMgtSetup.FieldNo("Allow Alter Posting Groups CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Header", ServiceShipmentHeader.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Header", ServiceShipmentHeader.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Header", ServiceShipmentHeader.FieldNo("Physical Transfer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Header", ServiceShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Header", ServiceShipmentHeader.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Line", ServiceShipmentLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Line", ServiceShipmentLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Shipment Line", ServiceShipmentLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Shipment Method", ShipmentMethod.FieldNo("Incl. Item Charges (Amt.) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Shipment Method", ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Shipment Method", ShipmentMethod.FieldNo("Incl. Item Charges (S.Val) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Shipment Method", ShipmentMethod.FieldNo("Adjustment % CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Source Code Setup", SourceCodeSetup.FieldNo("Purchase VAT Delay CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Source Code Setup", SourceCodeSetup.FieldNo("Sales VAT Delay CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Source Code Setup", SourceCodeSetup.FieldNo("VAT LCY Correction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Source Code Setup", SourceCodeSetup.FieldNo("Close Balance Sheet CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Source Code Setup", SourceCodeSetup.FieldNo("Open Balance Sheet CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Stockkeeping Unit", StockkeepingUnit.FieldNo("Gen. Prod. Posting Group CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Tariff Number", TariffNumber.FieldNo("Statement Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Tariff Number", TariffNumber.FieldNo("VAT Stat. UoM Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Tariff Number", TariffNumber.FieldNo("Allow Empty UoM Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Tariff Number", TariffNumber.FieldNo("Statement Limit Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Tariff Number", TariffNumber.FieldNo("Description EN CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Tariff Number", TariffNumber.FieldNo("Suppl. Unit of Meas. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Header", TransferHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Line", TransferLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Line", TransferLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Line", TransferLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Header", TransferReceiptHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Line", TransferReceiptLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Line", TransferReceiptLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Receipt Line", TransferReceiptLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Header", TransferShipmentHeader.FieldNo("Intrastat Exclude CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Tariff No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Statistic Indication CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Transfer Shipment Line", TransferShipmentLine.FieldNo("Country/Reg. of Orig. Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Unit of Measure", UnitofMeasure.FieldNo("Tariff Number UOM Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Allow VAT Posting From CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Allow VAT Posting To CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Doc. Date(work date) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Doc. Date(sys. date) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Post.Date(work date) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Post.Date(sys. date) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Bank Accounts CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Journal Templates CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Dimension Values CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Allow Post.toClosed Period CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Allow Complete Job CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Employee No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("User Name CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Allow Item Unapply CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Location Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Release LocationCode CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Invt. Movement Temp. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Value Entry", ValueEntry.FieldNo("G/L Correction CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Value Entry", ValueEntry.FieldNo("Incl. in Intrastat Amount CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Value Entry", ValueEntry.FieldNo("Incl. in Intrastat S.Value CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Amount Line", VATAmountLine.FieldNo("VAT Base (LCY) CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Amount Line", VATAmountLine.FieldNo("VAT Amount (LCY) CZL"));
#if not CLEAN22
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("VAT Date CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("VAT Settlement No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("VAT Delay CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("VAT Identifier CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("VAT Ctrl. Report No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("VAT Ctrl. Report Line No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("Original Doc. VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Reverse Charge Check CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Purch. VAT Curr. Exch. Acc CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Sales VAT Curr. Exch. Acc CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("VIES Purchase CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("VIES Sales CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Intrastat Service CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("VAT Rate CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Supplies Mode Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Ratio Coefficient CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Corrections Bad Receivable CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("VAT LCY Corr. Rounding Acc.CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("Attribute Code CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("G/L Amount Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("Gen. Bus. Posting Group CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("Gen. Prod. Posting Group CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("Show CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("EU 3-Party Intermed. Role CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("EU-3 Party Trade CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("VAT Ctrl. Report Section CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Line", VATStatementLine.FieldNo("Ignore Simpl. Doc. Limit CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Name", VATStatementName.FieldNo("Comments CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Name", VATStatementName.FieldNo("Attachments CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Template", VATStatementTemplate.FieldNo("XML Format CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Statement Template", VATStatementTemplate.FieldNo("Allow Comments/Attachments CZL"));
#if not CLEAN23
#pragma warning disable AL0432
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Registration No. CZL"));
#pragma warning restore AL0432
#endif
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Tax Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Validate Registration No. CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Last Unreliab. Check Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("VAT Unreliable Payer CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Disable Unreliab. Check CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Transaction Type CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Transaction Specification CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo("Transport Method CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Bank Account", VendorBankAccount.FieldNo("Third Party Bank Account CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Ledger Entry", VendorLedgerEntry.FieldNo("VAT Date CZL"));
        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Templ.", VendorTempl.FieldNo("Validate Registration No. CZL"));
    end;
}
