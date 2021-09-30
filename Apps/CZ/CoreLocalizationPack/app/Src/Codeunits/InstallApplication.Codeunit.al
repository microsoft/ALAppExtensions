#pragma warning disable AL0432,AL0603
codeunit 11748 "Install Application CZL"
{
    Subtype = Install;
    Permissions = tabledata "Statutory Reporting Setup CZL" = im,
                  tabledata "Unreliable Payer Entry CZL" = im,
                  tabledata "Registration Log CZL" = im,
                  tabledata "Invt. Movement Template CZL" = im,
                  tabledata "VAT Period CZL" = im,
                  tabledata "VAT Ctrl. Report Section CZL" = im,
                  tabledata "VAT Ctrl. Report Header CZL" = im,
                  tabledata "VAT Ctrl. Report Line CZL" = im,
                  tabledata "VAT Ctrl. Report Ent. Link CZL" = i,
                  tabledata "VIES Declaration Header CZL" = im,
                  tabledata "VIES Declaration Line CZL" = im,
                  tabledata "Company Official CZL" = im,
                  tabledata "Document Footer CZL" = im,
                  tabledata "VAT Attribute Code CZL" = im,
                  tabledata "VAT Statement Comment Line CZL" = im,
                  tabledata "VAT Statement Attachment CZL" = im,
                  tabledata "Excel Template CZL" = im,
                  tabledata "Acc. Schedule File Mapping CZL" = im,
                  tabledata "Commodity CZL" = im,
                  tabledata "Commodity Setup CZL" = im,
                  tabledata "Statistic Indication CZL" = im,
                  tabledata "Stockkeeping Unit Template CZL" = im,
                  tabledata "Config. Template Header" = i,
                  tabledata "Config. Template Line" = i,
                  tabledata "Certificate Code CZL" = im,
                  tabledata "EET Service Setup CZL" = im,
                  tabledata "EET Business Premises CZL" = im,
                  tabledata "EET Cash Register CZL" = im,
                  tabledata "EET Entry CZL" = im,
                  tabledata "EET Entry Status Log CZL" = im,
                  tabledata "Constant Symbol CZL" = im,
                  tabledata "Subst. Cust. Posting Group CZL" = i,
                  tabledata "Subst. Vend. Posting Group CZL" = i,
                  tabledata "Specific Movement CZL" = im,
                  tabledata "Intrastat Delivery Group CZL" = im,
                  tabledata "User Setup Line CZL" = im,
                  tabledata "Acc. Schedule Extension CZL" = im,
                  tabledata "Acc. Schedule Result Line CZL" = im,
                  tabledata "Acc. Schedule Result Col. CZL" = im,
                  tabledata "Acc. Schedule Result Value CZL" = im,
                  tabledata "Acc. Schedule Result Hdr. CZL" = im,
                  tabledata "Acc. Schedule Result Hist. CZL" = im,
                  tabledata "Unrel. Payer Service Setup CZL" = im,
                  tabledata "SWIFT Code" = i,
                  tabledata "Source Code" = i,
                  tabledata "Company Information" = m,
                  tabledata "Responsibility Center" = m,
                  tabledata Customer = m,
                  tabledata Vendor = m,
                  tabledata "Vendor Bank Account" = m,
                  tabledata Contact = m,
                  tabledata "Item Journal Line" = m,
                  tabledata "Job Journal Line" = m,
                  tabledata "Phys. Invt. Order Line" = m,
                  tabledata "Inventory Setup" = m,
                  tabledata "General Ledger Setup" = m,
                  tabledata "Sales & Receivables Setup" = m,
                  tabledata "Purchases & Payables Setup" = m,
                  tabledata "Service Mgt. Setup" = m,
                  tabledata "User Setup" = m,
                  tabledata "G/L Entry" = m,
                  tabledata "Cust. Ledger Entry" = m,
                  tabledata "Detailed Cust. Ledg. Entry" = m,
                  tabledata "Vendor Ledger Entry" = m,
                  tabledata "Detailed Vendor Ledg. Entry" = m,
                  tabledata "VAT Entry" = m,
                  tabledata "Gen. Journal Line" = m,
                  tabledata "Sales Header" = m,
                  tabledata "Sales Shipment Header" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Return Receipt Header" = m,
                  tabledata "Sales Header Archive" = m,
                  tabledata "Purchase Header" = m,
                  tabledata "Purch. Rcpt. Header" = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Return Shipment Header" = m,
                  tabledata "Purchase Header Archive" = m,
                  tabledata "Service Header" = m,
                  tabledata "Service Shipment Header" = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Reminder Header" = m,
                  tabledata "Issued Reminder Header" = m,
                  tabledata "Finance Charge Memo Header" = m,
                  tabledata "Issued Fin. Charge Memo Header" = m,
                  tabledata "VAT Posting Setup" = m,
                  tabledata "VAT Statement Template" = m,
                  tabledata "VAT Statement Line" = m,
                  tabledata "G/L Account" = m,
                  tabledata "Acc. Schedule Name" = m,
                  tabledata "Acc. Schedule Line" = m,
                  tabledata "Purchase Line" = m,
                  tabledata "Purch. Cr. Memo Line" = m,
                  tabledata "Purch. Inv. Line" = m,
                  tabledata "Purch. Rcpt. Line" = m,
                  tabledata "Sales Line" = m,
                  tabledata "Sales Cr.Memo Line" = m,
                  tabledata "Sales Invoice Line" = m,
                  tabledata "Sales Shipment Line" = m,
                  tabledata "Tariff Number" = m,
                  tabledata "Source Code Setup" = m,
                  tabledata "Stockkeeping Unit" = m,
                  tabledata Item = m,
                  tabledata Resource = m,
                  tabledata "Service Line" = m,
                  tabledata "Service Invoice Line" = m,
                  tabledata "Service Cr.Memo Line" = m,
                  tabledata "Service Shipment Line" = m,
                  tabledata "Isolated Certificate" = m,
                  tabledata "EET Service Setup" = m,
                  tabledata "Bank Account" = m,
                  tabledata "Depreciation Book" = m,
                  tabledata "Value Entry" = m,
                  tabledata "Shipment Method" = m,
                  tabledata "Unit of Measure" = m,
                  tabledata "Sales Line Archive" = m,
                  tabledata "Purchase Line Archive" = m,
                  tabledata "Transfer Header" = m,
                  tabledata "Transfer Line" = m,
                  tabledata "Transfer Receipt Header" = m,
                  tabledata "Transfer Shipment Header" = m,
                  tabledata "Item Ledger Entry" = m,
                  tabledata "Job Ledger Entry" = m,
                  tabledata "Item Charge" = m,
                  tabledata "Item Charge Assignment (Purch)" = m,
                  tabledata "Item Charge Assignment (Sales)" = m,
                  tabledata "Posted Gen. Journal Line" = m,
                  tabledata "Intrastat Jnl. Batch" = m,
                  tabledata "Intrastat Jnl. Line" = m,
                  tabledata "Inventory Posting Setup" = m,
                  tabledata "General Posting Setup" = m,
                  tabledata "Gen. Journal Template" = m,
                  tabledata "Report Selections" = m,
                  tabledata "Item Journal Template" = m;

    var
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnInstallAppPerDatabase()
    begin
        CopyPermission();
    end;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyData();
            ModifyData();
            UnbindSubscription(InstallApplicationsMgtCZL);
        end;
        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyPermission();
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Constant Symbol", Database::"Constant Symbol CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Excel Template", Database::"Excel Template CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Statement File Mapping", Database::"Acc. Schedule File Mapping CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Attribute Code", Database::"VAT Attribute Code CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Uncertainty Payer Entry", Database::"Unreliable Payer Entry CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Electronically Govern. Setup", Database::"Unrel. Payer Service Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Reg. No. Srv Config", Database::"Reg. No. Service Config CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Registration Log", Database::"Registration Log CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Period", Database::"VAT Period CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Statement Comment Line", Database::"VAT Statement Comment Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Statement Attachment", Database::"VAT Statement Attachment CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Company Officials", Database::"Company Official CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Stockkeeping Unit Template", Database::"Stockkeeping Unit Template CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Whse. Net Change Template", Database::"Invt. Movement Template CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Statistic Indication", Database::"Statistic Indication CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VIES Declaration Header", Database::"VIES Declaration Header CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VIES Declaration Line", Database::"VIES Declaration Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Commodity", Database::"Commodity CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Commodity Setup", Database::"Commodity Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Stat. Reporting Setup", Database::"Statutory Reporting Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Header", Database::"VAT Ctrl. Report Header CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Line", Database::"VAT Ctrl. Report Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Section", Database::"VAT Ctrl. Report Section CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Control Report Buffer", Database::"VAT Ctrl. Report Buffer CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"VAT Ctrl.Rep. - VAT Entry Link", Database::"VAT Ctrl. Report Ent. Link CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Document Footer", Database::"Document Footer CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Certificate CZ Code", Database::"Certificate Code CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Business Premises", Database::"EET Business Premises CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Cash Register", Database::"EET Cash Register CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Entry", Database::"EET Entry CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Entry Status", Database::"EET Entry Status Log CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"EET Service Setup", Database::"EET Service Setup CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Customer Posting Group", Database::"Subst. Cust. Posting Group CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Subst. Vendor Posting Group", Database::"Subst. Vend. Posting Group CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Specific Movement", Database::"Specific Movement CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Intrastat Delivery Group", Database::"Intrastat Delivery Group CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Extension", Database::"Acc. Schedule Extension CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Line", Database::"Acc. Schedule Result Line CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Column", Database::"Acc. Schedule Result Col. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Value", Database::"Acc. Schedule Result Value CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result Header", Database::"Acc. Schedule Result Hdr. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Acc. Schedule Result History", Database::"Acc. Schedule Result Hist. CZL");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"User Setup Line", Database::"User Setup Line CZL");
    end;

    local procedure CopyData()
    begin
        CopyCompanyInformation();
        CopyResponsibilityCenter();
        CopyCustomer();
        CopyVendor();
        CopyVendorBankAccount();
        CopyContact();
        CopyUncertaintyPayerEntry();
        CopyRegistrationLog();
        CopyWhseNetChangeTemplate();
        CopyItemJournalLine();
        CopyJobJournalLine();
        CopyPhysInvtOrderLine();
        CopyInventorySetup();
        CopyGLSetup();
        CopySalesSetup();
        CopyPurchaseSetup();
        CopyServiceSetup();
        CopyUserSetup();
        CopyVATPeriod();
        CopyGLEntry();
        CopyCustLedgerEntry();
        CopyDetailedCustLedgEntry();
        CopyVendLedgerEntry();
        CopyDetailedVendorLedgEntry();
        CopyVATEntry();
        CopyGenJournalLine();
        CopySalesHeader();
        CopySalesShipmentHeader();
        CopySalesInvoiceHeader();
        CopySalesCrMemoHeader();
        CopyReturnReceiptHeader();
        CopySalesHeaderArchive();
        CopyPurchaseHeader();
        CopyPurchaseReceiptHeader();
        CopyPurchaseInvoiceHeader();
        CopyPurchaseCrMemoHeader();
        CopyReturnShipmentHeader();
        CopyPurchaseHeaderArchive();
        CopyServiceHeader();
        CopyServiceShipmentHeader();
        CopyServiceInvoiceHeader();
        CopyServiceCrMemoHeader();
        CopyReminderHeader();
        CopyIssuedReminderHeader();
        CopyFinanceChargeMemoHeader();
        CopyIssuedFinanceChargeMemoHeader();
        CopyStatutoryReportingSetup();
        CopyVATControlReportSection();
        CopyVATControlReportHeader();
        CopyVATControlReportLine();
        CopyVATControlReportEntryLink();
        CopyVATPostingSetup();
        CopyVATStatementTemplate();
        CopyVATStatementLine();
        CopyVIESDeclarationHeader();
        CopyVIESDeclarationLine();
        CopyCompanyOfficials();
        CopyDocumentFooter();
        CopyGLAccount();
        CopyVATAttributeCode();
        CopyVATStatementCommentLine();
        CopyVATStatementAttachment();
        CopyAccScheduleName();
        CopyAccScheduleLine();
        CopyExcelTemplate();
        CopyStatementFileMapping();
        CopyPurchaseLine();
        CopyPurchCrMemoLine();
        CopyPurchInvLine();
        CopyPurchRcptLine();
        CopySalesCrMemoLine();
        CopySalesInvoiceLine();
        CopySalesLine();
        CopySalesShipmentLine();
        CopyTariffNumber();
        CopyCommodity();
        CopyCommoditySetup();
        CopyStatisticIndication();
        CopySourceCodeSetup();
        CopyStockkeepingUnitTemplate();
        CopyStockkeepingUnit();
        CopyItem();
        CopyResource();
        CopyServiceLine();
        CopyServiceInvoiceLine();
        CopyServiceCrMemoLine();
        CopyServiceShipmentLine();
        CopyCertificateCZCode();
        CopyIsolatedCertificate();
        CopyEETServiceSetup();
        CopyEETBusinessPremises();
        CopyEETCashRegister();
        CopyEETEntry();
        CopyEETEntryStatus();
        CopyBankAccount();
        CopyConstantSymbol();
        CopyDepreciationBook();
        CopyValueEntry();
        CopySubstCustomerPostingGroup();
        CopySubstVendorPostingGroup();
        CopyShipmentMethod();
        CopySpecificMovement();
        CopyIntrastatDeliveryGroup();
        CopyUnitofMeasure();
        CopySalesLineArchive();
        CopyPurchaseLineArchive();
        CopyTransferHeader();
        CopyTransferLine();
        CopyTransferReceiptHeader();
        CopyTransferShipmentHeader();
        CopyItemLedgerEntry();
        CopyJobLedgerEntry();
        CopyItemCharge();
        CopyItemChargeAssignmentPurch();
        CopyItemChargeAssignmentSales();
        CopyPostedGenJournalLine();
        CopyIntrastatJournalBatch();
        CopyIntrastatJournalLine();
        CopyInventoryPostingSetup();
        CopyGeneralPostingSetup();
        CopyUserSetupLine();
        CopyAccScheduleExtension();
        CopyAccScheduleResultLine();
        CopyAccScheduleResultColumn();
        CopyAccScheduleResultValue();
        CopyAccScheduleResultHeader();
        CopyAccScheduleResultHistory();
        CopyGenJournalTemplate();
    end;

    local procedure ModifyData()
    begin
        ModifyGenJournalTemplate();
        ModifyReportSelections();
        ModifyVATStatementTemplate();
        ModifyItemJournalTemplate();
    end;

    local procedure CopyCompanyInformation();
    var
        CompanyInformation: Record "Company Information";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if CompanyInformation.Get() then begin
            CompanyInformation."Default Bank Account Code CZL" := CompanyInformation."Default Bank Account Code";
            CompanyInformation."Bank Account Format Check CZL" := CompanyInformation."Bank Account Format Check";
            CompanyInformation."Tax Registration No. CZL" := CompanyInformation."Tax Registration No.";
            CompanyInformation.Modify(false);
        end;

        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert();
        end;
        StatutoryReportingSetupCZL."Primary Business Activity" := CompanyInformation."Primary Business Activity";
        StatutoryReportingSetupCZL."Court Authority No." := CompanyInformation."Court Authority No.";
        StatutoryReportingSetupCZL."Tax Authority No." := CompanyInformation."Tax Authority No.";
        StatutoryReportingSetupCZL."Registration Date" := CompanyInformation."Registration Date";
        StatutoryReportingSetupCZL."Equity Capital" := CompanyInformation."Equity Capital";
        StatutoryReportingSetupCZL."Paid Equity Capital" := CompanyInformation."Paid Equity Capital";
        StatutoryReportingSetupCZL."General Manager No." := CompanyInformation."General Manager No.";
        StatutoryReportingSetupCZL."Accounting Manager No." := CompanyInformation."Accounting Manager No.";
        StatutoryReportingSetupCZL."Finance Manager No." := CompanyInformation."Finance Manager No.";
        StatutoryReportingSetupCZL.Modify();
    end;

    local procedure CopyResponsibilityCenter();
    var
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        if ResponsibilityCenter.FindSet(true) then
            repeat
                ResponsibilityCenter."Default Bank Account Code CZL" := ResponsibilityCenter."Bank Account Code";
                ResponsibilityCenter.Modify(false);
            until ResponsibilityCenter.Next() = 0;
    end;

    local procedure CopyCustomer();
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet() then
            repeat
                Customer."Registration No. CZL" := Customer."Registration No.";
                Customer."Tax Registration No. CZL" := Customer."Tax Registration No.";
                Customer."Transaction Type CZL" := Customer."Transaction Type";
                Customer."Transaction Specification CZL" := Customer."Transaction Specification";
                Customer."Transport Method CZL" := Customer."Transport Method";
                Customer.Modify(false);
            until Customer.Next() = 0;
    end;

    local procedure CopyVendor();
    var
        Vendor: Record Vendor;
    begin
        if Vendor.FindSet() then
            repeat
                Vendor."Registration No. CZL" := Vendor."Registration No.";
                Vendor."Tax Registration No. CZL" := Vendor."Tax Registration No.";
                Vendor."Disable Unreliab. Check CZL" := Vendor."Disable Uncertainty Check";
                Vendor."Transaction Type CZL" := Vendor."Transaction Type";
                Vendor."Transaction Specification CZL" := Vendor."Transaction Specification";
                Vendor."Transport Method CZL" := Vendor."Transport Method";
                Vendor.Modify(false);
            until Vendor.Next() = 0;
    end;

    local procedure CopyVendorBankAccount();
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if VendorBankAccount.FindSet() then
            repeat
                VendorBankAccount."Third Party Bank Account CZL" := VendorBankAccount."Third Party Bank Account";
                VendorBankAccount.Modify(false);
            until VendorBankAccount.Next() = 0;
    end;

    local procedure CopyContact();
    var
        Contact: Record Contact;
    begin
        if Contact.FindSet() then
            repeat
                Contact."Registration No. CZL" := Contact."Registration No.";
                Contact."Tax Registration No. CZL" := Contact."Tax Registration No.";
                Contact.Modify(false);
            until Contact.Next() = 0;
    end;

    local procedure CopyUncertaintyPayerEntry();
    var
        UncertaintyPayerEntry: Record "Uncertainty Payer Entry";
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
    begin
        if UncertaintyPayerEntry.FindSet() then
            repeat
                if not UnreliablePayerEntryCZL.Get(UncertaintyPayerEntry."Entry No.") then begin
                    UnreliablePayerEntryCZL.Init();
                    UnreliablePayerEntryCZL."Entry No." := UncertaintyPayerEntry."Entry No.";
                    UnreliablePayerEntryCZL.SystemId := UncertaintyPayerEntry.SystemId;
                    UnreliablePayerEntryCZL.Insert(false, true);
                end;
                UnreliablePayerEntryCZL."Vendor No." := UncertaintyPayerEntry."Vendor No.";
                UnreliablePayerEntryCZL."Check Date" := UncertaintyPayerEntry."Check Date";
                UnreliablePayerEntryCZL."Public Date" := UncertaintyPayerEntry."Public Date";
                UnreliablePayerEntryCZL."End Public Date" := UncertaintyPayerEntry."End Public Date";
                UnreliablePayerEntryCZL."Unreliable Payer" := UncertaintyPayerEntry."Uncertainty Payer";
                UnreliablePayerEntryCZL."Entry Type" := UncertaintyPayerEntry."Entry Type";
                UnreliablePayerEntryCZL."VAT Registration No." := UncertaintyPayerEntry."VAT Registration No.";
                UnreliablePayerEntryCZL."Tax Office Number" := UncertaintyPayerEntry."Tax Office Number";
                UnreliablePayerEntryCZL."Full Bank Account No." := UncertaintyPayerEntry."Full Bank Account No.";
                UnreliablePayerEntryCZL."Bank Account No. Type" := UncertaintyPayerEntry."Bank Account No. Type";
                UnreliablePayerEntryCZL.Modify(false);
            until UncertaintyPayerEntry.Next() = 0;
    end;

    local procedure CopyRegistrationLog();
    var
        RegistrationLog: Record "Registration Log";
        RegistrationLogCZL: Record "Registration Log CZL";
    begin
        if RegistrationLog.FindSet() then
            repeat
                if not RegistrationLogCZL.Get(RegistrationLog."Entry No.") then begin
                    RegistrationLogCZL.Init();
                    RegistrationLogCZL."Entry No." := RegistrationLog."Entry No.";
                    RegistrationLogCZL.SystemId := RegistrationLog.SystemId;
                    RegistrationLogCZL.Insert(false, true);
                end;
                RegistrationLogCZL."Registration No." := RegistrationLog."Registration No.";
                RegistrationLogCZL."Account Type" := RegistrationLog."Account Type";
                RegistrationLogCZL."Account No." := RegistrationLog."Account No.";
                RegistrationLogCZL.Status := RegistrationLog.Status;
                RegistrationLogCZL."Verified Name" := RegistrationLog."Verified Name";
                RegistrationLogCZL."Verified Address" := RegistrationLog."Verified Address";
                RegistrationLogCZL."Verified City" := RegistrationLog."Verified City";
                RegistrationLogCZL."Verified Post Code" := RegistrationLog."Verified Post Code";
                RegistrationLogCZL."Verified VAT Registration No." := RegistrationLog."Verified VAT Registration No.";
                RegistrationLogCZL."Verified Date" := RegistrationLog."Verified Date";
                RegistrationLogCZL."Verified Result" := RegistrationLog."Verified Result";
                RegistrationLogCZL."User ID" := RegistrationLog."User ID";
                RegistrationLogCZL.Modify(false);
            until RegistrationLog.Next() = 0;
    end;

    local procedure CopyWhseNetChangeTemplate();
    var
        WhseNetChangeTemplate: Record "Whse. Net Change Template";
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
    begin
        if WhseNetChangeTemplate.FindSet() then
            repeat
                if not InvtMovementTemplateCZL.Get(WhseNetChangeTemplate.Name) then begin
                    InvtMovementTemplateCZL.Init();
                    InvtMovementTemplateCZL.Name := WhseNetChangeTemplate.Name;
                    InvtMovementTemplateCZL.SystemId := WhseNetChangeTemplate.SystemId;
                    InvtMovementTemplateCZL.Insert(false, true);
                end;
                InvtMovementTemplateCZL.Description := WhseNetChangeTemplate.Description;
                InvtMovementTemplateCZL."Entry Type" := WhseNetChangeTemplate."Entry Type";
                InvtMovementTemplateCZL."Gen. Bus. Posting Group" := WhseNetChangeTemplate."Gen. Bus. Posting Group";
                InvtMovementTemplateCZL.Modify(false);
            until WhseNetChangeTemplate.Next() = 0;
    end;

    local procedure CopyItemJournalLine();
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        if ItemJournalLine.FindSet() then
            repeat
                ItemJournalLine."Tariff No. CZL" := ItemJournalLine."Tariff No.";
                ItemJournalLine."Physical Transfer CZL" := ItemJournalLine."Physical Transfer";
                ItemJournalLine."Incl. in Intrastat Amount CZL" := ItemJournalLine."Incl. in Intrastat Amount";
                ItemJournalLine."Incl. in Intrastat S.Value CZL" := ItemJournalLine."Incl. in Intrastat Stat. Value";
                ItemJournalLine."Net Weight CZL" := ItemJournalLine."Net Weight";
                ItemJournalLine."Country/Reg. of Orig. Code CZL" := ItemJournalLine."Country/Region of Origin Code";
                ItemJournalLine."Statistic Indication CZL" := ItemJournalLine."Statistic Indication";
                ItemJournalLine."Intrastat Transaction CZL" := ItemJournalLine."Intrastat Transaction";
                ItemJournalLine."Invt. Movement Template CZL" := ItemJournalLine."Whse. Net Change Template";
                ItemJournalLine."G/L Correction CZL" := ItemJournalLine."G/L Correction";
                ItemJournalLine.Modify(false);
            until ItemJournalLine.Next() = 0;
    end;

    local procedure CopyJobJournalLine();
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        if JobJournalLine.FindSet() then
            repeat
                JobJournalLine."Invt. Movement Template CZL" := JobJournalLine."Whse. Net Change Template";
                JobJournalLine."Correction CZL" := JobJournalLine.Correction;
                JobJournalLine."Tariff No. CZL" := JobJournalLine."Tariff No.";
                JobJournalLine."Net Weight CZL" := JobJournalLine."Net Weight";
                JobJournalLine."Country/Reg. of Orig. Code CZL" := JobJournalLine."Country/Region of Origin Code";
                JobJournalLine."Statistic Indication CZL" := JobJournalLine."Statistic Indication";
                JobJournalLine."Intrastat Transaction CZL" := JobJournalLine."Intrastat Transaction";
                JobJournalLine.Modify(false);
            until JobJournalLine.Next() = 0;
    end;

    local procedure CopyPhysInvtOrderLine();
    var
        PhysInvtOrderLine: Record "Phys. Invt. Order Line";
    begin
        if PhysInvtOrderLine.FindSet() then
            repeat
                PhysInvtOrderLine."Invt. Movement Template CZL" := PhysInvtOrderLine."Whse. Net Change Template";
                PhysInvtOrderLine.Modify(false);
            until PhysInvtOrderLine.Next() = 0;
    end;

    local procedure CopyInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup."Date Order Invt. Change CZL" := InventorySetup."Date Order Inventory Change";
            InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" := InventorySetup."Def.Template for Phys.Pos.Adj";
            InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" := InventorySetup."Def.Template for Phys.Neg.Adj";
            InventorySetup."Post Exp.Cost Conv.As Corr.CZL" := InventorySetup."Post Exp. Cost Conv. as Corr.";
            InventorySetup."Post Neg.Transf. As Corr.CZL" := InventorySetup."Post Neg. Transfers as Corr.";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure CopyGLSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup."Use VAT Date CZL" := GeneralLedgerSetup."Use VAT Date";
            GeneralLedgerSetup."Allow VAT Posting From CZL" := GeneralLedgerSetup."Allow VAT Posting From";
            GeneralLedgerSetup."Allow VAT Posting To CZL" := GeneralLedgerSetup."Allow VAT Posting To";
            GeneralLedgerSetup."Do Not Check Dimensions CZL" := GeneralLedgerSetup."Dont Check Dimension";
            GeneralLedgerSetup."Check Posting Debit/Credit CZL" := GeneralLedgerSetup."Check Posting Debit/Credit";
            GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" := GeneralLedgerSetup."Mark Neg. Qty as Correction";
            GeneralLedgerSetup."Rounding Date CZL" := GeneralLedgerSetup."Rounding Date";
            GeneralLedgerSetup."Closed Per. Entry Pos.Date CZL" := GeneralLedgerSetup."Closed Period Entry Pos.Date";
            GeneralLedgerSetup."User Checks Allowed CZL" := GeneralLedgerSetup."User Checks Allowed";
            GeneralLedgerSetup."Shared Account Schedule CZL" := GeneralLedgerSetup."Shared Account Schedule";
            GeneralLedgerSetup."Acc. Schedule Results Nos. CZL" := GeneralLedgerSetup."Acc. Schedule Results Nos.";
            GeneralLedgerSetup.Modify(false);
            if not StatutoryReportingSetupCZL.Get() then begin
                StatutoryReportingSetupCZL.Init();
                StatutoryReportingSetupCZL.Insert();
            end;
            StatutoryReportingSetupCZL."Company Official Nos." := GeneralLedgerSetup."Company Officials Nos.";
            StatutoryReportingSetupCZL.Modify();
        end;
    end;

    local procedure CopySalesSetup();
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesReceivablesSetup.Get() then begin
            SalesReceivablesSetup."Default VAT Date CZL" := SalesReceivablesSetup."Default VAT Date";
            SalesReceivablesSetup."Allow Alter Posting Groups CZL" := SalesReceivablesSetup."Allow Alter Posting Groups";
            SalesReceivablesSetup.Modify(false);
        end;
    end;

    local procedure CopyPurchaseSetup();
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if PurchasesPayablesSetup.Get() then begin
            PurchasesPayablesSetup."Default VAT Date CZL" := PurchasesPayablesSetup."Default VAT Date";
            PurchasesPayablesSetup."Allow Alter Posting Groups CZL" := PurchasesPayablesSetup."Allow Alter Posting Groups";
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" := PurchasesPayablesSetup."Default Orig. Doc. VAT Date";
            PurchasesPayablesSetup.Modify(false);
        end;
    end;

    local procedure CopyServiceSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        if ServiceMgtSetup.Get() then begin
            ServiceMgtSetup."Default VAT Date CZL" := ServiceMgtSetup."Default VAT Date";
            ServiceMgtSetup."Allow Alter Posting Groups CZL" := ServiceMgtSetup."Allow Alter Cust. Post. Groups";
            ServiceMgtSetup.Modify(false);
        end;
    end;

    local procedure CopyUserSetup();
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.FindSet(true) then
            repeat
                UserSetup."Allow VAT Posting From CZL" := UserSetup."Allow VAT Posting From";
                UserSetup."Allow VAT Posting To CZL" := UserSetup."Allow VAT Posting To";
                UserSetup."Check Doc. Date(work date) CZL" := UserSetup."Check Document Date(work date)";
                UserSetup."Check Doc. Date(sys. date) CZL" := UserSetup."Check Document Date(sys. date)";
                UserSetup."Check Post.Date(work date) CZL" := UserSetup."Check Posting Date (work date)";
                UserSetup."Check Post.Date(sys. date) CZL" := UserSetup."Check Posting Date (sys. date)";
                UserSetup."Check Bank Accounts CZL" := UserSetup."Check Bank Accounts";
                UserSetup."Check Journal Templates CZL" := UserSetup."Check Journal Templates";
                UserSetup."Check Dimension Values CZL" := UserSetup."Check Dimension Values";
                UserSetup."Allow Post.toClosed Period CZL" := UserSetup."Allow Posting to Closed Period";
                UserSetup."Allow Complete Job CZL" := UserSetup."Allow Complete Job";
                UserSetup."Employee No. CZL" := UserSetup."Employee No.";
                UserSetup."User Name CZL" := UserSetup."User Name";
                UserSetup."Allow Item Unapply CZL" := UserSetup."Allow Item Unapply";
                UserSetup."Check Location Code CZL" := UserSetup."Check Location Code";
                UserSetup."Check Release LocationCode CZL" := UserSetup."Check Release Location Code";
                UserSetup."Check Invt. Movement Temp. CZL" := UserSetup."Check Whse. Net Change Temp.";
                UserSetup.Modify(false);
            until UserSetup.Next() = 0;
    end;

    local procedure CopyVATPeriod();
    var
        VATPeriod: Record "VAT Period";
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        if VATPeriod.FindSet(true) then
            repeat
                if not VATPeriodCZL.Get(VATPeriod."Starting Date") then begin
                    VATPeriodCZL.Init();
                    VATPeriodCZL."Starting Date" := VATPeriod."Starting Date";
                    VATPeriodCZL.SystemId := VATPeriod.SystemId;
                    VATPeriodCZL.Insert(false, true);
                end;
                VATPeriodCZL.Name := VATPeriod.Name;
                VATPeriodCZL."New VAT Year" := VATPeriod."New VAT Year";
                VATPeriodCZL.Closed := VATPeriod.Closed;
                VATPeriodCZL.Modify(false);
            until VATPeriod.Next() = 0;
    end;

    local procedure CopyGLEntry();
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetFilter(GLEntry."VAT Date", '<>0D');
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."VAT Date CZL" := GLEntry."VAT Date";
                GLEntry.Modify(false);
            until GLEntry.Next() = 0;

    end;

    local procedure CopyCustLedgerEntry();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgerEntry.FindSet(true) then
            repeat
                CustLedgerEntry."Specific Symbol CZL" := CustLedgerEntry."Specific Symbol";
                CustLedgerEntry."Variable Symbol CZL" := CustLedgerEntry."Variable Symbol";
                CustLedgerEntry."Constant Symbol CZL" := CustLedgerEntry."Constant Symbol";
                CustLedgerEntry."Bank Account Code CZL" := CustLedgerEntry."Bank Account Code";
                CustLedgerEntry."Bank Account No. CZL" := CustLedgerEntry."Bank Account No.";
                CustLedgerEntry."Transit No. CZL" := CustLedgerEntry."Transit No.";
                CustLedgerEntry."IBAN CZL" := CustLedgerEntry.IBAN;
                CustLedgerEntry."SWIFT Code CZL" := CustLedgerEntry."SWIFT Code";
                CustLedgerEntry."VAT Date CZL" := CustLedgerEntry."VAT Date";
                CustLedgerEntry.Modify(false);
            until CustLedgerEntry.Next() = 0;

    end;

    local procedure CopyDetailedCustLedgEntry();
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
#if CLEAN18
        ApplTransactionDictionary: Dictionary of [Integer, Boolean];
#else
        ApplAcrCustPostGroupsCZL: Query "Appl.Acr. Cust.Post.Groups CZL";
        ApplAcrossPostGrpEntryNo: List of [Integer];
#endif
    begin
#if not CLEAN18
        if ApplAcrCustPostGroupsCZL.Open() then
            while ApplAcrCustPostGroupsCZL.Read() do
                ApplAcrossPostGrpEntryNo.Add(ApplAcrCustPostGroupsCZL.Entry_No_);
#endif

        if DetailedCustLedgEntry.FindSet(true) then
            repeat
                DetailedCustLedgEntry."Customer Posting Group CZL" := DetailedCustLedgEntry."Customer Posting Group";
#if CLEAN18
                if DetailedCustLedgEntry."Entry Type" = DetailedCustLedgEntry."Entry Type"::Application then
                    DetailedCustLedgEntry."Appl. Across Post. Groups CZL" :=
                        IsCustomerApplAcrossPostGrpTransaction(DetailedCustLedgEntry."Transaction No.", ApplTransactionDictionary);
#else
                if ApplAcrossPostGrpEntryNo.Contains(DetailedCustLedgEntry."Entry No.") then
                    DetailedCustLedgEntry."Appl. Across Post. Groups CZL" := true;
#endif
                DetailedCustLedgEntry.Modify(false);
            until DetailedCustLedgEntry.Next() = 0;
    end;

#if CLEAN18
    procedure IsCustomerApplAcrossPostGrpTransaction(TransactionNo: Integer; var ApplTransactionDictionary: Dictionary of [Integer, Boolean]) ApplAcrossPostGroups: Boolean
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        FirstCustomerPostingGroup: Code[20];
    begin
        if not ApplTransactionDictionary.Get(TransactionNo, ApplAcrossPostGroups) then begin
            FirstCustomerPostingGroup := '';
            DetailedCustLedgEntry.SetCurrentKey("Transaction No.", "Customer No.", "Entry Type");
            DetailedCustLedgEntry.SetRange("Transaction No.", TransactionNo);
            DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
            if DetailedCustLedgEntry.FindSet() then
                repeat
                    if FirstCustomerPostingGroup = '' then
                        FirstCustomerPostingGroup := DetailedCustLedgEntry."Customer Posting Group";
                    ApplAcrossPostGroups := FirstCustomerPostingGroup <> DetailedCustLedgEntry."Customer Posting Group";
                until ApplAcrossPostGroups or (DetailedCustLedgEntry.Next() = 0);
            ApplTransactionDictionary.Add(TransactionNo, ApplAcrossPostGroups);
        end;
    end;

#endif
    local procedure CopyVendLedgerEntry();
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if VendorLedgerEntry.FindSet(true) then
            repeat
                VendorLedgerEntry."Specific Symbol CZL" := VendorLedgerEntry."Specific Symbol";
                VendorLedgerEntry."Variable Symbol CZL" := VendorLedgerEntry."Variable Symbol";
                VendorLedgerEntry."Constant Symbol CZL" := VendorLedgerEntry."Constant Symbol";
                VendorLedgerEntry."Bank Account Code CZL" := VendorLedgerEntry."Bank Account Code";
                VendorLedgerEntry."Bank Account No. CZL" := VendorLedgerEntry."Bank Account No.";
                VendorLedgerEntry."Transit No. CZL" := VendorLedgerEntry."Transit No.";
                VendorLedgerEntry."IBAN CZL" := VendorLedgerEntry.IBAN;
                VendorLedgerEntry."SWIFT Code CZL" := VendorLedgerEntry."SWIFT Code";
                VendorLedgerEntry."VAT Date CZL" := VendorLedgerEntry."VAT Date";
                VendorLedgerEntry.Modify(false);
            until VendorLedgerEntry.Next() = 0;

    end;

    local procedure CopyDetailedVendorLedgEntry();
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
#if CLEAN18
        ApplTransactionDictionary: Dictionary of [Integer, Boolean];
#else
        ApplAcrVendPostGroupsCZL: Query "Appl.Acr. Vend.Post.Groups CZL";
        ApplAcrossPostGrpEntryNo: List of [Integer];
#endif
    begin
#if not CLEAN18
        if ApplAcrVendPostGroupsCZL.Open() then
            while ApplAcrVendPostGroupsCZL.Read() do
                ApplAcrossPostGrpEntryNo.Add(ApplAcrVendPostGroupsCZL.Entry_No_);
#endif

        if DetailedVendorLedgEntry.FindSet(true) then
            repeat
                DetailedVendorLedgEntry."Vendor Posting Group CZL" := DetailedVendorLedgEntry."Vendor Posting Group";
#if CLEAN18
                if DetailedVendorLedgEntry."Entry Type" = DetailedVendorLedgEntry."Entry Type"::Application then
                    DetailedVendorLedgEntry."Appl. Across Post. Groups CZL" :=
                        IsVendorApplAcrossPostGrpTransaction(DetailedVendorLedgEntry."Transaction No.", ApplTransactionDictionary);
#else
                if ApplAcrossPostGrpEntryNo.Contains(DetailedVendorLedgEntry."Entry No.") then
                    DetailedVendorLedgEntry."Appl. Across Post. Groups CZL" := true;
#endif
                DetailedVendorLedgEntry.Modify(false);
            until DetailedVendorLedgEntry.Next() = 0;
    end;

#if CLEAN18
    procedure IsVendorApplAcrossPostGrpTransaction(TransactionNo: Integer; var ApplTransactionDictionary: Dictionary of [Integer, Boolean]) ApplAcrossPostGroups: Boolean
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        FirstVendorPostingGroup: Code[20];
    begin
        if not ApplTransactionDictionary.Get(TransactionNo, ApplAcrossPostGroups) then begin
            FirstVendorPostingGroup := '';
            DetailedVendorLedgEntry.SetCurrentKey("Transaction No.", "Vendor No.", "Entry Type");
            DetailedVendorLedgEntry.SetRange("Transaction No.", TransactionNo);
            DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::Application);
            if DetailedVendorLedgEntry.FindSet() then
                repeat
                    if FirstVendorPostingGroup = '' then
                        FirstVendorPostingGroup := DetailedVendorLedgEntry."Vendor Posting Group";
                    ApplAcrossPostGroups := FirstVendorPostingGroup <> DetailedVendorLedgEntry."Vendor Posting Group";
                until ApplAcrossPostGroups or (DetailedVendorLedgEntry.Next() = 0);
            ApplTransactionDictionary.Add(TransactionNo, ApplAcrossPostGroups);
        end;
    end;

