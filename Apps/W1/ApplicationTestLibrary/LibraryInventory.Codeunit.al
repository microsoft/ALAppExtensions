/// <summary>
/// Provides utility functions for creating and managing inventory-related entities in test scenarios, including items, item journals, locations, and inventory postings.
/// </summary>
codeunit 132201 "Library - Inventory"
{

    trigger OnRun()
    begin
    end;

    var
        InventorySetup: Record "Inventory Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        JOURNALTxt: Label ' journal';
        ReserveConfirmMsg: Label 'Do you want to reserve specific tracking numbers?';

    procedure CalculateInventory(ItemJournalLine: Record "Item Journal Line"; var Item: Record Item; PostingDate: Date; ItemsNotOnInvt: Boolean; ItemsWithNoTransactions: Boolean)
    var
        CalculateInventoryReport: Report "Calculate Inventory";
    begin
        Clear(CalculateInventoryReport);
        CalculateInventoryReport.UseRequestPage(false);
        CalculateInventoryReport.SetTableView(Item);
        CalculateInventoryReport.SetItemJnlLine(ItemJournalLine);
        CalculateInventoryReport.InitializeRequest(PostingDate, ItemJournalLine."Document No.", ItemsNotOnInvt, ItemsWithNoTransactions);
        CalculateInventoryReport.Run();
    end;

    procedure CalculateInventoryForSingleItem(ItemJournalLine: Record "Item Journal Line"; ItemNo: Code[20]; PostingDate: Date; ItemsNotOnInvt: Boolean; ItemsWithNoTransactions: Boolean)
    var
        Item: Record Item;
    begin
        Item.SetRange("No.", ItemNo);
        CalculateInventory(ItemJournalLine, Item, PostingDate, ItemsNotOnInvt, ItemsWithNoTransactions);
    end;

    procedure CreateAnalysisColumnTemplate(var AnalysisColumnTemplate: Record "Analysis Column Template"; AnalysisArea: Enum "Analysis Area Type")
    begin
        AnalysisColumnTemplate.Init();
        AnalysisColumnTemplate.Validate("Analysis Area", AnalysisArea);
        AnalysisColumnTemplate.Validate(
          Name, LibraryUtility.GenerateRandomCode(AnalysisColumnTemplate.FieldNo(Name), DATABASE::"Analysis Column Template"));
        AnalysisColumnTemplate.Insert(true);
    end;

    procedure CreateAnalysisColumn(var AnalysisColumn: Record "Analysis Column"; AnalysisArea: Enum "Analysis Area Type"; AnalysisColumnTemplateName: Code[10])
    var
        RecRef: RecordRef;
    begin
        AnalysisColumn.Init();
        AnalysisColumn.Validate("Analysis Area", AnalysisArea);
        AnalysisColumn.Validate("Analysis Column Template", AnalysisColumnTemplateName);
        RecRef.GetTable(AnalysisColumn);
        AnalysisColumn.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, AnalysisColumn.FieldNo("Line No.")));
        AnalysisColumn.Insert(true);
    end;

    procedure CreateBaseCalendarChange(var BaseCalendarChange: Record "Base Calendar Change"; BaseCalendarCode: Code[10]; RecurringSystem: Option; Date: Date; Day: Option)
    begin
        BaseCalendarChange.Init();
        BaseCalendarChange.Validate("Base Calendar Code", BaseCalendarCode);
        BaseCalendarChange.Validate("Recurring System", RecurringSystem);
        BaseCalendarChange.Validate(Date, Date);
        BaseCalendarChange.Validate(Day, Day);
        BaseCalendarChange.Insert(true);
    end;

    procedure CreateBOMComponent(var BOMComponent: Record "BOM Component"; ParentItemNo: Code[20]; Type: Enum "BOM Component Type"; No: Code[20]; QuantityPer: Decimal; UnitOfMeasureCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        BOMComponent.Init();
        BOMComponent.Validate("Parent Item No.", ParentItemNo);
        RecRef.GetTable(BOMComponent);
        BOMComponent.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, BOMComponent.FieldNo("Line No.")));
        BOMComponent.Insert(true);
        BOMComponent.Validate(Type, Type);
        if BOMComponent.Type <> BOMComponent.Type::" " then begin
            BOMComponent.Validate("No.", No);
            BOMComponent.Validate("Quantity per", QuantityPer);
            if UnitOfMeasureCode <> '' then
                BOMComponent.Validate("Unit of Measure Code", UnitOfMeasureCode);
        end;
        BOMComponent.Modify(true);
    end;

    procedure ClearItemJournal(ItemJournalTemplate: Record "Item Journal Template"; ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalLine: Record "Item Journal Line";
        SequenceNoMgt: Codeunit "Sequence No. Mgt.";
    begin
        Clear(ItemJournalLine);
        Clear(SequenceNoMgt);
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.DeleteAll();
    end;

    procedure CreateAnalysisLine(var AnalysisLine: Record "Analysis Line"; AnalysisArea: Enum "Analysis Area Type"; AnalysisLineTemplateName: Code[10])
    var
        RecRef: RecordRef;
    begin
        AnalysisLine.Init();
        AnalysisLine.Validate("Analysis Area", AnalysisArea);
        AnalysisLine.Validate("Analysis Line Template Name", AnalysisLineTemplateName);
        RecRef.GetTable(AnalysisLine);
        AnalysisLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, AnalysisLine.FieldNo("Line No.")));
        AnalysisLine.Insert(true);
    end;

    procedure CreateAnalysisLineTemplate(var AnalysisLineTemplate: Record "Analysis Line Template"; AnalysisArea: Enum "Analysis Area Type")
    begin
        AnalysisLineTemplate.Init();
        AnalysisLineTemplate.Validate("Analysis Area", AnalysisArea);
        AnalysisLineTemplate.Validate(
          Name, LibraryUtility.GenerateRandomCode(AnalysisLineTemplate.FieldNo(Name), DATABASE::"Analysis Line Template"));
        AnalysisLineTemplate.Insert(true);
    end;

    procedure CreateAnalysisReportName(var AnalysisReportName: Record "Analysis Report Name"; AnalysisArea: Enum "Analysis Area Type")
    begin
        AnalysisReportName.Init();
        AnalysisReportName.Validate("Analysis Area", AnalysisArea);
        AnalysisReportName.Validate(
          Name, LibraryUtility.GenerateRandomCode(AnalysisReportName.FieldNo(Name), DATABASE::"Analysis Report Name"));
        AnalysisReportName.Insert(true);
    end;

    procedure CreateAndUpdateTransferRoute(var TransferRoute: Record "Transfer Route"; TransferFrom: Code[10]; TransferTo: Code[10]; InTransitCode: Code[10]; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10])
    begin
        CreateTransferRoute(TransferRoute, TransferFrom, TransferTo);
        TransferRoute.Validate("In-Transit Code", InTransitCode);
        TransferRoute.Validate("Shipping Agent Code", ShippingAgentCode);
        TransferRoute.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);
        TransferRoute.Modify(true);
    end;

    procedure CreateSerialNoInformation(var SerialNoInformation: Record "Serial No. Information"; ItemNo: Code[20]; VariantCode: Code[10]; SerialNo: Code[50])
    begin
        Clear(SerialNoInformation);
        SerialNoInformation.Init();
        SerialNoInformation.Validate("Item No.", ItemNo);
        SerialNoInformation.Validate("Variant Code", VariantCode);
        SerialNoInformation.Validate("Serial No.", SerialNo);
        SerialNoInformation.Insert(true);
    end;

    procedure CreateLotNoInformation(var LotNoInformation: Record "Lot No. Information"; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50])
    begin
        Clear(LotNoInformation);
        LotNoInformation.Init();
        LotNoInformation.Validate("Item No.", ItemNo);
        LotNoInformation.Validate("Variant Code", VariantCode);
        LotNoInformation.Validate("Lot No.", LotNo);
        LotNoInformation.Insert(true);
    end;

    procedure CreateInventoryPostingGroup(var InventoryPostingGroup: Record "Inventory Posting Group")
    begin
        Clear(InventoryPostingGroup);
        InventoryPostingGroup.Init();
        InventoryPostingGroup.Validate(Code,
          LibraryUtility.GenerateRandomCode(InventoryPostingGroup.FieldNo(Code), DATABASE::"Inventory Posting Group"));
        InventoryPostingGroup.Validate(Description, InventoryPostingGroup.Code);
        InventoryPostingGroup.Insert(true);
    end;

    procedure CreateInventoryPeriod(var InventoryPeriod: Record "Inventory Period"; EndingDate: Date)
    begin
        Clear(InventoryPeriod);
        if InventoryPeriod.Get(EndingDate) then
            exit;
        InventoryPeriod.Init();
        InventoryPeriod.Validate("Ending Date", EndingDate);
        InventoryPeriod.Insert(true);
    end;

    procedure CreateInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup"; LocationCode: Text[10]; PostingGroupCode: Text[20])
    begin
        Clear(InventoryPostingSetup);
        InventoryPostingSetup.Init();
        InventoryPostingSetup.Validate("Location Code", LocationCode);
        InventoryPostingSetup.Validate("Invt. Posting Group Code", PostingGroupCode);
        InventoryPostingSetup.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure CreatePhysInvtOrderHeader(var PhysInvtOrderHeader: Record "Phys. Invt. Order Header")
    begin
        PhysInvtOrderHeader.Init();
        PhysInvtOrderHeader.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure CreatePhysInvtOrderLine(var PhysInvtOrderLine: Record "Phys. Invt. Order Line"; CountNo: Code[20]; ItemNo: Code[20])
    begin
        PhysInvtOrderLine.Validate("Document No.", CountNo);
        PhysInvtOrderLine.Validate("Line No.", LibraryUtility.GetNewRecNo(PhysInvtOrderLine, PhysInvtOrderLine.FieldNo("Line No.")));
        PhysInvtOrderLine.Validate("Item No.", ItemNo);
        PhysInvtOrderLine.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure CreatePhysInvtRecordHeader(var PhysInvtRecordHeader: Record "Phys. Invt. Record Header"; CountNo: Code[20])
    begin
        PhysInvtRecordHeader.Validate("Order No.", CountNo);
        PhysInvtRecordHeader.Validate("Recording No.", LibraryUtility.GetNewRecNo(PhysInvtRecordHeader, PhysInvtRecordHeader.FieldNo("Recording No.")));
        PhysInvtRecordHeader.Insert(true);
    end;

    [Scope('OnPrem')]
    procedure CreatePhysInvtRecordLine(var PhysInvtRecordLine: Record "Phys. Invt. Record Line"; PhysInvtOrderLine: Record "Phys. Invt. Order Line"; RecordingNo: Integer; Qty: Decimal)
    begin
        PhysInvtRecordLine.Validate("Order No.", PhysInvtOrderLine."Document No.");
        PhysInvtRecordLine.Validate("Order Line No.", PhysInvtOrderLine."Line No.");
        PhysInvtRecordLine.Validate("Recording No.", RecordingNo);
        PhysInvtRecordLine.Validate("Line No.", LibraryUtility.GetNewRecNo(PhysInvtRecordLine, PhysInvtRecordLine.FieldNo("Line No.")));
        PhysInvtRecordLine.Validate("Item No.", PhysInvtOrderLine."Item No.");
        PhysInvtRecordLine.Validate(Quantity, Qty);
        PhysInvtRecordLine.Validate(Recorded, true);
        PhysInvtRecordLine.Insert(true);
    end;

    procedure CreateItemWithoutVAT(var Item: Record Item)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralPostingSetup: Record "General Posting Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        TaxGroup: Record "Tax Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        ItemNoSeriesSetup(InventorySetup);
        Clear(Item);
        Item.Insert(true);

        CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", '', 1);
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);

        if not InventoryPostingGroup.FindFirst() then
            CreateInventoryPostingGroup(InventoryPostingGroup);

        InventoryPostingSetup.SetRange("Invt. Posting Group Code", InventoryPostingGroup.Code);
        if not InventoryPostingSetup.FindFirst() then
            CreateInventoryPostingSetup(InventoryPostingSetup, '', InventoryPostingGroup.Code);

        Item.Validate(Description, Item."No.");  // Validation Description as No. because value is not important.
        Item.Validate("Base Unit of Measure", ItemUnitOfMeasure.Code);
        Item.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        Item.Validate("Inventory Posting Group", InventoryPostingGroup.Code);

        if TaxGroup.FindFirst() then
            Item.Validate("Tax Group Code", TaxGroup.Code);

        Item.Modify(true);
    end;

    procedure CreateItem(var Item: Record Item): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateItemWithoutVAT(Item);

        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");

        Item.Modify(true);
        OnAfterCreateItem(Item);
        exit(Item."No.");
    end;

    procedure CreateItemNo(): Code[20]
    var
        Item: Record Item;
    begin
        CreateItem(Item);
        exit(Item."No.");
    end;

    procedure CreateItemNoWithoutVAT(): Code[20]
    var
        Item: Record Item;
    begin
        CreateItemWithoutVAT(Item);
        exit(Item."No.");
    end;

    procedure CreateItemWithTariffNo(var Item: Record Item; TariffNo: Code[20])
    begin
        CreateItem(Item);
        Item.Validate("Tariff No.", TariffNo);
        Item.Modify(true);
    end;

    procedure CreateItemWithUnitPriceAndUnitCost(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        CreateItem(Item);
        Item.Validate("Unit Price", UnitPrice);
        Item.Validate("Unit Cost", UnitCost);
        Item.Modify(true);
    end;

    procedure CreateItemWithUnitPriceUnitCostAndPostingGroup(var Item: Record Item; UnitPrice: Decimal; UnitCost: Decimal)
    begin
        CreateItemWithUnitPriceAndUnitCost(Item, UnitPrice, UnitCost);
    end;

    procedure CreateItemWithPostingSetup(var Item: Record Item; GenProdPostingGroup: Code[20]; VATProductPostingGroup: Code[20])
    begin
        CreateItem(Item);
        Item.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        Item.Validate("VAT Prod. Posting Group", VATProductPostingGroup);
        Item.Modify(true);
    end;

    procedure CreateItemNoWithPostingSetup(GenProdPostingGroup: Code[20]; VATProductPostingGroup: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        CreateItemWithPostingSetup(Item, GenProdPostingGroup, VATProductPostingGroup);
        exit(Item."No.");
    end;

    procedure CreateItemNoWithVATProdPostingGroup(VATProdPostGroupCode: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProdPostGroupCode);
        Item.Modify(true);
        exit(Item."No.");
    end;

    procedure CreateItemAttribute(var ItemAttribute: Record "Item Attribute"; AttributeType: Option; UnitOfMeasure: Text[30])
    begin
        Clear(ItemAttribute);
        ItemAttribute.Validate(Name, LibraryUtility.GenerateRandomCode(ItemAttribute.FieldNo(Name), DATABASE::"Item Attribute"));
        ItemAttribute.Validate(Type, AttributeType);
        ItemAttribute.Validate("Unit of Measure", UnitOfMeasure);
        ItemAttribute.Insert(true);
    end;

    procedure CreateItemAttributeWithValue(var ItemAttribute: Record "Item Attribute"; var ItemAttributeValue: Record "Item Attribute Value"; Type: Option Option,Text,"Integer",Decimal; Value: Text[250])
    begin
        CreateItemAttribute(ItemAttribute, Type, '');
        CreateItemAttributeValue(ItemAttributeValue, ItemAttribute.ID, Value);
    end;

    procedure CreateItemAttributeValue(var ItemAttributeValue: Record "Item Attribute Value"; AttributeID: Integer; AttributeValue: Text[250])
    begin
        Clear(ItemAttributeValue);
        ItemAttributeValue.Validate("Attribute ID", AttributeID);
        ItemAttributeValue.Validate(Value, AttributeValue);
        ItemAttributeValue.Insert(true);
    end;

    procedure CreateItemAttributeValueMapping(TableID: Integer; No: Code[20]; AttributeID: Integer; AttributeValueID: Integer)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        ItemAttributeValueMapping.Validate("Table ID", TableID);
        ItemAttributeValueMapping.Validate("No.", No);
        ItemAttributeValueMapping.Validate("Item Attribute ID", AttributeID);
        ItemAttributeValueMapping.Validate("Item Attribute Value ID", AttributeValueID);
        ItemAttributeValueMapping.Insert(true);
    end;

    procedure CreateUpdateItemTranslation(ItemNo: Code[20]; VariantCode: Code[10]; LanguageCode: Code[10]; Description: Text[100]; Description2: Text[50])
    var
        ItemTranslation: Record "Item Translation";
    begin
        if not ItemTranslation.Get(ItemNo, VariantCode, LanguageCode) then begin
            ItemTranslation.Init();
            ItemTranslation.Validate("Item No.", ItemNo);
            ItemTranslation.Validate("Variant Code", VariantCode);
            ItemTranslation.Validate("Language Code", LanguageCode);
            ItemTranslation.Insert(true);
        end;
        ItemTranslation.Validate(Description, Description);
        ItemTranslation.Validate("Description 2", Description2);
        ItemTranslation.Modify(true);
    end;

    procedure CreateItemWithVATProdPostingGroup(VATProdPostingGroup: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.Modify(true);
        exit(Item."No.");
    end;

    procedure CreateItemBudgetEntry(var ItemBudgetEntry: Record "Item Budget Entry"; AnalysisArea: Enum "Analysis Area Type"; BudgetName: Code[10]; Date: Date; ItemNo: Code[20])
    begin
        Clear(ItemBudgetEntry);
        ItemBudgetEntry.Validate("Analysis Area", AnalysisArea);
        ItemBudgetEntry.Validate("Budget Name", BudgetName);
        ItemBudgetEntry.Validate(Date, Date);
        ItemBudgetEntry.Validate("Item No.", ItemNo);
        ItemBudgetEntry.Insert(true);
    end;

    procedure CreateItemCategory(var ItemCategory: Record "Item Category")
    begin
        ItemCategory.Init();
        ItemCategory.Validate(Code, LibraryUtility.GenerateRandomCode(ItemCategory.FieldNo(Code), DATABASE::"Item Category"));
        ItemCategory.Insert(true);
    end;

    procedure CreateInvtDocument(var InvtDocumentHeader: Record "Invt. Document Header"; DocumentType: Enum "Invt. Doc. Document Type"; LocationCode: Code[10])
    begin
        InvtDocumentHeader.Init();
        InvtDocumentHeader."Document Type" := DocumentType;
        InvtDocumentHeader.Insert(true);
        InvtDocumentHeader.Validate("Location Code", LocationCode);
        InvtDocumentHeader.Modify();
    end;

    procedure CreateInvtDocumentLine(var InvtDocumentHeader: Record "Invt. Document Header"; var InvtDocumentLine: Record "Invt. Document Line"; ItemNo: Code[20]; UnitCost: Decimal; Quantity: Decimal)
    var
        RecRef: RecordRef;
    begin
        InvtDocumentLine.Init();
        InvtDocumentLine.Validate("Document Type", InvtDocumentHeader."Document Type");
        InvtDocumentLine.Validate("Document No.", InvtDocumentHeader."No.");
        RecRef.GetTable(InvtDocumentLine);
        InvtDocumentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, InvtDocumentLine.FieldNo("Line No.")));
        InvtDocumentLine.Insert(true);
        InvtDocumentLine.Validate("Item No.", ItemNo);
        InvtDocumentLine.Validate("Unit Cost", UnitCost);
        InvtDocumentLine.Validate(Quantity, Quantity);
        InvtDocumentLine.Modify(true);
    end;

    procedure PostInvtDocument(InvtDocumentHeader: Record "Invt. Document Header")
    var
        InvtDocPostReceipt: Codeunit "Invt. Doc.-Post Receipt";
        InvtDocPostShipment: Codeunit "Invt. Doc.-Post Shipment";
    begin
        case InvtDocumentHeader."Document Type" of
            InvtDocumentHeader."Document Type"::Receipt:
                InvtDocPostReceipt.Run(InvtDocumentHeader);
            InvtDocumentHeader."Document Type"::Shipment:
                InvtDocPostShipment.Run(InvtDocumentHeader);
        end;
    end;

    procedure CreateItemChargeWithoutVAT(var ItemCharge: Record "Item Charge")
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        Clear(ItemCharge);
        ItemCharge.Init();
        ItemCharge.Validate("No.", LibraryUtility.GenerateRandomCode(ItemCharge.FieldNo("No."), DATABASE::"Item Charge"));
        ItemCharge.Insert(true);

        LibraryERM.FindGeneralPostingSetupInvtBase(GeneralPostingSetup);

        ItemCharge.Validate(Description, ItemCharge."No.");  // Validation Description as No. because value is not important.
        ItemCharge.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        ItemCharge.Modify(true);
    end;

    procedure CreateItemCharge(var ItemCharge: Record "Item Charge")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateItemChargeWithoutVAT(ItemCharge);

        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        ItemCharge.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        ItemCharge.Modify(true);
    end;

    procedure CreateItemChargeNo(): Code[20]
    var
        ItemCharge: Record "Item Charge";
    begin
        CreateItemCharge(ItemCharge);
        exit(ItemCharge."No.")
    end;

    procedure CreateItemChargeNoWithoutVAT(): Code[20]
    var
        ItemCharge: Record "Item Charge";
    begin
        CreateItemChargeWithoutVAT(ItemCharge);
        exit(ItemCharge."No.");
    end;

    procedure CreateItemChargeAssignment(var ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)"; SalesLine: Record "Sales Line"; DocType: Enum "Sales Document Type"; DocNo: Code[20]; DocLineNo: Integer; ItemNo: Code[20])
    var
        ItemChargeAssgntSales: Codeunit "Item Charge Assgnt. (Sales)";
        RecRef: RecordRef;
        LineNo: Integer;
    begin
        ItemChargeAssignmentSales.Init();

        ItemChargeAssignmentSales."Document Type" := SalesLine."Document Type";
        ItemChargeAssignmentSales."Document No." := SalesLine."Document No.";
        ItemChargeAssignmentSales."Document Line No." := SalesLine."Line No.";
        ItemChargeAssignmentSales."Item Charge No." := SalesLine."No.";
        ItemChargeAssignmentSales."Unit Cost" := SalesLine."Unit Cost";

        RecRef.GetTable(ItemChargeAssignmentSales);
        LineNo := LibraryUtility.GetNewLineNo(RecRef, ItemChargeAssignmentSales.FieldNo("Line No."));
        ItemChargeAssgntSales.InsertItemChargeAssignment(ItemChargeAssignmentSales, DocType,
          DocNo, DocLineNo, ItemNo, '', LineNo);

        ItemChargeAssignmentSales.Get(SalesLine."Document Type", SalesLine."Document No.",
          SalesLine."Line No.", LineNo);
        ItemChargeAssignmentSales.Validate("Qty. to Assign", SalesLine.Quantity);
        ItemChargeAssignmentSales.Modify(true);
    end;

    procedure CreateItemChargeAssignPurchase(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; PurchaseLine: Record "Purchase Line"; DocType: Enum "Purchase Document Type"; DocNo: Code[20]; DocLineNo: Integer; ItemNo: Code[20])
    var
        ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        RecRef: RecordRef;
        LineNo: Integer;
    begin
        ItemChargeAssignmentPurch.Init();

        ItemChargeAssignmentPurch."Document Type" := PurchaseLine."Document Type";
        ItemChargeAssignmentPurch."Document No." := PurchaseLine."Document No.";
        ItemChargeAssignmentPurch."Document Line No." := PurchaseLine."Line No.";
        ItemChargeAssignmentPurch."Item Charge No." := PurchaseLine."No.";
        ItemChargeAssignmentPurch."Unit Cost" := PurchaseLine."Unit Cost";

        RecRef.GetTable(ItemChargeAssignmentPurch);
        LineNo := LibraryUtility.GetNewLineNo(RecRef, ItemChargeAssignmentPurch.FieldNo("Line No."));
        ItemChargeAssgntPurch.InsertItemChargeAssignment(
            ItemChargeAssignmentPurch, DocType, DocNo, DocLineNo, ItemNo, '', LineNo);

        ItemChargeAssignmentPurch.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.", LineNo);
        ItemChargeAssignmentPurch.Validate("Qty. to Assign", PurchaseLine.Quantity);
        ItemChargeAssignmentPurch.Modify(true);
    end;

#if not CLEAN26
    [Obsolete('Moved to codeunit Library Manufacturing', '26.0')]
    procedure CreateItemJournal(var ItemJournalBatch: Record "Item Journal Batch"; ItemNo: Code[20]; ItemJournalTemplateType: Enum "Item Journal Template Type"; ProductionOrderNo: Code[20])
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.CreateProdItemJournal(ItemJournalBatch, ItemNo, ItemJournalTemplateType, ProductionOrderNo);
    end;
#endif

    procedure CreateItemJournalTemplate(var ItemJournalTemplate: Record "Item Journal Template")
    begin
        ItemJournalTemplate.Init();
        ItemJournalTemplate.Validate(
          Name,
          CopyStr(
            LibraryUtility.GenerateRandomCode(ItemJournalTemplate.FieldNo(Name), DATABASE::"Item Journal Template"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Item Journal Template", ItemJournalTemplate.FieldNo(Name))));
        ItemJournalTemplate.Validate(Description, ItemJournalTemplate.Name);
        // Validating Name as Description because value is not important.
        ItemJournalTemplate.Insert(true);
    end;

    procedure CreateItemJournalTemplateByType(var ItemJournalTemplate: Record "Item Journal Template"; TemplateType: Enum "Item Journal Template Type")
    begin
        CreateItemJournalTemplate(ItemJournalTemplate);
        ItemJournalTemplate.Validate(Type, TemplateType);
        ItemJournalTemplate.Modify(true);
    end;

    procedure CreateItemJournalBatch(var ItemJournalBatch: Record "Item Journal Batch"; ItemJournalTemplateName: Code[10])
    begin
        // Create Item Journal Batch with a random Name of String length less than 10.
        ItemJournalBatch.Init();
        ItemJournalBatch.Validate("Journal Template Name", ItemJournalTemplateName);
        ItemJournalBatch.Validate(
          Name, CopyStr(LibraryUtility.GenerateRandomCode(ItemJournalBatch.FieldNo(Name), DATABASE::"Item Journal Batch"), 1,
            MaxStrLen(ItemJournalBatch.Name)));
        ItemJournalBatch.Insert(true);
    end;

    procedure CreateItemJournalBatchByType(var ItemJournalBatch: Record "Item Journal Batch"; TemplateType: Enum "Item Journal Template Type")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        Clear(ItemJournalBatch);
        SelectItemJournalTemplateName(ItemJournalTemplate, TemplateType);
        ItemJournalBatch."Journal Template Name" := ItemJournalTemplate.Name;
        ItemJournalBatch.Name := LibraryUtility.GenerateRandomCode(ItemJournalBatch.FieldNo(Name), DATABASE::"Item Journal Batch");
        ItemJournalBatch.Insert(true);
    end;

    procedure CreateItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; EntryType: Enum "Item Ledger Entry Type"; ItemNo: Text[20]; NewQuantity: Decimal)
    var
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        if not ItemJournalBatch.Get(JournalTemplateName, JournalBatchName) then begin
            ItemJournalBatch.Init();
            ItemJournalBatch.Validate("Journal Template Name", JournalTemplateName);
            ItemJournalBatch.SetupNewBatch();
            ItemJournalBatch.Validate(Name, JournalBatchName);
            ItemJournalBatch.Validate(Description, JournalBatchName + JOURNALTxt);
            ItemJournalBatch.Insert(true);
        end;
        CreateItemJnlLineWithNoItem(ItemJournalLine, ItemJournalBatch, JournalTemplateName, JournalBatchName, EntryType);
        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Validate(Quantity, NewQuantity);
        ItemJournalLine.Modify(true);
    end;

    procedure CreateItemJournalLineInItemTemplate(var ItemJournalLine: Record "Item Journal Line"; ItemNo: Code[20]; LocationCode: Code[10]; BinCode: Code[20]; Qty: Decimal)
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type::Item, ItemJournalTemplate.Name);
        CreateItemJournalLine(
          ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name, ItemJournalLine."Entry Type"::"Positive Adjmt.", ItemNo, Qty);
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Validate("Bin Code", BinCode);
        ItemJournalLine.Modify(true);
    end;

    procedure CreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; EntryType: Enum "Item Ledger Entry Type"; PostingDate: Date; ItemNo: Code[20]; Qty: Decimal; LocationCode: Code[10])
    var
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
    begin
        FindItemJournalTemplate(ItemJnlTemplate);
        FindItemJournalBatch(ItemJnlBatch, ItemJnlTemplate);
        CreateItemJournalLine(ItemJnlLine, ItemJnlTemplate.Name, ItemJnlBatch.Name, EntryType, ItemNo, Qty);
        ItemJnlLine."Posting Date" := PostingDate;
        ItemJnlLine."Location Code" := LocationCode;
        ItemJnlLine.Modify();
    end;

    procedure CreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; EntryType: Enum "Item Ledger Entry Type"; PostingDate: Date; ItemNo: Code[20]; Qty: Decimal; LocationCode: Code[10]; NewDocNo: Code[20])
    begin
        CreateItemJnlLine(ItemJnlLine, EntryType, PostingDate, ItemNo, Qty, LocationCode);
        ItemJnlLine."Document No." := NewDocNo;
        ItemJnlLine.Modify();
    end;

    procedure CreateItemJnlLineWithNoItem(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; EntryType: Enum "Item Ledger Entry Type")
    var
        NoSeries: Record "No. Series";
        NoSeriesCodeunit: Codeunit "No. Series";
        RecRef: RecordRef;
        DocumentNo: Code[20];
    begin
        Clear(ItemJournalLine);
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", JournalTemplateName);
        ItemJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(ItemJournalLine);
        ItemJournalLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ItemJournalLine.FieldNo("Line No.")));
        ItemJournalLine.Insert(true);
        ItemJournalLine.Validate("Posting Date", WorkDate());
        ItemJournalLine.Validate("Entry Type", EntryType);
        if NoSeries.Get(ItemJournalBatch."No. Series") then
            DocumentNo := NoSeriesCodeunit.PeekNextNo(ItemJournalBatch."No. Series", ItemJournalLine."Posting Date")
        else
            DocumentNo := LibraryUtility.GenerateRandomCode(ItemJournalLine.FieldNo("Document No."), DATABASE::"Item Journal Line");
        ItemJournalLine.Validate("Document No.", DocumentNo);
        ItemJournalLine.Modify(true);

        OnAfterCreateItemJnlLineWithNoItem(ItemJournalLine, ItemJournalBatch, JournalTemplateName, JournalBatchName, EntryType.AsInteger());
    end;

    procedure CreateItemManufacturing(var Item: Record Item): Code[20]
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        GeneralPostingSetup: Record "General Posting Setup";
        InventoryPostingGroup: Record "Inventory Posting Group";
        TaxGroup: Record "Tax Group";
        VATPostingSetup: Record "VAT Posting Setup";
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        ItemNoSeriesSetup(InventorySetup);
        Clear(Item);
        Item.Insert(true);

        CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", '', 1);

        LibraryERM.FindGeneralPostingSetupInvtToGL(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        InventoryPostingGroup.FindFirst();

        InventoryPostingSetup.SetRange("Invt. Posting Group Code", InventoryPostingGroup.Code);
        if not InventoryPostingSetup.FindFirst() then
            CreateInventoryPostingSetup(InventoryPostingSetup, '', InventoryPostingGroup.Code);

        Item.Validate(Description, Item."No.");  // Validation Description as No. because value is not important.
        Item.Validate("Base Unit of Measure", ItemUnitOfMeasure.Code);
        Item.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Inventory Posting Group", InventoryPostingGroup.Code);

        if TaxGroup.FindFirst() then
            Item.Validate("Tax Group Code", TaxGroup.Code);

        Item.Modify(true);
        OnAfterCreateItemManufacturing(Item);
        exit(Item."No.");
    end;

    procedure CreateItemTrackingCode(var ItemTrackingCode: Record "Item Tracking Code")
    begin
        ItemTrackingCode.Init();
        ItemTrackingCode.Validate(Code, LibraryUtility.GenerateRandomCode(ItemTrackingCode.FieldNo(Code), DATABASE::"Item Tracking Code"));
        ItemTrackingCode.Insert(true);
    end;

    procedure CreateItemUnitOfMeasure(var ItemUnitOfMeasure: Record "Item Unit of Measure"; ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; QtyPerUoM: Decimal)
    begin
        CreateItemUnitOfMeasure(ItemUnitOfMeasure, ItemNo, UnitOfMeasureCode, QtyPerUoM, 0);
    end;

    procedure CreateItemUnitOfMeasure(var ItemUnitOfMeasure: Record "Item Unit of Measure"; ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; QtyPerUoM: Decimal; QtyRndPrecision: Decimal)
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure.Validate("Item No.", ItemNo);

        // The IF condition is important because it grants flexibility to the function.
        if UnitOfMeasureCode = '' then begin
            UnitOfMeasure.SetFilter(Code, '<>%1', UnitOfMeasureCode);
            if not UnitOfMeasure.FindFirst() then
                CreateUnitOfMeasureCode(UnitOfMeasure);
            ItemUnitOfMeasure.Validate(Code, UnitOfMeasure.Code);
        end else
            ItemUnitOfMeasure.Validate(Code, UnitOfMeasureCode);
        if QtyPerUoM = 0 then
            QtyPerUoM := 1;
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPerUoM);

        if QtyRndPrecision <> 0 then
            ItemUnitOfMeasure.Validate("Qty. Rounding Precision", QtyRndPrecision);
        ItemUnitOfMeasure.Insert(true);
    end;

    procedure CreateItemUnitOfMeasureCode(var ItemUnitOfMeasure: Record "Item Unit of Measure"; ItemNo: Code[20]; QtyPerUoM: Decimal)
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        CreateUnitOfMeasureCode(UnitOfMeasure);
        CreateItemUnitOfMeasure(ItemUnitOfMeasure, ItemNo, UnitOfMeasure.Code, QtyPerUoM);
    end;

    procedure CreateItemVariant(var ItemVariant: Record "Item Variant"; ItemNo: Code[20]): Code[10]
    var
        Handled: Boolean;
    begin
        OnBeforeCreateItemVariant(ItemVariant, ItemNo, Handled);
        if Handled then
            exit(ItemVariant.Code);

        ItemVariant.Init();
        ItemVariant.Validate("Item No.", ItemNo);
        ItemVariant.Validate(Code, LibraryUtility.GenerateRandomCode(ItemVariant.FieldNo(Code), DATABASE::"Item Variant"));
        ItemVariant.Validate(Description, ItemVariant.Code);
        ItemVariant.Insert(true);
        OnAfterCreateItemVariant(ItemVariant, ItemNo);

        exit(ItemVariant.Code)
    end;

    procedure CreateItemVendor(var ItemVendor: Record "Item Vendor"; VendorNo: Code[20]; ItemNo: Code[20])
    begin
        ItemVendor.Init();
        ItemVendor.Validate("Vendor No.", VendorNo);
        ItemVendor.Validate("Item No.", ItemNo);
        ItemVendor.Insert(true);
    end;

    procedure CreateNonStock(var NonstockItem: Record "Nonstock Item")
    begin
        NonstockItem.Init();
        NonstockItem.Validate(
          "Entry No.", LibraryUtility.GenerateRandomCode(NonstockItem.FieldNo("Entry No."), DATABASE::"Nonstock Item"));
        NonstockItem.Insert(true);
    end;

    procedure CreateNonStockItem(var NonstockItem: Record "Nonstock Item")
    var
        ItemCategory: Record "Item Category";
        ItemTemplate: Record "Item Templ.";
        UnitOfMeasure: Record "Unit of Measure";
        CatalogItemManagement: Codeunit "Catalog Item Management";
    begin
        ItemCategory.FindFirst();
        CreateUnitOfMeasureCode(UnitOfMeasure);
        ItemTemplate.FindFirst();

        CreateNonStock(NonstockItem);
        NonstockItem.Validate("Vendor No.", LibraryPurchase.CreateVendorNo());
        NonstockItem.Validate(
          "Vendor Item No.", LibraryUtility.GenerateRandomCode(NonstockItem.FieldNo("Vendor Item No."), DATABASE::"Nonstock Item"));
        NonstockItem.Validate("Item Templ. Code", ItemTemplate.Code);
        NonstockItem.Validate("Unit of Measure", UnitOfMeasure.Code);
        NonstockItem.Validate(Description, NonstockItem."Entry No.");
        NonstockItem.Modify(true);
        CatalogItemManagement.NonstockAutoItem(NonstockItem);
    end;

    procedure CreateNonStockItemWithItemTemplateCode(var NonstockItem: Record "Nonstock Item"; ItemTemplateCode: Code[20])
    var
        ItemCategory: Record "Item Category";
        UnitOfMeasure: Record "Unit of Measure";
        CatalogItemManagement: Codeunit "Catalog Item Management";
    begin
        ItemCategory.FindFirst();
        CreateUnitOfMeasureCode(UnitOfMeasure);

        CreateNonStock(NonstockItem);
        NonstockItem.Validate("Vendor No.", LibraryPurchase.CreateVendorNo());
        NonstockItem.Validate(
          "Vendor Item No.", LibraryUtility.GenerateRandomCode(NonstockItem.FieldNo("Vendor Item No."), DATABASE::"Nonstock Item"));
        NonstockItem.Validate("Item Templ. Code", ItemTemplateCode);
        NonstockItem.Validate("Unit of Measure", UnitOfMeasure.Code);
        NonstockItem.Validate(Description, NonstockItem."Entry No.");
        NonstockItem.Modify(true);
        CatalogItemManagement.NonstockAutoItem(NonstockItem);
    end;

    procedure CreateServiceTypeItem(var Item: Record Item)
    begin
        CreateItem(Item);
        Item.Validate(Type, Item.Type::Service);
        Item.Modify(true);
    end;

    procedure CreateNonInventoryTypeItem(var Item: Record Item)
    begin
        CreateItem(Item);
        Item.Validate(Type, Item.Type::"Non-Inventory");
        Item.Modify(true);
    end;

    procedure CreateStockKeepingUnit(var Item: Record Item; CreationMethod: Enum "SKU Creation Method"; NewItemInInventoryOnly: Boolean; NewReplacePreviousSKUs: Boolean)
    var
        TmpItem: Record Item;
        CreateStockkeepingUnitReport: Report "Create Stockkeeping Unit";
    begin
        CreateStockkeepingUnitReport.SetParameters(CreationMethod, NewItemInInventoryOnly, NewReplacePreviousSKUs);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;

        CreateStockkeepingUnitReport.SetTableView(TmpItem);
        CreateStockkeepingUnitReport.UseRequestPage(false);
        CreateStockkeepingUnitReport.Run();
    end;

    procedure CreateStockkeepingUnitForLocationAndVariant(var StockkeepingUnit: Record "Stockkeeping Unit"; LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10])
    begin
        StockkeepingUnit.Init();
        StockkeepingUnit.Validate("Location Code", LocationCode);
        StockkeepingUnit.Validate("Item No.", ItemNo);
        StockkeepingUnit.Validate("Variant Code", VariantCode);
        StockkeepingUnit.Insert(true);
    end;

    procedure CreateShippingAgent(var ShippingAgent: Record "Shipping Agent")
    begin
        ShippingAgent.Init();
        ShippingAgent.Validate(Code, LibraryUtility.GenerateRandomCode(ShippingAgent.FieldNo(Code), DATABASE::"Shipping Agent"));
        ShippingAgent.Insert(true);
    end;

    procedure CreateShippingAgentService(var ShippingAgentServices: Record "Shipping Agent Services"; ShippingAgentCode: Code[10]; ShippingTime: DateFormula)
    begin
        ShippingAgentServices.Init();
        ShippingAgentServices.Validate("Shipping Agent Code", ShippingAgentCode);
        ShippingAgentServices.Validate(
          Code, LibraryUtility.GenerateRandomCode(ShippingAgentServices.FieldNo(Code), DATABASE::"Shipping Agent Services"));
        ShippingAgentServices.Insert(true);
        ShippingAgentServices.Validate("Shipping Time", ShippingTime);
        ShippingAgentServices.Modify(true);
    end;

    procedure CreateShippingAgentServiceUsingPages(ShippingAgentCode: Code[10]) ShippingAgentServiceCode: Code[10]
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        ShippingTime: DateFormula;
        ShippingAgents: TestPage "Shipping Agents";
        ShippingAgentServicesPage: TestPage "Shipping Agent Services";
    begin
        ShippingAgents.OpenEdit();
        ShippingAgents.GotoKey(ShippingAgentCode);

        ShippingAgentServicesPage.Trap();
        ShippingAgents.ShippingAgentServices.Invoke();

        ShippingAgentServiceCode :=
          LibraryUtility.GenerateRandomCode(ShippingAgentServices.FieldNo(Code), DATABASE::"Shipping Agent Services");
        Evaluate(ShippingTime, '<1M>');

        ShippingAgentServicesPage.New();
        ShippingAgentServicesPage.Code.SetValue(ShippingAgentServiceCode);
        ShippingAgentServicesPage."Shipping Time".SetValue(ShippingTime);

        ShippingAgentServicesPage.Close();
    end;

    procedure CreateStandardCostWorksheetName(var StandardCostWorksheetName: Record "Standard Cost Worksheet Name")
    begin
        StandardCostWorksheetName.Init();
        StandardCostWorksheetName.Validate(
          Name, LibraryUtility.GenerateRandomCode(StandardCostWorksheetName.FieldNo(Name), DATABASE::"Standard Cost Worksheet Name"));
        StandardCostWorksheetName.Insert(true);
    end;

    procedure CreateTrackedItem(var Item: Record Item; LotNos: Code[20]; SerialNos: Code[20]; ItemTrackingCode: Code[10])
    begin
        CreateItem(Item);
        Item.Validate("Item Tracking Code", ItemTrackingCode);
        Item.Validate("Serial Nos.", SerialNos);
        Item.Validate("Lot Nos.", LotNos);
        Item.Modify(true);
    end;

    procedure CreateTransferHeader(var TransferHeader: Record "Transfer Header")
    var
        Location: Record Location;
        FromLocationCode, ToLocationCode, InTransitLocationCode : Text[10];
    begin
        FromLocationCode := LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        ToLocationCode := LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        LibraryWarehouse.CreateInTransitLocation(Location);
        InTransitLocationCode := Location.Code;

        CreateTransferHeader(TransferHeader, FromLocationCode, ToLocationCode, InTransitLocationCode);
    end;

    procedure CreateTransferHeader(var TransferHeader: Record "Transfer Header"; FromLocation: Text[10]; ToLocation: Text[10]; InTransitCode: Text[10])
    var
        Handled: Boolean;
    begin
        OnBeforeCreateTransferHeader(TransferHeader, FromLocation, ToLocation, InTransitCode, Handled);
        if Handled then
            exit;

        Clear(TransferHeader);
        TransferHeader.Init();
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", FromLocation);
        TransferHeader.Validate("Transfer-to Code", ToLocation);
        TransferHeader.Validate("In-Transit Code", InTransitCode);
        TransferHeader.Modify(true);

        OnAfterCreateTransferHeader(TransferHeader, FromLocation, ToLocation, InTransitCode);
    end;

    procedure CreateTransferLine(var TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; ItemNo: Text[20]; Quantity: Decimal)
    var
        RecRef: RecordRef;
    begin
        Clear(TransferLine);
        TransferLine.Init();
        TransferLine.Validate("Document No.", TransferHeader."No.");
        RecRef.GetTable(TransferLine);
        TransferLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, TransferLine.FieldNo("Line No.")));
        TransferLine.Insert(true);
        TransferLine.Validate("Item No.", ItemNo);
        TransferLine.Validate(Quantity, Quantity);
        TransferLine.Modify(true);
    end;

    procedure CreateTransferOrder(var TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; Item: Record Item; FromLocation: Record Location; ToLocation: Record Location; InTransitLocation: Record Location; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; ShipmentDate: Date)
    begin
        CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, InTransitLocation.Code);
        TransferHeader.Validate("Posting Date", PostingDate);
        TransferHeader.Validate("Shipment Date", ShipmentDate);
        TransferHeader.Modify();
        CreateTransferLine(TransferHeader, TransferLine, Item."No.", Qty);
        TransferLine.Validate("Shipment Date", ShipmentDate);
        TransferLine.Validate("Variant Code", VariantCode);
        TransferLine.Modify();
    end;

    procedure CreateTransferRoute(var TransferRoute: Record "Transfer Route"; TransferFrom: Code[10]; TransferTo: Code[10])
    begin
        Clear(TransferRoute);
        TransferRoute.Init();
        TransferRoute.Validate("Transfer-from Code", TransferFrom);
        TransferRoute.Validate("Transfer-to Code", TransferTo);
        TransferRoute.Insert(true);
    end;

    procedure CreateAndPostTransferOrder(var TransferHeader: Record "Transfer Header"; Item: Record Item; FromLocation: Record Location; ToLocation: Record Location; InTransitLocation: Record Location; VariantCode: Code[10]; Qty: Decimal; PostingDate: Date; ShipmentDate: Date; Ship: Boolean; Receive: Boolean)
    var
        TransferLine: Record "Transfer Line";
    begin
        CreateTransferOrder(
          TransferHeader, TransferLine, Item, FromLocation, ToLocation, InTransitLocation, VariantCode, Qty, PostingDate, ShipmentDate);
        PostTransferHeader(TransferHeader, Ship, Receive);
    end;

    procedure CreateUnitOfMeasureCode(var UnitOfMeasure: Record "Unit of Measure")
    begin
        UnitOfMeasure.Init();
        UnitOfMeasure.Validate(Code, LibraryUtility.GenerateRandomCode(UnitOfMeasure.FieldNo(Code), DATABASE::"Unit of Measure"));
        UnitOfMeasure.Validate(Description, UnitOfMeasure.Code);
        UnitOfMeasure.Validate("International Standard Code",
          LibraryUtility.GenerateRandomCode(UnitOfMeasure.FieldNo("International Standard Code"), DATABASE::"Unit of Measure"));
        UnitOfMeasure.Validate(Symbol,
          LibraryUtility.GenerateRandomCode(UnitOfMeasure.FieldNo(Symbol), DATABASE::"Unit of Measure"));
        UnitOfMeasure.Insert(true);
    end;

    procedure CreateVariant(var ItemVariant: Record "Item Variant"; Item: Record Item)
    var
        Handled: Boolean;
    begin
        OnBeforeCreateVariant(ItemVariant, Item, Handled);
        if Handled then
            exit;

        Clear(ItemVariant);
        ItemVariant.Init();
        ItemVariant.Validate("Item No.", Item."No.");
        ItemVariant.Validate(Code, LibraryUtility.GenerateRandomCode(ItemVariant.FieldNo(Code), DATABASE::"Item Variant"));
        ItemVariant.Validate(Description, ItemVariant.Code);
        ItemVariant.Insert();

        OnAfterCreateVariant(ItemVariant, Item);
    end;

    procedure CreatePhysicalInventoryCountingPeriod(var PhysInvtCountingPeriod: Record "Phys. Invt. Counting Period")
    begin
        Clear(PhysInvtCountingPeriod);
        PhysInvtCountingPeriod.Init();
        PhysInvtCountingPeriod.Validate(
          Code, LibraryUtility.GenerateRandomCode(PhysInvtCountingPeriod.FieldNo(Code), DATABASE::"Phys. Invt. Counting Period"));
        PhysInvtCountingPeriod.Insert(true);
    end;

    procedure CreatePaymentTerms(var PaymentTerms: Record "Payment Terms")
    begin
        PaymentTerms.Init();
        PaymentTerms.Validate(Code, LibraryUtility.GenerateRandomCode(PaymentTerms.FieldNo(Code), DATABASE::"Payment Terms"));
        PaymentTerms.Validate(Description, PaymentTerms.Code);
        PaymentTerms.Insert(true);
    end;

    procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method")
    begin
        PaymentMethod.Init();
        PaymentMethod.Validate(Code, LibraryUtility.GenerateRandomCode(PaymentMethod.FieldNo(Code), DATABASE::"Payment Method"));
        PaymentMethod.Validate(Description, PaymentMethod.Code);
        PaymentMethod.Insert(true);
    end;

    procedure CreateExtendedTextForItem(ItemNo: Code[20]): Text
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
    begin
        CreateExtendedTextHeaderItem(ExtendedTextHeader, ItemNo);
        CreateExtendedTextLineItem(ExtendedTextLine, ExtendedTextHeader);
        ExtendedTextLine.Validate(Text, LibraryUtility.GenerateGUID());
        ExtendedTextLine.Modify();
        exit(ExtendedTextLine.Text);
    end;

    procedure CreateExtendedTextHeaderItem(var ExtendedTextHeader: Record "Extended Text Header"; ItemNo: Code[20])
    begin
        ExtendedTextHeader.Init();
        ExtendedTextHeader.Validate("Table Name", ExtendedTextHeader."Table Name"::Item);
        ExtendedTextHeader.Validate("No.", ItemNo);
        ExtendedTextHeader.Insert(true);
    end;

    procedure CreateExtendedTextLineItem(var ExtendedTextLine: Record "Extended Text Line"; ExtendedTextHeader: Record "Extended Text Header")
    var
        RecRef: RecordRef;
    begin
        ExtendedTextLine.Init();
        ExtendedTextLine.Validate("Table Name", ExtendedTextHeader."Table Name");
        ExtendedTextLine.Validate("No.", ExtendedTextHeader."No.");
        ExtendedTextLine.Validate("Language Code", ExtendedTextHeader."Language Code");
        ExtendedTextLine.Validate("Text No.", ExtendedTextHeader."Text No.");
        RecRef.GetTable(ExtendedTextLine);
        ExtendedTextLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ExtendedTextLine.FieldNo("Line No.")));
        ExtendedTextLine.Insert(true);
    end;

    procedure CopyItemAttributeToFilterItemAttributesBuffer(var TempFilterItemAttributesBuffer: Record "Filter Item Attributes Buffer" temporary; ItemAttributeValue: Record "Item Attribute Value")
    begin
        ItemAttributeValue.CalcFields("Attribute Name");
        TempFilterItemAttributesBuffer.Init();
        TempFilterItemAttributesBuffer.Attribute := ItemAttributeValue."Attribute Name";
        TempFilterItemAttributesBuffer.Value := ItemAttributeValue.Value;
        TempFilterItemAttributesBuffer.Insert();
    end;

    procedure CalculateCountingPeriod(var ItemJournalLine: Record "Item Journal Line")
    var
        PhysInvtCountManagement: Codeunit "Phys. Invt. Count.-Management";
    begin
        Clear(PhysInvtCountManagement);
        PhysInvtCountManagement.InitFromItemJnl(ItemJournalLine);
        PhysInvtCountManagement.Run();
    end;

    procedure DateComprItemBudgetEntries(var ItemBudgetEntry: Record "Item Budget Entry"; AnalysisAreaSelection: Option; StartDate: Date; EndDate: Date; PeriodLength: Option; Description: Text[50])
    var
        TmpItemBudgetEntry: Record "Item Budget Entry";
        AnalysisView: Record "Analysis View";
        DateCompItemBudgetEntries: Report "Date Comp. Item Budget Entries";
        RetainDimensions: Text;
    begin
        SetAnalysisViewDimensions(3 /*ObjectType::Report*/, Report::"Date Comp. Item Budget Entries", RetainDimensions);
        AnalysisView.UpdateAllAnalysisViews(true);
        DateCompItemBudgetEntries.InitializeRequest(AnalysisAreaSelection, StartDate, EndDate, PeriodLength, Description, RetainDimensions);
        if ItemBudgetEntry.HasFilter then
            TmpItemBudgetEntry.CopyFilters(ItemBudgetEntry)
        else begin
            ItemBudgetEntry.Get(ItemBudgetEntry."Entry No.");
            TmpItemBudgetEntry.SetRange("Entry No.", ItemBudgetEntry."Entry No.");
        end;
        DateCompItemBudgetEntries.SetTableView(TmpItemBudgetEntry);
        DateCompItemBudgetEntries.SetSkipAnalysisViewUpdateCheck();
        DateCompItemBudgetEntries.UseRequestPage(false);
        DateCompItemBudgetEntries.RunModal();
    end;

    local procedure SetAnalysisViewDimensions(ObjectType: Option; ObjectId: Integer; var RetainDimensions: Text[250])
    var
        SelectedDimension: Record "Selected Dimension";
        AnalysisView: Record "Analysis View";
        DimensionSelectionBuffer: Record "Dimension Selection Buffer";
    begin
        if AnalysisView.FindSet() then begin
            repeat
                if not SelectedDimension.Get(UserId, ObjectType, ObjectId, '', AnalysisView."Dimension 1 Code") then
                    InsertSelectedDimension(ObjectType, ObjectId, AnalysisView."Dimension 1 Code");
                if not SelectedDimension.Get(UserId, ObjectType, ObjectId, '', AnalysisView."Dimension 2 Code") then
                    InsertSelectedDimension(ObjectType, ObjectId, AnalysisView."Dimension 2 Code");
                if not SelectedDimension.Get(UserId, ObjectType, ObjectId, '', AnalysisView."Dimension 3 Code") then
                    InsertSelectedDimension(ObjectType, ObjectId, AnalysisView."Dimension 3 Code");
                if not SelectedDimension.Get(UserId, ObjectType, ObjectId, '', AnalysisView."Dimension 4 Code") then
                    InsertSelectedDimension(ObjectType, ObjectId, AnalysisView."Dimension 4 Code");
            until AnalysisView.Next() = 0;

            RetainDimensions := DimensionSelectionBuffer.GetDimSelectionText(ObjectType, ObjectId, '');
        end;
    end;

    local procedure InsertSelectedDimension(ObjectType: Option; ObjectId: Integer; DimensionCode: Text)
    var
        SelectedDimension: Record "Selected Dimension";
    begin
        if DimensionCode = '' then
            exit;

        SelectedDimension.Init();
        SelectedDimension."User ID" := CopyStr(UserId, 1, MaxStrLen(SelectedDimension."User ID"));
        SelectedDimension."Object Type" := ObjectType;
        SelectedDimension."Object ID" := ObjectId;
        SelectedDimension."Analysis View Code" := '';
        SelectedDimension."Dimension Code" := CopyStr(DimensionCode, 1, MaxStrLen(SelectedDimension."Dimension Code"));
        SelectedDimension.Insert();
    end;

    procedure FindItemJournalBatch(var ItemJnlBatch: Record "Item Journal Batch"; ItemJnlTemplate: Record "Item Journal Template")
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        ItemJnlBatch.SetRange("Template Type", ItemJnlTemplate.Type);
        ItemJnlBatch.SetRange("Journal Template Name", ItemJnlTemplate.Name);

        if not ItemJnlBatch.FindFirst() then
            CreateItemJournalBatch(ItemJnlBatch, ItemJnlTemplate.Name);

        if ItemJnlBatch."No. Series" = '' then begin
            LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
            ItemJnlBatch."No. Series" := NoSeries.Code;
        end;
    end;

    procedure FindItemJournalTemplate(var ItemJournalTemplate: Record "Item Journal Template")
    begin
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.SetRange(Recurring, false);
        if not ItemJournalTemplate.FindFirst() then begin
            CreateItemJournalTemplate(ItemJournalTemplate);
            ItemJournalTemplate.Validate(Type, ItemJournalTemplate.Type::Item);
            ItemJournalTemplate.Modify(true);
        end;
    end;

    procedure FindItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch")
    begin
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.FindFirst();
    end;

    procedure FindUnitOfMeasure(var UnitOfMeasure: Record "Unit of Measure")
    begin
        if not UnitOfMeasure.FindFirst() then
            CreateUnitOfMeasureCode(UnitOfMeasure);
    end;

    procedure GetQtyPerForItemUOM(ItemNo: Code[20]; UOMCode: Code[10]): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        Clear(ItemUnitOfMeasure);
        ItemUnitOfMeasure.Get(ItemNo, UOMCode);

        exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    procedure GetVariant(ItemNo: Code[20]; OldVariantCode: Code[10]): Code[10]
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", ItemNo);
        ItemVariant.SetFilter(Code, '<>%1', OldVariantCode);
        if ItemVariant.Count = 0 then
            exit('');
        ItemVariant.Next(LibraryRandom.RandInt(ItemVariant.Count));
        exit(ItemVariant.Code);
    end;

    procedure GetReservConfirmText(): Text
    begin
        exit(ReserveConfirmMsg);
    end;

    procedure NoSeriesSetup(var InventorySetup2: Record "Inventory Setup")
    begin
        InventorySetup2.Get();
        InventorySetup2.Validate("Internal Movement Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Inventory Movement Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Inventory Pick Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Inventory Put-away Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Item Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Posted Invt. Pick Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Posted Transfer Rcpt. Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Posted Transfer Shpt. Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Registered Invt. Movement Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Transfer Order Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Validate("Posted Invt. Put-away Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        InventorySetup2.Modify(true);
    end;

    local procedure ItemNoSeriesSetup(var InventorySetup2: Record "Inventory Setup")
    var
        NoSeriesCode: Code[20];
    begin
        InventorySetup2.Get();
        NoSeriesCode := LibraryUtility.GetGlobalNoSeriesCode();
        if NoSeriesCode <> InventorySetup2."Item Nos." then begin
            InventorySetup2.Validate("Item Nos.", LibraryUtility.GetGlobalNoSeriesCode());
            InventorySetup2.Modify(true);
        end;
    end;

    procedure CreateItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; PostingDate: Date; EntryType: Enum "Item Ledger Entry Type"; Qty: Decimal; UnitAmount: Decimal)
    begin
        MakeItemJournalLine(ItemJournalLine, ItemJournalBatch, Item, PostingDate, EntryType, Qty);
        ItemJournalLine."Location Code" := LocationCode;
        ItemJournalLine."Variant Code" := VariantCode;
        ItemJournalLine.Validate("Unit Amount", UnitAmount);
        ItemJournalLine.Insert();
    end;

    procedure CreateItemJournalLineWithApplication(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; PostingDate: Date; EntryType: Enum "Item Ledger Entry Type"; Qty: Decimal; UnitAmount: Decimal; AppltoEntryNo: Integer)
    begin
        MakeItemJournalLine(ItemJournalLine, ItemJournalBatch, Item, PostingDate, EntryType, Qty);
        ItemJournalLine."Location Code" := LocationCode;
        ItemJournalLine."Variant Code" := VariantCode;
        ItemJournalLine.Validate("Unit Amount", UnitAmount);
        ItemJournalLine.Validate("Applies-to Entry", AppltoEntryNo);
        ItemJournalLine.Insert();
    end;

    procedure CreateItemReclassificationJournalLine(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch"; Item: Record Item; VariantCode: Code[10]; LocationCode: Code[10]; NewLocationCode: Code[10]; BinCode: Code[20]; NewBinCode: Code[20]; PostingDate: Date; Quantity: Decimal)
    begin
        MakeItemJournalLine(ItemJournalLine, ItemJournalBatch, Item, PostingDate, ItemJournalLine."Entry Type"::Transfer, Quantity);
        ItemJournalLine."Location Code" := LocationCode;
        ItemJournalLine."Variant Code" := VariantCode;
        ItemJournalLine."New Location Code" := NewLocationCode;
        ItemJournalLine."Bin Code" := BinCode;
        ItemJournalLine."New Bin Code" := NewBinCode;
        ItemJournalLine.Insert();
    end;

    procedure CreateRevaluationJournalLine(var ItemJournalBatch: Record "Item Journal Batch"; var Item: Record Item; NewPostingDate: Date; NewCalculatePer: Enum "Inventory Value Calc. Per"; NewByLocation: Boolean; NewByVariant: Boolean; NewUpdStdCost: Boolean; NewCalcBase: Enum "Inventory Value Calc. Base")
    var
        ItemJournalLine: Record "Item Journal Line";
        NewDocNo: Code[20];
    begin
        NewDocNo := LibraryUtility.GenerateRandomCode(ItemJournalLine.FieldNo("Document No."), DATABASE::"Item Journal Line");
        RevaluationJournalCalcInventory(
          ItemJournalBatch, Item, NewPostingDate, NewDocNo, NewCalculatePer, NewByLocation, NewByVariant, NewUpdStdCost, NewCalcBase);
    end;

    procedure RevaluationJournalCalcInventory(var ItemJournalBatch: Record "Item Journal Batch"; var Item: Record Item; NewPostingDate: Date; NewDocNo: Code[20]; NewCalculatePer: Enum "Inventory Value Calc. Per"; NewByLocation: Boolean; NewByVariant: Boolean; NewUpdStdCost: Boolean; NewCalcBase: Enum "Inventory Value Calc. Base")
    var
        TmpItem: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        CalculateInventoryValue: Report "Calculate Inventory Value";
        ItemJnlMgt: Codeunit ItemJnlManagement;
        JnlSelected: Boolean;
    begin
        Commit();
        CalculateInventoryValue.SetParameters(
            NewPostingDate, NewDocNo, true, NewCalculatePer, NewByLocation, NewByVariant,
            NewUpdStdCost, NewCalcBase, true);

        CreateItemJournalBatchByType(ItemJournalBatch, ItemJournalBatch."Template Type"::Revaluation);

        ItemJournalLine.Init();
        ItemJnlMgt.TemplateSelection(PAGE::"Revaluation Journal", 3, false, ItemJournalLine, JnlSelected); // 3 = FormTemplate::Revaluation
        ItemJnlMgt.OpenJnl(ItemJournalBatch.Name, ItemJournalLine);

        ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.SetUpNewLine(ItemJournalLine);
        CalculateInventoryValue.SetItemJnlLine(ItemJournalLine);

        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;
        CalculateInventoryValue.SetTableView(TmpItem);
        CalculateInventoryValue.UseRequestPage(false);
        CalculateInventoryValue.RunModal();
    end;

    procedure MakeItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch"; Item: Record Item; PostingDate: Date; EntryType: Enum "Item Ledger Entry Type"; Quantity: Decimal)
    var
        RecRef: RecordRef;
    begin
        Clear(ItemJournalLine);
        ItemJournalLine."Journal Template Name" := ItemJournalBatch."Journal Template Name";
        ItemJournalLine."Journal Batch Name" := ItemJournalBatch.Name;
        ItemJournalLine."Posting Date" := PostingDate;
        ItemJournalLine."Entry Type" := EntryType;
        ItemJournalBatch.CalcFields("Template Type");
        if ItemJournalBatch."Template Type" = ItemJournalBatch."Template Type"::Revaluation then
            ItemJournalLine."Value Entry Type" := ItemJournalLine."Value Entry Type"::Revaluation;
        if Item.IsNonInventoriableType() then
            ItemJournalLine."Order Type" := ItemJournalLine."Order Type"::Production;
        ItemJournalLine.Validate("Item No.", Item."No.");
        ItemJournalLine.Validate(Quantity, Quantity);
        ItemJournalLine."Document No." :=
          LibraryUtility.GenerateRandomCode(ItemJournalLine.FieldNo("Document No."), DATABASE::"Item Journal Line");
        RecRef.GetTable(ItemJournalLine);
        ItemJournalLine."Line No." := LibraryUtility.GetNewLineNo(RecRef, ItemJournalLine.FieldNo("Line No."));
    end;

#if not CLEAN26
    [Obsolete('Moved to codeunit Library Manufacturing', '26.0')]
    procedure OutputJnlExplRoute(var ItemJournalLine: Record "Item Journal Line")
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.OutputJnlExplodeRoute(ItemJournalLine);
    end;
#endif

    procedure PostDirectTransferOrder(var TransferHeader: Record "Transfer Header")
    var
        TransferOrderPostTransfer: Codeunit "TransferOrder-Post Transfer";
    begin
        InventorySetup.Get();
        case InventorySetup."Direct Transfer Posting" of
            InventorySetup."Direct Transfer Posting"::"Receipt and Shipment":
                PostTransferHeader(TransferHeader, true, true);
            InventorySetup."Direct Transfer Posting"::"Direct Transfer":
                begin
                    TransferOrderPostTransfer.SetHideValidationDialog(true);
                    TransferOrderPostTransfer.Run(TransferHeader);
                end;
        end;
    end;

    procedure PostItemJournalBatch(ItemJournalBatch: Record "Item Journal Batch")
    begin
        PostItemJournalLine(ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name);
    end;

    procedure PostItemJournalLine(JournalTemplateName: Text[10]; JournalBatchName: Text[10])
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", JournalTemplateName);
        ItemJournalLine.Validate("Journal Batch Name", JournalBatchName);
        CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", ItemJournalLine);
    end;

    procedure PostItemJnlLineWithCheck(ItemJnlLine: Record "Item Journal Line")
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
    end;

    procedure PostItemJournalLine(TemplateType: Enum "Item Journal Template Type"; EntryType: Enum "Item Ledger Entry Type"; Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; BinCode: Code[20]; Qty: Decimal; PostingDate: Date; UnitAmount: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        CreateItemJournalBatchByType(ItemJournalBatch, TemplateType);
        CreateItemJournalLine(ItemJournalLine, ItemJournalBatch, Item, LocationCode, VariantCode, PostingDate, EntryType, Qty, UnitAmount);
        ItemJournalLine."Bin Code" := BinCode;
        ItemJournalLine.Modify();
        PostItemJournalBatch(ItemJournalBatch);
    end;

    procedure PostNegativeAdjustment(Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; BinCode: Code[20]; Qty: Decimal; PostingDate: Date; UnitAmount: Decimal)
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
    begin
        PostItemJournalLine(
            ItemJournalTemplate.Type::Item, ItemJournalLine."Entry Type"::"Negative Adjmt.", Item,
            LocationCode, VariantCode, BinCode, Qty, PostingDate, UnitAmount);
    end;

    procedure PostPositiveAdjustment(Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; BinCode: Code[20]; Qty: Decimal; PostingDate: Date; UnitAmount: Decimal)
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalLine: Record "Item Journal Line";
    begin
        PostItemJournalLine(
            ItemJournalTemplate.Type::Item, ItemJournalLine."Entry Type"::"Positive Adjmt.", Item,
            LocationCode, VariantCode, BinCode, Qty, PostingDate, UnitAmount);
    end;

    procedure PostReclassificationJournalLine(Item: Record Item; StartDate: Date; FromLocationCode: Code[10]; ToLocationCode: Code[10]; VariantCode: Code[10]; BinCode: Code[20]; NewBinCode: Code[20]; Quantity: Decimal)
    var
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
    begin
        CreateItemJournalBatchByType(ItemJnlBatch, ItemJnlBatch."Template Type"::Transfer);
        CreateItemReclassificationJournalLine(ItemJnlLine, ItemJnlBatch, Item, VariantCode, FromLocationCode, ToLocationCode,
          BinCode, NewBinCode, StartDate, Quantity);
        PostItemJournalBatch(ItemJnlBatch);
    end;

    procedure PostTransferHeader(var TransferHeader: Record "Transfer Header"; Ship: Boolean; Receive: Boolean)
    var
        TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment";
        TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
    begin
        Clear(TransferOrderPostShipment);
        if Ship then begin
            TransferOrderPostShipment.SetHideValidationDialog(true);
            TransferOrderPostShipment.Run(TransferHeader);
        end;
        if Receive then begin
            TransferOrderPostReceipt.SetHideValidationDialog(true);
            TransferOrderPostReceipt.Run(TransferHeader);
        end;
    end;

    procedure UndoTransferShipments(TransferOrderNo: Code[20])
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        TransferShipmentLine.SetFilter("Transfer Order No.", TransferOrderNo);
        TransferShipmentLine.SetRange("Correction Line", false);
        UndoTransferShipmentLinesInFilter(TransferShipmentLine);
    end;

    procedure UndoTransferShipmentLinesInFilter(var TransferShipmentLine: Record "Transfer Shipment Line")
    begin
        CODEUNIT.Run(CODEUNIT::"Undo Transfer Shipment", TransferShipmentLine);
    end;

    procedure ReleaseTransferOrder(var TransferHeader: Record "Transfer Header")
    var
        ReleaseTransferDocument: Codeunit "Release Transfer Document";
    begin
        Clear(ReleaseTransferDocument);
        ReleaseTransferDocument.Run(TransferHeader);
    end;

    procedure ReopenTransferOrder(var TransferHeader: Record "Transfer Header")
    var
        ReleaseTransferDocument: Codeunit "Release Transfer Document";
    begin
        ReleaseTransferDocument.Reopen(TransferHeader);
    end;

    procedure SaveAsStandardJournal(var GenJournalBatch: Record "Gen. Journal Batch"; "Code": Code[10]; SaveAmount: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        StandardGeneralJournal: Record "Standard General Journal";
        SaveAsStandardGenJournal: Report "Save as Standard Gen. Journal";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        SaveAsStandardGenJournal.Initialise(GenJournalLine, GenJournalBatch);
        SaveAsStandardGenJournal.InitializeRequest(Code, '', SaveAmount);
        SaveAsStandardGenJournal.UseRequestPage(false);
        SaveAsStandardGenJournal.RunModal();
        if not SaveAsStandardGenJournal.GetStdGeneralJournal(StandardGeneralJournal) then;
    end;

    procedure SelectItemJournalTemplateName(var ItemJournalTemplate: Record "Item Journal Template"; ItemJournalTemplateType: Enum "Item Journal Template Type")
    begin
        // Find Item Journal Template for the given Template Type.
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplateType);
        ItemJournalTemplate.SetRange(Recurring, false);
        if not ItemJournalTemplate.FindFirst() then
            CreateItemJournalTemplateByType(ItemJournalTemplate, ItemJournalTemplateType);
    end;

    procedure SelectItemJournalBatchName(var ItemJournalBatch: Record "Item Journal Batch"; ItemJournalBatchTemplateType: Enum "Item Journal Template Type"; ItemJournalTemplateName: Code[10])
    begin
        // Find Name for Batch Name.
        ItemJournalBatch.SetRange("Template Type", ItemJournalBatchTemplateType);
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplateName);

        // If Item Journal Batch not found then create it.
        if not ItemJournalBatch.FindFirst() then
            CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplateName);
    end;

    procedure SetAutomaticCostAdjmtAlways()
    begin
        InventorySetup.Get();
        InventorySetup."Automatic Cost Adjustment" := InventorySetup."Automatic Cost Adjustment"::Always;
        InventorySetup.Modify();
    end;

    procedure SetAutomaticCostAdjmtNever()
    begin
        InventorySetup.Get();
        InventorySetup."Automatic Cost Adjustment" := InventorySetup."Automatic Cost Adjustment"::Never;
        InventorySetup.Modify();
    end;

    procedure SetAutomaticCostPosting(AutomaticCostPosting: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup."Automatic Cost Posting" := AutomaticCostPosting;
        InventorySetup.Modify();
    end;

    procedure SetAverageCostSetup(AverageCostCalcType: Enum "Average Cost Calculation Type"; AverageCostPeriod: Enum "Average Cost Period Type")
    begin
        InventorySetup.Get();
        InventorySetup."Average Cost Calc. Type" := AverageCostCalcType;
        InventorySetup."Average Cost Period" := AverageCostPeriod;
        InventorySetup.Modify();
    end;

    procedure SetAverageCostSetupInAccPeriods(AverageCostCalcType: Enum "Average Cost Calculation Type"; AverageCostPeriod: Enum "Average Cost Period Type")
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.ModifyAll("Average Cost Calc. Type", AverageCostCalcType);
        AccountingPeriod.ModifyAll("Average Cost Period", AverageCostPeriod);
    end;

    procedure SetExpectedCostPosting(ExpectedCostPosting: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup."Expected Cost Posting to G/L" := ExpectedCostPosting;
        InventorySetup.Modify();
    end;

    procedure SetLocationMandatory(LocationMandatory: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup."Location Mandatory" := LocationMandatory;
        InventorySetup.Modify();
    end;

    procedure SetPreventNegativeInventory(PreventNegativeInventory: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup."Prevent Negative Inventory" := PreventNegativeInventory;
        InventorySetup.Modify();
    end;

    procedure UpdateAverageCostSettings(AverageCostCalcType: Enum "Average Cost Calculation Type"; AverageCostPeriod: Enum "Average Cost Period Type")
    begin
        InventorySetup.Get();
        InventorySetup."Average Cost Calc. Type" := AverageCostCalcType;
        InventorySetup."Average Cost Period" := AverageCostPeriod;
        CODEUNIT.Run(CODEUNIT::"Change Average Cost Setting", InventorySetup);
    end;

    procedure UpdateGenProdPostingSetup()
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.FindSet() then
            repeat
                if GeneralPostingSetup."Sales Account" = '' then
                    GeneralPostingSetup.Validate("Sales Account", LibraryERM.CreateGLAccountNo());
                if GeneralPostingSetup."Purch. Account" = '' then
                    GeneralPostingSetup.Validate("Purch. Account", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."COGS Account" = '' then
                    GeneralPostingSetup.Validate("COGS Account", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."Inventory Adjmt. Account" = '' then
                    GeneralPostingSetup.Validate("Inventory Adjmt. Account", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."COGS Account (Interim)" = '' then
                    GeneralPostingSetup.Validate("COGS Account (Interim)", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."Direct Cost Applied Account" = '' then
                    GeneralPostingSetup.Validate("Direct Cost Applied Account", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."Purchase Variance Account" = '' then
                    GeneralPostingSetup.Validate("Purchase Variance Account", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."Purch. Credit Memo Account" = '' then
                    GeneralPostingSetup.Validate("Purch. Credit Memo Account", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."Sales Credit Memo Account" = '' then
                    GeneralPostingSetup.Validate("Sales Credit Memo Account", GeneralPostingSetup."Sales Account");
                if GeneralPostingSetup."Sales Prepayments Account" = '' then
                    GeneralPostingSetup.Validate("Sales Prepayments Account", LibraryERM.CreateGLAccountWithSalesSetup());
                if GeneralPostingSetup."Purch. Prepayments Account" = '' then
                    GeneralPostingSetup.Validate("Purch. Prepayments Account", LibraryERM.CreateGLAccountWithPurchSetup());
                GeneralPostingSetup.Modify(true);
            until GeneralPostingSetup.Next() = 0;
    end;

    procedure UpdateInventorySetup(var InventorySetup2: Record "Inventory Setup"; AutomaticCostPosting: Boolean; ExpectedCostPostingtoGL: Boolean; AutomaticCostAdjustment: Enum "Automatic Cost Adjustment Type"; AverageCostCalcType: Enum "Average Cost Calculation Type"; AverageCostPeriod: Enum "Average Cost Period Type")
    begin
        InventorySetup2.Get();
        InventorySetup2.Validate("Automatic Cost Posting", AutomaticCostPosting);
        InventorySetup2.Validate("Expected Cost Posting to G/L", ExpectedCostPostingtoGL);
        InventorySetup2.Validate("Automatic Cost Adjustment", AutomaticCostAdjustment);
        InventorySetup2.Validate("Average Cost Calc. Type", AverageCostCalcType);
        InventorySetup2.Validate("Average Cost Period", AverageCostPeriod);
        InventorySetup2.Modify(true);
    end;

    procedure UpdateInventoryPostingSetup(Location: Record Location)
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
    begin
        if InventoryPostingGroup.FindSet() then
            repeat
                UpdateInventoryPostingSetup(Location, InventoryPostingGroup.Code);
            until InventoryPostingGroup.Next() = 0;
    end;

    procedure UpdateInventoryPostingSetup(Location: Record Location; InventoryPostingGroupCode: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.SetRange("Location Code", Location.Code);
        InventoryPostingSetup.SetRange("Invt. Posting Group Code", InventoryPostingGroupCode);
        if not InventoryPostingSetup.FindFirst() then
            CreateInventoryPostingSetup(InventoryPostingSetup, Location.Code, InventoryPostingGroupCode);
        InventoryPostingSetup.Validate("Inventory Account", LibraryERM.CreateGLAccountNo());
        InventoryPostingSetup.Validate("Inventory Account (Interim)", LibraryERM.CreateGLAccountNo());
        InventoryPostingSetup.Validate("WIP Account", LibraryERM.CreateGLAccountNo());
        InventoryPostingSetup.Validate("Material Variance Account", LibraryERM.CreateGLAccountNo());
        InventoryPostingSetup.Validate("Capacity Variance Account", LibraryERM.CreateGLAccountNo());
        OnBeforeModifyInventoryPostingSetup(InventoryPostingSetup);
        InventoryPostingSetup.Modify(true);
    end;

    procedure UpdateSalesLine(var SalesLine: Record "Sales Line"; FieldNo: Integer; Value: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        // Update Sales Line base on Field and its corresponding value.
        RecRef.GetTable(SalesLine);
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Validate(Value);
        RecRef.SetTable(SalesLine);
        SalesLine.Modify(true);
    end;

    procedure ItemJournalSetup(var ItemJournalTemplate: Record "Item Journal Template"; var ItemJournalBatch: Record "Item Journal Batch")
    begin
        Clear(ItemJournalTemplate);
        ItemJournalTemplate.Init();
        SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        ItemJournalTemplate.Modify(true);

        Clear(ItemJournalBatch);
        ItemJournalBatch.Init();
        SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
        ItemJournalBatch.Validate("No. Series", '');  // Value required to avoid the Document No mismatch.
        ItemJournalBatch.Modify(true);
    end;

    procedure OutputJournalSetup(var ItemJournalTemplate: Record "Item Journal Template"; var ItemJournalBatch: Record "Item Journal Batch")
    begin
        SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Output);
        SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
    end;

    procedure ConsumptionJournalSetup(var ItemJournalTemplate: Record "Item Journal Template"; var ItemJournalBatch: Record "Item Journal Batch")
    begin
        SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Consumption);
        SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
    end;

    procedure VerifyReservationEntryWithLotExists(SourceType: Option; SourceSubtype: Option; SourceID: Code[20]; SourceRefNo: Integer; ItemNo: Code[20]; ExpectedQty: Decimal)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetRange("Source Type", SourceType);
        ReservationEntry.SetRange("Source Subtype", SourceSubtype);
        ReservationEntry.SetRange("Source ID", SourceID);
        ReservationEntry.SetRange("Source Ref. No.", SourceRefNo);
        ReservationEntry.SetRange("Item No.", ItemNo);
        ReservationEntry.FindFirst();
        ReservationEntry.TestField("Quantity (Base)", ExpectedQty);
        ReservationEntry.TestField("Lot No.");
    end;

    procedure UpdateMaterialNonInvVarianceAccountInInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
        InventoryPostingSetup.Validate("Mat. Non-Inv. Variance Acc.", LibraryERM.CreateGLAccountNo());
        InventoryPostingSetup.Modify();
    end;

    procedure CreateItem(var Item: Record Item; CostingMethod: Enum "Costing Method"; UnitCost: Decimal; OverheadRate: Decimal; IndirectCostPercent: Decimal; ItemTrackingCode: Code[10])
    begin
        CreateItem(Item);
        Item."Costing Method" := CostingMethod;
        if Item."Costing Method" = Item."Costing Method"::Standard then
            Item."Standard Cost" := UnitCost;
        Item."Unit Cost" := UnitCost;
        Item."Overhead Rate" := OverheadRate;
        Item."Indirect Cost %" := IndirectCostPercent;
        Item."Item Tracking Code" := ItemTrackingCode;
        Item.Description := Item."No.";
        Item.Modify();
    end;

    procedure CreateItemSimple(var Item: Record Item; CostingMethod: Enum "Costing Method"; UnitCost: Decimal)
    begin
        CreateItem(Item, CostingMethod, UnitCost, 0, 0, '');
    end;

    procedure CreateItemWithExtendedText(var Item: Record Item; ExtText: Text; CostingMethod: Enum "Costing Method"; UnitCost: Decimal)
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
    begin
        // Create Item.
        CreateItem(Item, CostingMethod, UnitCost, 0, 0, '');
        Item.Validate("Automatic Ext. Texts", true);
        Item.Modify();

        // Create Extended Text Header and Line.
        CreateExtendedTextHeaderItem(ExtendedTextHeader, Item."No.");
        ExtendedTextHeader.Validate("All Language Codes", true);
        ExtendedTextHeader.Modify();
        CreateExtendedTextLineItem(ExtendedTextLine, ExtendedTextHeader);
        ExtendedTextLine.Validate(Text, CopyStr(ExtText, 1, MaxStrLen(ExtendedTextLine.Text)));
        ExtendedTextLine.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItem(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItemJnlLineWithNoItem(var ItemJournalLine: Record "Item Journal Line"; ItemJournalBatch: Record "Item Journal Batch"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; EntryType: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItemManufacturing(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateItemVariant(var ItemVariant: Record "Item Variant"; ItemNo: Code[20]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItemVariant(var ItemVariant: Record "Item Variant"; ItemNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateTransferHeader(var TransferHeader: Record "Transfer Header"; FromLocation: Text[10]; ToLocation: Text[10]; InTransitCode: Text[10]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateTransferHeader(var TransferHeader: Record "Transfer Header"; FromLocation: Text[10]; ToLocation: Text[10]; InTransitCode: Text[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVariant(var ItemVariant: Record "Item Variant"; Item: Record Item; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateVariant(var ItemVariant: Record "Item Variant"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
    end;
}

