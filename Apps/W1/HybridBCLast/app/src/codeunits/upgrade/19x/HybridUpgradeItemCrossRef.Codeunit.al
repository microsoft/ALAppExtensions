codeunit 40024 "Hybrid Upgrade Item Cross Ref"
{
#if not CLEAN19
    Permissions = TableData "Item Ledger Entry" = rm,
                  TableData "Sales Shipment Line" = rm,
                  TableData "Sales Invoice Line" = rm,
                  TableData "Sales Cr.Memo Line" = rm,
                  TableData "Purch. Rcpt. Line" = rm,
                  TableData "Purch. Inv. Line" = rm,
                  TableData "Purch. Cr. Memo Line" = rm,
                  TableData "Return Receipt Line" = rm,
                  TableData "Return Shipment Line" = rm,
                  TableData "Handled IC Inbox Purch. Line" = rm,
                  TableData "Handled IC Outbox Purch. Line" = rm,
                  TableData "Handled IC Inbox Sales Line" = rm,
                  TableData "Handled IC Outbox Sales Line" = rm;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    var
        DisableAggregateTableUpdate: Codeunit "Disable Aggregate Table Update";
    begin
        if TargetVersion <> 19.0 then
            exit;

        DisableAggregateTableUpdate.SetDisableAllRecords(true);
        BindSubscription(DisableAggregateTableUpdate);
        UpdateData();
        UpdateDateExchFieldMapping();
    end;

    procedure UpdateData();
    var
        InventorySetup: Record "Inventory Setup";
        ItemCrossReference: Record "Item Cross Reference";
        ItemReference: Record "Item Reference";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalLine: Record "Item Journal Line";
        ApplicationAreaSetup: Record "Application Area Setup";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
        CommitCount: Integer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetItemCrossReferenceUpgradeTag()) then
            exit;

        if ApplicationAreaSetup.Get() then begin
            ApplicationAreaSetup."Item References" := true;
            ApplicationAreaSetup.Modify();
            Commit();
        end;

        // check if update already completed using feature management or
        // check if item cross reference had been used before
        if not ItemReference.IsEmpty() or ItemCrossReference.IsEmpty() then begin
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetItemCrossReferenceUpgradeTag());
            exit;
        end;

        InventorySetup.Get();
        InventorySetup."Use Item References" := true;
        InventorySetup.Modify();

        if ItemCrossReference.FindSet() then
            repeat
                Clear(ItemReference);
                if not ItemReference.GetBySystemId(ItemCrossReference.SystemId) then begin
                    ItemReference.TransferFields(ItemCrossReference, true, true);
                    ItemReference.SystemId := ItemCrossReference.SystemId;
                    if ItemReference.Insert(false, true) then;
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until ItemCrossReference.Next() = 0;

        Commit();
        CommitCount := 0;

        ItemLedgerEntry.SetRange("Item Reference No.", '');
        ItemLedgerEntry.SetFilter("Cross-Reference No.", '<>%1', '');

        if ItemLedgerEntry.FindSet() then
            repeat
                ItemLedgerEntry."Item Reference No." := ItemLedgerEntry."Cross-Reference No.";
                ItemLedgerEntry.Modify();
                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until ItemLedgerEntry.Next() = 0;

        ItemJournalLine.SetLoadFields("Cross-Reference No.", "Item Reference No.");
        ItemJournalLine.SetFilter("Cross-Reference No.", '<>%1', '');
        if ItemJournalLine.FindSet() then
            repeat
                ItemJournalLine."Item Reference No." := ItemJournalLine."Cross-Reference No.";
                ItemJournalLine.Modify();
            until ItemJournalLine.Next() = 0;

        UpgradePurchaseLines();

        UpgradeSalesLines();
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetItemCrossReferenceUpgradeTag());
    end;

    local procedure UpgradePurchaseLines()
    begin
        UpgradePurchaseLine();
        UpgradePurchaseLineArchive();
        UpgradePurchRcptLine();
        UpgradePurchInvLine();
        UpgradePurchCrMemoLine();
        UpgradeReturnShipmentLine();
        UpgradeICInOutPurchLines();
    end;

    local procedure UpgradeSalesLines()
    begin
        UpgradeSalesLine();
        UpgradeSalesLineArchive();
        UpgradeSalesShipmentLine();
        UpgradeSalesInvoiceLine();
        UpgradeSalesCrMemoLine();
        UpgradeReturnReceiptLine();
        UpgradeICInOutSalesLines();
    end;

    local procedure ConvertCrossRefTypeToItemRefType(CrossReferenceType: Option): Enum "Item Reference Type"
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        case CrossReferenceType of
            ItemCrossReference."Cross-Reference Type"::" ":
                exit("Item Reference Type"::" ");
            ItemCrossReference."Cross-Reference Type"::Customer:
                exit("Item Reference Type"::Customer);
            ItemCrossReference."Cross-Reference Type"::Vendor:
                exit("Item Reference Type"::Vendor);
            ItemCrossReference."Cross-Reference Type"::"Bar Code":
                exit("Item Reference Type"::"Bar Code");
        end;
    end;

    local procedure UpgradeICInOutPurchLines()
    var
        ICInboxPurchaseLine: Record "IC Inbox Purchase Line";
        ICOutboxPurchaseLine: Record "IC Outbox Purchase Line";
        HandledICInboxPurchLine: Record "Handled IC Inbox Purch. Line";
        HandledICOutboxPurchLine: Record "Handled IC Outbox Purch. Line";
        CommitCount: Integer;
    begin
        ICInboxPurchaseLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        ICInboxPurchaseLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if ICInboxPurchaseLine.FindSet() then
            repeat
                if ICInboxPurchaseLine."IC Item Reference No." = '' then begin
                    ICInboxPurchaseLine."IC Item Reference No." := ICInboxPurchaseLine."IC Partner Reference";
                    ICInboxPurchaseLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until ICInboxPurchaseLine.Next() = 0;

        ICOutboxPurchaseLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        ICOutboxPurchaseLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if ICOutboxPurchaseLine.FindSet() then
            repeat
                if ICOutboxPurchaseLine."IC Item Reference No." = '' then begin
                    ICOutboxPurchaseLine."IC Item Reference No." := ICOutboxPurchaseLine."IC Partner Reference";
                    ICOutboxPurchaseLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until ICOutboxPurchaseLine.Next() = 0;

        HandledICInboxPurchLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        HandledICInboxPurchLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if HandledICInboxPurchLine.FindSet() then
            repeat
                if HandledICInboxPurchLine."IC Item Reference No." = '' then begin
                    HandledICInboxPurchLine."IC Item Reference No." := HandledICInboxPurchLine."IC Partner Reference";
                    HandledICInboxPurchLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until HandledICInboxPurchLine.Next() = 0;

        HandledICOutboxPurchLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        HandledICOutboxPurchLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if HandledICOutboxPurchLine.FindSet() then
            repeat
                if HandledICOutboxPurchLine."IC Item Reference No." = '' then begin
                    HandledICOutboxPurchLine."IC Item Reference No." := HandledICOutboxPurchLine."IC Partner Reference";
                    HandledICOutboxPurchLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until HandledICOutboxPurchLine.Next() = 0;
    end;

    local procedure UpgradeICInOutSalesLines()
    var
        ICInboxSalesLine: Record "IC Inbox Sales Line";
        ICOutboxSalesLine: Record "IC Outbox Sales Line";
        HandledICInboxSalesLine: Record "Handled IC Inbox Sales Line";
        HandledICOutboxSalesLine: Record "Handled IC Outbox Sales Line";
        CommitCount: Integer;
    begin
        ICInboxSalesLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        ICInboxSalesLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if ICInboxSalesLine.FindSet() then
            repeat
                if ICInboxSalesLine."IC Item Reference No." = '' then begin
                    ICInboxSalesLine."IC Item Reference No." := ICInboxSalesLine."IC Partner Reference";
                    ICInboxSalesLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until ICInboxSalesLine.Next() = 0;

        ICOutboxSalesLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        ICOutboxSalesLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if ICOutboxSalesLine.FindSet() then
            repeat
                if ICOutboxSalesLine."IC Item Reference No." = '' then begin
                    ICOutboxSalesLine."IC Item Reference No." := ICOutboxSalesLine."IC Partner Reference";
                    ICOutboxSalesLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until ICOutboxSalesLine.Next() = 0;

        HandledICInboxSalesLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        HandledICInboxSalesLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if HandledICInboxSalesLine.FindSet() then
            repeat
                if HandledICInboxSalesLine."IC Item Reference No." = '' then begin
                    HandledICInboxSalesLine."IC Item Reference No." := HandledICInboxSalesLine."IC Partner Reference";
                    HandledICInboxSalesLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until HandledICInboxSalesLine.Next() = 0;

        HandledICOutboxSalesLine.SetLoadFields("IC Partner Reference", "IC Item Reference No.");
        HandledICOutboxSalesLine.SetFilter("IC Partner Reference", '<>%1', '');

        Commit();
        CommitCount := 0;

        if HandledICOutboxSalesLine.FindSet() then
            repeat
                if HandledICOutboxSalesLine."IC Item Reference No." = '' then begin
                    HandledICOutboxSalesLine."IC Item Reference No." := HandledICOutboxSalesLine."IC Partner Reference";
                    HandledICOutboxSalesLine.Modify();
                    CommitCount += 1;
                    if CommitCount = GetCommitCount() then begin
                        CommitCount := 0;
                        Commit();
                    end;
                end;
            until HandledICOutboxSalesLine.Next() = 0;
    end;

    local procedure UpgradePurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        PurchaseLine.SetRange("Item Reference No.", '');
        PurchaseLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine."Item Reference No." := PurchaseLine."Cross-Reference No.";
                PurchaseLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(PurchaseLine."Cross-Reference Type");
                PurchaseLine."Item Reference Type No." := PurchaseLine."Cross-Reference Type No.";
                PurchaseLine."Item Reference Unit of Measure" := PurchaseLine."Unit of Measure (Cross Ref.)";

                if PurchaseLine."IC Partner Ref. Type" = PurchaseLine."IC Partner Ref. Type"::"Cross Reference" then
                    PurchaseLine."IC Item Reference No." := PurchaseLine."IC Partner Reference";
                PurchaseLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until PurchaseLine.Next() = 0;
    end;

    local procedure UpgradePurchaseLineArchive()
    var
        PurchaseLineArchive: Record "Purchase Line Archive";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        PurchaseLineArchive.SetLoadFields(
            "Cross-Reference No.", "Cross-Reference Type", "Cross-Reference Type No.", "Unit of Measure (Cross Ref.)",
            "IC Partner Ref. Type", "IC Partner Reference", "IC Item Reference No.",
            "Item Reference No.", "Item Reference Type", "Item Reference Type No.", "Item Reference Unit of Measure");
        PurchaseLineArchive.SetFilter("Cross-Reference No.", '<>%1', '');

        if PurchaseLineArchive.FindSet() then
            repeat
                PurchaseLineArchive."Item Reference No." := PurchaseLineArchive."Cross-Reference No.";
                PurchaseLineArchive."Item Reference Type" := ConvertCrossRefTypeToItemRefType(PurchaseLineArchive."Cross-Reference Type");
                PurchaseLineArchive."Item Reference Type No." := PurchaseLineArchive."Cross-Reference Type No.";
                PurchaseLineArchive."Item Reference Unit of Measure" := PurchaseLineArchive."Unit of Measure (Cross Ref.)";
                PurchaseLineArchive."Cross-Reference Type" := 0;
                PurchaseLineArchive."Cross-Reference Type No." := '';
                PurchaseLineArchive."Unit of Measure (Cross Ref.)" := '';
                if PurchaseLineArchive."IC Partner Ref. Type" = PurchaseLineArchive."IC Partner Ref. Type"::"Cross Reference" then
                    PurchaseLineArchive."IC Item Reference No." := PurchaseLineArchive."IC Partner Reference";
                PurchaseLineArchive.Modify();
                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until PurchaseLineArchive.Next() = 0;
    end;

    local procedure UpgradePurchCrMemoLine()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        PurchCrMemoLine.SetRange("Item Reference No.", '');
        PurchCrMemoLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if PurchCrMemoLine.FindSet() then
            repeat
                PurchCrMemoLine."Item Reference No." := PurchCrMemoLine."Cross-Reference No.";
                PurchCrMemoLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(PurchCrMemoLine."Cross-Reference Type");
                PurchCrMemoLine."Item Reference Type No." := PurchCrMemoLine."Cross-Reference Type No.";
                PurchCrMemoLine."Item Reference Unit of Measure" := PurchCrMemoLine."Unit of Measure (Cross Ref.)";

                if PurchCrMemoLine."IC Partner Ref. Type" = PurchCrMemoLine."IC Partner Ref. Type"::"Cross Reference" then
                    PurchCrMemoLine."IC Item Reference No." := PurchCrMemoLine."IC Partner Reference";

                PurchCrMemoLine.Modify();
                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until PurchCrMemoLine.Next() = 0;
    end;

    local procedure UpgradePurchInvLine()
    var
        PurchInvLine: Record "Purch. Inv. Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        PurchInvLine.SetRange("Item Reference No.", '');
        PurchInvLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if PurchInvLine.FindSet() then
            repeat
                PurchInvLine."Item Reference No." := PurchInvLine."Cross-Reference No.";
                PurchInvLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(PurchInvLine."Cross-Reference Type");
                PurchInvLine."Item Reference Type No." := PurchInvLine."Cross-Reference Type No.";
                PurchInvLine."Item Reference Unit of Measure" := PurchInvLine."Unit of Measure (Cross Ref.)";

                if PurchInvLine."IC Partner Ref. Type" = PurchInvLine."IC Partner Ref. Type"::"Cross Reference" then
                    PurchInvLine."IC Cross-Reference No." := PurchInvLine."IC Partner Reference";
                PurchInvLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until PurchInvLine.Next() = 0;
    end;

    local procedure UpgradePurchRcptLine()
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        PurchRcptLine.SetRange("Item Reference No.", '');
        PurchRcptLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if PurchRcptLine.FindSet() then
            repeat
                PurchRcptLine."Item Reference No." := PurchRcptLine."Cross-Reference No.";
                PurchRcptLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(PurchRcptLine."Cross-Reference Type");
                PurchRcptLine."Item Reference Type No." := PurchRcptLine."Cross-Reference Type No.";
                PurchRcptLine."Item Reference Unit of Measure" := PurchRcptLine."Unit of Measure (Cross Ref.)";

                if PurchRcptLine."IC Partner Ref. Type" = PurchRcptLine."IC Partner Ref. Type"::"Cross Reference" then
                    PurchRcptLine."IC Item Reference No." := PurchRcptLine."IC Partner Reference";
                PurchRcptLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until PurchRcptLine.Next() = 0;
    end;

    local procedure UpgradeReturnReceiptLine()
    var
        ReturnReceiptLine: Record "Return Receipt Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        ReturnReceiptLine.SetRange("Item Reference No.", '');
        ReturnReceiptLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if ReturnReceiptLine.FindSet() then
            repeat
                ReturnReceiptLine."Item Reference No." := ReturnReceiptLine."Cross-Reference No.";
                ReturnReceiptLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(ReturnReceiptLine."Cross-Reference Type");
                ReturnReceiptLine."Item Reference Type No." := ReturnReceiptLine."Cross-Reference Type No.";
                ReturnReceiptLine."Item Reference Unit of Measure" := ReturnReceiptLine."Unit of Measure (Cross Ref.)";
                ReturnReceiptLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until ReturnReceiptLine.Next() = 0;
    end;

    local procedure UpgradeReturnShipmentLine()
    var
        ReturnShipmentLine: Record "Return Shipment Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        ReturnShipmentLine.SetRange("Item Reference No.", '');
        ReturnShipmentLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if ReturnShipmentLine.FindSet() then
            repeat
                ReturnShipmentLine."Item Reference No." := ReturnShipmentLine."Cross-Reference No.";
                ReturnShipmentLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(ReturnShipmentLine."Cross-Reference Type");
                ReturnShipmentLine."Item Reference Type No." := ReturnShipmentLine."Cross-Reference Type No.";
                ReturnShipmentLine."Item Reference Unit of Measure" := ReturnShipmentLine."Unit of Measure (Cross Ref.)";

                ReturnShipmentLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until ReturnShipmentLine.Next() = 0;
    end;

    local procedure UpgradeSalesLine()
    var
        SalesLine: Record "Sales Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        SalesLine.SetRange("Item Reference No.", '');
        SalesLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if SalesLine.FindSet() then
            repeat
                SalesLine."Item Reference No." := SalesLine."Cross-Reference No.";
                SalesLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(SalesLine."Cross-Reference Type");
                SalesLine."Item Reference Type No." := SalesLine."Cross-Reference Type No.";
                SalesLine."Item Reference Unit of Measure" := SalesLine."Unit of Measure (Cross Ref.)";

                if SalesLine."IC Partner Ref. Type" = SalesLine."IC Partner Ref. Type"::"Cross Reference" then
                    SalesLine."IC Item Reference No." := SalesLine."IC Partner Reference";
                SalesLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until SalesLine.Next() = 0;
    end;

    local procedure UpgradeSalesLineArchive()
    var
        SalesLineArchive: Record "Sales Line Archive";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        SalesLineArchive.SetLoadFields(
            "Cross-Reference No.", "Cross-Reference Type", "Cross-Reference Type No.", "Unit of Measure (Cross Ref.)",
            "IC Partner Ref. Type", "IC Partner Reference", "IC Item Reference No.",
            "Item Reference No.", "Item Reference Type", "Item Reference Type No.", "Item Reference Unit of Measure");
        SalesLineArchive.SetFilter("Cross-Reference No.", '<>%1', '');

        if SalesLineArchive.FindSet() then
            repeat
                SalesLineArchive."Item Reference No." := SalesLineArchive."Cross-Reference No.";
                SalesLineArchive."Item Reference Type" := ConvertCrossRefTypeToItemRefType(SalesLineArchive."Cross-Reference Type");
                SalesLineArchive."Item Reference Type No." := SalesLineArchive."Cross-Reference Type No.";
                SalesLineArchive."Item Reference Unit of Measure" := SalesLineArchive."Unit of Measure (Cross Ref.)";
                SalesLineArchive."Cross-Reference Type" := 0;
                SalesLineArchive."Cross-Reference Type No." := '';
                SalesLineArchive."Unit of Measure (Cross Ref.)" := '';
                if SalesLineArchive."IC Partner Ref. Type" = SalesLineArchive."IC Partner Ref. Type"::"Cross Reference" then
                    SalesLineArchive."IC Item Reference No." := SalesLineArchive."IC Partner Reference";
                SalesLineArchive.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until SalesLineArchive.Next() = 0;
    end;

    local procedure UpgradeSalesShipmentLine()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        SalesShipmentLine.SetRange("Item Reference No.", '');
        SalesShipmentLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if SalesShipmentLine.FindSet() then
            repeat
                SalesShipmentLine."Item Reference No." := SalesShipmentLine."Cross-Reference No.";
                SalesShipmentLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(SalesShipmentLine."Cross-Reference Type");
                SalesShipmentLine."Item Reference Type No." := SalesShipmentLine."Cross-Reference Type No.";
                SalesShipmentLine."Item Reference Unit of Measure" := SalesShipmentLine."Unit of Measure (Cross Ref.)";

                if SalesShipmentLine."IC Partner Ref. Type" = SalesShipmentLine."IC Partner Ref. Type"::"Cross Reference" then
                    SalesShipmentLine."IC Item Reference No." := SalesShipmentLine."IC Partner Reference";
                SalesShipmentLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until SalesShipmentLine.Next() = 0;
    end;

    local procedure UpgradeSalesCrMemoLine()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        SalesCrMemoLine.SetRange("Item Reference No.", '');
        SalesCrMemoLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if SalesCrMemoLine.FindSet() then
            repeat
                SalesCrMemoLine."Item Reference No." := SalesCrMemoLine."Cross-Reference No.";
                SalesCrMemoLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(SalesCrMemoLine."Cross-Reference Type");
                SalesCrMemoLine."Item Reference Type No." := SalesCrMemoLine."Cross-Reference Type No.";
                SalesCrMemoLine."Item Reference Unit of Measure" := SalesCrMemoLine."Unit of Measure (Cross Ref.)";

                if SalesCrMemoLine."IC Partner Ref. Type" = SalesCrMemoLine."IC Partner Ref. Type"::"Cross Reference" then
                    SalesCrMemoLine."IC Item Reference No." := SalesCrMemoLine."IC Partner Reference";
                SalesCrMemoLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure UpgradeSalesInvoiceLine()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        CommitCount: Integer;
    begin
        Commit();
        CommitCount := 0;

        SalesInvoiceLine.SetRange("Item Reference No.", '');
        SalesInvoiceLine.SetFilter("Cross-Reference No.", '<>%1', '');

        if SalesInvoiceLine.FindSet() then
            repeat
                SalesInvoiceLine."Item Reference No." := SalesInvoiceLine."Cross-Reference No.";
                SalesInvoiceLine."Item Reference Type" := ConvertCrossRefTypeToItemRefType(SalesInvoiceLine."Cross-Reference Type");
                SalesInvoiceLine."Item Reference Type No." := SalesInvoiceLine."Cross-Reference Type No.";
                SalesInvoiceLine."Item Reference Unit of Measure" := SalesInvoiceLine."Unit of Measure (Cross Ref.)";

                if SalesInvoiceLine."IC Partner Ref. Type" = SalesInvoiceLine."IC Partner Ref. Type"::"Cross Reference" then
                    SalesInvoiceLine."IC Item Reference No." := SalesInvoiceLine."IC Partner Reference";
                SalesInvoiceLine.Modify();

                CommitCount += 1;
                if CommitCount = GetCommitCount() then begin
                    CommitCount := 0;
                    Commit();
                end;
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure GetCommitCount(): Integer
    begin
        exit(400);
    end;

    local procedure UpdateDateExchFieldMapping()
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetItemCrossReferenceInPEPPOLUpgradeTag()) then
            exit;

        DataExchFieldMapping.SetFilter("Data Exch. Def Code", 'PEPPOLINVOICE|PEPPOLCREDITMEMO');
        DataExchFieldMapping.SetRange("Target Table ID", Database::"Purchase Line");
        DataExchFieldMapping.SetRange("Target Field ID", 5705); // this is the old cross-reference no. field id
        if not DataExchFieldMapping.IsEmpty() then
            DataExchFieldMapping.ModifyAll("Target Field ID", 5725); // this is new Item Reference No. field id

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetItemCrossReferenceInPEPPOLUpgradeTag());
    end;
#endif
}