#endif
    local procedure CopyVATEntry();
    var
        VATEntry: Record "VAT Entry";
    begin
        if VATEntry.FindSet(true) then
            repeat
                VATEntry."VAT Date CZL" := VATEntry."VAT Date";
                VATEntry."Registration No. CZL" := VATEntry."Registration No.";
                VATEntry."VAT Settlement No. CZL" := VATEntry."VAT Settlement No.";
                VATEntry."Original Doc. VAT Date CZL" := VATEntry."Original Document VAT Date";
                VATEntry."EU 3-Party Intermed. Role CZL" := VATEntry."EU 3-Party Intermediate Role";
                VATEntry."VAT Delay CZL" := VATEntry."VAT Delay";
                VATEntry."VAT Identifier CZL" := VATEntry."VAT Identifier";
                VATEntry.Modify(false);
            until VATEntry.Next() = 0;
    end;

    local procedure CopyGenJournalLine();
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if GenJournalLine.FindSet(true) then
            repeat
                GenJournalLine."Specific Symbol CZL" := GenJournalLine."Specific Symbol";
                GenJournalLine."Variable Symbol CZL" := GenJournalLine."Variable Symbol";
                GenJournalLine."Constant Symbol CZL" := GenJournalLine."Constant Symbol";
                GenJournalLine."Bank Account Code CZL" := GenJournalLine."Bank Account Code";
                GenJournalLine."Bank Account No. CZL" := GenJournalLine."Bank Account No.";
                GenJournalLine."Transit No. CZL" := GenJournalLine."Transit No.";
                GenJournalLine."IBAN CZL" := GenJournalLine.IBAN;
                GenJournalLine."SWIFT Code CZL" := GenJournalLine."SWIFT Code";
                GenJournalLine."VAT Date CZL" := GenJournalLine."VAT Date";
                GenJournalLine."Registration No. CZL" := GenJournalLine."Registration No.";
                GenJournalLine."Tax Registration No. CZL" := GenJournalLine."Tax Registration No.";
                GenJournalLine."EU 3-Party Intermed. Role CZL" := GenJournalLine."EU 3-Party Intermediate Role";
                GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."Original Document VAT Date";
                GenJournalLine."Original Doc. Partner Type CZL" := GenJournalLine."Original Document Partner Type";
                GenJournalLine."Original Doc. Partner No. CZL" := GenJournalLine."Original Document Partner No.";
                GenJournalLine."VAT Currency Factor CZL" := GenJournalLine."Currency Factor VAT";
                GenJournalLine."VAT Currency Code CZL" := GenJournalLine."Currency Code VAT";
                GenJournalLine."VAT Delay CZL" := GenJournalLine."VAT Delay";
                GenJournalLine.Modify(false);
            until GenJournalLine.Next() = 0;
    end;

    local procedure CopySalesHeader();
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.FindSet(true) then
            repeat
                SalesHeader."Specific Symbol CZL" := SalesHeader."Specific Symbol";
                SalesHeader."Variable Symbol CZL" := SalesHeader."Variable Symbol";
                SalesHeader."Constant Symbol CZL" := SalesHeader."Constant Symbol";
                SalesHeader."Bank Account Code CZL" := SalesHeader."Bank Account Code";
                SalesHeader."Bank Account No. CZL" := SalesHeader."Bank Account No.";
                SalesHeader."Bank Branch No. CZL" := SalesHeader."Bank Branch No.";
                SalesHeader."Bank Name CZL" := SalesHeader."Bank Name";
                SalesHeader."Transit No. CZL" := SalesHeader."Transit No.";
                SalesHeader."IBAN CZL" := SalesHeader.IBAN;
                SalesHeader."SWIFT Code CZL" := SalesHeader."SWIFT Code";
                SalesHeader."VAT Date CZL" := SalesHeader."VAT Date";
                SalesHeader."Registration No. CZL" := SalesHeader."Registration No.";
                SalesHeader."Tax Registration No. CZL" := SalesHeader."Tax Registration No.";
                SalesHeader."Credit Memo Type CZL" := SalesHeader."Credit Memo Type";
                SalesHeader."Physical Transfer CZL" := SalesHeader."Physical Transfer";
                SalesHeader."Intrastat Exclude CZL" := SalesHeader."Intrastat Exclude";
                SalesHeader."EU 3-Party Intermed. Role CZL" := SalesHeader."EU 3-Party Intermediate Role";
                SalesHeader."Original Doc. VAT Date CZL" := SalesHeader."Original Document VAT Date";
                SalesHeader."VAT Currency Factor CZL" := SalesHeader."VAT Currency Factor";
                SalesHeader."VAT Currency Code CZL" := SalesHeader."Currency Code";
                SalesHeader.Modify(false);
            until SalesHeader.Next() = 0;
    end;

    local procedure CopySalesShipmentHeader();
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if SalesShipmentHeader.FindSet(true) then
            repeat
                SalesShipmentHeader."Registration No. CZL" := SalesShipmentHeader."Registration No.";
                SalesShipmentHeader."Tax Registration No. CZL" := SalesShipmentHeader."Tax Registration No.";
                SalesShipmentHeader."Physical Transfer CZL" := SalesShipmentHeader."Physical Transfer";
                SalesShipmentHeader."Intrastat Exclude CZL" := SalesShipmentHeader."Intrastat Exclude";
                SalesShipmentHeader."EU 3-Party Intermed. Role CZL" := SalesShipmentHeader."EU 3-Party Intermediate Role";
                SalesShipmentHeader.Modify(false);
            until SalesShipmentHeader.Next() = 0;
    end;

    local procedure CopySalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                SalesInvoiceHeader."Specific Symbol CZL" := SalesInvoiceHeader."Specific Symbol";
                SalesInvoiceHeader."Variable Symbol CZL" := SalesInvoiceHeader."Variable Symbol";
                SalesInvoiceHeader."Constant Symbol CZL" := SalesInvoiceHeader."Constant Symbol";
                SalesInvoiceHeader."Bank Account Code CZL" := SalesInvoiceHeader."Bank Account Code";
                SalesInvoiceHeader."Bank Account No. CZL" := SalesInvoiceHeader."Bank Account No.";
                SalesInvoiceHeader."Bank Branch No. CZL" := SalesInvoiceHeader."Bank Branch No.";
                SalesInvoiceHeader."Bank Name CZL" := SalesInvoiceHeader."Bank Name";
                SalesInvoiceHeader."Transit No. CZL" := SalesInvoiceHeader."Transit No.";
                SalesInvoiceHeader."IBAN CZL" := SalesInvoiceHeader.IBAN;
                SalesInvoiceHeader."SWIFT Code CZL" := SalesInvoiceHeader."SWIFT Code";
                SalesInvoiceHeader."VAT Date CZL" := SalesInvoiceHeader."VAT Date";
                SalesInvoiceHeader."Registration No. CZL" := SalesInvoiceHeader."Registration No.";
                SalesInvoiceHeader."Tax Registration No. CZL" := SalesInvoiceHeader."Tax Registration No.";
                SalesInvoiceHeader."Physical Transfer CZL" := SalesInvoiceHeader."Physical Transfer";
                SalesInvoiceHeader."Intrastat Exclude CZL" := SalesInvoiceHeader."Intrastat Exclude";
                SalesInvoiceHeader."EU 3-Party Intermed. Role CZL" := SalesInvoiceHeader."EU 3-Party Intermediate Role";
                SalesInvoiceHeader."VAT Currency Factor CZL" := SalesInvoiceHeader."VAT Currency Factor";
                SalesInvoiceHeader."VAT Currency Code CZL" := SalesInvoiceHeader."Currency Code";
                SalesInvoiceHeader.Modify(false);
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure CopySalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if SalesCrMemoHeader.FindSet(true) then
            repeat
                SalesCrMemoHeader."Specific Symbol CZL" := SalesCrMemoHeader."Specific Symbol";
                SalesCrMemoHeader."Variable Symbol CZL" := SalesCrMemoHeader."Variable Symbol";
                SalesCrMemoHeader."Constant Symbol CZL" := SalesCrMemoHeader."Constant Symbol";
                SalesCrMemoHeader."Bank Account Code CZL" := SalesCrMemoHeader."Bank Account Code";
                SalesCrMemoHeader."Bank Account No. CZL" := SalesCrMemoHeader."Bank Account No.";
                SalesCrMemoHeader."Bank Branch No. CZL" := SalesCrMemoHeader."Bank Branch No.";
                SalesCrMemoHeader."Bank Name CZL" := SalesCrMemoHeader."Bank Name";
                SalesCrMemoHeader."Transit No. CZL" := SalesCrMemoHeader."Transit No.";
                SalesCrMemoHeader."IBAN CZL" := SalesCrMemoHeader.IBAN;
                SalesCrMemoHeader."SWIFT Code CZL" := SalesCrMemoHeader."SWIFT Code";
                SalesCrMemoHeader."VAT Date CZL" := SalesCrMemoHeader."VAT Date";
                SalesCrMemoHeader."Registration No. CZL" := SalesCrMemoHeader."Registration No.";
                SalesCrMemoHeader."Tax Registration No. CZL" := SalesCrMemoHeader."Tax Registration No.";
                SalesCrMemoHeader."Physical Transfer CZL" := SalesCrMemoHeader."Physical Transfer";
                SalesCrMemoHeader."Intrastat Exclude CZL" := SalesCrMemoHeader."Intrastat Exclude";
                SalesCrMemoHeader."Credit Memo Type CZL" := SalesCrMemoHeader."Credit Memo Type";
                SalesCrMemoHeader."EU 3-Party Intermed. Role CZL" := SalesCrMemoHeader."EU 3-Party Intermediate Role";
                SalesCrMemoHeader."VAT Currency Factor CZL" := SalesCrMemoHeader."VAT Currency Factor";
                SalesCrMemoHeader."VAT Currency Code CZL" := SalesCrMemoHeader."Currency Code";
                SalesCrMemoHeader.Modify(false);
            until SalesCrMemoHeader.Next() = 0;
    end;

    local procedure CopyReturnReceiptHeader();
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
    begin
        if ReturnReceiptHeader.FindSet(true) then
            repeat
                ReturnReceiptHeader."Registration No. CZL" := ReturnReceiptHeader."Registration No.";
                ReturnReceiptHeader."Tax Registration No. CZL" := ReturnReceiptHeader."Tax Registration No.";
                ReturnReceiptHeader."Physical Transfer CZL" := ReturnReceiptHeader."Physical Transfer";
                ReturnReceiptHeader."Intrastat Exclude CZL" := ReturnReceiptHeader."Intrastat Exclude";
                ReturnReceiptHeader.Modify(false);
            until ReturnReceiptHeader.Next() = 0;
    end;

    local procedure CopySalesHeaderArchive();
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        if SalesHeaderArchive.FindSet(true) then
            repeat
                SalesHeaderArchive."Specific Symbol CZL" := SalesHeaderArchive."Specific Symbol";
                SalesHeaderArchive."Variable Symbol CZL" := SalesHeaderArchive."Variable Symbol";
                SalesHeaderArchive."Constant Symbol CZL" := SalesHeaderArchive."Constant Symbol";
                SalesHeaderArchive."Bank Account Code CZL" := SalesHeaderArchive."Bank Account Code";
                SalesHeaderArchive."Bank Account No. CZL" := SalesHeaderArchive."Bank Account No.";
                SalesHeaderArchive."Transit No. CZL" := SalesHeaderArchive."Transit No.";
                SalesHeaderArchive."IBAN CZL" := SalesHeaderArchive.IBAN;
                SalesHeaderArchive."SWIFT Code CZL" := SalesHeaderArchive."SWIFT Code";
                SalesHeaderArchive."VAT Date CZL" := SalesHeaderArchive."VAT Date";
                SalesHeaderArchive."Registration No. CZL" := SalesHeaderArchive."Registration No.";
                SalesHeaderArchive."Tax Registration No. CZL" := SalesHeaderArchive."Tax Registration No.";
                SalesHeaderArchive."Intrastat Exclude CZL" := SalesHeaderArchive."Intrastat Exclude";
                SalesHeaderArchive."Physical Transfer CZL" := SalesHeaderArchive."Physical Transfer";
                SalesHeaderArchive."EU 3-Party Intermed. Role CZL" := SalesHeaderArchive."EU 3-Party Intermediate Role";
                SalesHeaderArchive."VAT Currency Factor CZL" := SalesHeaderArchive."VAT Currency Factor";
                SalesHeaderArchive."VAT Currency Code CZL" := SalesHeaderArchive."Currency Code";
                SalesHeaderArchive.Modify(false);
            until SalesHeaderArchive.Next() = 0;
    end;

    local procedure CopyPurchaseHeader();
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.FindSet(true) then
            repeat
                PurchaseHeader."Specific Symbol CZL" := PurchaseHeader."Specific Symbol";
                PurchaseHeader."Variable Symbol CZL" := PurchaseHeader."Variable Symbol";
                PurchaseHeader."Constant Symbol CZL" := PurchaseHeader."Constant Symbol";
                PurchaseHeader."Bank Account Code CZL" := PurchaseHeader."Bank Account Code";
                PurchaseHeader."Bank Account No. CZL" := PurchaseHeader."Bank Account No.";
                PurchaseHeader."Bank Branch No. CZL" := PurchaseHeader."Bank Branch No.";
                PurchaseHeader."Bank Name CZL" := PurchaseHeader."Bank Name";
                PurchaseHeader."Transit No. CZL" := PurchaseHeader."Transit No.";
                PurchaseHeader."IBAN CZL" := PurchaseHeader.IBAN;
                PurchaseHeader."SWIFT Code CZL" := PurchaseHeader."SWIFT Code";
                PurchaseHeader."VAT Date CZL" := PurchaseHeader."VAT Date";
                PurchaseHeader."Registration No. CZL" := PurchaseHeader."Registration No.";
                PurchaseHeader."Tax Registration No. CZL" := PurchaseHeader."Tax Registration No.";
                PurchaseHeader."Physical Transfer CZL" := PurchaseHeader."Physical Transfer";
                PurchaseHeader."Intrastat Exclude CZL" := PurchaseHeader."Intrastat Exclude";
                PurchaseHeader."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermediate Role";
                PurchaseHeader."EU 3-Party Trade CZL" := PurchaseHeader."EU 3-Party Trade";
                PurchaseHeader."Original Doc. VAT Date CZL" := PurchaseHeader."Original Document VAT Date";
                PurchaseHeader."VAT Currency Factor CZL" := PurchaseHeader."VAT Currency Factor";
                PurchaseHeader."VAT Currency Code CZL" := PurchaseHeader."Currency Code";
                PurchaseHeader.Modify(false);
            until PurchaseHeader.Next() = 0;
    end;

    local procedure CopyPurchaseReceiptHeader();
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if PurchRcptHeader.FindSet(true) then
            repeat
                PurchRcptHeader."Registration No. CZL" := PurchRcptHeader."Registration No.";
                PurchRcptHeader."Tax Registration No. CZL" := PurchRcptHeader."Tax Registration No.";
                PurchRcptHeader."Physical Transfer CZL" := PurchRcptHeader."Physical Transfer";
                PurchRcptHeader."Intrastat Exclude CZL" := PurchRcptHeader."Intrastat Exclude";
                PurchRcptHeader."EU 3-Party Intermed. Role CZL" := PurchRcptHeader."EU 3-Party Intermediate Role";
                PurchRcptHeader."EU 3-Party Trade CZL" := PurchRcptHeader."EU 3-Party Trade";
                PurchRcptHeader.Modify(false);
            until PurchRcptHeader.Next() = 0;
    end;

    local procedure CopyPurchaseInvoiceHeader();
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if PurchInvHeader.FindSet(true) then
            repeat
                PurchInvHeader."Specific Symbol CZL" := PurchInvHeader."Specific Symbol";
                PurchInvHeader."Variable Symbol CZL" := PurchInvHeader."Variable Symbol";
                PurchInvHeader."Constant Symbol CZL" := PurchInvHeader."Constant Symbol";
                PurchInvHeader."Bank Account Code CZL" := PurchInvHeader."Bank Account Code";
                PurchInvHeader."Bank Account No. CZL" := PurchInvHeader."Bank Account No.";
                PurchInvHeader."Transit No. CZL" := PurchInvHeader."Transit No.";
                PurchInvHeader."IBAN CZL" := PurchInvHeader.IBAN;
                PurchInvHeader."SWIFT Code CZL" := PurchInvHeader."SWIFT Code";
                PurchInvHeader."VAT Date CZL" := PurchInvHeader."VAT Date";
                PurchInvHeader."Registration No. CZL" := PurchInvHeader."Registration No.";
                PurchInvHeader."Tax Registration No. CZL" := PurchInvHeader."Tax Registration No.";
                PurchInvHeader."Physical Transfer CZL" := PurchInvHeader."Physical Transfer";
                PurchInvHeader."Intrastat Exclude CZL" := PurchInvHeader."Intrastat Exclude";
                PurchInvHeader."EU 3-Party Intermed. Role CZL" := PurchInvHeader."EU 3-Party Intermediate Role";
                PurchInvHeader."EU 3-Party Trade CZL" := PurchInvHeader."EU 3-Party Trade";
                PurchInvHeader."Original Doc. VAT Date CZL" := PurchInvHeader."Original Document VAT Date";
                PurchInvHeader."VAT Currency Factor CZL" := PurchInvHeader."VAT Currency Factor";
                PurchInvHeader."VAT Currency Code CZL" := PurchInvHeader."Currency Code";
                PurchInvHeader.Modify(false);
            until PurchInvHeader.Next() = 0;
    end;

    local procedure CopyPurchaseCrMemoHeader();
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if PurchCrMemoHdr.FindSet(true) then
            repeat
                PurchCrMemoHdr."Specific Symbol CZL" := PurchCrMemoHdr."Specific Symbol";
                PurchCrMemoHdr."Variable Symbol CZL" := PurchCrMemoHdr."Variable Symbol";
                PurchCrMemoHdr."Constant Symbol CZL" := PurchCrMemoHdr."Constant Symbol";
                PurchCrMemoHdr."Bank Account Code CZL" := PurchCrMemoHdr."Bank Account Code";
                PurchCrMemoHdr."Bank Account No. CZL" := PurchCrMemoHdr."Bank Account No.";
                PurchCrMemoHdr."Transit No. CZL" := PurchCrMemoHdr."Transit No.";
                PurchCrMemoHdr."IBAN CZL" := PurchCrMemoHdr.IBAN;
                PurchCrMemoHdr."SWIFT Code CZL" := PurchCrMemoHdr."SWIFT Code";
                PurchCrMemoHdr."VAT Date CZL" := PurchCrMemoHdr."VAT Date";
                PurchCrMemoHdr."Registration No. CZL" := PurchCrMemoHdr."Registration No.";
                PurchCrMemoHdr."Tax Registration No. CZL" := PurchCrMemoHdr."Tax Registration No.";
                PurchCrMemoHdr."Physical Transfer CZL" := PurchCrMemoHdr."Physical Transfer";
                PurchCrMemoHdr."Intrastat Exclude CZL" := PurchCrMemoHdr."Intrastat Exclude";
                PurchCrMemoHdr."EU 3-Party Intermed. Role CZL" := PurchCrMemoHdr."EU 3-Party Intermediate Role";
                PurchCrMemoHdr."EU 3-Party Trade CZL" := PurchCrMemoHdr."EU 3-Party Trade";
                PurchCrMemoHdr."Original Doc. VAT Date CZL" := PurchCrMemoHdr."Original Document VAT Date";
                PurchCrMemoHdr."VAT Currency Factor CZL" := PurchCrMemoHdr."VAT Currency Factor";
                PurchCrMemoHdr."VAT Currency Code CZL" := PurchCrMemoHdr."Currency Code";
                PurchCrMemoHdr.Modify(false);
            until PurchCrMemoHdr.Next() = 0;
    end;

    local procedure CopyReturnShipmentHeader();
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        if ReturnShipmentHeader.FindSet(true) then
            repeat
                ReturnShipmentHeader."Registration No. CZL" := ReturnShipmentHeader."Registration No.";
                ReturnShipmentHeader."Tax Registration No. CZL" := ReturnShipmentHeader."Tax Registration No.";
                ReturnShipmentHeader."Physical Transfer CZL" := ReturnShipmentHeader."Physical Transfer";
                ReturnShipmentHeader."Intrastat Exclude CZL" := ReturnShipmentHeader."Intrastat Exclude";
                ReturnShipmentHeader."EU 3-Party Trade CZL" := ReturnShipmentHeader."EU 3-Party Trade";
                ReturnShipmentHeader.Modify(false);
            until ReturnShipmentHeader.Next() = 0;
    end;

    local procedure CopyPurchaseHeaderArchive();
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
    begin
        if PurchaseHeaderArchive.FindSet(true) then
            repeat
                PurchaseHeaderArchive."Specific Symbol CZL" := PurchaseHeaderArchive."Specific Symbol";
                PurchaseHeaderArchive."Variable Symbol CZL" := PurchaseHeaderArchive."Variable Symbol";
                PurchaseHeaderArchive."Constant Symbol CZL" := PurchaseHeaderArchive."Constant Symbol";
                PurchaseHeaderArchive."Bank Account Code CZL" := PurchaseHeaderArchive."Bank Account Code";
                PurchaseHeaderArchive."Bank Account No. CZL" := PurchaseHeaderArchive."Bank Account No.";
                PurchaseHeaderArchive."Transit No. CZL" := PurchaseHeaderArchive."Transit No.";
                PurchaseHeaderArchive."IBAN CZL" := PurchaseHeaderArchive.IBAN;
                PurchaseHeaderArchive."SWIFT Code CZL" := PurchaseHeaderArchive."SWIFT Code";
                PurchaseHeaderArchive."VAT Date CZL" := PurchaseHeaderArchive."VAT Date";
                PurchaseHeaderArchive."Registration No. CZL" := PurchaseHeaderArchive."Registration No.";
                PurchaseHeaderArchive."Tax Registration No. CZL" := PurchaseHeaderArchive."Tax Registration No.";
                PurchaseHeaderArchive."EU 3-Party Intermed. Role CZL" := PurchaseHeaderArchive."EU 3-Party Intermediate Role";
                PurchaseHeaderArchive."EU 3-Party Trade CZL" := PurchaseHeaderArchive."EU 3-Party Trade";
                PurchaseHeaderArchive."VAT Currency Factor CZL" := PurchaseHeaderArchive."VAT Currency Factor";
                PurchaseHeaderArchive."VAT Currency Code CZL" := PurchaseHeaderArchive."Currency Code";
                PurchaseHeaderArchive.Modify(false);
            until PurchaseHeaderArchive.Next() = 0;
    end;

    local procedure CopyServiceHeader();
    var
        ServiceHeader: Record "Service Header";
    begin
        if ServiceHeader.FindSet(true) then
            repeat
                ServiceHeader."Specific Symbol CZL" := ServiceHeader."Specific Symbol";
                ServiceHeader."Variable Symbol CZL" := ServiceHeader."Variable Symbol";
                ServiceHeader."Constant Symbol CZL" := ServiceHeader."Constant Symbol";
                ServiceHeader."Bank Account Code CZL" := ServiceHeader."Bank Account Code";
                ServiceHeader."Bank Account No. CZL" := ServiceHeader."Bank Account No.";
                ServiceHeader."Bank Branch No. CZL" := ServiceHeader."Bank Branch No.";
                ServiceHeader."Bank Name CZL" := ServiceHeader."Bank Name";
                ServiceHeader."Transit No. CZL" := ServiceHeader."Transit No.";
                ServiceHeader."IBAN CZL" := ServiceHeader.IBAN;
                ServiceHeader."SWIFT Code CZL" := ServiceHeader."SWIFT Code";
                ServiceHeader."VAT Date CZL" := ServiceHeader."VAT Date";
                ServiceHeader."Registration No. CZL" := ServiceHeader."Registration No.";
                ServiceHeader."Tax Registration No. CZL" := ServiceHeader."Tax Registration No.";
                ServiceHeader."Physical Transfer CZL" := ServiceHeader."Physical Transfer";
                ServiceHeader."Intrastat Exclude CZL" := ServiceHeader."Intrastat Exclude";
                ServiceHeader."Credit Memo Type CZL" := ServiceHeader."Credit Memo Type";
                ServiceHeader."EU 3-Party Intermed. Role CZL" := ServiceHeader."EU 3-Party Intermediate Role";
                ServiceHeader."VAT Currency Factor CZL" := ServiceHeader."VAT Currency Factor";
                ServiceHeader."VAT Currency Code CZL" := ServiceHeader."Currency Code";
                ServiceHeader.Modify(false);
            until ServiceHeader.Next() = 0;
    end;

    local procedure CopyServiceShipmentHeader();
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        if ServiceShipmentHeader.FindSet(true) then
            repeat
                ServiceShipmentHeader."Registration No. CZL" := ServiceShipmentHeader."Registration No.";
                ServiceShipmentHeader."Tax Registration No. CZL" := ServiceShipmentHeader."Tax Registration No.";
                ServiceShipmentHeader."Physical Transfer CZL" := ServiceShipmentHeader."Physical Transfer";
                ServiceShipmentHeader."Intrastat Exclude CZL" := ServiceShipmentHeader."Intrastat Exclude";
                ServiceShipmentHeader."EU 3-Party Intermed. Role CZL" := ServiceShipmentHeader."EU 3-Party Intermediate Role";
                ServiceShipmentHeader.Modify(false);
            until ServiceShipmentHeader.Next() = 0;
    end;

    local procedure CopyServiceInvoiceHeader();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                ServiceInvoiceHeader."Specific Symbol CZL" := ServiceInvoiceHeader."Specific Symbol";
                ServiceInvoiceHeader."Variable Symbol CZL" := ServiceInvoiceHeader."Variable Symbol";
                ServiceInvoiceHeader."Constant Symbol CZL" := ServiceInvoiceHeader."Constant Symbol";
                ServiceInvoiceHeader."Bank Account Code CZL" := ServiceInvoiceHeader."Bank Account Code";
                ServiceInvoiceHeader."Bank Account No. CZL" := ServiceInvoiceHeader."Bank Account No.";
                ServiceInvoiceHeader."Bank Branch No. CZL" := ServiceInvoiceHeader."Bank Branch No.";
                ServiceInvoiceHeader."Bank Name CZL" := ServiceInvoiceHeader."Bank Name";
                ServiceInvoiceHeader."Transit No. CZL" := ServiceInvoiceHeader."Transit No.";
                ServiceInvoiceHeader."IBAN CZL" := ServiceInvoiceHeader.IBAN;
                ServiceInvoiceHeader."SWIFT Code CZL" := ServiceInvoiceHeader."SWIFT Code";
                ServiceInvoiceHeader."VAT Date CZL" := ServiceInvoiceHeader."VAT Date";
                ServiceInvoiceHeader."Registration No. CZL" := ServiceInvoiceHeader."Registration No.";
                ServiceInvoiceHeader."Tax Registration No. CZL" := ServiceInvoiceHeader."Tax Registration No.";
                ServiceInvoiceHeader."Physical Transfer CZL" := ServiceInvoiceHeader."Physical Transfer";
                ServiceInvoiceHeader."Intrastat Exclude CZL" := ServiceInvoiceHeader."Intrastat Exclude";
                ServiceInvoiceHeader."EU 3-Party Intermed. Role CZL" := ServiceInvoiceHeader."EU 3-Party Intermediate Role";
                ServiceInvoiceHeader."VAT Currency Factor CZL" := ServiceInvoiceHeader."VAT Currency Factor";
                ServiceInvoiceHeader."VAT Currency Code CZL" := ServiceInvoiceHeader."Currency Code";
                ServiceInvoiceHeader.Modify(false);
            until ServiceInvoiceHeader.Next() = 0;
    end;

    local procedure CopyServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        if ServiceCrMemoHeader.FindSet(true) then
            repeat
                ServiceCrMemoHeader."Specific Symbol CZL" := ServiceCrMemoHeader."Specific Symbol";
                ServiceCrMemoHeader."Variable Symbol CZL" := ServiceCrMemoHeader."Variable Symbol";
                ServiceCrMemoHeader."Constant Symbol CZL" := ServiceCrMemoHeader."Constant Symbol";
                ServiceCrMemoHeader."Bank Account Code CZL" := ServiceCrMemoHeader."Bank Account Code";
                ServiceCrMemoHeader."Bank Account No. CZL" := ServiceCrMemoHeader."Bank Account No.";
                ServiceCrMemoHeader."Bank Branch No. CZL" := ServiceCrMemoHeader."Bank Branch No.";
                ServiceCrMemoHeader."Bank Name CZL" := ServiceCrMemoHeader."Bank Name";
                ServiceCrMemoHeader."Transit No. CZL" := ServiceCrMemoHeader."Transit No.";
                ServiceCrMemoHeader."IBAN CZL" := ServiceCrMemoHeader.IBAN;
                ServiceCrMemoHeader."SWIFT Code CZL" := ServiceCrMemoHeader."SWIFT Code";
                ServiceCrMemoHeader."VAT Date CZL" := ServiceCrMemoHeader."VAT Date";
                ServiceCrMemoHeader."Registration No. CZL" := ServiceCrMemoHeader."Registration No.";
                ServiceCrMemoHeader."Tax Registration No. CZL" := ServiceCrMemoHeader."Tax Registration No.";
                ServiceCrMemoHeader."Physical Transfer CZL" := ServiceCrMemoHeader."Physical Transfer";
                ServiceCrMemoHeader."Intrastat Exclude CZL" := ServiceCrMemoHeader."Intrastat Exclude";
                ServiceCrMemoHeader."Credit Memo Type CZL" := ServiceCrMemoHeader."Credit Memo Type";
                ServiceCrMemoHeader."EU 3-Party Intermed. Role CZL" := ServiceCrMemoHeader."EU 3-Party Intermediate Role";
                ServiceCrMemoHeader."VAT Currency Factor CZL" := ServiceCrMemoHeader."VAT Currency Factor";
                ServiceCrMemoHeader."VAT Currency Code CZL" := ServiceCrMemoHeader."Currency Code";
                ServiceCrMemoHeader.Modify(false);
            until ServiceCrMemoHeader.Next() = 0;
    end;

    local procedure CopyReminderHeader();
    var
        ReminderHeader: Record "Reminder Header";
    begin
        if ReminderHeader.FindSet(true) then
            repeat
                ReminderHeader."Specific Symbol CZL" := ReminderHeader."Specific Symbol";
                ReminderHeader."Variable Symbol CZL" := ReminderHeader."Variable Symbol";
                ReminderHeader."Constant Symbol CZL" := ReminderHeader."Constant Symbol";
                ReminderHeader."Bank Account Code CZL" := ReminderHeader."Bank No.";
                ReminderHeader."Bank Account No. CZL" := ReminderHeader."Bank Account No.";
                ReminderHeader."Bank Branch No. CZL" := ReminderHeader."Bank Branch No.";
                ReminderHeader."Bank Name CZL" := ReminderHeader."Bank Name";
                ReminderHeader."Transit No. CZL" := ReminderHeader."Transit No.";
                ReminderHeader."IBAN CZL" := ReminderHeader.IBAN;
                ReminderHeader."SWIFT Code CZL" := ReminderHeader."SWIFT Code";
                ReminderHeader."Registration No. CZL" := ReminderHeader."Registration No.";
                ReminderHeader."Tax Registration No. CZL" := ReminderHeader."Tax Registration No.";
                ReminderHeader.Modify(false);
            until ReminderHeader.Next() = 0;
    end;

    local procedure CopyIssuedReminderHeader();
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin
        if IssuedReminderHeader.FindSet(true) then
            repeat
                IssuedReminderHeader."Specific Symbol CZL" := IssuedReminderHeader."Specific Symbol";
                IssuedReminderHeader."Variable Symbol CZL" := IssuedReminderHeader."Variable Symbol";
                IssuedReminderHeader."Constant Symbol CZL" := IssuedReminderHeader."Constant Symbol";
                IssuedReminderHeader."Bank Account Code CZL" := IssuedReminderHeader."Bank No.";
                IssuedReminderHeader."Bank Account No. CZL" := IssuedReminderHeader."Bank Account No.";
                IssuedReminderHeader."Bank Branch No. CZL" := IssuedReminderHeader."Bank Branch No.";
                IssuedReminderHeader."Bank Name CZL" := IssuedReminderHeader."Bank Name";
                IssuedReminderHeader."Transit No. CZL" := IssuedReminderHeader."Transit No.";
                IssuedReminderHeader."IBAN CZL" := IssuedReminderHeader.IBAN;
                IssuedReminderHeader."SWIFT Code CZL" := IssuedReminderHeader."SWIFT Code";
                IssuedReminderHeader."Registration No. CZL" := IssuedReminderHeader."Registration No.";
                IssuedReminderHeader."Tax Registration No. CZL" := IssuedReminderHeader."Tax Registration No.";
                IssuedReminderHeader.Modify(false);
            until IssuedReminderHeader.Next() = 0;
    end;

    local procedure CopyFinanceChargeMemoHeader();
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        if FinanceChargeMemoHeader.FindSet(true) then
            repeat
                FinanceChargeMemoHeader."Specific Symbol CZL" := FinanceChargeMemoHeader."Specific Symbol";
                FinanceChargeMemoHeader."Variable Symbol CZL" := FinanceChargeMemoHeader."Variable Symbol";
                FinanceChargeMemoHeader."Constant Symbol CZL" := FinanceChargeMemoHeader."Constant Symbol";
                FinanceChargeMemoHeader."Bank Account Code CZL" := FinanceChargeMemoHeader."Bank No.";
                FinanceChargeMemoHeader."Bank Account No. CZL" := FinanceChargeMemoHeader."Bank Account No.";
                FinanceChargeMemoHeader."Bank Branch No. CZL" := FinanceChargeMemoHeader."Bank Branch No.";
                FinanceChargeMemoHeader."Bank Name CZL" := FinanceChargeMemoHeader."Bank Name";
                FinanceChargeMemoHeader."Transit No. CZL" := FinanceChargeMemoHeader."Transit No.";
                FinanceChargeMemoHeader."IBAN CZL" := FinanceChargeMemoHeader.IBAN;
                FinanceChargeMemoHeader."SWIFT Code CZL" := FinanceChargeMemoHeader."SWIFT Code";
                FinanceChargeMemoHeader."Registration No. CZL" := FinanceChargeMemoHeader."Registration No.";
                FinanceChargeMemoHeader."Tax Registration No. CZL" := FinanceChargeMemoHeader."Tax Registration No.";
                FinanceChargeMemoHeader.Modify(false);
            until FinanceChargeMemoHeader.Next() = 0;
    end;

    local procedure CopyIssuedFinanceChargeMemoHeader();
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin
        if IssuedFinChargeMemoHeader.FindSet(true) then
            repeat
                IssuedFinChargeMemoHeader."Specific Symbol CZL" := IssuedFinChargeMemoHeader."Specific Symbol";
                IssuedFinChargeMemoHeader."Variable Symbol CZL" := IssuedFinChargeMemoHeader."Variable Symbol";
                IssuedFinChargeMemoHeader."Constant Symbol CZL" := IssuedFinChargeMemoHeader."Constant Symbol";
                IssuedFinChargeMemoHeader."Bank Account Code CZL" := IssuedFinChargeMemoHeader."Bank No.";
                IssuedFinChargeMemoHeader."Bank Account No. CZL" := IssuedFinChargeMemoHeader."Bank Account No.";
                IssuedFinChargeMemoHeader."Bank Branch No. CZL" := IssuedFinChargeMemoHeader."Bank Branch No.";
                IssuedFinChargeMemoHeader."Bank Name CZL" := IssuedFinChargeMemoHeader."Bank Name";
                IssuedFinChargeMemoHeader."Transit No. CZL" := IssuedFinChargeMemoHeader."Transit No.";
                IssuedFinChargeMemoHeader."IBAN CZL" := IssuedFinChargeMemoHeader.IBAN;
                IssuedFinChargeMemoHeader."SWIFT Code CZL" := IssuedFinChargeMemoHeader."SWIFT Code";
                IssuedFinChargeMemoHeader."Registration No. CZL" := IssuedFinChargeMemoHeader."Registration No.";
                IssuedFinChargeMemoHeader."Tax Registration No. CZL" := IssuedFinChargeMemoHeader."Tax Registration No.";
                IssuedFinChargeMemoHeader.Modify(false);
            until IssuedFinChargeMemoHeader.Next() = 0;
    end;

    local procedure CopyStatutoryReportingSetup();
    var
        StatReportingSetup: Record "Stat. Reporting Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if StatReportingSetup.Get() then begin
            if not StatutoryReportingSetupCZL.Get() then begin
                StatutoryReportingSetupCZL.Init();
                StatutoryReportingSetupCZL.Insert();
            end;
            StatutoryReportingSetupCZL."Primary Key" := StatReportingSetup."Primary Key";
            StatutoryReportingSetupCZL."Company Trade Name" := StatReportingSetup."Company Trade Name";
            StatutoryReportingSetupCZL."Company Trade Name Appendix" := StatReportingSetup."Company Trade Name Appendix";
            StatutoryReportingSetupCZL."Municipality No." := StatReportingSetup."Municipality No.";
            StatutoryReportingSetupCZL.Street := StatReportingSetup.Street;
            StatutoryReportingSetupCZL."House No." := StatReportingSetup."House No.";
            StatutoryReportingSetupCZL."Apartment No." := StatReportingSetup."Apartment No.";
            StatutoryReportingSetupCZL."VAT Control Report Nos." := StatReportingSetup."VAT Control Report Nos.";
            StatutoryReportingSetupCZL."Simplified Tax Document Limit" := StatReportingSetup."Simplified Tax Document Limit";
            StatutoryReportingSetupCZL."Data Box ID" := StatReportingSetup."Data Box ID";
            StatutoryReportingSetupCZL."VAT Control Report E-mail" := StatReportingSetup."VAT Control Report E-mail";
            StatutoryReportingSetupCZL."VAT Control Report XML Format" := StatReportingSetup."VAT Control Report Xml Format";
            StatutoryReportingSetupCZL."Tax Office Number" := StatReportingSetup."Tax Office Number";
            StatutoryReportingSetupCZL."Tax Office Region Number" := StatReportingSetup."Tax Office Region Number";
            case StatReportingSetup."Taxpayer Type" of
                StatReportingSetup."Taxpayer Type"::Corporation:
                    StatutoryReportingSetupCZL."Company Type" := StatutoryReportingSetupCZL."Company Type"::Corporate;
                StatReportingSetup."Taxpayer Type"::Individual:
                    StatutoryReportingSetupCZL."Company Type" := StatutoryReportingSetupCZL."Company Type"::Individual;
            end;
            StatutoryReportingSetupCZL."Individual First Name" := StatReportingSetup."Natural Person First Name";
            StatutoryReportingSetupCZL."Individual Surname" := StatReportingSetup."Natural Person Surname";
            StatutoryReportingSetupCZL."Individual Title" := StatReportingSetup."Natural Person Title";
            StatutoryReportingSetupCZL."Individual Employee No." := StatReportingSetup."Natural Employee No.";
            StatutoryReportingSetupCZL."Official Code" := StatReportingSetup."Official Code";
            StatutoryReportingSetupCZL."Official Name" := StatReportingSetup."Official Name";
            StatutoryReportingSetupCZL."Official First Name" := StatReportingSetup."Official First Name";
            StatutoryReportingSetupCZL."Official Surname" := StatReportingSetup."Official Surname";
            StatutoryReportingSetupCZL."Official Birth Date" := StatReportingSetup."Official Birth Date";
            StatutoryReportingSetupCZL."Official Reg.No.of Tax Adviser" := StatReportingSetup."Official Reg.No.of Tax Adviser";
            StatutoryReportingSetupCZL."Official Registration No." := StatReportingSetup."Official Registration No.";
            StatutoryReportingSetupCZL."Official Type" := StatReportingSetup."Official Type";
            StatutoryReportingSetupCZL."VAT Statement Country Name" := StatReportingSetup."VAT Statement Country Name";
            StatutoryReportingSetupCZL."VAT Stat. Auth. Employee No." := StatReportingSetup."VAT Stat. Auth.Employee No.";
            StatutoryReportingSetupCZL."VAT Stat. Filled Employee No." := StatReportingSetup."VAT Stat. Filled by Empl. No.";
            StatutoryReportingSetupCZL."Tax Payer Status" := StatReportingSetup."Tax Payer Status";
            StatutoryReportingSetupCZL."Primary Business Activity Code" := StatReportingSetup."Main Economic Activity I Code";
            StatutoryReportingSetupCZL."VIES Declaration Nos." := StatReportingSetup."VIES Declaration Nos.";
            StatutoryReportingSetupCZL."VIES Decl. Auth. Employee No." := StatReportingSetup."VIES Decl. Auth. Employee No.";
            StatutoryReportingSetupCZL."VIES Decl. Filled Employee No." := StatReportingSetup."VIES Decl. Filled by Empl. No.";
            StatutoryReportingSetupCZL."VIES Number of Lines" := StatReportingSetup."VIES Number of Lines";
