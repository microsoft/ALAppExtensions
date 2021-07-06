#pragma warning disable AL0432,AL0603
codeunit 31017 "Upgrade Application CZL"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZL: Codeunit "Upgrade Tag Definitions CZL";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        UpdatePermission();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag());
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        UpdateGeneralLedgerSetup();
        UpdateSalesSetup();
        UpdatePurchaseSetup();
        UpdateServiceSetup();
        UpdateInventorySetup();
        UpdateDepreciationBook();
        UpdateItemJournalLine();
        UpdateJobJournalLine();
        UpdateSalesLine();
        UpdatePurchaseLine();
        UpdateServiceLine();
        UpdateValueEntry();
        UpdateDetailedCustLedgEntry();
        UpdateDetailedVendorLedgEntry();
        UpdateSubstCustomerPostingGroup();
        UpdateSubstVendorPostingGroup();
        UpdateCertificateCZCode();
        UpdateIsolatedCertificate();
        UpdateEETServiceSetup();
        UpdateEETBusinessPremises();
        UpdateEETCashRegister();
        UpdateEETEntry();
        UpdateEETEntryStatus();
        UpdateConstantSymbol();
        UpdateShipmentMethod();
        UpdateTariffNumber();
        UpdateStatisticIndication();
        UpdateSpecificMovement();
        UpdateIntrastatDeliveryGroup();
        UpdateStatutoryReportingSetup();
        UpdateCustomer();
        UpdateVendor();
        UpdateItem();
        UpdateUnitofMeasure();
        UpdateVATPostingSetup();
        UpdateSalesHeader();
        UpdateSalesShipmentHeader();
        UpdateSalesInvoiceHeader();
        UpdateSalesInvoiceLine();
        UpdateSalesCrMemoLine();
        UpdateSalesCrMemoLine();
        UpdateSalesCrMemoHeader();
        UpdateSalesHeaderArchive();
        UpdateSalesLineArchive();
        UpdatePurchaseHeader();
        UpdatePurchRcptHeader();
        UpdatePurchRcptLine();
        UpdatePurchInvHeader();
        UpdatePurchInvLine();
        UpdatePurchCrMemoHdr();
        UpdatePurchCrMemoLine();
        UpdatePurchaseHeaderArchive();
        UpdatePurchaseLineArchive();
        UpdateServiceHeader();
        UpdateServiceShipmentHeader();
        UpdateServiceInvoiceHeader();
        UpdateServiceInvoiceLine();
        UpdateServiceCrMemoHeader();
        UpdateServiceCrMemoLine();
        UpdateReturnShipmentHeader();
        UpdateReturnReceiptHeader();
        UpdateTransferHeader();
        UpdateTransferLine();
        UpdateTransferReceiptHeader();
        UpdateTransferShipmentHeader();
        UpdateItemLedgerEntry();
        UpdateJobLedgerEntry();
        UpdateItemCharge();
        UpdateItemChargeAssignmentPurch();
        UpdateItemChargeAssignmentSales();
        UpdatePostedGenJournalLine();
        UpdateIntrastatJournalBatch();
        UpdateIntrastatJournalLine();
        UpdateGeneralPostingSetup();
        UpdateInventoryPostingSetup();
        UpdateUserSetup();
        UpdateUserSetupLine();
        UpdateAccScheduleLine();
        UpdateAccScheduleExtension();
        UpdateAccScheduleResultLine();
        UpdateAccScheduleResultColumn();
        UpdateAccScheduleResultValue();
        UpdateAccScheduleResultHeader();
        UpdateAccScheduleResultHistory();
        UpdateGenJournalTemplate();
        UpdateVATEntry();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag());
    end;

    local procedure UpdateGeneralLedgerSetup();
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup."Shared Account Schedule CZL" := GeneralLedgerSetup."Shared Account Schedule";
            GeneralLedgerSetup."Acc. Schedule Results Nos. CZL" := GeneralLedgerSetup."Acc. Schedule Results Nos.";
            GeneralLedgerSetup.Modify(false);
        end;

        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup."Check Posting Debit/Credit CZL" := GeneralLedgerSetup."Check Posting Debit/Credit";
            GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" := GeneralLedgerSetup."Mark Neg. Qty as Correction";
            GeneralLedgerSetup."Rounding Date CZL" := GeneralLedgerSetup."Rounding Date";
            GeneralLedgerSetup."Closed Per. Entry Pos.Date CZL" := GeneralLedgerSetup."Closed Period Entry Pos.Date";
            GeneralLedgerSetup."User Checks Allowed CZL" := GeneralLedgerSetup."User Checks Allowed";
            GeneralLedgerSetup.Modify(false);
        end;
    end;

    local procedure UpdateSalesSetup();
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesReceivablesSetup.Get() then begin
            SalesReceivablesSetup."Allow Alter Posting Groups CZL" := SalesReceivablesSetup."Allow Alter Posting Groups";
            SalesReceivablesSetup.Modify(false);
        end;
    end;

    local procedure UpdatePurchaseSetup();
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchasesPayablesSetup.Get() then begin
            PurchasesPayablesSetup."Allow Alter Posting Groups CZL" := PurchasesPayablesSetup."Allow Alter Posting Groups";
            PurchasesPayablesSetup.Modify(false);
        end;
    end;

    local procedure UpdateServiceSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceMgtSetup.Get() then begin
            ServiceMgtSetup."Allow Alter Posting Groups CZL" := ServiceMgtSetup."Allow Alter Cust. Post. Groups";
            ServiceMgtSetup.Modify(false);
        end;
    end;

    local procedure UpdateInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if InventorySetup.Get() then begin
            InventorySetup."Date Order Invt. Change CZL" := InventorySetup."Date Order Inventory Change";
            InventorySetup."Post Neg.Transf. As Corr.CZL" := InventorySetup."Post Neg. Transfers as Corr.";
            InventorySetup."Post Exp.Cost Conv.As Corr.CZL" := InventorySetup."Post Exp. Cost Conv. as Corr.";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure UpdateDepreciationBook();
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if DepreciationBook.FindSet(true) then
            repeat
                DepreciationBook."Mark Reclass. as Correct. CZL" := DepreciationBook."Mark Reclass. as Corrections";
                DepreciationBook.Modify(false);
            until DepreciationBook.Next() = 0;
    end;

    local procedure UpdateItemJournalLine();
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ItemJournalLine.FindSet(true) then
            repeat
                ItemJournalLine."Tariff No. CZL" := ItemJournalLine."Tariff No.";
                ItemJournalLine."Physical Transfer CZL" := ItemJournalLine."Physical Transfer";
                ItemJournalLine."Incl. in Intrastat Amount CZL" := ItemJournalLine."Incl. in Intrastat Amount";
                ItemJournalLine."Incl. in Intrastat S.Value CZL" := ItemJournalLine."Incl. in Intrastat Stat. Value";
                ItemJournalLine."Net Weight CZL" := ItemJournalLine."Net Weight";
                ItemJournalLine."Country/Reg. of Orig. Code CZL" := ItemJournalLine."Country/Region of Origin Code";
                ItemJournalLine."Statistic Indication CZL" := ItemJournalLine."Statistic Indication";
                ItemJournalLine."Intrastat Transaction CZL" := ItemJournalLine."Intrastat Transaction";
                ItemJournalLine."G/L Correction CZL" := ItemJournalLine."G/L Correction";
                ItemJournalLine.Modify(false);
            until ItemJournalLine.Next() = 0;
    end;

    local procedure UpdateJobJournalLine();
    var
        JobJournalLine: Record "Job Journal Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if JobJournalLine.FindSet(true) then
            repeat
                JobJournalLine."Correction CZL" := JobJournalLine.Correction;
                JobJournalLine."Tariff No. CZL" := JobJournalLine."Tariff No.";
                JobJournalLine."Net Weight CZL" := JobJournalLine."Net Weight";
                JobJournalLine."Country/Reg. of Orig. Code CZL" := JobJournalLine."Country/Region of Origin Code";
                JobJournalLine."Statistic Indication CZL" := JobJournalLine."Statistic Indication";
                JobJournalLine."Intrastat Transaction CZL" := JobJournalLine."Intrastat Transaction";
                JobJournalLine.Modify(false);
            until JobJournalLine.Next() = 0;
    end;

    local procedure UpdateSalesLine();
    var
        SalesLine: Record "Sales Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesLine.FindSet(true) then
            repeat
                SalesLine."Negative CZL" := SalesLine.Negative;
                SalesLine."Physical Transfer CZL" := SalesLine."Physical Transfer";
                SalesLine."Country/Reg. of Orig. Code CZL" := SalesLine."Country/Region of Origin Code";
                SalesLine.Modify(false);
            until SalesLine.Next() = 0;
    end;

    local procedure UpdatePurchaseLine();
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchaseLine.FindSet(true) then
            repeat
                PurchaseLine."Negative CZL" := PurchaseLine.Negative;
                PurchaseLine."Physical Transfer CZL" := PurchaseLine."Physical Transfer";
                PurchaseLine."Country/Reg. of Orig. Code CZL" := PurchaseLine."Country/Region of Origin Code";
                PurchaseLine.Modify(false);
            until PurchaseLine.Next() = 0;
    end;

    local procedure UpdateServiceLine();
    var
        ServiceLine: Record "Service Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceLine.FindSet(true) then
            repeat
                ServiceLine."Negative CZL" := ServiceLine.Negative;
                ServiceLine."Physical Transfer CZL" := ServiceLine."Physical Transfer";
                ServiceLine."Country/Reg. of Orig. Code CZL" := ServiceLine."Country/Region of Origin Code";
                ServiceLine.Modify(false);
            until ServiceLine.Next() = 0;
    end;

    local procedure UpdateValueEntry();
    var
        ValueEntry: Record "Value Entry";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ValueEntry.FindSet(true) then
            repeat
                ValueEntry."G/L Correction CZL" := ValueEntry."G/L Correction";
                ValueEntry."Incl. in Intrastat Amount CZL" := ValueEntry."Incl. in Intrastat Amount";
                ValueEntry."Incl. in Intrastat S.Value CZL" := ValueEntry."Incl. in Intrastat Stat. Value";
                ValueEntry.Modify(false);
            until ValueEntry.Next() = 0;
    end;

    local procedure UpdateDetailedCustLedgEntry()
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ApplAcrCustPostGroupsCZL: Query "Appl.Acr. Cust.Post.Groups CZL";
        ApplAcrossPostGrpEntryNo: List of [Integer];
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ApplAcrCustPostGroupsCZL.Open() then
            while ApplAcrCustPostGroupsCZL.Read() do
                ApplAcrossPostGrpEntryNo.Add(ApplAcrCustPostGroupsCZL.Entry_No_);

        if DetailedCustLedgEntry.FindSet(true) then
            repeat
                DetailedCustLedgEntry."Customer Posting Group CZL" := DetailedCustLedgEntry."Customer Posting Group";
                if ApplAcrossPostGrpEntryNo.Contains(DetailedCustLedgEntry."Entry No.") then
                    DetailedCustLedgEntry."Appl. Across Post. Groups CZL" := true;
                DetailedCustLedgEntry.Modify(false);
            until DetailedCustLedgEntry.Next() = 0;
    end;

    local procedure UpdateDetailedVendorLedgEntry()
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        ApplAcrVendPostGroupsCZL: Query "Appl.Acr. Vend.Post.Groups CZL";
        ApplAcrossPostGrpEntryNo: List of [Integer];
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ApplAcrVendPostGroupsCZL.Open() then
            while ApplAcrVendPostGroupsCZL.Read() do
                ApplAcrossPostGrpEntryNo.Add(ApplAcrVendPostGroupsCZL.Entry_No_);

        if DetailedVendorLedgEntry.FindSet(true) then
            repeat
                DetailedVendorLedgEntry."Vendor Posting Group CZL" := DetailedVendorLedgEntry."Vendor Posting Group";
                if ApplAcrossPostGrpEntryNo.Contains(DetailedVendorLedgEntry."Entry No.") then
                    DetailedVendorLedgEntry."Appl. Across Post. Groups CZL" := true;
                DetailedVendorLedgEntry.Modify(false);
            until DetailedVendorLedgEntry.Next() = 0;
    end;

    local procedure UpdateSubstCustomerPostingGroup();
    var
        SubstCustomerPostingGroup: Record "Subst. Customer Posting Group";
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SubstCustomerPostingGroup.FindSet() then
            repeat
                if not SubstCustPostingGroupCZL.Get(SubstCustomerPostingGroup."Parent Cust. Posting Group", SubstCustomerPostingGroup."Customer Posting Group") then begin
                    SubstCustPostingGroupCZL.Init();
                    SubstCustPostingGroupCZL."Parent Customer Posting Group" := SubstCustomerPostingGroup."Parent Cust. Posting Group";
                    SubstCustPostingGroupCZL."Customer Posting Group" := SubstCustomerPostingGroup."Customer Posting Group";
                    SubstCustPostingGroupCZL.Insert(false);
                end;
            until SubstCustomerPostingGroup.Next() = 0;
    end;

    local procedure UpdateSubstVendorPostingGroup();
    var
        SubstVendorPostingGroup: Record "Subst. Vendor Posting Group";
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SubstVendorPostingGroup.FindSet() then
            repeat
                if not SubstVendPostingGroupCZL.Get(SubstVendorPostingGroup."Parent Vend. Posting Group", SubstVendorPostingGroup."Vendor Posting Group") then begin
                    SubstVendPostingGroupCZL.Init();
                    SubstVendPostingGroupCZL."Parent Vendor Posting Group" := SubstVendorPostingGroup."Parent Vend. Posting Group";
                    SubstVendPostingGroupCZL."Vendor Posting Group" := SubstVendorPostingGroup."Vendor Posting Group";
                    SubstVendPostingGroupCZL.Insert(false);
                end;
            until SubstVendorPostingGroup.Next() = 0;
    end;

    local procedure UpdateCertificateCZCode()
    var
        CertificateCZCode: Record "Certificate CZ Code";
        CertificateCodeCZL: Record "Certificate Code CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if CertificateCZCode.FindSet() then
            repeat
                if not CertificateCodeCZL.Get(CertificateCZCode.Code) then begin
                    CertificateCodeCZL.Init();
                    CertificateCodeCZL.Code := CertificateCZCode.Code;
                    CertificateCodeCZL.Insert();
                end;
                CertificateCodeCZL.Description := CertificateCZCode.Description;
                CertificateCodeCZL.Modify(false);
            until CertificateCZCode.Next() = 0;
    end;

    local procedure UpdateIsolatedCertificate()
    var
        IsolatedCertificate: Record "Isolated Certificate";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if IsolatedCertificate.FindSet() then
            repeat
                IsolatedCertificate."Certificate Code CZL" := IsolatedCertificate."Certificate Code";
                IsolatedCertificate.Modify(false);
            until IsolatedCertificate.Next() = 0;
    end;

    local procedure UpdateEETServiceSetup()
    var
        EETServiceSetup: Record "EET Service Setup";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETServiceSetup.Get() then begin
            if not EETServiceSetupCZL.Get() then begin
                EETServiceSetupCZL.Init();
                EETServiceSetupCZL.Insert();
            end;

            EETServiceSetupCZL."Service URL" := EETServiceSetup."Service URL";
            EETServiceSetupCZL."Sales Regime" := "EET Sales Regime CZL".FromInteger(EETServiceSetup."Sales Regime");
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

    local procedure UpdateEETBusinessPremises()
    var
        EETBusinessPremises: Record "EET Business Premises";
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETBusinessPremises.FindSet() then
            repeat
                if not EETBusinessPremisesCZL.Get(EETBusinessPremises.Code) then begin
                    EETBusinessPremisesCZL.Init();
                    EETBusinessPremisesCZL.Code := EETBusinessPremises.Code;
                    EETBusinessPremisesCZL.Insert();
                end;
                EETBusinessPremisesCZL.Description := EETBusinessPremises.Description;
                EETBusinessPremisesCZL.Identification := EETBusinessPremises.Identification;
                EETBusinessPremisesCZL."Certificate Code" := EETBusinessPremises."Certificate Code";
                EETBusinessPremisesCZL.Modify(false);
            until EETBusinessPremises.Next() = 0;
    end;

    local procedure UpdateEETCashRegister()
    var
        EETCashRegister: Record "EET Cash Register";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETCashRegister.FindSet() then
            repeat
                if not EETCashRegisterCZL.Get(EETCashRegister."Business Premises Code", EETCashRegister.Code) then begin
                    EETCashRegisterCZL.Init();
                    EETCashRegisterCZL."Business Premises Code" := EETCashRegister."Business Premises Code";
                    EETCashRegisterCZL.Code := EETCashRegister.Code;
                    EETCashRegisterCZL.Insert();
                end;
                EETCashRegisterCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETCashRegister."Register Type");
                EETCashRegisterCZL."Cash Register No." := EETCashRegister."Register No.";
                EETCashRegisterCZL."Cash Register Name" := EETCashRegister."Register Name";
                EETCashRegisterCZL."Certificate Code" := EETCashRegister."Certificate Code";
                EETCashRegisterCZL."Receipt Serial Nos." := EETCashRegister."Receipt Serial Nos.";
                EETCashRegisterCZL.Modify(false);
            until EETCashRegister.Next() = 0;
    end;

    local procedure UpdateEETEntry()
    var
        EETEntry: Record "EET Entry";
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETEntry.FindSet() then
            repeat
                if not EETEntryCZL.Get(EETEntry."Entry No.") then begin
                    EETEntryCZL.Init();
                    EETEntryCZL."Entry No." := EETEntry."Entry No.";
                    EETEntryCZL.Insert();
                end;
                EETEntryCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETEntry."Source Type");
                EETEntryCZL."Cash Register No." := EETEntry."Source No.";
                EETEntryCZL."Business Premises Code" := EETEntry."Business Premises Code";
                EETEntryCZL."Cash Register Code" := EETEntry."Cash Register Code";
                EETEntryCZL."Document No." := EETEntry."Document No.";
                EETEntryCZL.Description := EETEntry.Description;
                EETEntryCZL."Applied Document Type" := "EET Applied Document Type CZL".FromInteger(EETEntry."Applied Document Type");
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

    local procedure UpdateEETEntryStatus()
    var
        EETEntryStatus: Record "EET Entry Status";
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETEntryStatus.FindSet() then
            repeat
                if not EETEntryStatusLogCZL.Get(EETEntryStatus."Entry No.") then begin
                    EETEntryStatusLogCZL.Init();
                    EETEntryStatusLogCZL."Entry No." := EETEntryStatus."Entry No.";
                    EETEntryStatusLogCZL.Insert();
                end;
                EETEntryStatusLogCZL."EET Entry No." := EETEntryStatus."EET Entry No.";
                EETEntryStatusLogCZL.Description := EETEntryStatus.Description;
                EETEntryStatusLogCZL.Status := "EET Status CZL".FromInteger(EETEntryStatus.Status);
                EETEntryStatusLogCZL."Changed At" := EETEntryStatus."Change Datetime";
                EETEntryStatusLogCZL.Modify(false);
            until EETEntryStatus.Next() = 0;
    end;

    local procedure UpdateConstantSymbol();
    var
        ConstantSymbol: Record "Constant Symbol";
        ConstantSymbolCZL: Record "Constant Symbol CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ConstantSymbol.FindSet() then
            repeat
                if not ConstantSymbolCZL.Get(ConstantSymbol.Code) then begin
                    ConstantSymbolCZL.Init();
                    ConstantSymbolCZL.Code := ConstantSymbol.Code;
                    ConstantSymbolCZL.Description := ConstantSymbol.Description;
                    ConstantSymbolCZL.Insert(false);
                end;
            until ConstantSymbol.Next() = 0;
    end;

    local procedure UpdateShipmentMethod()
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ShipmentMethod.FindSet() then
            repeat
                ShipmentMethod."Incl. Item Charges (Amt.) CZL" := ShipmentMethod."Include Item Charges (Amount)";
                ShipmentMethod."Intrastat Deliv. Grp. Code CZL" := ShipmentMethod."Intrastat Delivery Group Code";
                ShipmentMethod."Incl. Item Charges (S.Val) CZL" := ShipmentMethod."Incl. Item Charges (Stat.Val.)";
                ShipmentMethod."Adjustment % CZL" := ShipmentMethod."Adjustment %";
                ShipmentMethod.Modify(false);
            until ShipmentMethod.Next() = 0;
    end;

    local procedure UpdateTariffNumber()
    var
        TariffNumber: Record "Tariff Number";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if TariffNumber.FindSet() then
            repeat
                TariffNumber."Description EN CZL" := CopyStr(TariffNumber."Full Name ENG", 1, MaxStrLen(TariffNumber."Description EN CZL"));
                TariffNumber."Suppl. Unit of Meas. Code CZL" := TariffNumber."Supplem. Unit of Measure Code";
                TariffNumber.Modify(false);
            until TariffNumber.Next() = 0;
    end;

    local procedure UpdateStatisticIndication()
    var
        StatisticIndication: Record "Statistic Indication";
        StatisticIndicationCZL: Record "Statistic Indication CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if StatisticIndication.FindSet() then
            repeat
                if StatisticIndicationCZL.Get(StatisticIndication.Code) then begin
                    StatisticIndicationCZL."Description EN" := CopyStr(StatisticIndication."Full Name ENG", 1, MaxStrLen(StatisticIndicationCZL."Description EN"));
                    StatisticIndicationCZL.Modify(false);
                end;
            until StatisticIndication.Next() = 0;
    end;

    local procedure UpdateSpecificMovement()
    var
        SpecificMovement: Record "Specific Movement";
        SpecificMovementCZL: Record "Specific Movement CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SpecificMovement.FindSet() then
            repeat
                if not SpecificMovementCZL.Get(SpecificMovement.Code) then begin
                    SpecificMovementCZL.Init();
                    SpecificMovementCZL.Code := SpecificMovement.Code;
                    SpecificMovementCZL.Insert();
                end;
                SpecificMovementCZL.Description := SpecificMovement.Description;
                SpecificMovementCZL.Modify(false);
            until SpecificMovement.Next() = 0;
    end;

    local procedure UpdateIntrastatDeliveryGroup()
    var
        IntrastatDeliveryGroup: Record "Intrastat Delivery Group";
        IntrastatDeliveryGroupCZL: Record "Intrastat Delivery Group CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if IntrastatDeliveryGroup.FindSet() then
            repeat
                if not IntrastatDeliveryGroupCZL.Get(IntrastatDeliveryGroup.Code) then begin
                    IntrastatDeliveryGroupCZL.Init();
                    IntrastatDeliveryGroupCZL.Code := IntrastatDeliveryGroup.Code;
                    IntrastatDeliveryGroupCZL.Insert();
                end;
                IntrastatDeliveryGroupCZL.Description := IntrastatDeliveryGroup.Description;
                IntrastatDeliveryGroupCZL.Modify(false);
            until IntrastatDeliveryGroup.Next() = 0;
    end;

    local procedure UpdateStatutoryReportingSetup();
    var
        StatReportingSetup: Record "Stat. Reporting Setup";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;
        if not StatReportingSetup.Get() then
            exit;
        if not StatutoryReportingSetupCZL.Get() then
            exit;
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

    local procedure UpdateCustomer();
    var
        Customer: Record Customer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if Customer.FindSet(true) then
            repeat
                Customer."Transaction Type CZL" := Customer."Transaction Type";
                Customer."Transaction Specification CZL" := Customer."Transaction Specification";
                Customer."Transport Method CZL" := Customer."Transport Method";
                Customer.Modify(false);
            until Customer.Next() = 0;
    end;

    local procedure UpdateVendor();
    var
        Vendor: Record Vendor;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if Vendor.FindSet(true) then
            repeat
                Vendor."Transaction Type CZL" := Vendor."Transaction Type";
                Vendor."Transaction Specification CZL" := Vendor."Transaction Specification";
                Vendor."Transport Method CZL" := Vendor."Transport Method";
                Vendor.Modify(false);
            until Vendor.Next() = 0;
    end;

    local procedure UpdateItem();
    var
        Item: Record Item;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if Item.FindSet(true) then
            repeat
                Item."Specific Movement CZL" := Item."Specific Movement";
                Item.Modify(false);
            until Item.Next() = 0;
    end;

    local procedure UpdateUnitofMeasure();
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if UnitofMeasure.FindSet(true) then
            repeat
                UnitofMeasure."Tariff Number UOM Code CZL" := CopyStr(UnitofMeasure."Tariff Number UOM Code", 1, 10);
                UnitofMeasure.Modify(false);
            until UnitofMeasure.Next() = 0;
    end;

    local procedure UpdateVATPostingSetup();
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if VATPostingSetup.FindSet(true) then
            repeat
                VATPostingSetup."Intrastat Service CZL" := VATPostingSetup."Intrastat Service";
                VATPostingSetup.Modify(false);
            until VATPostingSetup.Next() = 0;
    end;

    local procedure UpdateSalesHeader();
    var
        SalesHeader: Record "Sales Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesHeader.FindSet(true) then
            repeat
                SalesHeader."Physical Transfer CZL" := SalesHeader."Physical Transfer";
                SalesHeader."Intrastat Exclude CZL" := SalesHeader."Intrastat Exclude";
                SalesHeader.Modify(false);
            until SalesHeader.Next() = 0;
    end;

    local procedure UpdateSalesShipmentHeader();
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesShipmentHeader.FindSet(true) then
            repeat
                SalesShipmentHeader."Physical Transfer CZL" := SalesShipmentHeader."Physical Transfer";
                SalesShipmentHeader."Intrastat Exclude CZL" := SalesShipmentHeader."Intrastat Exclude";
                SalesShipmentHeader.Modify(false);
            until SalesShipmentHeader.Next() = 0;
    end;

    local procedure UpdateSalesInvoiceHeader();
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesInvoiceHeader.FindSet(true) then
            repeat
                SalesInvoiceHeader."Physical Transfer CZL" := SalesInvoiceHeader."Physical Transfer";
                SalesInvoiceHeader."Intrastat Exclude CZL" := SalesInvoiceHeader."Intrastat Exclude";
                SalesInvoiceHeader.Modify(false);
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure UpdateSalesInvoiceLine();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesInvoiceLine.FindSet(true) then
            repeat
                SalesInvoiceLine."Country/Reg. of Orig. Code CZL" := SalesInvoiceLine."Country/Region of Origin Code";
                SalesInvoiceLine.Modify(false);
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure UpdateSalesCrMemoHeader();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesCrMemoHeader.FindSet(true) then
            repeat
                SalesCrMemoHeader."Physical Transfer CZL" := SalesCrMemoHeader."Physical Transfer";
                SalesCrMemoHeader."Intrastat Exclude CZL" := SalesCrMemoHeader."Intrastat Exclude";
                SalesCrMemoHeader.Modify(false);
            until SalesCrMemoHeader.Next() = 0;
    end;

    local procedure UpdateSalesCrMemoLine();
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesCrMemoLine.FindSet(true) then
            repeat
                SalesCrMemoLine."Country/Reg. of Orig. Code CZL" := SalesCrMemoLine."Country/Region of Origin Code";
                SalesCrMemoLine.Modify(false);
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure UpdateSalesHeaderArchive();
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesHeaderArchive.FindSet(true) then
            repeat
                SalesHeaderArchive."Physical Transfer CZL" := SalesHeaderArchive."Physical Transfer";
                SalesHeaderArchive."Intrastat Exclude CZL" := SalesHeaderArchive."Intrastat Exclude";
                SalesHeaderArchive.Modify(false);
            until SalesHeaderArchive.Next() = 0;
    end;

    local procedure UpdateSalesLineArchive();
    var
        SalesLineArchive: Record "Sales Line Archive";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if SalesLineArchive.FindSet(true) then
            repeat
                SalesLineArchive."Physical Transfer CZL" := SalesLineArchive."Physical Transfer";
                SalesLineArchive.Modify(false);
            until SalesLineArchive.Next() = 0;
    end;

    local procedure UpdatePurchaseHeader();
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchaseHeader.FindSet(true) then
            repeat
                PurchaseHeader."Physical Transfer CZL" := PurchaseHeader."Physical Transfer";
                PurchaseHeader."Intrastat Exclude CZL" := PurchaseHeader."Intrastat Exclude";
                PurchaseHeader.Modify(false);
            until PurchaseHeader.Next() = 0;
    end;

    local procedure UpdatePurchRcptHeader();
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchRcptHeader.FindSet(true) then
            repeat
                PurchRcptHeader."Physical Transfer CZL" := PurchRcptHeader."Physical Transfer";
                PurchRcptHeader."Intrastat Exclude CZL" := PurchRcptHeader."Intrastat Exclude";
                PurchRcptHeader.Modify(false);
            until PurchRcptHeader.Next() = 0;
    end;

    local procedure UpdatePurchRcptLine();
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchRcptLine.FindSet(true) then
            repeat
                PurchRcptLine."Country/Reg. of Orig. Code CZL" := PurchRcptLine."Country/Region of Origin Code";
                PurchRcptLine.Modify(false);
            until PurchRcptLine.Next() = 0;
    end;

    local procedure UpdatePurchInvHeader();
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchInvHeader.FindSet(true) then
            repeat
                PurchInvHeader."Physical Transfer CZL" := PurchInvHeader."Physical Transfer";
                PurchInvHeader."Intrastat Exclude CZL" := PurchInvHeader."Intrastat Exclude";
                PurchInvHeader.Modify(false);
            until PurchInvHeader.Next() = 0;
    end;

    local procedure UpdatePurchInvLine();
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchInvLine.FindSet(true) then
            repeat
                PurchInvLine."Country/Reg. of Orig. Code CZL" := PurchInvLine."Country/Region of Origin Code";
                PurchInvLine.Modify(false);
            until PurchInvLine.Next() = 0;
    end;

    local procedure UpdatePurchCrMemoHdr();
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchCrMemoHdr.FindSet(true) then
            repeat
                PurchCrMemoHdr."Physical Transfer CZL" := PurchCrMemoHdr."Physical Transfer";
                PurchCrMemoHdr."Intrastat Exclude CZL" := PurchCrMemoHdr."Intrastat Exclude";
                PurchCrMemoHdr.Modify(false);
            until PurchCrMemoHdr.Next() = 0;
    end;

    local procedure UpdatePurchCrMemoLine();
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchCrMemoLine.FindSet(true) then
            repeat
                PurchCrMemoLine."Country/Reg. of Orig. Code CZL" := PurchCrMemoLine."Country/Region of Origin Code";
                PurchCrMemoLine.Modify(false);
            until PurchCrMemoLine.Next() = 0;
    end;

    local procedure UpdatePurchaseHeaderArchive();
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchaseHeaderArchive.FindSet(true) then
            repeat
                PurchaseHeaderArchive."Physical Transfer CZL" := PurchaseHeaderArchive."Physical Transfer";
                PurchaseHeaderArchive."Intrastat Exclude CZL" := PurchaseHeaderArchive."Intrastat Exclude";
                PurchaseHeaderArchive.Modify(false);
            until PurchaseHeaderArchive.Next() = 0;
    end;

    local procedure UpdatePurchaseLineArchive();
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if PurchaseLineArchive.FindSet(true) then
            repeat
                PurchaseLineArchive."Physical Transfer CZL" := PurchaseLineArchive."Physical Transfer";
                PurchaseLineArchive.Modify(false);
            until PurchaseLineArchive.Next() = 0;
    end;

    local procedure UpdateServiceHeader();
    var
        ServiceHeader: Record "Service Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceHeader.FindSet(true) then
            repeat
                ServiceHeader."Physical Transfer CZL" := ServiceHeader."Physical Transfer";
                ServiceHeader."Intrastat Exclude CZL" := ServiceHeader."Intrastat Exclude";
                ServiceHeader.Modify(false);
            until ServiceHeader.Next() = 0;
    end;

    local procedure UpdateServiceShipmentHeader();
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceShipmentHeader.FindSet(true) then
            repeat
                ServiceShipmentHeader."Physical Transfer CZL" := ServiceShipmentHeader."Physical Transfer";
                ServiceShipmentHeader."Intrastat Exclude CZL" := ServiceShipmentHeader."Intrastat Exclude";
                ServiceShipmentHeader.Modify(false);
            until ServiceShipmentHeader.Next() = 0;
    end;

    local procedure UpdateServiceInvoiceHeader();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceInvoiceHeader.FindSet(true) then
            repeat
                ServiceInvoiceHeader."Physical Transfer CZL" := ServiceInvoiceHeader."Physical Transfer";
                ServiceInvoiceHeader."Intrastat Exclude CZL" := ServiceInvoiceHeader."Intrastat Exclude";
                ServiceInvoiceHeader.Modify(false);
            until ServiceInvoiceHeader.Next() = 0;
    end;

    local procedure UpdateServiceInvoiceLine();
    var
        ServiceInvoiceLine: Record "Service Invoice Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceInvoiceLine.FindSet(true) then
            repeat
                ServiceInvoiceLine."Country/Reg. of Orig. Code CZL" := ServiceInvoiceLine."Country/Region of Origin Code";
                ServiceInvoiceLine.Modify(false);
            until ServiceInvoiceLine.Next() = 0;
    end;

    local procedure UpdateServiceCrMemoHeader();
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceCrMemoHeader.FindSet(true) then
            repeat
                ServiceCrMemoHeader."Physical Transfer CZL" := ServiceCrMemoHeader."Physical Transfer";
                ServiceCrMemoHeader."Intrastat Exclude CZL" := ServiceCrMemoHeader."Intrastat Exclude";
                ServiceCrMemoHeader.Modify(false);
            until ServiceCrMemoHeader.Next() = 0;
    end;

    local procedure UpdateServiceCrMemoLine();
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ServiceCrMemoLine.FindSet(true) then
            repeat
                ServiceCrMemoLine."Country/Reg. of Orig. Code CZL" := ServiceCrMemoLine."Country/Region of Origin Code";
                ServiceCrMemoLine.Modify(false);
            until ServiceCrMemoLine.Next() = 0;
    end;

    local procedure UpdateReturnShipmentHeader();
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ReturnShipmentHeader.FindSet(true) then
            repeat
                ReturnShipmentHeader."Physical Transfer CZL" := ReturnShipmentHeader."Physical Transfer";
                ReturnShipmentHeader."Intrastat Exclude CZL" := ReturnShipmentHeader."Intrastat Exclude";
                ReturnShipmentHeader.Modify(false);
            until ReturnShipmentHeader.Next() = 0;
    end;

    local procedure UpdateReturnReceiptHeader();
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ReturnReceiptHeader.FindSet(true) then
            repeat
                ReturnReceiptHeader."Physical Transfer CZL" := ReturnReceiptHeader."Physical Transfer";
                ReturnReceiptHeader."Intrastat Exclude CZL" := ReturnReceiptHeader."Intrastat Exclude";
                ReturnReceiptHeader.Modify(false);
            until ReturnReceiptHeader.Next() = 0;
    end;

    local procedure UpdateTransferHeader();
    var
        TransferHeader: Record "Transfer Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if TransferHeader.FindSet(true) then
            repeat
                TransferHeader."Intrastat Exclude CZL" := TransferHeader."Intrastat Exclude";
                TransferHeader.Modify(false);
            until TransferHeader.Next() = 0;
    end;

    local procedure UpdateTransferLine();
    var
        TransferLine: Record "Transfer Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if TransferLine.FindSet(true) then
            repeat
                TransferLine."Tariff No. CZL" := TransferLine."Tariff No.";
                TransferLine."Statistic Indication CZL" := TransferLine."Statistic Indication";
                TransferLine."Country/Reg. of Orig. Code CZL" := TransferLine."Country/Region of Origin Code";
                TransferLine.Modify(false);
            until TransferLine.Next() = 0;
    end;

    local procedure UpdateTransferReceiptHeader();
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if TransferReceiptHeader.FindSet(true) then
            repeat
                TransferReceiptHeader."Intrastat Exclude CZL" := TransferReceiptHeader."Intrastat Exclude";
                TransferReceiptHeader.Modify(false);
            until TransferReceiptHeader.Next() = 0;
    end;

    local procedure UpdateTransferShipmentHeader();
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if TransferShipmentHeader.FindSet(true) then
            repeat
                TransferShipmentHeader."Intrastat Exclude CZL" := TransferShipmentHeader."Intrastat Exclude";
                TransferShipmentHeader.Modify(false);
            until TransferShipmentHeader.Next() = 0;
    end;

    local procedure UpdateItemLedgerEntry();
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpdateJobLedgerEntry();
    var
        JobLedgerEntry: Record "Job Ledger Entry";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpdateItemCharge();
    var
        ItemCharge: Record "Item Charge";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ItemCharge.FindSet(true) then
            repeat
                ItemCharge."Incl. in Intrastat Amount CZL" := ItemCharge."Incl. in Intrastat Amount";
                ItemCharge."Incl. in Intrastat S.Value CZL" := ItemCharge."Incl. in Intrastat Stat. Value";
                ItemCharge.Modify(false);
            until ItemCharge.Next() = 0;
    end;

    local procedure UpdateItemChargeAssignmentPurch();
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ItemChargeAssignmentPurch.FindSet(true) then
            repeat
                ItemChargeAssignmentPurch."Incl. in Intrastat Amount CZL" := ItemChargeAssignmentPurch."Incl. in Intrastat Amount";
                ItemChargeAssignmentPurch."Incl. in Intrastat S.Value CZL" := ItemChargeAssignmentPurch."Incl. in Intrastat Stat. Value";
                ItemChargeAssignmentPurch.Modify(false);
            until ItemChargeAssignmentPurch.Next() = 0;
    end;

    local procedure UpdateItemChargeAssignmentSales();
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if ItemChargeAssignmentSales.FindSet(true) then
            repeat
                ItemChargeAssignmentSales."Incl. in Intrastat Amount CZL" := ItemChargeAssignmentSales."Incl. in Intrastat Amount";
                ItemChargeAssignmentSales."Incl. in Intrastat S.Value CZL" := ItemChargeAssignmentSales."Incl. in Intrastat Stat. Value";
                ItemChargeAssignmentSales.Modify(false);
            until ItemChargeAssignmentSales.Next() = 0;
    end;

    local procedure UpdatePostedGenJournalLine();
    var
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

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


    local procedure UpdateIntrastatJournalBatch();
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if IntrastatJnlBatch.FindSet(true) then
            repeat
                IntrastatJnlBatch."Declaration No. CZL" := IntrastatJnlBatch."Declaration No.";
                IntrastatJnlBatch."Statement Type CZL" := "Intrastat Statement Type CZL".FromInteger(IntrastatJnlBatch."Statement Type");
                IntrastatJnlBatch.Modify(false);
            until IntrastatJnlBatch.Next() = 0;
    end;

    local procedure UpdateIntrastatJournalLine();
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

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

    local procedure UpdateInventoryPostingSetup();
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if InventoryPostingSetup.FindSet() then
            repeat
                InventoryPostingSetup."Change In Inv.OfProd. Acc. CZL" := InventoryPostingSetup."Change In Inv.Of Product Acc.";
                InventoryPostingSetup."Change In Inv.Of WIP Acc. CZL" := InventoryPostingSetup."Change In Inv.Of WIP Acc.";
                InventoryPostingSetup."Consumption Account CZL" := InventoryPostingSetup."Consumption Account";
                InventoryPostingSetup.Modify(false);
            until InventoryPostingSetup.Next() = 0;
    end;

    local procedure UpdateGeneralPostingSetup();
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if GeneralPostingSetup.FindSet() then
            repeat
                GeneralPostingSetup."Invt. Rounding Adj. Acc. CZL" := GeneralPostingSetup."Invt. Rounding Adj. Account";
                GeneralPostingSetup.Modify(false);
            until GeneralPostingSetup.Next() = 0;
    end;

    local procedure UpdateUserSetup();
    var
        UserSetup: Record "User Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if UserSetup.FindSet() then
            repeat
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

    local procedure UpdateUserSetupLine();
    var
        UserSetupLine: Record "User Setup Line";
        UserSetupLineCZL: Record "User Setup Line CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        if UserSetupLine.FindSet() then
            repeat
                if not UserSetupLineCZL.Get(UserSetupLine."User ID", UserSetupLine.Type, UserSetupLine."Line No.") then begin
                    UserSetupLineCZL.Init();
                    UserSetupLineCZL."User ID" := UserSetupLine."User ID";
                    UserSetupLineCZL.Type := UserSetupLine.Type;
                    UserSetupLineCZL."Line No." := UserSetupLine."Line No.";
                    UserSetupLineCZL.Insert();
                end;
                UserSetupLineCZL."Code / Name" := UserSetupLine."Code / Name";
                UserSetupLineCZL.Modify(false);
            until UserSetupLine.Next() = 0;
    end;

    local procedure UpdateAccScheduleLine();
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if AccScheduleLine.FindSet(true) then
            repeat
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

    local procedure UpdateAccScheduleExtension();
    var
        AccScheduleExtension: Record "Acc. Schedule Extension";
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if AccScheduleExtension.FindSet() then
            repeat
                if not AccScheduleExtensionCZL.Get(AccScheduleExtension.Code) then begin
                    AccScheduleExtensionCZL.Init();
                    AccScheduleExtensionCZL.Code := AccScheduleExtension.Code;
                    AccScheduleExtensionCZL.Insert();
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

    local procedure UpdateAccScheduleResultLine();
    var
        AccScheduleResultLine: Record "Acc. Schedule Result Line";
        AccScheduleResultLineCZL: Record "Acc. Schedule Result Line CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if AccScheduleResultLine.FindSet() then
            repeat
                if not AccScheduleResultLineCZL.Get(AccScheduleResultLine."Result Code", AccScheduleResultLine."Line No.") then begin
                    AccScheduleResultLineCZL.Init();
                    AccScheduleResultLineCZL."Result Code" := AccScheduleResultLine."Result Code";
                    AccScheduleResultLineCZL."Line No." := AccScheduleResultLine."Line No.";
                    AccScheduleResultLineCZL.Insert();
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

    local procedure UpdateAccScheduleResultColumn();
    var
        AccScheduleResultColumn: Record "Acc. Schedule Result Column";
        AccScheduleResultColCZL: Record "Acc. Schedule Result Col. CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if AccScheduleResultColumn.FindSet() then
            repeat
                if not AccScheduleResultColCZL.Get(AccScheduleResultColumn."Result Code", AccScheduleResultColumn."Line No.") then begin
                    AccScheduleResultColCZL.Init();
                    AccScheduleResultColCZL."Result Code" := AccScheduleResultColumn."Result Code";
                    AccScheduleResultColCZL."Line No." := AccScheduleResultColumn."Line No.";
                    AccScheduleResultColCZL.Insert();
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

    local procedure UpdateAccScheduleResultValue();
    var
        AccScheduleResultValue: Record "Acc. Schedule Result Value";
        AccScheduleResultValueCZL: Record "Acc. Schedule Result Value CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if AccScheduleResultValue.FindSet() then
            repeat
                if not AccScheduleResultValueCZL.Get(AccScheduleResultValue."Result Code", AccScheduleResultValue."Row No.", AccScheduleResultValue."Column No.") then begin
                    AccScheduleResultValueCZL.Init();
                    AccScheduleResultValueCZL."Result Code" := AccScheduleResultValue."Result Code";
                    AccScheduleResultValueCZL."Row No." := AccScheduleResultValue."Row No.";
                    AccScheduleResultValueCZL."Column No." := AccScheduleResultValue."Column No.";
                    AccScheduleResultValueCZL.Insert();
                end;
                AccScheduleResultValueCZL.Value := AccScheduleResultValue.Value;
                AccScheduleResultValueCZL.Modify(false);
            until AccScheduleResultValue.Next() = 0;
    end;

    local procedure UpdateAccScheduleResultHeader();
    var
        AccScheduleResultHeader: Record "Acc. Schedule Result Header";
        AccScheduleResultHdrCZL: Record "Acc. Schedule Result Hdr. CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if AccScheduleResultHeader.FindSet() then
            repeat
                if not AccScheduleResultHdrCZL.Get(AccScheduleResultHeader."Result Code") then begin
                    AccScheduleResultHdrCZL.Init();
                    AccScheduleResultHdrCZL."Result Code" := AccScheduleResultHeader."Result Code";
                    AccScheduleResultHdrCZL.Insert();
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

    local procedure UpdateAccScheduleResultHistory();
    var
        AccScheduleResultHistory: Record "Acc. Schedule Result History";
        AccScheduleResultHistCZL: Record "Acc. Schedule Result Hist. CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if AccScheduleResultHistory.FindSet() then
            repeat
                if not AccScheduleResultHistCZL.Get(AccScheduleResultHistory."Result Code", AccScheduleResultHistory."Row No.",
                                                    AccScheduleResultHistory."Column No.", AccScheduleResultHistory."Variant No.") then begin
                    AccScheduleResultHistCZL.Init();
                    AccScheduleResultHistCZL."Result Code" := AccScheduleResultHistory."Result Code";
                    AccScheduleResultHistCZL."Row No." := AccScheduleResultHistory."Row No.";
                    AccScheduleResultHistCZL."Column No." := AccScheduleResultHistory."Column No.";
                    AccScheduleResultHistCZL."Variant No." := AccScheduleResultHistory."Variant No.";
                    AccScheduleResultHistCZL.Insert();
                end;
                AccScheduleResultHistCZL."New Value" := AccScheduleResultHistory."New Value";
                AccScheduleResultHistCZL."Old Value" := AccScheduleResultHistory."Old Value";
                AccScheduleResultHistCZL."User ID" := AccScheduleResultHistory."User ID";
                AccScheduleResultHistCZL."Modified DateTime" := AccScheduleResultHistory."Modified DateTime";
                AccScheduleResultHistCZL.Modify(false);
            until AccScheduleResultHistory.Next() = 0;
    end;

    local procedure UpdateGenJournalTemplate();
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;

        GenJournalTemplate.SetRange("Not Check Doc. Type", true);
        if GenJournalTemplate.FindSet() then
            repeat
                GenJournalTemplate."Not Check Doc. Type CZL" := GenJournalTemplate."Not Check Doc. Type";
                GenJournalTemplate.Modify(false);
            until GenJournalTemplate.Next() = 0;
    end;

    local procedure UpdateVATEntry();
    var
        VATEntry: Record "VAT Entry";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerCompanyUpgradeTag()) then
            exit;
        VATEntry.SetFilter("VAT Identifier", '<>%1', '');
        if VATEntry.FindSet(true) then
            repeat
                VATEntry."VAT Identifier CZL" := VATEntry."VAT Identifier";
                VATEntry.Modify(false);
            until VATEntry.Next() = 0;
    end;

    local procedure UpdatePermission()
    begin
        UpdatePermissionVersion174();
        UpdatePermissionVersion180();
        UpdatePermissionVersion190();
    end;

    local procedure UpdatePermissionVersion174()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag()) then
            exit;

        InsertTableDataPermissions(Database::"Certificate CZ Code", Database::"Certificate Code CZL");
        InsertTableDataPermissions(Database::"EET Business Premises", Database::"EET Business Premises CZL");
        InsertTableDataPermissions(Database::"EET Cash Register", Database::"EET Cash Register CZL");
        InsertTableDataPermissions(Database::"EET Entry", Database::"EET Entry CZL");
        InsertTableDataPermissions(Database::"EET Entry Status", Database::"EET Entry Status Log CZL");
        InsertTableDataPermissions(Database::"EET Service Setup", Database::"EET Service Setup CZL");
    end;

    local procedure UpdatePermissionVersion180()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag()) then
            exit;

        InsertTableDataPermissions(Database::"Subst. Customer Posting Group", Database::"Subst. Cust. Posting Group CZL");
        InsertTableDataPermissions(Database::"Subst. Vendor Posting Group", Database::"Subst. Vend. Posting Group CZL");
        InsertTableDataPermissions(Database::"Constant Symbol", Database::"Constant Symbol CZL");
        InsertTableDataPermissions(Database::"Specific Movement", Database::"Specific Movement CZL");
        InsertTableDataPermissions(Database::"Intrastat Delivery Group", Database::"Intrastat Delivery Group CZL");
        InsertTableDataPermissions(Database::"User Setup Line", Database::"User Setup Line CZL");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion180PerDatabaseUpgradeTag());
    end;

    local procedure UpdatePermissionVersion190()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag()) then
            exit;

        InsertTableDataPermissions(Database::"Acc. Schedule Extension", Database::"Acc. Schedule Extension CZL");
        InsertTableDataPermissions(Database::"Acc. Schedule Result Line", Database::"Acc. Schedule Result Line CZL");
        InsertTableDataPermissions(Database::"Acc. Schedule Result Column", Database::"Acc. Schedule Result Col. CZL");
        InsertTableDataPermissions(Database::"Acc. Schedule Result Value", Database::"Acc. Schedule Result Value CZL");
        InsertTableDataPermissions(Database::"Acc. Schedule Result Header", Database::"Acc. Schedule Result Hdr. CZL");
        InsertTableDataPermissions(Database::"Acc. Schedule Result History", Database::"Acc. Schedule Result Hist. CZL");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion183PerDatabaseUpgradeTag());
    end;

    local procedure InsertTableDataPermissions(OldTableID: Integer; NewTableID: Integer)
    var
        Permission: Record Permission;
        NewPermission: Record Permission;
    begin
        Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
        Permission.SetRange("Object ID", OldTableID);
        if not Permission.FindSet() then
            exit;
        repeat
            if not NewPermission.Get(Permission."Role ID", Permission."Object Type", Permission."Object ID") then begin
                NewPermission.Init();
                NewPermission := Permission;
                NewPermission."Object ID" := NewTableID;
                NewPermission.Insert();
            end;
        until Permission.Next() = 0;
    end;
}
