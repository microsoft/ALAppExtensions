#pragma warning disable AL0432,AL0603
codeunit 11748 "Install Application CZL"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            CopyData();
            ModifyData();
        end;

        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyData()
    begin
        CopyCompanyInformation();
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
        CopyVendLedgerEntry();
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
    end;

    local procedure ModifyData()
    begin
        ModifyGenJournalTemplate();
        ModifyReportSelections();
        ModifyVATStatementTemplate();
        ModifyItemJournalTemplate();
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyCompanyInformation();
    var
        CompanyInformation: Record "Company Information";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if CompanyInformation.Get() then begin
            CompanyInformation."Bank Branch Name CZL" := CompanyInformation."Branch Name";
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyCustomer();
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet() then
            repeat
                Customer."Registration No. CZL" := Customer."Registration No.";
                Customer."Tax Registration No. CZL" := Customer."Tax Registration No.";
                Customer.Modify(false);
            until Customer.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyVendor();
    var
        Vendor: Record Vendor;
    begin
        if Vendor.FindSet() then
            repeat
                Vendor."Registration No. CZL" := Vendor."Registration No.";
                Vendor."Tax Registration No. CZL" := Vendor."Tax Registration No.";
                Vendor."Disable Unreliab. Check CZL" := true;
                Vendor.Modify(false);
            until Vendor.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    UnreliablePayerEntryCZL.Insert();
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    RegistrationLogCZL.Insert();
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    InvtMovementTemplateCZL.Insert();
                end;
                InvtMovementTemplateCZL.Description := WhseNetChangeTemplate.Description;
                InvtMovementTemplateCZL."Entry Type" := WhseNetChangeTemplate."Entry Type";
                InvtMovementTemplateCZL."Gen. Bus. Posting Group" := WhseNetChangeTemplate."Gen. Bus. Posting Group";
                InvtMovementTemplateCZL.Modify(false);
            until WhseNetChangeTemplate.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyItemJournalLine();
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        if ItemJournalLine.FindSet() then
            repeat
                ItemJournalLine."Invt. Movement Template CZL" := ItemJournalLine."Whse. Net Change Template";
                ItemJournalLine.Modify(false);
            until ItemJournalLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyJobJournalLine();
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        if JobJournalLine.FindSet() then
            repeat
                JobJournalLine."Invt. Movement Template CZL" := JobJournalLine."Whse. Net Change Template";
                JobJournalLine.Modify(false);
            until JobJournalLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup."Def.Tmpl. for Phys.Pos.Adj CZL" := InventorySetup."Def.Template for Phys.Pos.Adj";
            InventorySetup."Def.Tmpl. for Phys.Neg.Adj CZL" := InventorySetup."Def.Template for Phys.Neg.Adj";
            InventorySetup.Modify(false);
        end;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyGLSetup();
    var
        GLSetup: Record "General Ledger Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if GLSetup.Get() then begin
            GLSetup."Use VAT Date CZL" := GLSetup."Use VAT Date";
            GLSetup."Allow VAT Posting From CZL" := GLSetup."Allow VAT Posting From";
            GLSetup."Allow VAT Posting To CZL" := GLSetup."Allow VAT Posting To";
            GLSetup."Do Not Check Dimensions CZL" := GLSetup."Dont Check Dimension";
            GLSetup.Modify(false);

            if not StatutoryReportingSetupCZL.Get() then begin
                StatutoryReportingSetupCZL.Init();
                StatutoryReportingSetupCZL.Insert();
            end;
            StatutoryReportingSetupCZL."Company Official Nos." := GLSetup."Company Officials Nos.";
            StatutoryReportingSetupCZL.Modify();
        end;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesSetup();
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesSetup.Get() then begin
            SalesSetup."Default VAT Date CZL" := SalesSetup."Default VAT Date";
            SalesSetup.Modify(false);
        end;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchaseSetup();
    var
        PurchaseSetup: Record "Purchases & Payables Setup";
    begin
        if PurchaseSetup.Get() then begin
            PurchaseSetup."Default VAT Date CZL" := PurchaseSetup."Default VAT Date";
            PurchaseSetup."Def. Orig. Doc. VAT Date CZL" := PurchaseSetup."Default Orig. Doc. VAT Date";
            PurchaseSetup.Modify(false);
        end;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceSetup();
    var
        ServiceSetup: Record "Service Mgt. Setup";
    begin
        if ServiceSetup.Get() then begin
            ServiceSetup."Default VAT Date CZL" := ServiceSetup."Default VAT Date";
            ServiceSetup.Modify(false);
        end;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyUserSetup();
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.FindSet(true) then
            repeat
                UserSetup."Allow VAT Posting From CZL" := UserSetup."Allow VAT Posting From";
                UserSetup."Allow VAT Posting To CZL" := UserSetup."Allow VAT Posting To";
                UserSetup.Modify(false);
            until UserSetup.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATPeriodCZL.Insert();
                end;
                VATPeriodCZL.Name := VATPeriod.Name;
                VATPeriodCZL."New VAT Year" := VATPeriod."New VAT Year";
                VATPeriodCZL.Closed := VATPeriod.Closed;
                VATPeriodCZL.Modify(false);
            until VATPeriod.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyCustLedgerEntry();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetFilter(CustLedgerEntry."VAT Date", '<>0D');
        if CustLedgerEntry.FindSet(true) then
            repeat
                CustLedgerEntry."VAT Date CZL" := CustLedgerEntry."VAT Date";
                CustLedgerEntry.Modify(false);
            until CustLedgerEntry.Next() = 0;

    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyVendLedgerEntry();
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgerEntry.SetFilter(VendLedgerEntry."VAT Date", '<>0D');
        if VendLedgerEntry.FindSet(true) then
            repeat
                VendLedgerEntry."VAT Date CZL" := VendLedgerEntry."VAT Date";
                VendLedgerEntry.Modify(false);
            until VendLedgerEntry.Next() = 0;

    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                VATEntry."VAT Ctrl. Report No. CZL" := VATEntry."VAT Control Report No.";
                VATEntry."VAT Ctrl. Report Line No. CZL" := VATEntry."VAT Control Report Line No.";
                VATEntry."VAT Delay CZL" := VATEntry."VAT Delay";
                VATEntry.Modify(false);
            until VATEntry.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyGenJournalLine();
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if GenJournalLine.FindSet(true) then
            repeat
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesHeader();
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.FindSet(true) then
            repeat
                SalesHeader."VAT Date CZL" := SalesHeader."VAT Date";
                SalesHeader."Registration No. CZL" := SalesHeader."Registration No.";
                SalesHeader."Tax Registration No. CZL" := SalesHeader."Tax Registration No.";
                SalesHeader."Credit Memo Type CZL" := SalesHeader."Credit Memo Type";
                SalesHeader."EU 3-Party Intermed. Role CZL" := SalesHeader."EU 3-Party Intermediate Role";
                SalesHeader."Original Doc. VAT Date CZL" := SalesHeader."Original Document VAT Date";
                SalesHeader."VAT Currency Factor CZL" := SalesHeader."VAT Currency Factor";
                SalesHeader."VAT Currency Code CZL" := SalesHeader."Currency Code";
                SalesHeader.Modify(false);
            until SalesHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesShipmentHeader();
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if SalesShipmentHeader.FindSet(true) then
            repeat
                SalesShipmentHeader."Registration No. CZL" := SalesShipmentHeader."Registration No.";
                SalesShipmentHeader."Tax Registration No. CZL" := SalesShipmentHeader."Tax Registration No.";
                SalesShipmentHeader."EU 3-Party Intermed. Role CZL" := SalesShipmentHeader."EU 3-Party Intermediate Role";
                SalesShipmentHeader.Modify(false);
            until SalesShipmentHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if SalesInvoiceHeader.FindSet(true) then
            repeat
                SalesInvoiceHeader."VAT Date CZL" := SalesInvoiceHeader."VAT Date";
                SalesInvoiceHeader."Registration No. CZL" := SalesInvoiceHeader."Registration No.";
                SalesInvoiceHeader."Tax Registration No. CZL" := SalesInvoiceHeader."Tax Registration No.";
                SalesInvoiceHeader."EU 3-Party Intermed. Role CZL" := SalesInvoiceHeader."EU 3-Party Intermediate Role";
                SalesInvoiceHeader."VAT Currency Factor CZL" := SalesInvoiceHeader."VAT Currency Factor";
                SalesInvoiceHeader."VAT Currency Code CZL" := SalesInvoiceHeader."Currency Code";
                SalesInvoiceHeader.Modify(false);
            until SalesInvoiceHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if SalesCrMemoHeader.FindSet(true) then
            repeat
                SalesCrMemoHeader."VAT Date CZL" := SalesCrMemoHeader."VAT Date";
                SalesCrMemoHeader."Registration No. CZL" := SalesCrMemoHeader."Registration No.";
                SalesCrMemoHeader."Tax Registration No. CZL" := SalesCrMemoHeader."Tax Registration No.";
                SalesCrMemoHeader."Credit Memo Type CZL" := SalesCrMemoHeader."Credit Memo Type";
                SalesCrMemoHeader."EU 3-Party Intermed. Role CZL" := SalesCrMemoHeader."EU 3-Party Intermediate Role";
                SalesCrMemoHeader."VAT Currency Factor CZL" := SalesCrMemoHeader."VAT Currency Factor";
                SalesCrMemoHeader."VAT Currency Code CZL" := SalesCrMemoHeader."Currency Code";
                SalesCrMemoHeader.Modify(false);
            until SalesCrMemoHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyReturnReceiptHeader();
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
    begin
        if ReturnReceiptHeader.FindSet(true) then
            repeat
                ReturnReceiptHeader."Registration No. CZL" := ReturnReceiptHeader."Registration No.";
                ReturnReceiptHeader."Tax Registration No. CZL" := ReturnReceiptHeader."Tax Registration No.";
                ReturnReceiptHeader.Modify(false);
            until ReturnReceiptHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesHeaderArchive();
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        if SalesHeaderArchive.FindSet(true) then
            repeat
                SalesHeaderArchive."VAT Date CZL" := SalesHeaderArchive."VAT Date";
                SalesHeaderArchive."Registration No. CZL" := SalesHeaderArchive."Registration No.";
                SalesHeaderArchive."Tax Registration No. CZL" := SalesHeaderArchive."Tax Registration No.";
                SalesHeaderArchive."EU 3-Party Intermed. Role CZL" := SalesHeaderArchive."EU 3-Party Intermediate Role";
                SalesHeaderArchive."VAT Currency Factor CZL" := SalesHeaderArchive."VAT Currency Factor";
                SalesHeaderArchive."VAT Currency Code CZL" := SalesHeaderArchive."Currency Code";
                SalesHeaderArchive.Modify(false);
            until SalesHeaderArchive.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchaseHeader();
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.FindSet(true) then
            repeat
                PurchaseHeader."VAT Date CZL" := PurchaseHeader."VAT Date";
                PurchaseHeader."Registration No. CZL" := PurchaseHeader."Registration No.";
                PurchaseHeader."Tax Registration No. CZL" := PurchaseHeader."Tax Registration No.";
                PurchaseHeader."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermediate Role";
                PurchaseHeader."EU 3-Party Trade CZL" := PurchaseHeader."EU 3-Party Trade";
                PurchaseHeader."Original Doc. VAT Date CZL" := PurchaseHeader."Original Document VAT Date";
                PurchaseHeader."VAT Currency Factor CZL" := PurchaseHeader."VAT Currency Factor";
                PurchaseHeader."VAT Currency Code CZL" := PurchaseHeader."Currency Code";
                PurchaseHeader.Modify(false);
            until PurchaseHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchaseReceiptHeader();
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if PurchRcptHeader.FindSet(true) then
            repeat
                PurchRcptHeader."Registration No. CZL" := PurchRcptHeader."Registration No.";
                PurchRcptHeader."Tax Registration No. CZL" := PurchRcptHeader."Tax Registration No.";
                PurchRcptHeader."EU 3-Party Intermed. Role CZL" := PurchRcptHeader."EU 3-Party Intermediate Role";
                PurchRcptHeader."EU 3-Party Trade CZL" := PurchRcptHeader."EU 3-Party Trade";
                PurchRcptHeader.Modify(false);
            until PurchRcptHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchaseInvoiceHeader();
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        if PurchaseInvoiceHeader.FindSet(true) then
            repeat
                PurchaseInvoiceHeader."VAT Date CZL" := PurchaseInvoiceHeader."VAT Date";
                PurchaseInvoiceHeader."Registration No. CZL" := PurchaseInvoiceHeader."Registration No.";
                PurchaseInvoiceHeader."Tax Registration No. CZL" := PurchaseInvoiceHeader."Tax Registration No.";
                PurchaseInvoiceHeader."EU 3-Party Intermed. Role CZL" := PurchaseInvoiceHeader."EU 3-Party Intermediate Role";
                PurchaseInvoiceHeader."EU 3-Party Trade CZL" := PurchaseInvoiceHeader."EU 3-Party Trade";
                PurchaseInvoiceHeader."Original Doc. VAT Date CZL" := PurchaseInvoiceHeader."Original Document VAT Date";
                PurchaseInvoiceHeader."VAT Currency Factor CZL" := PurchaseInvoiceHeader."VAT Currency Factor";
                PurchaseInvoiceHeader."VAT Currency Code CZL" := PurchaseInvoiceHeader."Currency Code";
                PurchaseInvoiceHeader.Modify(false);
            until PurchaseInvoiceHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchaseCrMemoHeader();
    var
        PurchaseCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        if PurchaseCrMemoHeader.FindSet(true) then
            repeat
                PurchaseCrMemoHeader."VAT Date CZL" := PurchaseCrMemoHeader."VAT Date";
                PurchaseCrMemoHeader."Registration No. CZL" := PurchaseCrMemoHeader."Registration No.";
                PurchaseCrMemoHeader."Tax Registration No. CZL" := PurchaseCrMemoHeader."Tax Registration No.";
                PurchaseCrMemoHeader."EU 3-Party Intermed. Role CZL" := PurchaseCrMemoHeader."EU 3-Party Intermediate Role";
                PurchaseCrMemoHeader."EU 3-Party Trade CZL" := PurchaseCrMemoHeader."EU 3-Party Trade";
                PurchaseCrMemoHeader."Original Doc. VAT Date CZL" := PurchaseCrMemoHeader."Original Document VAT Date";
                PurchaseCrMemoHeader."VAT Currency Factor CZL" := PurchaseCrMemoHeader."VAT Currency Factor";
                PurchaseCrMemoHeader."VAT Currency Code CZL" := PurchaseCrMemoHeader."Currency Code";
                PurchaseCrMemoHeader.Modify(false);
            until PurchaseCrMemoHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyReturnShipmentHeader();
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        if ReturnShipmentHeader.FindSet(true) then
            repeat
                ReturnShipmentHeader."Registration No. CZL" := ReturnShipmentHeader."Registration No.";
                ReturnShipmentHeader."Tax Registration No. CZL" := ReturnShipmentHeader."Tax Registration No.";
                ReturnShipmentHeader."EU 3-Party Trade CZL" := ReturnShipmentHeader."EU 3-Party Trade";
                ReturnShipmentHeader.Modify(false);
            until ReturnShipmentHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchaseHeaderArchive();
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
    begin
        if PurchaseHeaderArchive.FindSet(true) then
            repeat
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceHeader();
    var
        ServiceHeader: Record "Service Header";
    begin
        if ServiceHeader.FindSet(true) then
            repeat
                ServiceHeader."VAT Date CZL" := ServiceHeader."VAT Date";
                ServiceHeader."Registration No. CZL" := ServiceHeader."Registration No.";
                ServiceHeader."Tax Registration No. CZL" := ServiceHeader."Tax Registration No.";
                ServiceHeader."Credit Memo Type CZL" := ServiceHeader."Credit Memo Type";
                ServiceHeader."EU 3-Party Intermed. Role CZL" := ServiceHeader."EU 3-Party Intermediate Role";
                ServiceHeader."VAT Currency Factor CZL" := ServiceHeader."VAT Currency Factor";
                ServiceHeader."VAT Currency Code CZL" := ServiceHeader."Currency Code";
                ServiceHeader.Modify(false);
            until ServiceHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceShipmentHeader();
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        if ServiceShipmentHeader.FindSet(true) then
            repeat
                ServiceShipmentHeader."Registration No. CZL" := ServiceShipmentHeader."Registration No.";
                ServiceShipmentHeader."Tax Registration No. CZL" := ServiceShipmentHeader."Tax Registration No.";
                ServiceShipmentHeader."EU 3-Party Intermed. Role CZL" := ServiceShipmentHeader."EU 3-Party Intermediate Role";
                ServiceShipmentHeader.Modify(false);
            until ServiceShipmentHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceInvoiceHeader();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                ServiceInvoiceHeader."VAT Date CZL" := ServiceInvoiceHeader."VAT Date";
                ServiceInvoiceHeader."Registration No. CZL" := ServiceInvoiceHeader."Registration No.";
                ServiceInvoiceHeader."Tax Registration No. CZL" := ServiceInvoiceHeader."Tax Registration No.";
                ServiceInvoiceHeader."EU 3-Party Intermed. Role CZL" := ServiceInvoiceHeader."EU 3-Party Intermediate Role";
                ServiceInvoiceHeader."VAT Currency Factor CZL" := ServiceInvoiceHeader."VAT Currency Factor";
                ServiceInvoiceHeader."VAT Currency Code CZL" := ServiceInvoiceHeader."Currency Code";
                ServiceInvoiceHeader.Modify(false);
            until ServiceInvoiceHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        if ServiceCrMemoHeader.FindSet(true) then
            repeat
                ServiceCrMemoHeader."VAT Date CZL" := ServiceCrMemoHeader."VAT Date";
                ServiceCrMemoHeader."Registration No. CZL" := ServiceCrMemoHeader."Registration No.";
                ServiceCrMemoHeader."Tax Registration No. CZL" := ServiceCrMemoHeader."Tax Registration No.";
                ServiceCrMemoHeader."Credit Memo Type CZL" := ServiceCrMemoHeader."Credit Memo Type";
                ServiceCrMemoHeader."EU 3-Party Intermed. Role CZL" := ServiceCrMemoHeader."EU 3-Party Intermediate Role";
                ServiceCrMemoHeader."VAT Currency Factor CZL" := ServiceCrMemoHeader."VAT Currency Factor";
                ServiceCrMemoHeader."VAT Currency Code CZL" := ServiceCrMemoHeader."Currency Code";
                ServiceCrMemoHeader.Modify(false);
            until ServiceCrMemoHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyReminderHeader();
    var
        ReminderHeader: Record "Reminder Header";
    begin
        if ReminderHeader.FindSet(true) then
            repeat
                ReminderHeader."Registration No. CZL" := ReminderHeader."Registration No.";
                ReminderHeader."Tax Registration No. CZL" := ReminderHeader."Tax Registration No.";
                ReminderHeader.Modify(false);
            until ReminderHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyIssuedReminderHeader();
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin
        if IssuedReminderHeader.FindSet(true) then
            repeat
                IssuedReminderHeader."Registration No. CZL" := IssuedReminderHeader."Registration No.";
                IssuedReminderHeader."Tax Registration No. CZL" := IssuedReminderHeader."Tax Registration No.";
                IssuedReminderHeader.Modify(false);
            until IssuedReminderHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyFinanceChargeMemoHeader();
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        if FinanceChargeMemoHeader.FindSet(true) then
            repeat
                FinanceChargeMemoHeader."Registration No. CZL" := FinanceChargeMemoHeader."Registration No.";
                FinanceChargeMemoHeader."Tax Registration No. CZL" := FinanceChargeMemoHeader."Tax Registration No.";
                FinanceChargeMemoHeader.Modify(false);
            until FinanceChargeMemoHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyIssuedFinanceChargeMemoHeader();
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin
        if IssuedFinChargeMemoHeader.FindSet(true) then
            repeat
                IssuedFinChargeMemoHeader."Registration No. CZL" := IssuedFinChargeMemoHeader."Registration No.";
                IssuedFinChargeMemoHeader."Tax Registration No. CZL" := IssuedFinChargeMemoHeader."Tax Registration No.";
                IssuedFinChargeMemoHeader.Modify(false);
            until IssuedFinChargeMemoHeader.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
            StatutoryReportingSetupCZL."Company Type" := StatReportingSetup."Official Type";
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
            if StatReportingSetup."VIES Declaration Report No." = Report::"VIES Declaration" then
                StatutoryReportingSetupCZL."VIES Declaration Report No." := Report::"VIES Declaration CZL";
            if (StatReportingSetup."VIES Decl. Exp. Obj. Type" = StatReportingSetup."VIES Decl. Exp. Obj. Type"::Report) and (StatReportingSetup."VIES Decl. Exp. Obj. No." = Report::"VIES Declaration Export") then
                StatutoryReportingSetupCZL."VIES Declaration Export No." := Xmlport::"VIES Declaration CZL";
            StatutoryReportingSetupCZL.Modify(false);
        end;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATCtrlReportSectionCZL.Insert();
                end;
                VATCtrlReportSectionCZL.Description := VATControlReportSection.Description;
                VATCtrlReportSectionCZL."Group By" := VATControlReportSection."Group By";
                VATCtrlReportSectionCZL."Simplified Tax Doc. Sect. Code" := VATControlReportSection."Simplified Tax Doc. Sect. Code";
                VATCtrlReportSectionCZL.Modify(false);
            until VATControlReportSection.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATCtrlReportHeaderCZL.Insert();
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATCtrlReportLineCZL.Insert();
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATCtrlReportEntLinkCZL.Insert(false);
                end;
            until VATCtrlRepVATEntryLink.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                VATPostingSetup.Modify(false);
            until VATPostingSetup.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure ConvertVATStatementLineDeprEnumValues(var VATStatementLine: Record "VAT Statement Line");
    begin
        if VATStatementLine.Type = VATStatementLine.Type::Formula then
            VATStatementLine.Type := VATStatementLine.Type::"Formula CZL";
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VIESDeclarationHeaderCZL.Insert();
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VIESDeclarationLineCZL.Insert();
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    CompanyOfficialCZL.Insert();
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    DocumentFooterCZL.Insert(false);
                end;
                DocumentFooterCZL."Footer Text" := DocumentFooter."Footer Text";
                DocumentFooterCZL.Modify(false);
            until DocumentFooter.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATAttributeCodeCZL.Insert(false);
                end;
                VATAttributeCodeCZL.Description := VATAttributeCode.Description;
                VATAttributeCodeCZL."XML Code" := VATAttributeCode."XML Code";
                VATAttributeCodeCZL.Modify(false);
            until VATAttributeCode.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATStatementCommentLineCZL.Insert(false);
                end;
                VATStatementCommentLineCZL.Date := VATStatementCommentLine.Date;
                VATStatementCommentLineCZL.Comment := VATStatementCommentLine.Comment;
                VATStatementCommentLineCZL.Modify(false);
            until VATStatementCommentLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    VATStatementAttachmentCZL.Insert(false);
                end;
                VATStatementAttachmentCZL.Date := VATStatementAttachment.Date;
                VATStatementAttachmentCZL.Description := VATStatementAttachment.Description;
                VATStatementAttachment.CalcFields(VATStatementAttachment.Attachment);
                VATStatementAttachmentCZL.Attachment := VATStatementAttachment.Attachment;
                VATStatementAttachmentCZL."File Name" := VATStatementAttachment."File Name";
                VATStatementAttachmentCZL.Modify(false);
            until VATStatementAttachment.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyAccScheduleLine();
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        if AccScheduleLine.FindSet() then
            repeat
                AccScheduleLine."Calc CZL" := AccScheduleLine.Calc;
                AccScheduleLine."Row Correction CZL" := AccScheduleLine."Row Correction";
                AccScheduleLine."Assets/Liabilities Type CZL" := AccScheduleLine."Assets/Liabilities Type";
                AccScheduleLine.Modify(false);
            until AccScheduleLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyExcelTemplate();
    var
        ExcelTemplate: Record "Excel Template";
        ExcelTemplateCZL: Record "Excel Template CZL";
        OutStr: OutStream;
        InStr: InStream;
    begin
        if ExcelTemplate.FindSet() then
            repeat
                if not ExcelTemplateCZL.Get(ExcelTemplate.Code) then begin
                    ExcelTemplateCZL.Init();
                    ExcelTemplateCZL.Code := ExcelTemplate.Code;
                    ExcelTemplateCZL.Insert(false);
                end;
                ExcelTemplateCZL.Description := ExcelTemplate.Description;
                ExcelTemplateCZL.Sheet := ExcelTemplate.Sheet;
                ExcelTemplateCZL.Blocked := ExcelTemplate.Blocked;
                if ExcelTemplate.Template.HasValue() then begin
                    ExcelTemplate.CalcFields(ExcelTemplate.Template);
                    ExcelTemplate.Template.CreateInStream(InStr);
                    ExcelTemplateCZL.Template.CreateOutStream(OutStr);
                    CopyStream(OutStr, InStr);
                end;
                ExcelTemplateCZL.Modify(false);
            until ExcelTemplate.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    AccScheduleFileMappingCZL.Insert(false);
                end;
                AccScheduleFileMappingCZL."Excel Row No." := StatementFileMapping."Excel Row No.";
                AccScheduleFileMappingCZL."Excel Column No." := StatementFileMapping."Excel Column No.";
                AccScheduleFileMappingCZL.Split := StatementFileMapping.Split;
                AccScheduleFileMappingCZL.Offset := StatementFileMapping.Offset;
                AccScheduleFileMappingCZL.Modify(false);
            until StatementFileMapping.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchaseLine();
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine."Tariff No. CZL" := PurchaseLine."Tariff No.";
                PurchaseLine."Statistic Indication CZL" := PurchaseLine."Statistic Indication";
                PurchaseLine.Modify(false);
            until PurchaseLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchCrMemoLine();
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        if PurchCrMemoLine.FindSet() then
            repeat
                PurchCrMemoLine."Tariff No. CZL" := PurchCrMemoLine."Tariff No.";
                PurchCrMemoLine."Statistic Indication CZL" := PurchCrMemoLine."Statistic Indication";
                PurchCrMemoLine.Modify(false);
            until PurchCrMemoLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchInvLine();
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        if PurchInvLine.FindSet() then
            repeat
                PurchInvLine."Tariff No. CZL" := PurchInvLine."Tariff No.";
                PurchInvLine."Statistic Indication CZL" := PurchInvLine."Statistic Indication";
                PurchInvLine.Modify(false);
            until PurchInvLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyPurchRcptLine();
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        if PurchRcptLine.FindSet() then
            repeat
                PurchRcptLine."Tariff No. CZL" := PurchRcptLine."Tariff No.";
                PurchRcptLine."Statistic Indication CZL" := PurchRcptLine."Statistic Indication";
                PurchRcptLine.Modify(false);
            until PurchRcptLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesCrMemoLine();
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        if SalesCrMemoLine.FindSet() then
            repeat
                SalesCrMemoLine."Tariff No. CZL" := SalesCrMemoLine."Tariff No.";
                SalesCrMemoLine."Statistic Indication CZL" := SalesCrMemoLine."Statistic Indication";
                SalesCrMemoLine.Modify(false);
            until SalesCrMemoLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesInvoiceLine();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        if SalesInvoiceLine.FindSet() then
            repeat
                SalesInvoiceLine."Tariff No. CZL" := SalesInvoiceLine."Tariff No.";
                SalesInvoiceLine."Statistic Indication CZL" := SalesInvoiceLine."Statistic Indication";
                SalesInvoiceLine.Modify(false);
            until SalesInvoiceLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopySalesLine();
    var
        SalesLine: Record "Sales Line";
    begin
        if SalesLine.FindSet() then
            repeat
                SalesLine."Tariff No. CZL" := SalesLine."Tariff No.";
                SalesLine."Statistic Indication CZL" := SalesLine."Statistic Indication";
                SalesLine.Modify(false);
            until SalesLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyTariffNumber();
    var
        TariffNumber: Record "Tariff Number";
    begin
        if TariffNumber.FindSet() then
            repeat
                TariffNumber."Statement Code CZL" := TariffNumber."Statement Code";
                TariffNumber."Statement Limit Code CZL" := TariffNumber."Statement Limit Code";
                TariffNumber."VAT Stat. UoM Code CZL" := TariffNumber."VAT Stat. Unit of Measure Code";
                TariffNumber."Allow Empty UoM Code CZL" := TariffNumber."Allow Empty Unit of Meas.Code";
                TariffNumber.Modify(false);
            until TariffNumber.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    CommodityCZL.Insert();
                end;
                CommodityCZL.Description := Commodity.Description;
                CommodityCZL.Modify(false);
            until Commodity.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    CommoditySetupCZL.Insert();
                end;
                CommoditySetupCZL."Commodity Limit Amount LCY" := CommoditySetup."Commodity Limit Amount LCY";
                CommoditySetupCZL."Valid To" := CommoditySetup."Valid To";
                CommoditySetupCZL.Modify(false);
            until CommoditySetup.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    StatisticIndicationCZL.Insert();
                end;
                StatisticIndicationCZL.Description := StatisticIndication.Description;
                StatisticIndication.Modify(false);
            until StatisticIndication.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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
                    StockkeepingUnitTemplateCZL.Insert(false);
                end;
                StockkeepingUnitTemplateCZL.Description := StockkeepingUnitTemplateCZL.GetDefaultDescription();
                StockkeepingUnitTemplateCZL."Configuration Template Code" := ConfigTemplateHeader.Code;
                StockkeepingUnitTemplateCZL.Modify(false);
            until StockkeepingUnitTemplate.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CreateTemplateHeader(var ConfigTemplateHeader: Record "Config. Template Header"; "Code": Code[10]; Description: Text[100]; TableID: Integer)
    begin
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := Code;
        ConfigTemplateHeader.Description := Description;
        ConfigTemplateHeader."Table ID" := TableID;
        ConfigTemplateHeader.Enabled := true;
        ConfigTemplateHeader.Insert();
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure GetNextDataTemplateAvailableCode(): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        StockkeepingUnitConfigTemplCode: Code[10];
        StockkeepingUnitConfigTemplCodeTxt: Label 'SKU0000000', MaxLength = 10;
    begin
        if StockkeepingUnitConfigTemplCode = '' then
            StockkeepingUnitConfigTemplCode := StockkeepingUnitConfigTemplCodeTxt;
        repeat
            StockkeepingUnitConfigTemplCode := CopyStr(IncStr(StockkeepingUnitConfigTemplCode), 1, MaxStrLen(ConfigTemplateHeader.Code));
        until not ConfigTemplateHeader.Get(StockkeepingUnitConfigTemplCode);
        exit(StockkeepingUnitConfigTemplCode);
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyItem();
    var
        Item: Record Item;
    begin
        if Item.FindSet() then
            repeat
                Item."Statistic Indication CZL" := Item."Statistic Indication";
                Item.Modify(false);
            until Item.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceLine();
    var
        ServiceLine: Record "Service Line";
    begin
        if ServiceLine.FindSet() then
            repeat
                ServiceLine."Tariff No. CZL" := ServiceLine."Tariff No.";
                ServiceLine."Statistic Indication CZL" := ServiceLine."Statistic Indication";
                ServiceLine.Modify(false);
            until ServiceLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceInvoiceLine();
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
    begin
        if ServiceInvoiceLine.FindSet() then
            repeat
                ServiceInvoiceLine."Tariff No. CZL" := ServiceInvoiceLine."Tariff No.";
                ServiceInvoiceLine."Statistic Indication CZL" := ServiceInvoiceLine."Statistic Indication";
                ServiceInvoiceLine.Modify(false);
            until ServiceInvoiceLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
    local procedure CopyServiceCrMemoLine();
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        if ServiceCrMemoLine.FindSet() then
            repeat
                ServiceCrMemoLine."Tariff No. CZL" := ServiceCrMemoLine."Tariff No.";
                ServiceCrMemoLine."Statistic Indication CZL" := ServiceCrMemoLine."Statistic Indication";
                ServiceCrMemoLine.Modify(false);
            until ServiceCrMemoLine.Next() = 0;
    end;

    [Obsolete('Moved to Core Localization Pack for Czech.', '17.0')]
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

    local procedure ModifyGenJournalTemplate()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        PrevGenJournalTemplate: Record "Gen. Journal Template";
    begin
        if GenJournalTemplate.FindSet(true) then
            repeat
                PrevGenJournalTemplate := GenJournalTemplate;
                GenJournalTemplate."Test Report ID" := Report::"General Journal - Test CZL";
                if GenJournalTemplate."Posting Report ID" = Report::"General Ledger Document" then
                    GenJournalTemplate."Posting Report ID" := Report::"General Ledger Document CZL";
                if (GenJournalTemplate."Test Report ID" <> PrevGenJournalTemplate."Test Report ID") or (GenJournalTemplate."Posting Report ID" <> PrevGenJournalTemplate."Posting Report ID") then
                    GenJournalTemplate.Modify();
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
                    Report::"Sales - Quote CZ", Report::"Standard Sales - Quote":
                        ReportSelections."Report ID" := Report::"Sales Quote CZL";
                    Report::"Order Confirmation CZ", Report::"Standard Sales - Order Conf.":
                        ReportSelections."Report ID" := Report::"Sales Order Confirmation CZL";
                    Report::"Sales - Invoice CZ", Report::"Standard Sales - Invoice":
                        ReportSelections."Report ID" := Report::"Sales Invoice CZL";
                    Report::"Return Order Confirmation CZ", Report::"Return Order Confirmation":
                        ReportSelections."Report ID" := Report::"Sales Return Order Confirm CZL";
                    Report::"Sales - Credit Memo CZ", Report::"Standard Sales - Credit Memo":
                        ReportSelections."Report ID" := Report::"Sales Credit Memo CZL";
                    Report::"Sales - Shipment CZ", Report::"Sales - Shipment":
                        ReportSelections."Report ID" := Report::"Sales Shipment CZL";
                    Report::"Sales - Return Reciept CZ", Report::"Sales - Return Receipt":
                        ReportSelections."Report ID" := Report::"Sales Return Reciept CZL";
                    Report::"Purchase - Quote CZ", Report::"Purchase - Quote":
                        ReportSelections."Report ID" := Report::"Purchase Quote CZL";
                    Report::"Order CZ", Report::"Standard Purchase - Order":
                        ReportSelections."Report ID" := Report::"Purchase Order CZL";
                    Report::"Service Quote CZ", Report::"Service Quote":
                        ReportSelections."Report ID" := Report::"Service Quote CZL";
                    Report::"Service Order CZ", Report::"Service Order":
                        ReportSelections."Report ID" := Report::"Service Order CZL";
                    Report::"Service - Invoice CZ", Report::"Service - Invoice":
                        ReportSelections."Report ID" := Report::"Service Invoice CZL";
                    Report::"Service - Credit Memo CZ", Report::"Service - Credit Memo":
                        ReportSelections."Report ID" := Report::"Service Credit Memo CZL";
                    Report::"Service - Shipment CZ", Report::"Service - Shipment":
                        ReportSelections."Report ID" := Report::"Service Shipment CZL";
                    Report::"Service Contract Quote CZ", Report::"Service Contract Quote":
                        ReportSelections."Report ID" := Report::"Service Contract Quote CZL";
                    Report::"Service Contract CZ", Report::"Service Contract":
                        ReportSelections."Report ID" := Report::"Service Contract CZL";
                    Report::"Reminder CZ", Report::Reminder:
                        ReportSelections."Report ID" := Report::"Reminder CZL";
                    Report::"Finance Charge Memo CZ", Report::"Finance Charge Memo":
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
    begin
        InitRegistrationNoServiceConfig();
        InitUnreliablePayerServiceSetup();
        InitVATCtrlReportSection();
        InitStatutoryReportingSetup();
        InitSourceCodeSetup();

        ModifyReportSelections();

        DataClassEvalHandlerCZL.ApplyEvaluationClassificationsForPrivacy();
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
        UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" := 5000;

        if (UnrelPayerServiceSetupCZL."Unreliable Payer Web Service" <> PrevUnrelPayerServiceSetupCZL."Unreliable Payer Web Service") or
           (UnrelPayerServiceSetupCZL.Enabled <> PrevUnrelPayerServiceSetupCZL.Enabled) or
           (UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" <> PrevUnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date") or
           (UnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit" <> PrevUnrelPayerServiceSetupCZL."Public Bank Acc.Check Limit") or
           (UnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit" <> PrevUnrelPayerServiceSetupCZL."Unr.Payer Request Record Limit")
        then
            UnrelPayerServiceSetupCZL.Modify();
    end;

    local procedure InitVATCtrlReportSection()
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

    local procedure InitSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
        PrevSourceCodeSetup: Record "Source Code Setup";
        PurchaseVATDelaySourceCodeTxt: Label 'VATPD', MaxLength = 10;
        PurchaseVATDelaySourceCodeDescriptionTxt: Label 'Purchase VAT Delay', MaxLength = 100;
        SalesVATDelaySourceCodeTxt: Label 'VATSD', MaxLength = 10;
        SalesVATDelaySourceCodeDescriptionTxt: Label 'Sales VAT Delay', MaxLength = 100;
    begin
        SourceCodeSetup.Get();
        PrevSourceCodeSetup := SourceCodeSetup;
        InsertSourceCode(SourceCodeSetup."Purchase VAT Delay CZL", PurchaseVATDelaySourceCodeTxt, PurchaseVATDelaySourceCodeDescriptionTxt);
        InsertSourceCode(SourceCodeSetup."Sales VAT Delay CZL", SalesVATDelaySourceCodeTxt, SalesVATDelaySourceCodeDescriptionTxt);

        if (SourceCodeSetup."Purchase VAT Delay CZL" <> PrevSourceCodeSetup."Purchase VAT Delay CZL") or
           (SourceCodeSetup."Sales VAT Delay CZL" <> PrevSourceCodeSetup."Sales VAT Delay CZL")
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
                if ItemJournalTemplate."Posting Report ID" = Report::"Posted Inventory Document" then
                    ItemJournalTemplate."Posting Report ID" := Report::"Posted Inventory Document CZL";
                if (ItemJournalTemplate."Posting Report ID" <> PrevItemJournalTemplate."Posting Report ID") then
                    ItemJournalTemplate.Modify();
            until ItemJournalTemplate.Next() = 0;
    end;
}