#if CLEAN17
            if StatReportingSetup."VIES Declaration Report No." = 31060 then
#else
            if StatReportingSetup."VIES Declaration Report No." = Report::"VIES Declaration" then
#endif            
                StatutoryReportingSetupCZL."VIES Declaration Report No." := Report::"VIES Declaration CZL";
#if CLEAN17
            if (StatReportingSetup."VIES Decl. Exp. Obj. Type" = StatReportingSetup."VIES Decl. Exp. Obj. Type"::Report) and (StatReportingSetup."VIES Decl. Exp. Obj. No." = 31066) then
#else
            if (StatReportingSetup."VIES Decl. Exp. Obj. Type" = StatReportingSetup."VIES Decl. Exp. Obj. Type"::Report) and (StatReportingSetup."VIES Decl. Exp. Obj. No." = Report::"VIES Declaration Export") then
#endif
                StatutoryReportingSetupCZL."VIES Declaration Export No." := Xmlport::"VIES Declaration CZL";
            StatutoryReportingSetupCZL."Transaction Type Mandatory" := StatReportingSetup."Transaction Type Mandatory";
            StatutoryReportingSetupCZL."Transaction Spec. Mandatory" := StatReportingSetup."Transaction Spec. Mandatory";
            StatutoryReportingSetupCZL."Transport Method Mandatory" := StatReportingSetup."Transport Method Mandatory";
            StatutoryReportingSetupCZL."Shipment Method Mandatory" := StatReportingSetup."Shipment Method Mandatory";
            StatutoryReportingSetupCZL."Tariff No. Mandatory" := StatReportingSetup."Tariff No. Mandatory";
            StatutoryReportingSetupCZL."Net Weight Mandatory" := StatReportingSetup."Net Weight Mandatory";
            StatutoryReportingSetupCZL."Country/Region of Origin Mand." := StatReportingSetup."Country/Region of Origin Mand.";
            StatutoryReportingSetupCZL."Get Tariff No. From" := "Intrastat Detail Source CZL".FromInteger(StatReportingSetup."Get Tariff No. From");
            StatutoryReportingSetupCZL."Get Net Weight From" := "Intrastat Detail Source CZL".FromInteger(StatReportingSetup."Get Net Weight From");
            StatutoryReportingSetupCZL."Get Country/Region of Origin" := "Intrastat Detail Source CZL".FromInteger(StatReportingSetup."Get Country/Region of Origin");
            StatutoryReportingSetupCZL."Intrastat Rounding Type" := StatReportingSetup."Intrastat Rounding Type";
            StatutoryReportingSetupCZL."No Item Charges in Intrastat" := StatReportingSetup."No Item Charges in Intrastat";
            StatutoryReportingSetupCZL."Intrastat Declaration Nos." := StatReportingSetup."Intrastat Declaration Nos.";
            StatutoryReportingSetupCZL."Stat. Value Reporting" := StatReportingSetup."Stat. Value Reporting";
            StatutoryReportingSetupCZL."Cost Regulation %" := StatReportingSetup."Cost Regulation %";
            StatutoryReportingSetupCZL."Include other Period add.Costs" := StatReportingSetup."Include other Period add.Costs";
            StatutoryReportingSetupCZL.Modify(false);
        end;
    end;

    local procedure CopyVATControlReportSection();
    var
        VATControlReportSection: Record "VAT Control Report Section";
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        if VATControlReportSection.FindSet() then
            repeat
                if not VATCtrlReportSectionCZL.Get(VATControlReportSection.Code) then begin
                    VATCtrlReportSectionCZL.Init();
                    VATCtrlReportSectionCZL.Code := VATControlReportSection.Code;
                    VATCtrlReportSectionCZL.SystemId := VATControlReportSection.SystemId;
                    VATCtrlReportSectionCZL.Insert(false, true);
                end;
                VATCtrlReportSectionCZL.Description := VATControlReportSection.Description;
                VATCtrlReportSectionCZL."Group By" := VATControlReportSection."Group By";
                VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" := VATControlReportSection."Simplified Tax Doc. Sect. Code";
                VATCtrlReportSectionCZL.Modify(false);
            until VATControlReportSection.Next() = 0;
    end;

    local procedure CopyVATControlReportHeader();
    var
        VATControlReportHeader: Record "VAT Control Report Header";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
    begin
        if VATControlReportHeader.FindSet() then
            repeat
                if not VATCtrlReportHeaderCZL.Get(VATControlReportHeader."No.") then begin
                    VATCtrlReportHeaderCZL.Init();
                    VATCtrlReportHeaderCZL."No." := VATControlReportHeader."No.";
                    VATCtrlReportHeaderCZL.SystemId := VATControlReportHeader.SystemId;
                    VATCtrlReportHeaderCZL.Insert(false, true);
                end;
                VATCtrlReportHeaderCZL.Description := VATControlReportHeader.Description;
                VATCtrlReportHeaderCZL."Report Period" := VATControlReportHeader."Report Period";
                VATCtrlReportHeaderCZL."Period No." := VATControlReportHeader."Period No.";
                VATCtrlReportHeaderCZL.Year := VATControlReportHeader.Year;
                VATCtrlReportHeaderCZL."Start Date" := VATControlReportHeader."Start Date";
                VATCtrlReportHeaderCZL."End Date" := VATControlReportHeader."End Date";
                VATCtrlReportHeaderCZL."Created Date" := VATControlReportHeader."Created Date";
                VATCtrlReportHeaderCZL.Status := VATControlReportHeader.Status;
                VATCtrlReportHeaderCZL."VAT Statement Template Name" := VATControlReportHeader."VAT Statement Template Name";
                VATCtrlReportHeaderCZL."VAT Statement Name" := VATControlReportHeader."VAT Statement Name";
                VATCtrlReportHeaderCZL."No. Series" := VATControlReportHeader."No. Series";
                VATCtrlReportHeaderCZL.Modify(false);
            until VATControlReportHeader.Next() = 0;
    end;

    local procedure CopyVATControlReportLine();
    var
        VATControlReportLine: Record "VAT Control Report Line";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        if VATControlReportLine.FindSet() then
            repeat
                if not VATCtrlReportLineCZL.Get(VATControlReportLine."Control Report No.", VATControlReportLine."Line No.") then begin
                    VATCtrlReportLineCZL.Init();
                    VATCtrlReportLineCZL."VAT Ctrl. Report No." := VATControlReportLine."Control Report No.";
                    VATCtrlReportLineCZL."Line No." := VATControlReportLine."Line No.";
                    VATCtrlReportLineCZL.SystemId := VATControlReportLine.SystemId;
                    VATCtrlReportLineCZL.Insert(false, true);
                end;
                VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" := VATControlReportLine."VAT Control Rep. Section Code";
                VATCtrlReportLineCZL."Posting Date" := VATControlReportLine."Posting Date";
                VATCtrlReportLineCZL."VAT Date" := VATControlReportLine."VAT Date";
                VATCtrlReportLineCZL."Original Document VAT Date" := VATControlReportLine."Original Document VAT Date";
                VATCtrlReportLineCZL."Bill-to/Pay-to No." := VATControlReportLine."Bill-to/Pay-to No.";
                VATCtrlReportLineCZL."VAT Registration No." := VATControlReportLine."VAT Registration No.";
                VATCtrlReportLineCZL."Registration No." := VATControlReportLine."Registration No.";
                VATCtrlReportLineCZL."Tax Registration No." := VATControlReportLine."Tax Registration No.";
                VATCtrlReportLineCZL."Document No." := VATControlReportLine."Document No.";
                VATCtrlReportLineCZL."External Document No." := VATControlReportLine."External Document No.";
                VATCtrlReportLineCZL.Type := VATControlReportLine.Type;
                VATCtrlReportLineCZL."VAT Bus. Posting Group" := VATControlReportLine."VAT Bus. Posting Group";
                VATCtrlReportLineCZL."VAT Prod. Posting Group" := VATControlReportLine."VAT Prod. Posting Group";
                VATCtrlReportLineCZL.Base := VATControlReportLine.Base;
                VATCtrlReportLineCZL.Amount := VATControlReportLine.Amount;
                VATCtrlReportLineCZL."VAT Rate" := VATControlReportLine."VAT Rate";
                VATCtrlReportLineCZL."Commodity Code" := VATControlReportLine."Commodity Code";
                VATCtrlReportLineCZL."Supplies Mode Code" := VATControlReportLine."Supplies Mode Code";
                VATCtrlReportLineCZL."Corrections for Bad Receivable" := VATControlReportLine."Corrections for Bad Receivable";
                VATCtrlReportLineCZL."Ratio Use" := VATControlReportLine."Ratio Use";
                VATCtrlReportLineCZL.Name := VATControlReportLine.name;
                VATCtrlReportLineCZL."Birth Date" := VATControlReportLine."Birth Date";
                VATCtrlReportLineCZL."Place of Stay" := VATControlReportLine."Place of Stay";
                VATCtrlReportLineCZL."Exclude from Export" := VATControlReportLine."Exclude from Export";
                VATCtrlReportLineCZL."Closed by Document No." := VATControlReportLine."Closed by Document No.";
                VATCtrlReportLineCZL."Closed Date" := VATControlReportLine."Closed Date";
                VATCtrlReportLineCZL.Modify(false);
            until VATControlReportLine.Next() = 0;
    end;

    local procedure CopyVATControlReportEntryLink();
    var
        VATCtrlRepVATEntryLink: Record "VAT Ctrl.Rep. - VAT Entry Link";
        VATCtrlReportEntLinkCZL: Record "VAT Ctrl. Report Ent. Link CZL";
    begin
        if VATCtrlRepVATEntryLink.FindSet() then
            repeat
                if not VATCtrlReportEntLinkCZL.Get(VATCtrlRepVATEntryLink."Control Report No.", VATCtrlRepVATEntryLink."Line No.", VATCtrlRepVATEntryLink."VAT Entry No.") then begin
                    VATCtrlReportEntLinkCZL.Init();
                    VATCtrlReportEntLinkCZL."VAT Ctrl. Report No." := VATCtrlRepVATEntryLink."Control Report No.";
                    VATCtrlReportEntLinkCZL."Line No." := VATCtrlRepVATEntryLink."Line No.";
                    VATCtrlReportEntLinkCZL."VAT Entry No." := VATCtrlRepVATEntryLink."VAT Entry No.";
                    VATCtrlReportEntLinkCZL.SystemId := VATCtrlRepVATEntryLink.SystemId;
                    VATCtrlReportEntLinkCZL.Insert(false, true);
                end;
            until VATCtrlRepVATEntryLink.Next() = 0;
    end;

    local procedure CopyVATPostingSetup();
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if VATPostingSetup.FindSet() then
            repeat
                VATPostingSetup."VAT Rate CZL" := VATPostingSetup."VAT Rate";
                VATPostingSetup."Supplies Mode Code CZL" := VATPostingSetup."Supplies Mode Code";
                VATPostingSetup."Ratio Coefficient CZL" := VATPostingSetup."Ratio Coefficient";
                VATPostingSetup."Corrections Bad Receivable CZL" := VATPostingSetup."Corrections for Bad Receivable";
                VATPostingSetup."Reverse Charge Check CZL" := VATPostingSetup."Reverse Charge Check";
                VATPostingSetup."Sales VAT Curr. Exch. Acc CZL" := VATPostingSetup."Sales VAT Delay Account";
                VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL" := VATPostingSetup."Purchase VAT Delay Account";
                VATPostingSetup."VIES Purchase CZL" := VATPostingSetup."VIES Purchases";
                VATPostingSetup."VIES Sales CZL" := VATPostingSetup."VIES Sales";
                VATPostingSetup."Intrastat Service CZL" := VATPostingSetup."Intrastat Service";
                VATPostingSetup.Modify(false);
            until VATPostingSetup.Next() = 0;
    end;

    local procedure CopyVATStatementTemplate();
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        if VATStatementTemplate.FindSet() then
            repeat
                VATStatementTemplate."Allow Comments/Attachments CZL" := VATStatementTemplate."Allow Comments/Attachments";
                VATStatementTemplate."XML Format CZL" := VATStatementTemplate."XML Format CZL"::DPHDP3;
                VATStatementTemplate.Modify(false);
            until VATStatementTemplate.Next() = 0;
    end;

    local procedure CopyVATStatementLine();
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        if VATStatementLine.FindSet() then
            repeat
                VATStatementLine."Attribute Code CZL" := VATStatementLine."Attribute Code";
                VATStatementLine."G/L Amount Type CZL" := VATStatementLine."G/L Amount Type";
                VATStatementLine."Gen. Bus. Posting Group CZL" := VATStatementLine."Gen. Bus. Posting Group";
                VATStatementLine."Gen. Prod. Posting Group CZL" := VATStatementLine."Gen. Prod. Posting Group";
                VATStatementLine."Show CZL" := VATStatementLine.Show;
                VATStatementLine."EU 3-Party Intermed. Role CZL" := VATStatementLine."EU 3-Party Intermediate Role";
                VATStatementLine."EU-3 Party Trade CZL" := VATStatementLine."EU-3 Party Trade";
                VATStatementLine."VAT Ctrl. Report Section CZL" := VATStatementLine."VAT Control Rep. Section Code";
                VATStatementLine."Ignore Simpl. Doc. Limit CZL" := VATStatementLine."Ignore Simpl. Tax Doc. Limit";
                ConvertVATStatementLineDeprEnumValues(VATStatementLine);
                VATStatementLine.Modify(false);
            until VATStatementLine.Next() = 0;
    end;

    local procedure ConvertVATStatementLineDeprEnumValues(var VATStatementLine: Record "VAT Statement Line");
    begin
