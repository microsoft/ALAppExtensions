#pragma warning disable AL0432
codeunit 31250 "Install Application CZA"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then
            CopyData();

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
        CopyInventorySetup();
        CopyManufacturingSetup();
        CopyAssemblySetup();
        CopyAssemblyHeader();
        CopyAssemblyLine();
        CopyPostedAssemblyHeader();
        CopyPostedAssemblyLine();
        CopyNonstockItemSetup();
        CopyItemLedgerEntry();
        CopyValueEntry();
        CopyCapacityLedgerEntry();
        CopyItemJournalLine();
        CopyTransferRoute();
        CopyTransferHeader();
        CopyTransferLine();
        CopyTransferShipmentHeader();
        CopyTransferShipmentLine();
        CopyTransferReceiptHeader();
        CopyTransferReceiptLine();
    end;

    local procedure CopyInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup."Use GPPG from SKU CZA" := InventorySetup."Use GPPG from SKU";
            InventorySetup."Skip Update SKU on Posting CZA" := InventorySetup."Skip Update SKU on Posting";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure CopyManufacturingSetup();
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        if ManufacturingSetup.Get() then begin
            ManufacturingSetup."Default Gen.Bus.Post. Grp. CZA" := ManufacturingSetup."Default Gen.Bus. Posting Group";
            ManufacturingSetup.Modify(false);
        end;
    end;

    local procedure CopyAssemblySetup();
    var
        AssemblySetup: Record "Assembly Setup";
    begin
        if AssemblySetup.Get() then begin
            AssemblySetup."Default Gen.Bus.Post. Grp. CZA" := AssemblySetup."Gen. Bus. Posting Group";
            AssemblySetup.Modify(false);
        end;
    end;

    local procedure CopyAssemblyHeader();
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        if AssemblyHeader.FindSet(true) then
            repeat
                AssemblyHeader."Gen. Bus. Posting Group CZA" := AssemblyHeader."Gen. Bus. Posting Group";
                AssemblyHeader.Modify(false);
            until AssemblyHeader.Next() = 0;
    end;

    local procedure CopyAssemblyLine();
    var
        AssemblyLine: Record "Assembly Line";
    begin
        if AssemblyLine.FindSet(true) then
            repeat
                AssemblyLine."Gen. Bus. Posting Group CZA" := AssemblyLine."Gen. Bus. Posting Group";
                AssemblyLine.Modify(false);
            until AssemblyLine.Next() = 0;
    end;

    local procedure CopyPostedAssemblyHeader();
    var
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        if PostedAssemblyHeader.FindSet(true) then
            repeat
                PostedAssemblyHeader."Gen. Bus. Posting Group CZA" := PostedAssemblyHeader."Gen. Bus. Posting Group";
                PostedAssemblyHeader.Modify(false);
            until PostedAssemblyHeader.Next() = 0;
    end;

    local procedure CopyPostedAssemblyLine();
    var
        PostedAssemblyLine: Record "Posted Assembly Line";
    begin
        if PostedAssemblyLine.FindSet(true) then
            repeat
                PostedAssemblyLine."Gen. Bus. Posting Group CZA" := PostedAssemblyLine."Gen. Bus. Posting Group";
                PostedAssemblyLine.Modify(false);
            until PostedAssemblyLine.Next() = 0;
    end;

    local procedure CopyNonstockItemSetup();
    var
        NonstockItemSetup: Record "Nonstock Item Setup";
    begin
        if NonstockItemSetup.Get() then begin
            if NonstockItemSetup."No. From No. Series" then
                NonstockItemSetup."No. Format" := NonstockItemSetup."No. Format"::"Item No. Series CZA";
            NonstockItemSetup.Modify(false);
        end;
    end;

    local procedure CopyItemLedgerEntry();
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if ItemLedgerEntry.FindSet(true) then
            repeat
                ItemLedgerEntry."Invoice-to Source No. CZA" := ItemLedgerEntry."Source No. 2";
                ItemLedgerEntry."Delivery-to Source No. CZA" := ItemLedgerEntry."Source No. 3";
                ItemLedgerEntry."Source Code CZA" := ItemLedgerEntry."Source Code";
                ItemLedgerEntry."Reason Code CZA" := ItemLedgerEntry."Reason Code";
                ItemLedgerEntry."Currency Code CZA" := ItemLedgerEntry."Currency Code";
                ItemLedgerEntry."Currency Factor CZA" := ItemLedgerEntry."Currency Factor";
                ItemLedgerEntry.Modify(false);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure CopyValueEntry();
    var
        ItemLedgerEntry: Record "Value Entry";
    begin
        if ItemLedgerEntry.FindSet(true) then
            repeat
                ItemLedgerEntry."Invoice-to Source No. CZA" := ItemLedgerEntry."Source No. 2";
                ItemLedgerEntry."Delivery-to Source No. CZA" := ItemLedgerEntry."Source No. 3";
                ItemLedgerEntry."Currency Code CZA" := ItemLedgerEntry."Currency Code";
                ItemLedgerEntry."Currency Factor CZA" := ItemLedgerEntry."Currency Factor";
                ItemLedgerEntry.Modify(false);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure CopyCapacityLedgerEntry();
    var
        ItemLedgerEntry: Record "Capacity Ledger Entry";
    begin
        if ItemLedgerEntry.FindSet(true) then
            repeat
                ItemLedgerEntry."User ID CZA" := ItemLedgerEntry."User ID";
                ItemLedgerEntry.Modify(false);
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure CopyItemJournalLine();
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        if ItemJournalLine.FindSet(true) then
            repeat
                ItemJournalLine."Delivery-to Source No. CZA" := ItemJournalLine."Source No. 3";
                ItemJournalLine."Currency Code CZA" := ItemJournalLine."Currency Code";
                ItemJournalLine."Currency Factor CZA" := ItemJournalLine."Currency Factor";
                ItemJournalLine.Modify(false);
            until ItemJournalLine.Next() = 0;
    end;

    local procedure CopyTransferRoute();
    var
        TransferRoute: Record "Transfer Route";
    begin
        if TransferRoute.FindSet(true) then
            repeat
                TransferRoute."Gen.Bus.Post.Group Ship CZA" := TransferRoute."Gen. Bus. Post. Group Ship";
                TransferRoute."Gen.Bus.Post.Group Receive CZA" := TransferRoute."Gen. Bus. Post. Group Receive";
                TransferRoute.Modify(false);
            until TransferRoute.Next() = 0;
    end;

    local procedure CopyTransferHeader();
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.FindSet(true) then
            repeat
                TransferHeader."Gen.Bus.Post.Group Ship CZA" := TransferHeader."Gen. Bus. Post. Group Ship";
                TransferHeader."Gen.Bus.Post.Group Receive CZA" := TransferHeader."Gen. Bus. Post. Group Receive";
                TransferHeader.Modify(false);
            until TransferHeader.Next() = 0;
    end;

    local procedure CopyTransferLine();
    var
        TransferLine: Record "Transfer Line";
    begin
        if TransferLine.FindSet(true) then
            repeat
                TransferLine."Gen.Bus.Post.Group Ship CZA" := TransferLine."Gen. Bus. Post. Group Ship";
                TransferLine."Gen.Bus.Post.Group Receive CZA" := TransferLine."Gen. Bus. Post. Group Receive";
                TransferLine.Modify(false);
            until TransferLine.Next() = 0;
    end;

    local procedure CopyTransferShipmentHeader();
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        if TransferShipmentHeader.FindSet(true) then
            repeat
                TransferShipmentHeader."Gen.Bus.Post.Group Ship CZA" := TransferShipmentHeader."Gen. Bus. Post. Group Ship";
                TransferShipmentHeader."Gen.Bus.Post.Group Receive CZA" := TransferShipmentHeader."Gen. Bus. Post. Group Receive";
                TransferShipmentHeader.Modify(false);
            until TransferShipmentHeader.Next() = 0;
    end;

    local procedure CopyTransferShipmentLine();
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        if TransferShipmentLine.FindSet(true) then
            repeat
                TransferShipmentLine."Gen.Bus.Post.Group Ship CZA" := TransferShipmentLine."Gen. Bus. Post. Group Ship";
                TransferShipmentLine."Gen.Bus.Post.Group Receive CZA" := TransferShipmentLine."Gen. Bus. Post. Group Receive";
                TransferShipmentLine.Modify(false);
            until TransferShipmentLine.Next() = 0;
    end;

    local procedure CopyTransferReceiptHeader();
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
    begin
        if TransferReceiptHeader.FindSet(true) then
            repeat
                TransferReceiptHeader."Gen.Bus.Post.Group Ship CZA" := TransferReceiptHeader."Gen. Bus. Post. Group Ship";
                TransferReceiptHeader."Gen.Bus.Post.Group Receive CZA" := TransferReceiptHeader."Gen. Bus. Post. Group Receive";
                TransferReceiptHeader.Modify(false);
            until TransferReceiptHeader.Next() = 0;
    end;

    local procedure CopyTransferReceiptLine();
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        if TransferReceiptLine.FindSet(true) then
            repeat
                TransferReceiptLine."Gen.Bus.Post.Group Ship CZA" := TransferReceiptLine."Gen. Bus. Post. Group Ship";
                TransferReceiptLine."Gen.Bus.Post.Group Receive CZA" := TransferReceiptLine."Gen. Bus. Post. Group Receive";
                TransferReceiptLine.Modify(false);
            until TransferReceiptLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZA: Codeunit "Data Class. Eval. Handler CZA";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        DataClassEvalHandlerCZA.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;
}
