#pragma warning disable AL0432
codeunit 31250 "Install Application CZA"
{
    Subtype = Install;
    Permissions = tabledata "Inventory Setup" = m,
                  tabledata "Manufacturing Setup" = m,
                  tabledata "Assembly Setup" = m,
                  tabledata "Assembly Header" = m,
                  tabledata "Assembly Line" = m,
                  tabledata "Posted Assembly Header" = m,
                  tabledata "Posted Assembly Line" = m,
                  tabledata "Nonstock Item Setup" = m,
                  tabledata "Item Ledger Entry" = m,
                  tabledata "Value Entry" = m,
                  tabledata "Capacity Ledger Entry" = m,
                  tabledata "Item Journal Line" = m,
                  tabledata "Transfer Route" = m,
                  tabledata "Transfer Header" = m,
                  tabledata "Transfer Line" = m,
                  tabledata "Transfer Shipment Header" = m,
                  tabledata "Transfer Shipment Line" = m,
                  tabledata "Transfer Receipt Header" = m,
                  tabledata "Transfer Receipt Line" = m,
                  tabledata "Detailed G/L Entry CZA" = im,
                  tabledata "G/L Entry" = m,
                  tabledata "Default Dimension" = m;

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
            CopyUsage();
            CopyData();
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
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
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
        CopyDetailedGLEntry();
        CopyGLEntry();
        CopyDefaultDimension();
    end;

    local procedure CopyInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup."Use GPPG from SKU CZA" := InventorySetup."Use GPPG from SKU";
            InventorySetup."Skip Update SKU on Posting CZA" := InventorySetup."Skip Update SKU on Posting";
            InventorySetup."Exact Cost Revers. Mandat. CZA" := InventorySetup."Exact Cost Reversing Mandatory";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure CopyManufacturingSetup();
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        if ManufacturingSetup.Get() then begin
            ManufacturingSetup."Default Gen.Bus.Post. Grp. CZA" := ManufacturingSetup."Default Gen.Bus. Posting Group";
            ManufacturingSetup."Exact Cost Rev.Mand. Cons. CZA" := ManufacturingSetup."Exact Cost Rev.Manda. (Cons.)";
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
        ValueEntry: Record "Value Entry";
    begin
        if ValueEntry.FindSet(true) then
            repeat
                ValueEntry."Invoice-to Source No. CZA" := ValueEntry."Source No. 2";
                ValueEntry."Delivery-to Source No. CZA" := ValueEntry."Source No. 3";
                ValueEntry."Currency Code CZA" := ValueEntry."Currency Code";
                ValueEntry."Currency Factor CZA" := ValueEntry."Currency Factor";
                ValueEntry.Modify(false);
            until ValueEntry.Next() = 0;
    end;

    local procedure CopyCapacityLedgerEntry();
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
    begin
        if CapacityLedgerEntry.FindSet(true) then
            repeat
                CapacityLedgerEntry."User ID CZA" := CapacityLedgerEntry."User ID";
                CapacityLedgerEntry.Modify(false);
            until CapacityLedgerEntry.Next() = 0;
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

    local procedure CopyDetailedGLEntry()
    var
        DetailedGLEntry: Record "Detailed G/L Entry";
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        if DetailedGLEntry.FindSet() then
            repeat
                if not DetailedGLEntryCZA.Get(DetailedGLEntry."Entry No.") then begin
                    DetailedGLEntryCZA.Init();
                    DetailedGLEntryCZA."Entry No." := DetailedGLEntry."Entry No.";
                    DetailedGLEntryCZA.SystemId := DetailedGLEntry.SystemId;
                    DetailedGLEntryCZA.Insert(false, true);
                end;
                DetailedGLEntryCZA."G/L Entry No." := DetailedGLEntry."G/L Entry No.";
                DetailedGLEntryCZA."Applied G/L Entry No." := DetailedGLEntry."Applied G/L Entry No.";
                DetailedGLEntryCZA."G/L Account No." := DetailedGLEntry."G/L Account No.";
                DetailedGLEntryCZA."Posting Date" := DetailedGLEntry."Posting Date";
                DetailedGLEntryCZA."Document No." := DetailedGLEntry."Document No.";
                DetailedGLEntryCZA."Transaction No." := DetailedGLEntry."Transaction No.";
                DetailedGLEntryCZA.Amount := DetailedGLEntry.Amount;
                DetailedGLEntryCZA.Unapplied := DetailedGLEntry.Unapplied;
                DetailedGLEntryCZA."Unapplied by Entry No." := DetailedGLEntry."Unapplied by Entry No.";
                DetailedGLEntryCZA."User ID" := DetailedGLEntry."User ID";
                DetailedGLEntryCZA.Modify(false);
            until DetailedGLEntry.Next() = 0;
    end;

    local procedure CopyGLEntry();
    var
        GLEntry: Record "G/L Entry";
    begin
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."Closed CZA" := GLEntry.Closed;
                GLEntry."Closed at Date CZA" := GLEntry."Closed at Date";
                GLEntry."Applied Amount CZA" := GLEntry."Applied Amount";
                GLEntry.Modify(false);
            until GLEntry.Next() = 0;
    end;

    local procedure CopyDefaultDimension();
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DefaultDimension.FindSet(true) then
            repeat
                if DefaultDimension."Automatic Create" then begin
                    DefaultDimension."Automatic Create CZA" := DefaultDimension."Automatic Create";
                    DefaultDimension."Dim. Description Field ID CZA" := DefaultDimension."Dimension Description Field ID";
                    DefaultDimension."Dim. Description Format CZA" := DefaultDimension."Dimension Description Format";
                    DefaultDimension."Dim. Description Update CZA" := DefaultDimension."Dimension Description Update";
                    case DefaultDimension."Automatic Cr. Value Posting" of
                        DefaultDimension."Automatic Cr. Value Posting"::" ":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::" ";
                        DefaultDimension."Automatic Cr. Value Posting"::"No Code":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"No Code";
                        DefaultDimension."Automatic Cr. Value Posting"::"Same Code":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"Same Code";
                        DefaultDimension."Automatic Cr. Value Posting"::"Code Mandatory":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"Code Mandatory";
                    end;
                    Clear(DefaultDimension."Automatic Create");
                    Clear(DefaultDimension."Dimension Description Field ID");
                    Clear(DefaultDimension."Dimension Description Format");
                    Clear(DefaultDimension."Dimension Description Update");
                    Clear(DefaultDimension."Automatic Cr. Value Posting");
                    DefaultDimension.Modify(false);
                end;
            until DefaultDimension.Next() = 0;
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