#if CLEAN17
        if VATStatementLine.Type = 4 then //4 = VATStatementLine.Type::Formula
#else
        if VATStatementLine.Type = VATStatementLine.Type::Formula then
#endif
            VATStatementLine.Type := VATStatementLine.Type::"Formula CZL";
    end;

    local procedure CopyVIESDeclarationHeader();
    var
        VIESDeclarationHeader: Record "VIES Declaration Header";
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
    begin
        if VIESDeclarationHeader.FindSet() then
            repeat
                if not VIESDeclarationHeaderCZL.Get(VIESDeclarationHeader."No.") then begin
                    VIESDeclarationHeaderCZL.Init();
                    VIESDeclarationHeaderCZL."No." := VIESDeclarationHeader."No.";
                    VIESDeclarationHeaderCZL.SystemId := VIESDeclarationHeader.SystemId;
                    VIESDeclarationHeaderCZL.Insert(false, true);
                end;
                VIESDeclarationHeaderCZL."VAT Registration No." := VIESDeclarationHeader."VAT Registration No.";
                VIESDeclarationHeaderCZL."Trade Type" := VIESDeclarationHeader."Trade Type";
                VIESDeclarationHeaderCZL."Period No." := VIESDeclarationHeader."Period No.";
                VIESDeclarationHeaderCZL.Year := VIESDeclarationHeader.Year;
                VIESDeclarationHeaderCZL."Start Date" := VIESDeclarationHeader."Start Date";
                VIESDeclarationHeaderCZL."End Date" := VIESDeclarationHeader."End Date";
                VIESDeclarationHeaderCZL.Name := VIESDeclarationHeader.Name;
                VIESDeclarationHeaderCZL."Name 2" := VIESDeclarationHeader."Name 2";
                VIESDeclarationHeaderCZL."Country/Region Name" := VIESDeclarationHeader."Country/Region Name";
                VIESDeclarationHeaderCZL.County := VIESDeclarationHeader.County;
                VIESDeclarationHeaderCZL."Municipality No." := VIESDeclarationHeader."Municipality No.";
                VIESDeclarationHeaderCZL.Street := VIESDeclarationHeader.Street;
                VIESDeclarationHeaderCZL."House No." := VIESDeclarationHeader."House No.";
                VIESDeclarationHeaderCZL."Apartment No." := VIESDeclarationHeader."Apartment No.";
                VIESDeclarationHeaderCZL.City := VIESDeclarationHeader.City;
                VIESDeclarationHeaderCZL."Post Code" := VIESDeclarationHeader."Post Code";
                VIESDeclarationHeaderCZL."Tax Office Number" := VIESDeclarationHeader."Tax Office Number";
                VIESDeclarationHeaderCZL."Declaration Period" := VIESDeclarationHeader."Declaration Period";
                VIESDeclarationHeaderCZL."Declaration Type" := VIESDeclarationHeader."Declaration Type";
                VIESDeclarationHeaderCZL."Corrected Declaration No." := VIESDeclarationHeader."Corrected Declaration No.";
                VIESDeclarationHeaderCZL."Document Date" := VIESDeclarationHeader."Document Date";
                VIESDeclarationHeaderCZL."Sign-off Date" := VIESDeclarationHeader."Sign-off Date";
                VIESDeclarationHeaderCZL."Sign-off Place" := VIESDeclarationHeader."Sign-off Place";
                VIESDeclarationHeaderCZL."EU Goods/Services" := VIESDeclarationHeader."EU Goods/Services";
                VIESDeclarationHeaderCZL.Status := VIESDeclarationHeader.Status;
                VIESDeclarationHeaderCZL."No. Series" := VIESDeclarationHeader."No. Series";
                VIESDeclarationHeaderCZL."Authorized Employee No." := VIESDeclarationHeader."Authorized Employee No.";
                VIESDeclarationHeaderCZL."Filled by Employee No." := VIESDeclarationHeader."Filled by Employee No.";
                VIESDeclarationHeaderCZL."Individual First Name" := VIESDeclarationHeader."Natural Person First Name";
                VIESDeclarationHeaderCZL."Individual Surname" := VIESDeclarationHeader."Natural Person Surname";
                VIESDeclarationHeaderCZL."Individual Title" := VIESDeclarationHeader."Natural Person Title";
                VIESDeclarationHeaderCZL."Company Type" := VIESDeclarationHeader."Taxpayer Type";
                VIESDeclarationHeaderCZL."Individual Employee No." := VIESDeclarationHeader."Natural Employee No.";
                VIESDeclarationHeaderCZL."Company Trade Name Appendix" := VIESDeclarationHeader."Company Trade Name Appendix";
                VIESDeclarationHeaderCZL."Tax Office Region Number" := VIESDeclarationHeader."Tax Office Region Number";
                VIESDeclarationHeaderCZL.Modify(false);
            until VIESDeclarationHeader.Next() = 0;
    end;

    local procedure CopyVIESDeclarationLine();
    var
        VIESDeclarationLine: Record "VIES Declaration Line";
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
    begin
        if VIESDeclarationLine.FindSet() then
            repeat
                if not VIESDeclarationLineCZL.Get(VIESDeclarationLine."VIES Declaration No.", VIESDeclarationLine."Line No.") then begin
                    VIESDeclarationLineCZL.Init();
                    VIESDeclarationLineCZL."VIES Declaration No." := VIESDeclarationLine."VIES Declaration No.";
                    VIESDeclarationLineCZL."Line No." := VIESDeclarationLine."Line No.";
                    VIESDEclarationLineCZL.SystemId := VIESDeclarationLine.SystemId;
                    VIESDeclarationLineCZL.Insert(false, true);
                end;
                VIESDeclarationLineCZL."Trade Type" := VIESDeclarationLine."Trade Type";
                VIESDeclarationLineCZL."Line Type" := VIESDeclarationLine."Line Type";
                VIESDeclarationLineCZL."Related Line No." := VIESDeclarationLine."Related Line No.";
                VIESDeclarationLineCZL."EU Service" := VIESDeclarationLine."EU Service";
                VIESDeclarationLineCZL."Country/Region Code" := VIESDeclarationLine."Country/Region Code";
                VIESDeclarationLineCZL."VAT Registration No." := VIESDeclarationLine."VAT Registration No.";
                VIESDeclarationLineCZL."Amount (LCY)" := VIESDeclarationLine."Amount (LCY)";
                VIESDeclarationLineCZL."EU 3-Party Trade" := VIESDeclarationLine."EU 3-Party Trade";
                VIESDeclarationLineCZL."Registration No." := VIESDeclarationLine."Registration No.";
                VIESDeclarationLineCZL."EU 3-Party Intermediate Role" := VIESDeclarationLine."EU 3-Party Intermediate Role";
                VIESDeclarationLineCZL."Number of Supplies" := VIESDeclarationLine."Number of Supplies";
                VIESDeclarationLineCZL."Corrected Reg. No." := VIESDeclarationLine."Corrected Reg. No.";
                VIESDeclarationLineCZL."Corrected Amount" := VIESDeclarationLine."Corrected Amount";
                VIESDeclarationLineCZL."Trade Role Type" := VIESDeclarationLine."Trade Role Type";
                VIESDeclarationLineCZL."System-Created" := VIESDeclarationLine."System-Created";
                VIESDeclarationLineCZL."Report Page Number" := VIESDeclarationLine."Report Page Number";
                VIESDeclarationLineCZL."Report Line Number" := VIESDeclarationLine."Report Line Number";
                VIESDeclarationLineCZL."Record Code" := VIESDeclarationLine."Record Code";
                VIESDeclarationLineCZL."VAT Reg. No. of Original Cust." := VIESDeclarationLine."VAT Reg. No. of Original Cust.";
                VIESDeclarationLineCZL.Modify(false);
            until VIESDeclarationLine.Next() = 0;
    end;

    local procedure CopyCompanyOfficials();
    var
        CompanyOfficials: Record "Company Officials";
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        if CompanyOfficials.FindSet(true) then
            repeat
                if not CompanyOfficialCZL.Get(CompanyOfficials."No.") then begin
                    CompanyOfficialCZL.Init();
                    CompanyOfficialCZL."No." := CompanyOfficials."No.";
                    CompanyOfficialCZL.SystemId := CompanyOfficials.SystemId;
                    CompanyOfficialCZL.Insert(false, true);
                end;
                CompanyOfficialCZL."First Name" := CompanyOfficials."First Name";
                CompanyOfficialCZL."Middle Name" := CompanyOfficials."Middle Name";
                CompanyOfficialCZL."Last Name" := CompanyOfficials."Last Name";
                CompanyOfficialCZL.Initials := CompanyOfficials.Initials;
                CompanyOfficialCZL."Job Title" := CompanyOfficials."Job Title";
                CompanyOfficialCZL."Search Name" := CompanyOfficials."Search Name";
                CompanyOfficialCZL.Address := CompanyOfficials.Address;
                CompanyOfficialCZL."Address 2" := CompanyOfficials."Address 2";
                CompanyOfficialCZL.City := CompanyOfficials.City;
                CompanyOfficialCZL."Post Code" := CompanyOfficials."Post Code";
                CompanyOfficialCZL.County := CompanyOfficials.County;
                CompanyOfficialCZL."Phone No." := CompanyOfficials."Phone No.";
                CompanyOfficialCZL."Mobile Phone No." := CompanyOfficials."Mobile Phone No.";
                CompanyOfficialCZL."E-Mail" := CompanyOfficials."E-Mail";
                CompanyOfficialCZL."Country/Region Code" := CompanyOfficials."Country/Region Code";
                CompanyOfficialCZL."Last Date Modified" := CompanyOfficials."Last Date Modified";
                CompanyOfficialCZL."Fax No." := CompanyOfficials."Fax No.";
                CompanyOfficialCZL."No. Series" := CompanyOfficials."No. Series";
                CompanyOfficialCZL."Employee No." := CompanyOfficials."Employee No.";
                CompanyOfficialCZL.Modify(false);
            until CompanyOfficials.Next() = 0;
    end;

    local procedure CopyDocumentFooter();
    var
        DocumentFooter: Record "Document Footer";
        DocumentFooterCZL: Record "Document Footer CZL";
    begin
        if DocumentFooter.FindSet() then
            repeat
                if not DocumentFooterCZL.Get(DocumentFooter."Language Code") then begin
                    DocumentFooterCZL.Init();
                    DocumentFooterCZL."Language Code" := DocumentFooter."Language Code";
                    DocumentFooterCZL.SystemId := DocumentFooter.SystemId;
                    DocumentFooterCZL.Insert(false, true);
                end;
                DocumentFooterCZL."Footer Text" := DocumentFooter."Footer Text";
                DocumentFooterCZL.Modify(false);
            until DocumentFooter.Next() = 0;
    end;

    local procedure CopyGLAccount();
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.FindSet() then
            repeat
                GLAccount."G/L Account Group CZL" := GLAccount."G/L Account Group";
                GLAccount.Modify(false);
            until GLAccount.Next() = 0;
    end;

    local procedure CopyVATAttributeCode();
    var
        VATAttributeCode: Record "VAT Attribute Code";
        VATAttributeCodeCZL: Record "VAT Attribute Code CZL";
    begin
        if VATAttributeCode.FindSet() then
            repeat
                if not VATAttributeCodeCZL.Get(VATAttributeCode."VAT Statement Template Name", VATAttributeCode."Code") then begin
                    VATAttributeCodeCZL.Init();
                    VATAttributeCodeCZL."VAT Statement Template Name" := VATAttributeCode."VAT Statement Template Name";
                    VATAttributeCodeCZL."Code" := VATAttributeCode."Code";
                    VATAttributeCodeCZL.SystemId := VATAttributeCode.SystemId;
                    VATAttributeCodeCZL.Insert(false, true);
                end;
                VATAttributeCodeCZL.Description := VATAttributeCode.Description;
                VATAttributeCodeCZL."XML Code" := VATAttributeCode."XML Code";
                VATAttributeCodeCZL.Modify(false);
            until VATAttributeCode.Next() = 0;
    end;

    local procedure CopyVATStatementCommentLine();
    var
        VATStatementCommentLine: Record "VAT Statement Comment Line";
        VATStatementCommentLineCZL: Record "VAT Statement Comment Line CZL";
    begin
        if VATStatementCommentLine.FindSet() then
            repeat
                if not VATStatementCommentLineCZL.Get(VATStatementCommentLine."VAT Statement Template Name", VATStatementCommentLine."VAT Statement Name", VATStatementCommentLine."Line No.") then begin
                    VATStatementCommentLineCZL.Init();
                    VATStatementCommentLineCZL."VAT Statement Template Name" := VATStatementCommentLine."VAT Statement Template Name";
                    VATStatementCommentLineCZL."VAT Statement Name" := VATStatementCommentLine."VAT Statement Name";
                    VATStatementCommentLineCZL."Line No." := VATStatementCommentLine."Line No.";
                    VATStatementCommentLineCZL.SystemId := VATStatementCommentLine.SystemId;
                    VATStatementCommentLineCZL.Insert(false, true);
                end;
                VATStatementCommentLineCZL.Date := VATStatementCommentLine.Date;
                VATStatementCommentLineCZL.Comment := VATStatementCommentLine.Comment;
                VATStatementCommentLineCZL.Modify(false);
            until VATStatementCommentLine.Next() = 0;
    end;

    local procedure CopyVATStatementAttachment();
    var
        VATStatementAttachment: Record "VAT Statement Attachment";
        VATStatementAttachmentCZL: Record "VAT Statement Attachment CZL";
    begin
        if VATStatementAttachment.FindSet() then
            repeat
                if not VATStatementAttachmentCZL.Get(VATStatementAttachment."VAT Statement Template Name", VATStatementAttachment."VAT Statement Name", VATStatementAttachment."Line No.") then begin
                    VATStatementAttachmentCZL.Init();
                    VATStatementAttachmentCZL."VAT Statement Template Name" := VATStatementAttachment."VAT Statement Template Name";
                    VATStatementAttachmentCZL."VAT Statement Name" := VATStatementAttachment."VAT Statement Name";
                    VATStatementAttachmentCZL."Line No." := VATStatementAttachment."Line No.";
                    VATStatementAttachmentCZL.SystemId := VATStatementAttachment.SystemId;
                    VATStatementAttachmentCZL.Insert(false, true);
                end;
                VATStatementAttachmentCZL.Date := VATStatementAttachment.Date;
                VATStatementAttachmentCZL.Description := VATStatementAttachment.Description;
                VATStatementAttachment.CalcFields(VATStatementAttachment.Attachment);
                VATStatementAttachmentCZL.Attachment := VATStatementAttachment.Attachment;
                VATStatementAttachmentCZL."File Name" := VATStatementAttachment."File Name";
                VATStatementAttachmentCZL.Modify(false);
            until VATStatementAttachment.Next() = 0;
    end;

    local procedure CopyAccScheduleName();
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        if AccScheduleName.FindSet() then
            repeat
                AccScheduleName."Acc. Schedule Type CZL" := AccScheduleName."Acc. Schedule Type";
                AccScheduleName.Modify(false);
            until AccScheduleName.Next() = 0;
    end;

    local procedure CopyAccScheduleLine();
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        if AccScheduleLine.FindSet() then
            repeat
                AccScheduleLine."Calc CZL" := AccScheduleLine.Calc;
                AccScheduleLine."Row Correction CZL" := AccScheduleLine."Row Correction";
                AccScheduleLine."Assets/Liabilities Type CZL" := AccScheduleLine."Assets/Liabilities Type";
                AccScheduleLine."Source Table CZL" := AccScheduleLine."Source Table";
                ConvertAccScheduleLineTotalingTypeEnumValues(AccScheduleLine);
                AccScheduleLine.Modify(false);
            until AccScheduleLine.Next() = 0;
    end;

    local procedure ConvertAccScheduleLineTotalingTypeEnumValues(var AccScheduleLine: Record "Acc. Schedule Line");
    begin
#if CLEAN19
        if AccScheduleLine."Totaling Type" = 14 then //14 = AccScheduleLine.Type::Custom
#else
        if AccScheduleLine."Totaling Type" = AccScheduleLine."Totaling Type"::Custom then
#endif
            AccScheduleLine."Totaling Type" := AccScheduleLine."Totaling Type"::"Custom CZL";
#if CLEAN19
        if AccScheduleLine."Totaling Type" = 15 then //15 = AccScheduleLine.Type::Constant
#else
        if AccScheduleLine."Totaling Type" = AccScheduleLine."Totaling Type"::Constant then
#endif
            AccScheduleLine."Totaling Type" := AccScheduleLine."Totaling Type"::"Constant CZL";
    end;

    local procedure CopyExcelTemplate();
    var
        ExcelTemplate: Record "Excel Template";
        ExcelTemplateCZL: Record "Excel Template CZL";
        ExcelTemplateOutStream: OutStream;
        ExcelTemplateInStream: InStream;
    begin
        if ExcelTemplate.FindSet() then
            repeat
                if not ExcelTemplateCZL.Get(ExcelTemplate.Code) then begin
                    ExcelTemplateCZL.Init();
                    ExcelTemplateCZL.Code := ExcelTemplate.Code;
                    ExcelTemplateCZL.SystemId := ExcelTemplate.SystemId;
                    ExcelTemplateCZL.Insert(false, true);
                end;
                ExcelTemplateCZL.Description := ExcelTemplate.Description;
                ExcelTemplateCZL.Sheet := ExcelTemplate.Sheet;
                ExcelTemplateCZL.Blocked := ExcelTemplate.Blocked;
                if ExcelTemplate.Template.HasValue() then begin
                    ExcelTemplate.CalcFields(ExcelTemplate.Template);
                    ExcelTemplate.Template.CreateInStream(ExcelTemplateInStream);
                    ExcelTemplateCZL.Template.CreateOutStream(ExcelTemplateOutStream);
                    CopyStream(ExcelTemplateOutStream, ExcelTemplateInStream);
                end;
                ExcelTemplateCZL.Modify(false);
            until ExcelTemplate.Next() = 0;
    end;

    local procedure CopyStatementFileMapping();
    var
        StatementFileMapping: Record "Statement File Mapping";
        AccScheduleFileMappingCZL: Record "Acc. Schedule File Mapping CZL";
    begin
        if StatementFileMapping.FindSet() then
            repeat
                if not AccScheduleFileMappingCZL.Get(StatementFileMapping."Schedule Name", StatementFileMapping."Schedule Line No.", StatementFileMapping."Schedule Column Layout Name", StatementFileMapping."Schedule Column No.", StatementFileMapping."Excel Cell") then begin
                    AccScheduleFileMappingCZL.Init();
                    AccScheduleFileMappingCZL."Schedule Name" := StatementFileMapping."Schedule Name";
                    AccScheduleFileMappingCZL."Schedule Line No." := StatementFileMapping."Schedule Line No.";
                    AccScheduleFileMappingCZL."Schedule Column Layout Name" := StatementFileMapping."Schedule Column Layout Name";
                    AccScheduleFileMappingCZL."Schedule Column No." := StatementFileMapping."Schedule Column No.";
                    AccScheduleFileMappingCZL."Excel Cell" := StatementFileMapping."Excel Cell";
                    AccScheduleFileMappingCZL.SystemId := StatementFileMapping.SystemId;
                    AccScheduleFileMappingCZL.Insert(false, true);
                end;
                AccScheduleFileMappingCZL."Excel Row No." := StatementFileMapping."Excel Row No.";
                AccScheduleFileMappingCZL."Excel Column No." := StatementFileMapping."Excel Column No.";
                AccScheduleFileMappingCZL.Split := StatementFileMapping.Split;
                AccScheduleFileMappingCZL.Offset := StatementFileMapping.Offset;
                AccScheduleFileMappingCZL.Modify(false);
            until StatementFileMapping.Next() = 0;
    end;

    local procedure CopyPurchaseLine();
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine."Negative CZL" := PurchaseLine.Negative;
                PurchaseLine."Physical Transfer CZL" := PurchaseLine."Physical Transfer";
                PurchaseLine."Tariff No. CZL" := PurchaseLine."Tariff No.";
                PurchaseLine."Statistic Indication CZL" := PurchaseLine."Statistic Indication";
                PurchaseLine."Country/Reg. of Orig. Code CZL" := PurchaseLine."Country/Region of Origin Code";
                PurchaseLine.Modify(false);
            until PurchaseLine.Next() = 0;
    end;

    local procedure CopyPurchCrMemoLine();
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        if PurchCrMemoLine.FindSet() then
            repeat
                PurchCrMemoLine."Tariff No. CZL" := PurchCrMemoLine."Tariff No.";
                PurchCrMemoLine."Statistic Indication CZL" := PurchCrMemoLine."Statistic Indication";
                PurchCrMemoLine."Country/Reg. of Orig. Code CZL" := PurchCrMemoLine."Country/Region of Origin Code";
                PurchCrMemoLine.Modify(false);
            until PurchCrMemoLine.Next() = 0;
    end;

    local procedure CopyPurchInvLine();
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        if PurchInvLine.FindSet() then
            repeat
                PurchInvLine."Tariff No. CZL" := PurchInvLine."Tariff No.";
                PurchInvLine."Statistic Indication CZL" := PurchInvLine."Statistic Indication";
                PurchInvLine."Country/Reg. of Orig. Code CZL" := PurchInvLine."Country/Region of Origin Code";
                PurchInvLine.Modify(false);
            until PurchInvLine.Next() = 0;
    end;

    local procedure CopyPurchRcptLine();
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        if PurchRcptLine.FindSet() then
            repeat
                PurchRcptLine."Tariff No. CZL" := PurchRcptLine."Tariff No.";
                PurchRcptLine."Statistic Indication CZL" := PurchRcptLine."Statistic Indication";
                PurchRcptLine."Country/Reg. of Orig. Code CZL" := PurchRcptLine."Country/Region of Origin Code";
                PurchRcptLine.Modify(false);
            until PurchRcptLine.Next() = 0;
    end;

    local procedure CopySalesCrMemoLine();
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        if SalesCrMemoLine.FindSet() then
            repeat
                SalesCrMemoLine."Tariff No. CZL" := SalesCrMemoLine."Tariff No.";
                SalesCrMemoLine."Statistic Indication CZL" := SalesCrMemoLine."Statistic Indication";
                SalesCrMemoLine."Country/Reg. of Orig. Code CZL" := SalesCrMemoLine."Country/Region of Origin Code";
                SalesCrMemoLine.Modify(false);
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure CopySalesInvoiceLine();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        if SalesInvoiceLine.FindSet() then
            repeat
                SalesInvoiceLine."Tariff No. CZL" := SalesInvoiceLine."Tariff No.";
                SalesInvoiceLine."Statistic Indication CZL" := SalesInvoiceLine."Statistic Indication";
                SalesInvoiceLine."Country/Reg. of Orig. Code CZL" := SalesInvoiceLine."Country/Region of Origin Code";
                SalesInvoiceLine.Modify(false);
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure CopySalesLine();
    var
        SalesLine: Record "Sales Line";
    begin
        if SalesLine.FindSet() then
            repeat
                SalesLine."Negative CZL" := SalesLine.Negative;
                SalesLine."Physical Transfer CZL" := SalesLine."Physical Transfer";
                SalesLine."Tariff No. CZL" := SalesLine."Tariff No.";
                SalesLine."Statistic Indication CZL" := SalesLine."Statistic Indication";
                SalesLine."Country/Reg. of Orig. Code CZL" := SalesLine."Country/Region of Origin Code";
                SalesLine.Modify(false);
            until SalesLine.Next() = 0;
    end;

    local procedure CopySalesShipmentLine();
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        if SalesShipmentLine.FindSet() then
            repeat
                SalesShipmentLine."Tariff No. CZL" := SalesShipmentLine."Tariff No.";
                SalesShipmentLine."Statistic Indication CZL" := SalesShipmentLine."Statistic Indication";
                SalesShipmentLine.Modify(false);
            until SalesShipmentLine.Next() = 0;
    end;

    local procedure CopyTariffNumber();
    var
#if CLEAN19
        UnitOfMeasure: Record "Unit of Measure";
#endif
        TariffNumber: Record "Tariff Number";
    begin
        if TariffNumber.FindSet() then
            repeat
                TariffNumber."Statement Code CZL" := TariffNumber."Statement Code";
                TariffNumber."Statement Limit Code CZL" := TariffNumber."Statement Limit Code";
                TariffNumber."VAT Stat. UoM Code CZL" := TariffNumber."VAT Stat. Unit of Measure Code";
                TariffNumber."Allow Empty UoM Code CZL" := TariffNumber."Allow Empty Unit of Meas.Code";
                TariffNumber."Description EN CZL" := CopyStr(TariffNumber."Full Name ENG", 1, MaxStrLen(TariffNumber."Description EN CZL"));
                TariffNumber."Suppl. Unit of Meas. Code CZL" := TariffNumber."Supplem. Unit of Measure Code";
#if not CLEAN18
                // Field "Supplementary Units" will change from FlowField to Normal in CLEAN18. Existing data has to be updated according to original CalcFormula.
                TariffNumber.CalcFields("Supplementary Units");
#else
                TariffNumber."Supplementary Units" := UnitOfMeasure.Get(TariffNumber."Supplem. Unit of Measure Code");
#endif
                TariffNumber.Modify(false);
            until TariffNumber.Next() = 0;
    end;

    local procedure CopyCommodity();
    var
        Commodity: Record Commodity;
        CommodityCZL: Record "Commodity CZL";
    begin
        if Commodity.FindSet() then
            repeat
                if not CommodityCZL.Get(Commodity.Code) then begin
                    CommodityCZL.Init();
                    CommodityCZL.Code := Commodity.Code;
                    CommodityCZL.SystemId := Commodity.SystemId;
                    CommodityCZL.Insert(false, true);
                end;
                CommodityCZL.Description := Commodity.Description;
                CommodityCZL.Modify(false);
            until Commodity.Next() = 0;
    end;

    local procedure CopyCommoditySetup();
    var
        CommoditySetup: Record "Commodity Setup";
        CommoditySetupCZL: Record "Commodity Setup CZL";
    begin
        if CommoditySetup.FindSet() then
            repeat
                if not CommoditySetupCZL.Get(CommoditySetup."Commodity Code", CommoditySetup."Valid From") then begin
                    CommoditySetupCZL.Init();
                    CommoditySetupCZL."Commodity Code" := CommoditySetup."Commodity Code";
                    CommoditySetupCZL."Valid From" := CommoditySetup."Valid From";
                    CommoditySetupCZL.SystemId := CommoditySetup.SystemId;
                    CommoditySetupCZL.Insert(false, true);
                end;
                CommoditySetupCZL."Commodity Limit Amount LCY" := CommoditySetup."Commodity Limit Amount LCY";
                CommoditySetupCZL."Valid To" := CommoditySetup."Valid To";
                CommoditySetupCZL.Modify(false);
            until CommoditySetup.Next() = 0;
    end;

    local procedure CopyStatisticIndication();
    var
        StatisticIndication: Record "Statistic Indication";
        StatisticIndicationCZL: Record "Statistic Indication CZL";
    begin
        if StatisticIndication.FindSet() then
            repeat
                if not StatisticIndicationCZL.Get(StatisticIndication."Tariff No.", StatisticIndication.Code) then begin
                    StatisticIndicationCZL.Init();
                    StatisticIndicationCZL."Tariff No." := StatisticIndication."Tariff No.";
                    StatisticIndicationCZL.Code := StatisticIndication.Code;
                    StatisticIndicationCZL.SystemId := StatisticIndication.SystemId;
                    StatisticIndicationCZL.Insert(false, true);
                end;
                StatisticIndicationCZL.Description := StatisticIndication.Description;
                StatisticIndicationCZL."Description EN" := CopyStr(StatisticIndication."Full Name ENG", 1, MaxStrLen(StatisticIndicationCZL."Description EN"));
                StatisticIndication.Modify(false);
            until StatisticIndication.Next() = 0;
    end;

    local procedure CopySourceCodeSetup();
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if SourceCodeSetup.Get() then begin
            SourceCodeSetup."Sales VAT Delay CZL" := SourceCodeSetup."Sales VAT Delay";
            SourceCodeSetup."Purchase VAT Delay CZL" := SourceCodeSetup."Purchase VAT Delay";
            SourceCodeSetup.Modify(false);
        end;

    end;

    local procedure CopyStockkeepingUnitTemplate();
    var
        StockkeepingUnitTemplate: Record "Stockkeeping Unit Template";
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        StockkeepingUnit: Record "Stockkeeping Unit";
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        if StockkeepingUnitTemplate.FindSet() then
            repeat
                CreateTemplateHeader(ConfigTemplateHeader, GetNextDataTemplateAvailableCode(),
                                     GetDataTemplateDescription(StockkeepingUnitTemplate),
                                     Database::"Stockkeeping Unit");
                if StockkeepingUnitTemplate."Components at Location" <> '' then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Components at Location"), StockkeepingUnitTemplate."Components at Location");
                if StockkeepingUnitTemplate."Replenishment System" <> StockkeepingUnitTemplate."Replenishment System"::Purchase then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Replenishment System"), Format(StockkeepingUnitTemplate."Replenishment System"));
                if StockkeepingUnitTemplate."Reordering Policy" <> StockkeepingUnitTemplate."Reordering Policy"::" " then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Reordering Policy"), Format(StockkeepingUnitTemplate."Reordering Policy"));
                if StockkeepingUnitTemplate."Include Inventory" then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Include Inventory"), Format(StockkeepingUnitTemplate."Include Inventory"));
                if StockkeepingUnitTemplate."Transfer-from Code" <> '' then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Transfer-from Code"), StockkeepingUnitTemplate."Transfer-from Code");
                if StockkeepingUnitTemplate."Gen. Prod. Posting Group" <> '' then
                    CreateTemplateLine(ConfigTemplateHeader, StockkeepingUnit.FieldNo("Gen. Prod. Posting Group"), StockkeepingUnitTemplate."Gen. Prod. Posting Group");

                if not StockkeepingUnitTemplateCZL.Get(StockkeepingUnitTemplate."Item Category Code", StockkeepingUnitTemplate."Location Code") then begin
                    StockkeepingUnitTemplateCZL.Init();
                    StockkeepingUnitTemplateCZL."Item Category Code" := StockkeepingUnitTemplate."Item Category Code";
                    StockkeepingUnitTemplateCZL."Location Code" := StockkeepingUnitTemplate."Location Code";
                    StockkeepingUnitTemplateCZL.SystemId := StockkeepingUnitTemplate.SystemId;
                    StockkeepingUnitTemplateCZL.Insert(false, true);
                end;
                StockkeepingUnitTemplateCZL.Description := StockkeepingUnitTemplateCZL.GetDefaultDescription();
                StockkeepingUnitTemplateCZL."Configuration Template Code" := ConfigTemplateHeader.Code;
                StockkeepingUnitTemplateCZL.Modify(false);
            until StockkeepingUnitTemplate.Next() = 0;
    end;

    local procedure CreateTemplateHeader(var ConfigTemplateHeader: Record "Config. Template Header"; "Code": Code[10]; Description: Text[100]; TableID: Integer)
    begin
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := Code;
        ConfigTemplateHeader.Description := Description;
        ConfigTemplateHeader."Table ID" := TableID;
        ConfigTemplateHeader.Enabled := true;
        ConfigTemplateHeader.Insert();
    end;

    local procedure CreateTemplateLine(var ConfigTemplateHeader: Record "Config. Template Header"; FieldID: Integer; Value: Text[50])
    var
        ConfigTemplateLine: Record "Config. Template Line";
        NextLineNo: Integer;
    begin
        NextLineNo := 10000;
        ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
        if ConfigTemplateLine.FindLast() then
            NextLineNo := ConfigTemplateLine."Line No." + 10000;

        ConfigTemplateLine.Init();
        ConfigTemplateLine.Validate("Data Template Code", ConfigTemplateHeader.Code);
        ConfigTemplateLine.Validate("Line No.", NextLineNo);
        ConfigTemplateLine.Validate(Type, ConfigTemplateLine.Type::Field);
        ConfigTemplateLine.Validate("Table ID", ConfigTemplateHeader."Table ID");
        ConfigTemplateLine.Validate("Field ID", FieldID);
        ConfigTemplateLine."Default Value" := Value;
        ConfigTemplateLine.Insert(true);
    end;

    local procedure GetNextDataTemplateAvailableCode(): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        StockkeepingUnitConfigTemplCode: Code[10];
        StockkeepingUnitConfigTemplCodeTxt: Label 'SKU0000000', MaxLength = 10;
    begin
        StockkeepingUnitConfigTemplCode := StockkeepingUnitConfigTemplCodeTxt;
        repeat
            StockkeepingUnitConfigTemplCode := CopyStr(IncStr(StockkeepingUnitConfigTemplCode), 1, MaxStrLen(ConfigTemplateHeader.Code));
        until not ConfigTemplateHeader.Get(StockkeepingUnitConfigTemplCode);
        exit(StockkeepingUnitConfigTemplCode);
    end;

    local procedure GetDataTemplateDescription(StockkeepingUnitTemplate1: Record "Stockkeeping Unit Template"): Text[100]
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
        StockkeepingUnitConfigTemplDescTok: Label '%1 %2 %3', Comment = '%1 = Stockkeeping Unit TableCaption, %2 = "Item Category Code", %3 = "Location Code"', Locked = true;
    begin
        exit(CopyStr(StrSubstNo(StockkeepingUnitConfigTemplDescTok,
                                StockkeepingUnit.TableCaption(),
                                StockkeepingUnitTemplate1."Item Category Code",
                                StockkeepingUnitTemplate1."Location Code"), 1, 100));
    end;

    local procedure CopyStockkeepingUnit();
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        if StockkeepingUnit.FindSet() then
            repeat
                StockkeepingUnit."Gen. Prod. Posting Group CZL" := StockkeepingUnit."Gen. Prod. Posting Group";
                StockkeepingUnit.Modify(false);
            until StockkeepingUnit.Next() = 0;
    end;

    local procedure CopyItem();
    var
        Item: Record Item;
    begin
        if Item.FindSet() then
            repeat
                Item."Statistic Indication CZL" := Item."Statistic Indication";
                Item."Specific Movement CZL" := Item."Specific Movement";
                Item.Modify(false);
            until Item.Next() = 0;
    end;

    local procedure CopyResource();
    var
        Resource: Record Resource;
    begin
        if Resource.FindSet() then
            repeat
                Resource."Tariff No. CZL" := Resource."Tariff No.";
                Resource.Modify(false);
            until Resource.Next() = 0;
    end;

    local procedure CopyServiceLine();
    var
        ServiceLine: Record "Service Line";
    begin
        if ServiceLine.FindSet() then
            repeat
                ServiceLine."Negative CZL" := ServiceLine.Negative;
                ServiceLine."Physical Transfer CZL" := ServiceLine."Physical Transfer";
                ServiceLine."Tariff No. CZL" := ServiceLine."Tariff No.";
                ServiceLine."Statistic Indication CZL" := ServiceLine."Statistic Indication";
                ServiceLine."Country/Reg. of Orig. Code CZL" := ServiceLine."Country/Region of Origin Code";
                ServiceLine.Modify(false);
            until ServiceLine.Next() = 0;
    end;

    local procedure CopyServiceInvoiceLine();
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
    begin
        if ServiceInvoiceLine.FindSet() then
            repeat
                ServiceInvoiceLine."Tariff No. CZL" := ServiceInvoiceLine."Tariff No.";
                ServiceInvoiceLine."Statistic Indication CZL" := ServiceInvoiceLine."Statistic Indication";
                ServiceInvoiceLine."Country/Reg. of Orig. Code CZL" := ServiceInvoiceLine."Country/Region of Origin Code";
                ServiceInvoiceLine.Modify(false);
            until ServiceInvoiceLine.Next() = 0;
    end;

    local procedure CopyServiceCrMemoLine();
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        if ServiceCrMemoLine.FindSet() then
            repeat
                ServiceCrMemoLine."Tariff No. CZL" := ServiceCrMemoLine."Tariff No.";
                ServiceCrMemoLine."Statistic Indication CZL" := ServiceCrMemoLine."Statistic Indication";
                ServiceCrMemoLine."Country/Reg. of Orig. Code CZL" := ServiceCrMemoLine."Country/Region of Origin Code";
                ServiceCrMemoLine.Modify(false);
            until ServiceCrMemoLine.Next() = 0;
    end;

    local procedure CopyServiceShipmentLine();
    var
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        if ServiceShipmentLine.FindSet() then
            repeat
                ServiceShipmentLine."Tariff No. CZL" := ServiceShipmentLine."Tariff No.";
                ServiceShipmentLine."Statistic Indication CZL" := ServiceShipmentLine."Statistic Indication";
                ServiceShipmentLine.Modify(false);
            until ServiceShipmentLine.Next() = 0;
    end;

    local procedure CopyCertificateCZCode()
    var
        CertificateCZCode: Record "Certificate CZ Code";
        CertificateCodeCZL: Record "Certificate Code CZL";
    begin
        if CertificateCZCode.FindSet() then
            repeat
                if not CertificateCodeCZL.Get(CertificateCZCode.Code) then begin
                    CertificateCodeCZL.Init();
                    CertificateCodeCZL.Code := CertificateCZCode.Code;
                    CertificateCodeCZL.SystemId := CertificateCZCode.SystemId;
                    CertificateCodeCZL.Insert(false, true);
                end;
                CertificateCodeCZL.Description := CertificateCZCode.Description;
                CertificateCodeCZL.Modify(false);
            until CertificateCZCode.Next() = 0;
    end;

    local procedure CopyIsolatedCertificate()
    var
        IsolatedCertificate: Record "Isolated Certificate";
    begin
        if IsolatedCertificate.FindSet() then
            repeat
                IsolatedCertificate."Certificate Code CZL" := IsolatedCertificate."Certificate Code";
                IsolatedCertificate.Modify(false);
            until IsolatedCertificate.Next() = 0;
    end;

    local procedure CopyEETServiceSetup()
    var
        EETServiceSetup: Record "EET Service Setup";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if EETServiceSetup.Get() then begin
            if not EETServiceSetupCZL.Get() then begin
                EETServiceSetupCZL.Init();
                EETServiceSetupCZL.SystemId := EETServiceSetup.SystemId;
                EETServiceSetupCZL.Insert(false, true);
            end;
            EETServiceSetupCZL."Service URL" := EETServiceSetup."Service URL";
            EETServiceSetupCZL."Sales Regime" := EETServiceSetup."Sales Regime";
            EETServiceSetupCZL."Limit Response Time" := EETServiceSetup."Limit Response Time";
            EETServiceSetupCZL."Appointing VAT Reg. No." := EETServiceSetup."Appointing VAT Reg. No.";
            EETServiceSetupCZL."Certificate Code" := EETServiceSetup."Certificate Code";
            if EETServiceSetup.Enabled then begin
                EETServiceSetupCZL.Enabled := true;
                EETServiceSetup.Validate(Enabled, false);
                EETServiceSetup.Modify(false);
            end;
            EETServiceSetupCZL.Modify(false);
        end;
    end;

    local procedure CopyEETBusinessPremises()
    var
        EETBusinessPremises: Record "EET Business Premises";
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        if EETBusinessPremises.FindSet() then
            repeat
                if not EETBusinessPremisesCZL.Get(EETBusinessPremises.Code) then begin
                    EETBusinessPremisesCZL.Init();
                    EETBusinessPremisesCZL.Code := EETBusinessPremises.Code;
                    EETBusinessPremisesCZL.SystemId := EETBusinessPremises.SystemId;
                    EETBusinessPremisesCZL.Insert(false, true);
                end;
                EETBusinessPremisesCZL.Description := EETBusinessPremises.Description;
                EETBusinessPremisesCZL.Identification := EETBusinessPremises.Identification;
                EETBusinessPremisesCZL."Certificate Code" := EETBusinessPremises."Certificate Code";
                EETBusinessPremisesCZL.Modify(false);
            until EETBusinessPremises.Next() = 0;
    end;

    local procedure CopyEETCashRegister()
    var
        EETCashRegister: Record "EET Cash Register";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        if EETCashRegister.FindSet() then
            repeat
                if not EETCashRegisterCZL.Get(EETCashRegister."Business Premises Code", EETCashRegister.Code) then begin
                    EETCashRegisterCZL.Init();
                    EETCashRegisterCZL."Business Premises Code" := EETCashRegister."Business Premises Code";
                    EETCashRegisterCZL.Code := EETCashRegister.Code;
                    EETCashRegisterCZL.SystemId := EETCashRegister.SystemId;
                    EETCashRegisterCZL.Insert(false, true);
                end;
                EETCashRegisterCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETCashRegister."Register Type");
                EETCashRegisterCZL."Cash Register No." := EETCashRegister."Register No.";
                EETCashRegisterCZL."Cash Register Name" := EETCashRegister."Register Name";
                EETCashRegisterCZL."Certificate Code" := EETCashRegister."Certificate Code";
                EETCashRegisterCZL."Receipt Serial Nos." := EETCashRegister."Receipt Serial Nos.";
                EETCashRegisterCZL.Modify(false);
            until EETCashRegister.Next() = 0;
    end;

    local procedure CopyEETEntry()
    var
        EETEntry: Record "EET Entry";
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if EETEntry.FindSet() then
            repeat
                if not EETEntryCZL.Get(EETEntry."Entry No.") then begin
                    EETEntryCZL.Init();
                    EETEntryCZL."Entry No." := EETEntry."Entry No.";
                    EETEntryCZL.SystemId := EETEntry.SystemId;
                    EETEntryCZL.Insert(false, true);
                end;
                EETEntryCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETEntry."Source Type");
                EETEntryCZL."Cash Register No." := EETEntry."Source No.";
                EETEntryCZL."Business Premises Code" := EETEntry."Business Premises Code";
                EETEntryCZL."Cash Register Code" := EETEntry."Cash Register Code";
                EETEntryCZL."Document No." := EETEntry."Document No.";
                EETEntryCZL.Description := EETEntry.Description;
                EETEntryCZL."Applied Document Type" := EETEntry."Applied Document Type";
                EETEntryCZL."Applied Document No." := EETEntry."Applied Document No.";
                EETEntryCZL."Created By" := EETEntry."User ID";
                EETEntryCZL."Created At" := EETEntry."Creation Datetime";
                EETEntryCZL."Status" := "EET Status CZL".FromInteger(EETEntry."EET Status");
                EETEntryCZL."Status Last Changed At" := EETEntry."EET Status Last Changed";
                EETEntryCZL."Message UUID" := EETEntry."Message UUID";
                EETEntry.CalcFields("Signature Code (PKP)");
                EETEntryCZL."Taxpayer's Signature Code" := EETEntry."Signature Code (PKP)";
                EETEntryCZL."Taxpayer's Security Code" := EETEntry."Security Code (BKP)";
                EETEntryCZL."Fiscal Identification Code" := EETEntry."Fiscal Identification Code";
                EETEntryCZL."Receipt Serial No." := EETEntry."Receipt Serial No.";
                EETEntryCZL."Total Sales Amount" := EETEntry."Total Sales Amount";
                EETEntryCZL."Amount Exempted From VAT" := EETEntry."Amount Exempted From VAT";
                EETEntryCZL."VAT Base (Basic)" := EETEntry."VAT Base (Basic)";
                EETEntryCZL."VAT Amount (Basic)" := EETEntry."VAT Amount (Basic)";
                EETEntryCZL."VAT Base (Reduced)" := EETEntry."VAT Base (Reduced)";
                EETEntryCZL."VAT Amount (Reduced)" := EETEntry."VAT Amount (Reduced)";
                EETEntryCZL."VAT Base (Reduced 2)" := EETEntry."VAT Base (Reduced 2)";
                EETEntryCZL."VAT Amount (Reduced 2)" := EETEntry."VAT Amount (Reduced 2)";
                EETEntryCZL."Amount - Art.89" := EETEntry."Amount - Art.89";
                EETEntryCZL."Amount (Basic) - Art.90" := EETEntry."Amount (Basic) - Art.90";
                EETEntryCZL."Amount (Reduced) - Art.90" := EETEntry."Amount (Reduced) - Art.90";
                EETEntryCZL."Amount (Reduced 2) - Art.90" := EETEntry."Amount (Reduced 2) - Art.90";
                EETEntryCZL."Amt. For Subseq. Draw/Settle" := EETEntry."Amt. For Subseq. Draw/Settle";
                EETEntryCZL."Amt. Subseq. Drawn/Settled" := EETEntry."Amt. Subseq. Drawn/Settled";
                EETEntryCZL."Canceled By Entry No." := EETEntry."Canceled By Entry No.";
                EETEntryCZL."Simple Registration" := EETEntry."Simple Registration";
                EETEntryCZL.Modify(false);
            until EETEntry.Next() = 0;
    end;

    local procedure CopyEETEntryStatus()
    var
        EETEntryStatus: Record "EET Entry Status";
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        if EETEntryStatus.FindSet() then
            repeat
                if not EETEntryStatusLogCZL.Get(EETEntryStatus."Entry No.") then begin
                    EETEntryStatusLogCZL.Init();
                    EETEntryStatusLogCZL."Entry No." := EETEntryStatus."Entry No.";
                    EETEntryStatusLogCZL.SystemId := EETEntryStatus.SystemId;
                    EETEntryStatusLogCZL.Insert(false, true);
                end;
                EETEntryStatusLogCZL."EET Entry No." := EETEntryStatus."EET Entry No.";
                EETEntryStatusLogCZL.Description := EETEntryStatus.Description;
                EETEntryStatusLogCZL.Status := "EET Status CZL".FromInteger(EETEntryStatus.Status);
                EETEntryStatusLogCZL."Changed At" := EETEntryStatus."Change Datetime";
                EETEntryStatusLogCZL.Modify(false);
            until EETEntryStatus.Next() = 0;
    end;

    local procedure CopyBankAccount();
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.FindSet() then
            repeat
                BankAccount."Excl. from Exch. Rate Adj. CZL" := BankAccount."Exclude from Exch. Rate Adj.";
                BankAccount.Modify(false);
            until BankAccount.Next() = 0;
    end;

    local procedure CopyConstantSymbol();
    var
        ConstantSymbol: Record "Constant Symbol";
        ConstantSymbolCZL: Record "Constant Symbol CZL";
    begin
        if ConstantSymbol.FindSet() then
            repeat
                if not ConstantSymbolCZL.Get(ConstantSymbol.Code) then begin
                    ConstantSymbolCZL.Init();
                    ConstantSymbolCZL.Code := ConstantSymbol.Code;
                    ConstantSymbolCZL.SystemId := ConstantSymbol.SystemId;
                    ConstantSymbolCZL.Insert(false, true);
                end;
                ConstantSymbolCZL.Description := ConstantSymbol.Description;
                ConstantSymbolCZL.Modify(false);
            until ConstantSymbol.Next() = 0;
    end;

    local procedure CopyDepreciationBook();
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        if DepreciationBook.FindSet() then
            repeat
                DepreciationBook."Mark Reclass. as Correct. CZL" := DepreciationBook."Mark Reclass. as Corrections";
                DepreciationBook.Modify(false);
            until DepreciationBook.Next() = 0;
    end;

    local procedure CopyValueEntry();
    var
        ValueEntry: Record "Value Entry";
    begin
        if ValueEntry.FindSet(true) then
            repeat
                ValueEntry."G/L Correction CZL" := ValueEntry."G/L Correction";
                ValueEntry."Incl. in Intrastat Amount CZL" := ValueEntry."Incl. in Intrastat Amount";
                ValueEntry."Incl. in Intrastat S.Value CZL" := ValueEntry."Incl. in Intrastat Stat. Value";
                ValueEntry.Modify(false);
            until ValueEntry.Next() = 0;
    end;

    local procedure CopySubstCustomerPostingGroup();
    var
        SubstCustomerPostingGroup: Record "Subst. Customer Posting Group";
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
    begin
        if SubstCustomerPostingGroup.FindSet() then
            repeat
                if not SubstCustPostingGroupCZL.Get(SubstCustomerPostingGroup."Parent Cust. Posting Group", SubstCustomerPostingGroup."Customer Posting Group") then begin
                    SubstCustPostingGroupCZL.Init();
                    SubstCustPostingGroupCZL."Parent Customer Posting Group" := SubstCustomerPostingGroup."Parent Cust. Posting Group";
                    SubstCustPostingGroupCZL."Customer Posting Group" := SubstCustomerPostingGroup."Customer Posting Group";
                    SubstCustPostingGroupCZL.SystemId := SubstCustomerPostingGroup.SystemId;
                    SubstCustPostingGroupCZL.Insert(false, true);
                end;
            until SubstCustomerPostingGroup.Next() = 0;
    end;

    local procedure CopySubstVendorPostingGroup();
    var
        SubstVendorPostingGroup: Record "Subst. Vendor Posting Group";
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
    begin
        if SubstVendorPostingGroup.FindSet() then
            repeat
                if not SubstVendPostingGroupCZL.Get(SubstVendorPostingGroup."Parent Vend. Posting Group", SubstVendorPostingGroup."Vendor Posting Group") then begin
                    SubstVendPostingGroupCZL.Init();
                    SubstVendPostingGroupCZL."Parent Vendor Posting Group" := SubstVendorPostingGroup."Parent Vend. Posting Group";
                    SubstVendPostingGroupCZL."Vendor Posting Group" := SubstVendorPostingGroup."Vendor Posting Group";
                    SubstVendPostingGroupCZL.SystemId := SubstVendorPostingGroup.SystemId;
                    SubstVendPostingGroupCZL.Insert(false, true);
                end;
            until SubstVendorPostingGroup.Next() = 0;
    end;

    local procedure CopyShipmentMethod();
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if ShipmentMethod.FindSet() then
            repeat
                ShipmentMethod."Incl. Item Charges (Amt.) CZL" := ShipmentMethod."Include Item Charges (Amount)";
                ShipmentMethod."Intrastat Deliv. Grp. Code CZL" := ShipmentMethod."Intrastat Delivery Group Code";
                ShipmentMethod."Incl. Item Charges (S.Val) CZL" := ShipmentMethod."Incl. Item Charges (Stat.Val.)";
                ShipmentMethod."Adjustment % CZL" := ShipmentMethod."Adjustment %";
                ShipmentMethod.Modify(false);
            until ShipmentMethod.Next() = 0;
    end;

    local procedure CopySpecificMovement()
    var
        SpecificMovement: Record "Specific Movement";
        SpecificMovementCZL: Record "Specific Movement CZL";
    begin
        if SpecificMovement.FindSet() then
            repeat
                if not SpecificMovementCZL.Get(SpecificMovement.Code) then begin
                    SpecificMovementCZL.Init();
                    SpecificMovementCZL.Code := SpecificMovement.Code;
                    SpecificMovementCZL.SystemId := SpecificMovement.SystemId;
                    SpecificMovementCZL.Insert(false, true);
                end;
                SpecificMovementCZL.Description := SpecificMovement.Description;
                SpecificMovementCZL.Modify(false);
            until SpecificMovement.Next() = 0;
    end;

    local procedure CopyIntrastatDeliveryGroup()
    var
        IntrastatDeliveryGroup: Record "Intrastat Delivery Group";
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
    begin
        if IntrastatDeliveryGroup.FindSet() then
            repeat
                if not IntrastatDeliveryGroupCZL.Get(IntrastatDeliveryGroup.Code) then begin
                    IntrastatDeliveryGroupCZL.Init();
                    IntrastatDeliveryGroupCZL.Code := IntrastatDeliveryGroup.Code;
                    IntrastatDeliveryGroupCZL.SystemId := IntrastatDeliveryGroup.SystemId;
                    IntrastatDeliveryGroupCZL.Insert(false, true);
                end;
                IntrastatDeliveryGroupCZL.Description := IntrastatDeliveryGroup.Description;
                IntrastatDeliveryGroupCZL.Modify(false);
            until IntrastatDeliveryGroup.Next() = 0;
    end;

    local procedure CopyUnitofMeasure();
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if UnitofMeasure.FindSet() then
            repeat
                UnitofMeasure."Tariff Number UOM Code CZL" := CopyStr(UnitofMeasure."Tariff Number UOM Code", 1, 10);
                UnitofMeasure.Modify(false);
            until UnitofMeasure.Next() = 0;
    end;

    local procedure CopySalesLineArchive();
    var
        SalesLineArchive: Record "Sales Line Archive";
    begin
        if SalesLineArchive.FindSet() then
            repeat
                SalesLineArchive."Physical Transfer CZL" := SalesLineArchive."Physical Transfer";
                SalesLineArchive.Modify(false);
            until SalesLineArchive.Next() = 0;
    end;

    local procedure CopyPurchaseLineArchive();
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
    begin
        if PurchaseLineArchive.FindSet() then
            repeat
                PurchaseLineArchive."Physical Transfer CZL" := PurchaseLineArchive."Physical Transfer";
                PurchaseLineArchive.Modify(false);
            until PurchaseLineArchive.Next() = 0;
    end;

    local procedure CopyTransferHeader();
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.FindSet() then
            repeat
                TransferHeader."Intrastat Exclude CZL" := TransferHeader."Intrastat Exclude";
                TransferHeader.Modify(false);
            until TransferHeader.Next() = 0;
    end;

    local procedure CopyTransferLine();
    var
        TransferLine: Record "Transfer Line";
    begin
        if TransferLine.FindSet() then
            repeat
                TransferLine."Tariff No. CZL" := TransferLine."Tariff No.";
                TransferLine."Statistic Indication CZL" := TransferLine."Statistic Indication";
                TransferLine."Country/Reg. of Orig. Code CZL" := TransferLine."Country/Region of Origin Code";
                TransferLine.Modify(false);
            until TransferLine.Next() = 0;
    end;

    local procedure CopyTransferReceiptHeader();
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        if TransferReceiptHeader.FindSet() then
            repeat
                TransferReceiptHeader."Intrastat Exclude CZL" := TransferReceiptHeader."Intrastat Exclude";
                TransferReceiptHeader.Modify(false);
            until TransferReceiptHeader.Next() = 0;
    end;

    local procedure CopyTransferShipmentHeader();
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        if TransferShipmentHeader.FindSet() then
            repeat
                TransferShipmentHeader."Intrastat Exclude CZL" := TransferShipmentHeader."Intrastat Exclude";
                TransferShipmentHeader.Modify(false);
            until TransferShipmentHeader.Next() = 0;
    end;

    local procedure CopyItemLedgerEntry();
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if ItemLedgerEntry.FindSet(true) then
            repeat
                ItemLedgerEntry."Tariff No. CZL" := ItemLedgerEntry."Tariff No.";
                ItemLedgerEntry."Physical Transfer CZL" := ItemLedgerEntry."Physical Transfer";
                ItemLedgerEntry."Net Weight CZL" := ItemLedgerEntry."Net Weight";
                ItemLedgerEntry."Country/Reg. of Orig. Code CZL" := ItemLedgerEntry."Country/Region of Origin Code";
                ItemLedgerEntry."Statistic Indication CZL" := ItemLedgerEntry."Statistic Indication";
                ItemLedgerEntry."Intrastat Transaction CZL" := ItemLedgerEntry."Intrastat Transaction";
                ItemLedgerEntry.Modify(false);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure CopyJobLedgerEntry();
    var
        JobLedgerEntry: Record "Job Ledger Entry";
    begin
        if JobLedgerEntry.FindSet(true) then
            repeat
                JobLedgerEntry."Tariff No. CZL" := JobLedgerEntry."Tariff No.";
                JobLedgerEntry."Net Weight CZL" := JobLedgerEntry."Net Weight";
                JobLedgerEntry."Country/Reg. of Orig. Code CZL" := JobLedgerEntry."Country/Region of Origin Code";
                JobLedgerEntry."Statistic Indication CZL" := JobLedgerEntry."Statistic Indication";
                JobLedgerEntry."Intrastat Transaction CZL" := JobLedgerEntry."Intrastat Transaction";
                JobLedgerEntry.Modify(false);
            until JobLedgerEntry.Next() = 0;
    end;

    local procedure CopyItemCharge();
    var
        ItemCharge: Record "Item Charge";
    begin
        if ItemCharge.FindSet(true) then
            repeat
                ItemCharge."Incl. in Intrastat Amount CZL" := ItemCharge."Incl. in Intrastat Amount";
                ItemCharge."Incl. in Intrastat S.Value CZL" := ItemCharge."Incl. in Intrastat Stat. Value";
                ItemCharge.Modify(false);
            until ItemCharge.Next() = 0;
    end;

    local procedure CopyItemChargeAssignmentPurch();
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
    begin
        if ItemChargeAssignmentPurch.FindSet(true) then
            repeat
                ItemChargeAssignmentPurch."Incl. in Intrastat Amount CZL" := ItemChargeAssignmentPurch."Incl. in Intrastat Amount";
                ItemChargeAssignmentPurch."Incl. in Intrastat S.Value CZL" := ItemChargeAssignmentPurch."Incl. in Intrastat Stat. Value";
                ItemChargeAssignmentPurch.Modify(false);
            until ItemChargeAssignmentPurch.Next() = 0;
    end;

    local procedure CopyItemChargeAssignmentSales();
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
    begin
        if ItemChargeAssignmentSales.FindSet(true) then
            repeat
                ItemChargeAssignmentSales."Incl. in Intrastat Amount CZL" := ItemChargeAssignmentSales."Incl. in Intrastat Amount";
                ItemChargeAssignmentSales."Incl. in Intrastat S.Value CZL" := ItemChargeAssignmentSales."Incl. in Intrastat Stat. Value";
                ItemChargeAssignmentSales.Modify(false);
            until ItemChargeAssignmentSales.Next() = 0;
    end;

    local procedure CopyPostedGenJournalLine();
    var
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
    begin
        if PostedGenJournalLine.FindSet(true) then
            repeat
                PostedGenJournalLine."Specific Symbol CZL" := PostedGenJournalLine."Specific Symbol";
                PostedGenJournalLine."Variable Symbol CZL" := PostedGenJournalLine."Variable Symbol";
                PostedGenJournalLine."Constant Symbol CZL" := PostedGenJournalLine."Constant Symbol";
                PostedGenJournalLine."Bank Account Code CZL" := PostedGenJournalLine."Bank Account Code";
                PostedGenJournalLine."Bank Account No. CZL" := PostedGenJournalLine."Bank Account No.";
                PostedGenJournalLine."Transit No. CZL" := PostedGenJournalLine."Transit No.";
                PostedGenJournalLine."IBAN CZL" := PostedGenJournalLine.IBAN;
                PostedGenJournalLine."SWIFT Code CZL" := PostedGenJournalLine."SWIFT Code";
                PostedGenJournalLine.Modify(false);
            until PostedGenJournalLine.Next() = 0;
    end;

    local procedure CopyIntrastatJournalBatch();
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
    begin
        if IntrastatJnlBatch.FindSet(true) then
            repeat
                IntrastatJnlBatch."Declaration No. CZL" := IntrastatJnlBatch."Declaration No.";
                IntrastatJnlBatch."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(IntrastatJnlBatch."Statement Type");
                IntrastatJnlBatch.Modify(false);
            until IntrastatJnlBatch.Next() = 0;
    end;

    local procedure CopyIntrastatJournalLine();
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        if IntrastatJnlLine.FindSet(true) then
            repeat
                IntrastatJnlLine."Additional Costs CZL" := IntrastatJnlLine."Additional Costs";
                IntrastatJnlLine."Source Entry Date CZL" := IntrastatJnlLine."Source Entry Date";
                IntrastatJnlLine."Statistic Indication CZL" := IntrastatJnlLine."Statistic Indication";
                IntrastatJnlLine."Statistics Period CZL" := IntrastatJnlLine."Statistics Period";
                IntrastatJnlLine."Declaration No. CZL" := IntrastatJnlLine."Declaration No.";
                IntrastatJnlLine."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(IntrastatJnlLine."Statement Type");
                IntrastatJnlLine."Prev. Declaration No. CZL" := IntrastatJnlLine."Prev. Declaration No.";
                IntrastatJnlLine."Prev. Declaration Line No. CZL" := IntrastatJnlLine."Prev. Declaration Line No.";
                IntrastatJnlLine."Specific Movement CZL" := IntrastatJnlLine."Specific Movement";
                IntrastatJnlLine."Supplem. UoM Code CZL" := IntrastatJnlLine."Supplem. UoM Code";
                IntrastatJnlLine."Supplem. UoM Quantity CZL" := IntrastatJnlLine."Supplem. UoM Quantity";
                IntrastatJnlLine."Supplem. UoM Net Weight CZL" := IntrastatJnlLine."Supplem. UoM Net Weight";
                IntrastatJnlLine."Base Unit of Measure CZL" := IntrastatJnlLine."Base Unit of Measure";
                IntrastatJnlLine.Modify(false);
            until IntrastatJnlLine.Next() = 0;
    end;

    local procedure CopyInventoryPostingSetup();
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        if InventoryPostingSetup.FindSet() then
            repeat
                InventoryPostingSetup."Change In Inv.OfProd. Acc. CZL" := InventoryPostingSetup."Change In Inv.Of Product Acc.";
                InventoryPostingSetup."Change In Inv.Of WIP Acc. CZL" := InventoryPostingSetup."Change In Inv.Of WIP Acc.";
                InventoryPostingSetup."Consumption Account CZL" := InventoryPostingSetup."Consumption Account";
                InventoryPostingSetup.Modify(false);
            until InventoryPostingSetup.Next() = 0;
    end;

    local procedure CopyGeneralPostingSetup();
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.FindSet() then
            repeat
                GeneralPostingSetup."Invt. Rounding Adj. Acc. CZL" := GeneralPostingSetup."Invt. Rounding Adj. Account";
                GeneralPostingSetup.Modify(false);
            until GeneralPostingSetup.Next() = 0;
    end;

    local procedure CopyUserSetupLine();
    var
        UserSetupLine: Record "User Setup Line";
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        if UserSetupLine.FindSet() then
            repeat
                if not UserSetupLineCZL.Get(UserSetupLine."User ID", UserSetupLine.Type, UserSetupLine."Line No.") then begin
                    UserSetupLineCZL.Init();
                    UserSetupLineCZL."User ID" := UserSetupLine."User ID";
                    UserSetupLineCZL.Type := UserSetupLine.Type;
                    UserSetupLineCZL."Line No." := UserSetupLine."Line No.";
                    UserSetupLineCZL.SystemId := UserSetupLine.SystemId;
                    UserSetupLineCZL.Insert(false, true);
                end;
                UserSetupLineCZL."Code / Name" := UserSetupLine."Code / Name";
                UserSetupLineCZL.Modify(false);
            until UserSetupLine.Next() = 0;
    end;

    local procedure CopyAccScheduleExtension();
    var
        AccScheduleExtension: Record "Acc. Schedule Extension";
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
    begin
        if AccScheduleExtension.FindSet() then
            repeat
                if not AccScheduleExtensionCZL.Get(AccScheduleExtension.Code) then begin
                    AccScheduleExtensionCZL.Init();
                    AccScheduleExtensionCZL.Code := AccScheduleExtension.Code;
                    AccScheduleExtensionCZL.SystemId := AccScheduleExtension.SystemId;
                    AccScheduleExtensionCZL.Insert(false, true);
                end;
                AccScheduleExtensionCZL.Description := AccScheduleExtension.Description;
                AccScheduleExtensionCZL."Source Table" := AccScheduleExtension."Source Table";
                AccScheduleExtensionCZL."Source Type" := AccScheduleExtension."Source Type";
                AccScheduleExtensionCZL."Source Filter" := AccScheduleExtension."Source Filter";
                AccScheduleExtensionCZL."G/L Account Filter" := AccScheduleExtension."G/L Account Filter";
                AccScheduleExtensionCZL."G/L Amount Type" := AccScheduleExtension."G/L Amount Type";
                AccScheduleExtensionCZL."Amount Sign" := AccScheduleExtension."Amount Sign";
                AccScheduleExtensionCZL."Entry Type" := AccScheduleExtension."Entry Type";
                AccScheduleExtensionCZL.Prepayment := AccScheduleExtension.Prepayment;
                AccScheduleExtensionCZL."Reverse Sign" := AccScheduleExtension."Reverse Sign";
                AccScheduleExtensionCZL."VAT Amount Type" := AccScheduleExtension."VAT Amount Type";
                AccScheduleExtensionCZL."VAT Bus. Post. Group Filter" := AccScheduleExtension."VAT Bus. Post. Group Filter";
                AccScheduleExtensionCZL."VAT Prod. Post. Group Filter" := AccScheduleExtension."VAT Prod. Post. Group Filter";
                AccScheduleExtensionCZL."Location Filter" := AccScheduleExtension."Location Filter";
                AccScheduleExtensionCZL."Bin Filter" := AccScheduleExtension."Bin Filter";
                AccScheduleExtensionCZL."Posting Group Filter" := AccScheduleExtension."Posting Group Filter";
                AccScheduleExtensionCZL."Posting Date Filter" := AccScheduleExtension."Posting Date Filter";
                AccScheduleExtensionCZL."Due Date Filter" := AccScheduleExtension."Due Date Filter";
                AccScheduleExtensionCZL."Document Type Filter" := AccScheduleExtension."Document Type Filter";
                AccScheduleExtensionCZL.Modify(false);
            until AccScheduleExtension.Next() = 0;
    end;

    local procedure CopyAccScheduleResultLine();
    var
        AccScheduleResultLine: Record "Acc. Schedule Result Line";
        AccScheduleResultLineCZL: Record "Acc. Schedule Result Line CZL";
    begin
        if AccScheduleResultLine.FindSet() then
            repeat
                if not AccScheduleResultLineCZL.Get(AccScheduleResultLine."Result Code", AccScheduleResultLine."Line No.") then begin
                    AccScheduleResultLineCZL.Init();
                    AccScheduleResultLineCZL."Result Code" := AccScheduleResultLine."Result Code";
                    AccScheduleResultLineCZL."Line No." := AccScheduleResultLine."Line No.";
                    AccScheduleResultLineCZL.SystemId := AccScheduleResultLine.SystemId;
                    AccScheduleResultLineCZL.Insert(false, true);
                end;
                AccScheduleResultLineCZL."Row No." := AccScheduleResultLine."Row No.";
                AccScheduleResultLineCZL.Description := AccScheduleResultLine.Description;
                AccScheduleResultLineCZL.Totaling := AccScheduleResultLine.Totaling;
                AccScheduleResultLineCZL."Totaling Type" := AccScheduleResultLine."Totaling Type";
                AccScheduleResultLineCZL."New Page" := AccScheduleResultLine."New Page";
                AccScheduleResultLineCZL.Show := AccScheduleResultLine.Show;
                AccScheduleResultLineCZL.Bold := AccScheduleResultLine.Bold;
                AccScheduleResultLineCZL.Italic := AccScheduleResultLine.Italic;
                AccScheduleResultLineCZL.Underline := AccScheduleResultLine.Underline;
                AccScheduleResultLineCZL."Show Opposite Sign" := AccScheduleResultLine."Show Opposite Sign";
                AccScheduleResultLineCZL."Row Type" := AccScheduleResultLine."Row Type";
                AccScheduleResultLineCZL."Amount Type" := AccScheduleResultLine."Amount Type";
                AccScheduleResultLineCZL.Modify(false);
            until AccScheduleResultLine.Next() = 0;
    end;

    local procedure CopyAccScheduleResultColumn();
    var
        AccScheduleResultColumn: Record "Acc. Schedule Result Column";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
    begin
        if AccScheduleResultColumn.FindSet() then
            repeat
                if not AccScheduleResultColCZL.Get(AccScheduleResultColumn."Result Code", AccScheduleResultColumn."Line No.") then begin
                    AccScheduleResultColCZL.Init();
                    AccScheduleResultColCZL."Result Code" := AccScheduleResultColumn."Result Code";
                    AccScheduleResultColCZL."Line No." := AccScheduleResultColumn."Line No.";
                    AccScheduleResultColCZL.SystemId := AccScheduleResultColumn.SystemId;
                    AccScheduleResultColCZL.Insert(false, true);
                end;
                AccScheduleResultColCZL."Column No." := AccScheduleResultColumn."Column No.";
                AccScheduleResultColCZL."Column Header" := AccScheduleResultColumn."Column Header";
                AccScheduleResultColCZL."Column Type" := AccScheduleResultColumn."Column Type";
                AccScheduleResultColCZL."Ledger Entry Type" := AccScheduleResultColumn."Ledger Entry Type";
                AccScheduleResultColCZL."Amount Type" := AccScheduleResultColumn."Amount Type";
                AccScheduleResultColCZL.Formula := AccScheduleResultColumn.Formula;
                AccScheduleResultColCZL."Comparison Date Formula" := AccScheduleResultColumn."Comparison Date Formula";
                AccScheduleResultColCZL."Show Opposite Sign" := AccScheduleResultColumn."Show Opposite Sign";
                AccScheduleResultColCZL.Show := AccScheduleResultColumn.Show;
                AccScheduleResultColCZL."Rounding Factor" := AccScheduleResultColumn."Rounding Factor";
                AccScheduleResultColCZL."Comparison Period Formula" := AccScheduleResultColumn."Comparison Period Formula";
                AccScheduleResultColCZL.Modify(false);
            until AccScheduleResultColumn.Next() = 0;
    end;

    local procedure CopyAccScheduleResultValue();
    var
        AccScheduleResultValue: Record "Acc. Schedule Result Value";
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
    begin
        if AccScheduleResultValue.FindSet() then
            repeat
                if not AccScheduleResultValueCZL.Get(AccScheduleResultValue."Result Code", AccScheduleResultValue."Row No.", AccScheduleResultValue."Column No.") then begin
                    AccScheduleResultValueCZL.Init();
                    AccScheduleResultValueCZL."Result Code" := AccScheduleResultValue."Result Code";
                    AccScheduleResultValueCZL."Row No." := AccScheduleResultValue."Row No.";
                    AccScheduleResultValueCZL."Column No." := AccScheduleResultValue."Column No.";
                    AccScheduleResultValueCZL.SystemId := AccScheduleResultValue.SystemId;
                    AccScheduleResultValueCZL.Insert(false, true);
                end;
                AccScheduleResultValueCZL.Value := AccScheduleResultValue.Value;
                AccScheduleResultValueCZL.Modify(false);
            until AccScheduleResultValue.Next() = 0;
    end;

    local procedure CopyAccScheduleResultHeader();
    var
        AccScheduleResultHeader: Record "Acc. Schedule Result Header";
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
    begin
        if AccScheduleResultHeader.FindSet() then
            repeat
                if not AccScheduleResultHdrCZL.Get(AccScheduleResultHeader."Result Code") then begin
                    AccScheduleResultHdrCZL.Init();
                    AccScheduleResultHdrCZL."Result Code" := AccScheduleResultHeader."Result Code";
                    AccScheduleResultHdrCZL.SystemId := AccScheduleResultHeader.SystemId;
                    AccScheduleResultHdrCZL.Insert(false, true);
                end;
                AccScheduleResultHdrCZL.Description := AccScheduleResultHeader.Description;
                AccScheduleResultHdrCZL."Date Filter" := AccScheduleResultHeader."Date Filter";
                AccScheduleResultHdrCZL."Acc. Schedule Name" := AccScheduleResultHeader."Acc. Schedule Name";
                AccScheduleResultHdrCZL."Column Layout Name" := AccScheduleResultHeader."Column Layout Name";
                AccScheduleResultHdrCZL."Dimension 1 Filter" := AccScheduleResultHeader."Dimension 1 Filter";
                AccScheduleResultHdrCZL."Dimension 2 Filter" := AccScheduleResultHeader."Dimension 2 Filter";
                AccScheduleResultHdrCZL."Dimension 3 Filter" := AccScheduleResultHeader."Dimension 3 Filter";
                AccScheduleResultHdrCZL."Dimension 4 Filter" := AccScheduleResultHeader."Dimension 4 Filter";
                AccScheduleResultHdrCZL."User ID" := AccScheduleResultHeader."User ID";
                AccScheduleResultHdrCZL."Result Date" := AccScheduleResultHeader."Result Date";
                AccScheduleResultHdrCZL."Result Time" := AccScheduleResultHeader."Result Time";
                AccScheduleResultHdrCZL.Modify(false);
            until AccScheduleResultHeader.Next() = 0;
    end;

    local procedure CopyAccScheduleResultHistory();
    var
        AccScheduleResultHistory: Record "Acc. Schedule Result History";
        AccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
    begin
        if AccScheduleResultHistory.FindSet() then
            repeat
                if not AccScheduleResultHistCZL.Get(AccScheduleResultHistory."Result Code", AccScheduleResultHistory."Row No.",
                                                    AccScheduleResultHistory."Column No.", AccScheduleResultHistory."Variant No.") then begin
                    AccScheduleResultHistCZL.Init();
                    AccScheduleResultHistCZL."Result Code" := AccScheduleResultHistory."Result Code";
                    AccScheduleResultHistCZL."Row No." := AccScheduleResultHistory."Row No.";
                    AccScheduleResultHistCZL."Column No." := AccScheduleResultHistory."Column No.";
                    AccScheduleResultHistCZL."Variant No." := AccScheduleResultHistory."Variant No.";
                    AccScheduleResultHistCZL.SystemId := AccScheduleResultHistory.SystemId;
                    AccScheduleResultHistCZL.Insert(false, true);
                end;
                AccScheduleResultHistCZL."New Value" := AccScheduleResultHistory."New Value";
                AccScheduleResultHistCZL."Old Value" := AccScheduleResultHistory."Old Value";
                AccScheduleResultHistCZL."User ID" := AccScheduleResultHistory."User ID";
                AccScheduleResultHistCZL."Modified DateTime" := AccScheduleResultHistory."Modified DateTime";
                AccScheduleResultHistCZL.Modify(false);
            until AccScheduleResultHistory.Next() = 0;
    end;

    local procedure CopyGenJournalTemplate();
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange("Not Check Doc. Type", true);
        if GenJournalTemplate.FindSet() then
            repeat
                GenJournalTemplate."Not Check Doc. Type CZL" := GenJournalTemplate."Not Check Doc. Type";
                GenJournalTemplate.Modify(false);
            until GenJournalTemplate.Next() = 0;
    end;

    local procedure ModifyGenJournalTemplate()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        PrevGenJournalTemplate: Record "Gen. Journal Template";
    begin
        if GenJournalTemplate.FindSet(true) then
            repeat
                PrevGenJournalTemplate := GenJournalTemplate;
                GenJournalTemplate."Test Report ID" := Report::"General Journal - Test CZL";
#if CLEAN17
                if GenJournalTemplate."Posting Report ID" = 11763 then
#else
                if GenJournalTemplate."Posting Report ID" = Report::"General Ledger Document" then
#endif
                    GenJournalTemplate."Posting Report ID" := Report::"General Ledger Document CZL";
                if (GenJournalTemplate."Test Report ID" <> PrevGenJournalTemplate."Test Report ID") or (GenJournalTemplate."Posting Report ID" <> PrevGenJournalTemplate."Posting Report ID") then
                    GenJournalTemplate.Modify(false);
            until GenJournalTemplate.Next() = 0;
    end;

    local procedure ModifyReportSelections()
    var
        ReportSelections: Record "Report Selections";
        PrevReportSelections: Record "Report Selections";
    begin
        if ReportSelections.FindSet(true) then
            repeat
                PrevReportSelections := ReportSelections;
                case ReportSelections."Report ID" of
#if CLEAN17
                    31094,
#else
                    Report::"Sales - Quote CZ",
#endif
                    Report::"Standard Sales - Quote":
                        ReportSelections."Report ID" := Report::"Sales Quote CZL";
#if CLEAN17
                    31095,
#else
                    Report::"Order Confirmation CZ",
#endif
                    Report::"Standard Sales - Order Conf.":
                        ReportSelections."Report ID" := Report::"Sales Order Confirmation CZL";
#if CLEAN17
                    31096,
#else
                    Report::"Sales - Invoice CZ",
#endif
                    Report::"Standard Sales - Invoice":
                        ReportSelections."Report ID" := Report::"Sales Invoice CZL";
#if CLEAN17
                    31093,
#else
                    Report::"Return Order Confirmation CZ",
#endif
                    Report::"Return Order Confirmation":
                        ReportSelections."Report ID" := Report::"Sales Return Order Confirm CZL";
#if CLEAN17
                    31097,
#else
                    Report::"Sales - Credit Memo CZ",
#endif
                    Report::"Standard Sales - Credit Memo":
                        ReportSelections."Report ID" := Report::"Sales Credit Memo CZL";
#if CLEAN17
                    31098,
#else
                    Report::"Sales - Shipment CZ",
#endif
                    Report::"Sales - Shipment":
                        ReportSelections."Report ID" := Report::"Sales Shipment CZL";
#if CLEAN17 
                    31099,
#else
                    Report::"Sales - Return Reciept CZ",
#endif
                    Report::"Sales - Return Receipt":
                        ReportSelections."Report ID" := Report::"Sales Return Reciept CZL";
#if CLEAN17
                    31091,
#else
                    Report::"Purchase - Quote CZ",
#endif
                    Report::"Purchase - Quote":
                        ReportSelections."Report ID" := Report::"Purchase Quote CZL";
#if CLEAN17
                    31092,
#else
                    Report::"Order CZ",
#endif
                    Report::"Standard Purchase - Order":
                        ReportSelections."Report ID" := Report::"Purchase Order CZL";
#if CLEAN17
                    31110,
#else
                    Report::"Service Quote CZ",
#endif
                    Report::"Service Quote":
                        ReportSelections."Report ID" := Report::"Service Quote CZL";
#if CLEAN17
                    31111,
#else
                    Report::"Service Order CZ",
#endif
                    Report::"Service Order":
                        ReportSelections."Report ID" := Report::"Service Order CZL";
#if CLEAN17
                    31088,
#else
                    Report::"Service - Invoice CZ",
#endif
                    Report::"Service - Invoice":
                        ReportSelections."Report ID" := Report::"Service Invoice CZL";
#if CLEAN17
                    31089,
#else
                    Report::"Service - Credit Memo CZ",
#endif
                    Report::"Service - Credit Memo":
                        ReportSelections."Report ID" := Report::"Service Credit Memo CZL";
#if CLEAN17
                    31090,
#else
                    Report::"Service - Shipment CZ",
#endif
                    Report::"Service - Shipment":
                        ReportSelections."Report ID" := Report::"Service Shipment CZL";
#if CLEAN17
                    31112,
#else
                    Report::"Service Contract Quote CZ",
#endif
                    Report::"Service Contract Quote":
                        ReportSelections."Report ID" := Report::"Service Contract Quote CZL";
#if CLEAN17
                    31113,
#else
                    Report::"Service Contract CZ",
#endif
                    Report::"Service Contract":
                        ReportSelections."Report ID" := Report::"Service Contract CZL";
#if CLEAN17
                    31086,
#else
                    Report::"Reminder CZ",
#endif
                    Report::Reminder:
                        ReportSelections."Report ID" := Report::"Reminder CZL";
#if CLEAN17
                    31087,
#else
                    Report::"Finance Charge Memo CZ",
#endif
                    Report::"Finance Charge Memo":
                        ReportSelections."Report ID" := Report::"Finance Charge Memo CZL";
                end;
                if ReportSelections."Report ID" <> PrevReportSelections."Report ID" then
                    ReportSelections.Modify();
            until ReportSelections.Next() = 0;
    end;

    local procedure ModifyVATStatementTemplate()
    var
        VATStatementTemplate: Record "VAT Statement Template";
        PrevVATStatementTemplate: Record "VAT Statement Template";
    begin
        if VATStatementTemplate.FindSet(true) then
            repeat
                PrevVATStatementTemplate := VATStatementTemplate;
                if VATStatementTemplate."VAT Statement Report ID" = Report::"VAT Statement" then
                    VATStatementTemplate."VAT Statement Report ID" := Report::"VAT Statement CZL";
                if (VATStatementTemplate."VAT Statement Report ID" <> PrevVATStatementTemplate."VAT Statement Report ID") then
                    VATStatementTemplate.Modify();
            until VATStatementTemplate.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZL: Codeunit "Data Class. Eval. Handler CZL";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        InitRegistrationNoServiceConfig();
        InitUnreliablePayerServiceSetup();
        InitVATCtrlReportSections();
        InitStatutoryReportingSetup();
        InitSWIFTCodes();
        InitEETServiceSetup();
        InitSourceCodeSetup();

        ModifyReportSelections();

        DataClassEvalHandlerCZL.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;

    local procedure InitRegistrationNoServiceConfig()
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.SetupService();
    end;

    local procedure InitUnreliablePayerServiceSetup()
    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        PrevUnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        UnreliablePayerWSCZL: Codeunit "Unreliable Payer WS CZL";
    begin
        if not UnrelPayerServiceSetupCZL.Get() then begin
            UnrelPayerServiceSetupCZL.Init();
            UnrelPayerServiceSetupCZL.Insert();
        end;

        PrevUnrelPayerServiceSetupCZL := UnrelPayerServiceSetupCZL;
        UnrelPayerServiceSetupCZL."Unreliable Payer Web Service" := UnreliablePayerMgtCZL.GetUnreliablePayerServiceURL();
        UnrelPayerServiceSetupCZL.Enabled := false;
        UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" := 20140101D;
        UnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit" := 700000;
        UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" := UnreliablePayerWSCZL.GetDefaultInputRecordLimit();

        if (UnrelPayerServiceSetupCZL."Unreliable Payer Web Service" <> PrevUnrelPayerServiceSetupCZL."Unreliable Payer Web Service") or
           (UnrelPayerServiceSetupCZL.Enabled <> PrevUnrelPayerServiceSetupCZL.Enabled) or
           (UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" <> PrevUnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date") or
           (UnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit" <> PrevUnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit") or
           (UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" <> PrevUnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit")
        then
            UnrelPayerServiceSetupCZL.Modify();
    end;

    local procedure InitVATCtrlReportSections()
    var
        XA1Tok: Label 'A1', Locked = true;
        XA2Tok: Label 'A2', Locked = true;
        XA3Tok: Label 'A3', Locked = true;
        XA4Tok: Label 'A4', Locked = true;
        XA5Tok: Label 'A5', Locked = true;
        XB1Tok: Label 'B1', Locked = true;
        XB2Tok: Label 'B2', Locked = true;
        XB3Tok: Label 'B3', Locked = true;
        XReverseChargeSalesTxt: Label 'Reverse charge sales';
        XReverseChargePurchaseTxt: Label 'Reverse charge purchase';
        XEUPurchaseTxt: Label 'EU purchase';
        XSalesOfInvestmentGoldTxt: Label 'Sales of investment gold';
        XDomesticSalesAbove10ThousandTxt: Label 'Domestic sales above 10 thousand';
        XDomesticSalesBelow10ThousandTxt: Label 'Domestic sales below 10 thousand';
        XDomesticPurchaseAbove10ThousandTxt: Label 'Domestic purchase above 10 thousand';
        XDomesticPurchaseBelow10ThousandTxt: Label 'Domestic purchase below 10 thousand';
    begin
        InsertVATCtrlReportSection(XA1Tok, XReverseChargeSalesTxt, 0, '');
        InsertVATCtrlReportSection(XA2Tok, XEUPurchaseTxt, 1, '');
        InsertVATCtrlReportSection(XA3Tok, XSalesOfInvestmentGoldTxt, 0, '');
        InsertVATCtrlReportSection(XA4Tok, XDomesticSalesAbove10ThousandTxt, 0, XA5Tok);
        InsertVATCtrlReportSection(XA5Tok, XDomesticSalesBelow10ThousandTxt, 2, '');
        InsertVATCtrlReportSection(XB1Tok, XReverseChargePurchaseTxt, 1, '');
        InsertVATCtrlReportSection(XB2Tok, XDomesticPurchaseAbove10ThousandTxt, 1, XB3Tok);
        InsertVATCtrlReportSection(XB3Tok, XDomesticPurchaseBelow10ThousandTxt, 2, '');
    end;

    local procedure InsertVATCtrlReportSection(VATCtrlReportCode: Code[20]; VATCtrlReportDescription: Text[50]; GroupBy: Option; SimplifiedTaxDocSectCode: Code[20])
    var
        VATCtrlReportSectionCZL: Record "VAT Ctrl. Report Section CZL";
    begin
        if VATCtrlReportSectionCZL.Get(VATCtrlReportCode) then
            exit;
        VATCtrlReportSectionCZL.Init();
        VATCtrlReportSectionCZL.Code := VATCtrlReportCode;
        VATCtrlReportSectionCZL.Description := VATCtrlReportDescription;
        VATCtrlReportSectionCZL."Group By" := GroupBy;
        VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" := SimplifiedTaxDocSectCode;
        VATCtrlReportSectionCZL.Insert();
    end;

    local procedure InitStatutoryReportingSetup()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        PrevStatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if not StatutoryReportingSetupCZL.Get() then begin
            StatutoryReportingSetupCZL.Init();
            StatutoryReportingSetupCZL.Insert();
        end;

        PrevStatutoryReportingSetupCZL := StatutoryReportingSetupCZL;
        StatutoryReportingSetupCZL."VAT Control Report XML Format" := StatutoryReportingSetupCZL."VAT Control Report XML Format"::"03_01_03";
        StatutoryReportingSetupCZL."Simplified Tax Document Limit" := 10000;
        StatutoryReportingSetupCZL."VIES Declaration Report No." := Report::"VIES Declaration CZL";
        StatutoryReportingSetupCZL."VIES Declaration Export No." := Xmlport::"VIES Declaration CZL";

        if (StatutoryReportingSetupCZL."VAT Control Report XML Format" <> PrevStatutoryReportingSetupCZL."VAT Control Report XML Format") or
           (StatutoryReportingSetupCZL."Simplified Tax Document Limit" <> PrevStatutoryReportingSetupCZL."Simplified Tax Document Limit") or
           (StatutoryReportingSetupCZL."VIES Declaration Report No." <> PrevStatutoryReportingSetupCZL."VIES Declaration Report No.") or
           (StatutoryReportingSetupCZL."VIES Declaration Export No." <> PrevStatutoryReportingSetupCZL."VIES Declaration Export No.")
        then
            StatutoryReportingSetupCZL.Modify();
    end;

    local procedure InitSWIFTCodes()
    var
        KOMBCZPPTok: Label 'KOMBCZPP', Locked = true;
        KOMBCZPPTxt: Label 'Komerční banka, a.s.';
        CEKOCZPPTok: Label 'CEKOCZPP', Locked = true;
        CEKOCZPPTxt: Label 'Československá obchodní banka, a.s.';
        CNBACZPPTok: Label 'CNBACZPP', Locked = true;
        CNBACZPPTxt: Label 'Česká národní banka';
        GIBACZPXTok: Label 'GIBACZPX', Locked = true;
        GIBACZPXTxt: Label 'Česká spořitelna, a.s.';
        AGBACZPPTok: Label 'AGBACZPP', Locked = true;
        AGBACZPPTxt: Label 'MONETA Money Bank, a.s.';
        FIOBCZPPTok: Label 'FIOBCZPP', Locked = true;
        FIOBCZPPTxt: Label 'Fio banka, a.s.';
        BACXCZPPTok: Label 'BACXCZPP', Locked = true;
        BACXCZPPTxt: Label 'UniCredit Bank Czech Republic and Slovakia, a.s.';
        AIRACZPPTok: Label 'AIRACZPP', Locked = true;
        AIRACZPPTxt: Label 'Air Bank a.s.';
        INGBCZPPTok: Label 'INGBCZPP', Locked = true;
        INGBCZPPTxt: Label 'ING Bank N.V.';
        RZBCCZPPTok: Label 'RZBCCZPP', Locked = true;
        RZBCCZPPTxt: Label 'Raiffeisenbank a.s.';
        JTBPCZPPTok: Label 'JTBPCZPP', Locked = true;
        JTBPCZPPTxt: Label 'J & T Banka, a.s.';
        PMBPCZPPTok: Label 'PMBPCZPP', Locked = true;
        PMBPCZPPTxt: Label 'PPF banka a.s.';
        EQBKCZPPTok: Label 'EQBKCZPP', Locked = true;
        EQBKCZPPTxt: Label 'Equa bank a.s.';
    begin
        InsertSWIFTCode(KOMBCZPPTok, KOMBCZPPTxt);
        InsertSWIFTCode(CEKOCZPPTok, CEKOCZPPTxt);
        InsertSWIFTCode(CNBACZPPTok, CNBACZPPTxt);
        InsertSWIFTCode(GIBACZPXTok, GIBACZPXTxt);
        InsertSWIFTCode(AGBACZPPTok, AGBACZPPTxt);
        InsertSWIFTCode(FIOBCZPPTok, FIOBCZPPTxt);
        InsertSWIFTCode(BACXCZPPTok, BACXCZPPTxt);
        InsertSWIFTCode(AIRACZPPTok, AIRACZPPTxt);
        InsertSWIFTCode(INGBCZPPTok, INGBCZPPTxt);
        InsertSWIFTCode(RZBCCZPPTok, RZBCCZPPTxt);
        InsertSWIFTCode(JTBPCZPPTok, JTBPCZPPTxt);
        InsertSWIFTCode(PMBPCZPPTok, PMBPCZPPTxt);
        InsertSWIFTCode(EQBKCZPPTok, EQBKCZPPTxt);
    end;

    local procedure InsertSWIFTCode(SWIFTCodeCode: Code[20]; SWIFTCodeName: Text[100])
    var
        SWIFTCode: Record "SWIFT Code";
    begin
        if SWIFTCode.Get(SWIFTCodeCode) then
            exit;
        SWIFTCode.Init();
        SWIFTCode.Code := SWIFTCodeCode;
        SWIFTCode.Name := SWIFTCodeName;
        SWIFTCode.Insert();
    end;

    local procedure InitEETServiceSetup()
    var
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if EETServiceSetupCZL.Get() then
            exit;

        EETServiceSetupCZL.Init();
        EETServiceSetupCZL.SetURLToDefault(false);
        EETServiceSetupCZL.Insert(true);
    end;

    local procedure InitSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
        PrevSourceCodeSetup: Record "Source Code Setup";
        PurchaseVATDelaySourceCodeTxt: Label 'VATPD', MaxLength = 10;
        PurchaseVATDelaySourceCodeDescriptionTxt: Label 'Purchase VAT Delay', MaxLength = 100;
        SalesVATDelaySourceCodeTxt: Label 'VATSD', MaxLength = 10;
        SalesVATDelaySourceCodeDescriptionTxt: Label 'Sales VAT Delay', MaxLength = 100;
        VATLCYCorrectionSourceCodeTxt: Label 'VATCORR', MaxLength = 10;
        VATLCYCorrectionSourceCodeDescriptionTxt: Label 'VAT Correction in LCY', MaxLength = 100;
        OpenBalanceSheetSourceCodeTxt: Label 'OPBALANCE', MaxLength = 10;
        OpenBalanceSheetSourceCodeDescriptionTxt: Label 'Open Balance Sheet', MaxLength = 100;
        CloseBalanceSheetSourceCodeTxt: Label 'CLBALANCE', MaxLength = 10;
        CloseBalanceSheetSourceCodeDescriptionTxt: Label 'Close Balance Sheet', MaxLength = 100;
    begin
        SourceCodeSetup.Get();
        PrevSourceCodeSetup := SourceCodeSetup;
        InsertSourceCode(SourceCodeSetup."Purchase VAT Delay CZL", PurchaseVATDelaySourceCodeTxt, PurchaseVATDelaySourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."Sales VAT Delay CZL", SalesVATDelaySourceCodeTxt, SalesVATDelaySourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."VAT LCY Correction CZL", VATLCYCorrectionSourceCodeTxt, VATLCYCorrectionSourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."Open Balance Sheet CZL", OpenBalanceSheetSourceCodeTxt, OpenBalanceSheetSourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."Close Balance Sheet CZL", CloseBalanceSheetSourceCodeTxt, CloseBalanceSheetSourceCodeDescriptionTxt);

        if (SourceCodeSetup."Purchase VAT Delay CZL" <> PrevSourceCodeSetup."Purchase VAT Delay CZL") or
           (SourceCodeSetup."Sales VAT Delay CZL" <> PrevSourceCodeSetup."Sales VAT Delay CZL") or
           (SourceCodeSetup."VAT LCY Correction CZL" <> PrevSourceCodeSetup."VAT LCY Correction CZL") or
           (SourceCodeSetup."Open Balance Sheet CZL" <> PrevSourceCodeSetup."Open Balance Sheet CZL") or
           (SourceCodeSetup."Close Balance Sheet CZL" <> PrevSourceCodeSetup."Close Balance Sheet CZL")
        then
            SourceCodeSetup.Modify();
    end;

    local procedure InsertSourceCode(var SourceCodeDefCode: Code[10]; "Code": Code[10]; Description: Text[100])
    var
        SourceCode: Record "Source Code";
    begin
        SourceCodeDefCode := Code;
        if SourceCode.Get(Code) then
            exit;
        SourceCode.Init();
        SourceCode.Code := Code;
        SourceCode.Description := Description;
        SourceCode.Insert();
    end;

    local procedure ModifyItemJournalTemplate()
    var
        ItemJournalTemplate: Record "Item Journal Template";
        PrevItemJournalTemplate: Record "Item Journal Template";
    begin
        if ItemJournalTemplate.FindSet(true) then
            repeat
                PrevItemJournalTemplate := ItemJournalTemplate;
#if CLEAN17
                if ItemJournalTemplate."Posting Report ID" = 31078 then
#else
                if ItemJournalTemplate."Posting Report ID" = Report::"Posted Inventory Document" then
#endif
                    ItemJournalTemplate."Posting Report ID" := Report::"Posted Inventory Document CZL";
                if (ItemJournalTemplate."Posting Report ID" <> PrevItemJournalTemplate."Posting Report ID") then
                    ItemJournalTemplate.Modify();
            until ItemJournalTemplate.Next() = 0;
    end;
}
