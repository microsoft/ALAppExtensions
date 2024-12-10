codeunit 5699 "Contoso Inventory"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    Permissions = tabledata "Order Promising Setup" = rim,
                    tabledata "Requisition Wksh. Name" = rim,
                    tabledata "Req. Wksh. Template" = rim,
                    tabledata "BOM Component" = rim,
                    tabledata "Item Templ." = rim,
                    tabledata "Item Unit of Measure" = rim,
                    tabledata Location = rim,
                    tabledata Manufacturer = rim,
                    tabledata "Nonstock Item" = rim,
                    tabledata Purchasing = rim,
                    tabledata "Transfer Header" = ri,
                    tabledata "Transfer Line" = ri,
                    tabledata "Transfer Route" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertOrderPromisingSetup(OffsetTime: Text; OrderPromisingNos: Code[20]; OrderPromisingTemplate: Code[10]; OrderPromisingWorksheet: Code[10])
    var
        OrderPromisingSetup: Record "Order Promising Setup";
    begin
        if not OrderPromisingSetup.Get() then
            OrderPromisingSetup.Insert();

        Evaluate(OrderPromisingSetup."Offset (Time)", OffsetTime);
        OrderPromisingSetup.Validate("Offset (Time)");
        OrderPromisingSetup.Validate("Order Promising Nos.", OrderPromisingNos);
        OrderPromisingSetup.Validate("Order Promising Template", OrderPromisingTemplate);
        OrderPromisingSetup.Validate("Order Promising Worksheet", OrderPromisingWorksheet);
        OrderPromisingSetup.Modify(true);
    end;

    procedure InsertRequisitionWkshName(WorksheetTemplateName: Code[10]; Name: Code[10]; Description: Text[100])
    var
        RequisitionWkshName: Record "Requisition Wksh. Name";
        Exists: Boolean;
    begin
        if RequisitionWkshName.Get(WorksheetTemplateName, Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        RequisitionWkshName.Validate("Worksheet Template Name", WorksheetTemplateName);
        RequisitionWkshName.Validate(Name, Name);
        RequisitionWkshName.Validate(Description, Description);

        if Exists then
            RequisitionWkshName.Modify(true)
        else
            RequisitionWkshName.Insert(true);
    end;

    procedure InsertReqWkshTemplate(Name: Code[10]; Description: Text[80]; PageID: Integer; ReqWorksheetTemplateType: Enum "Req. Worksheet Template Type")
    var
        ReqWkshTemplate: Record "Req. Wksh. Template";
        Exists: Boolean;
    begin
        if ReqWkshTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ReqWkshTemplate.Validate(Name, Name);
        ReqWkshTemplate.Validate(Description, Description);
        ReqWkshTemplate.Validate("Page ID", PageID);
        ReqWkshTemplate.Validate(Type, ReqWorksheetTemplateType);

        if Exists then
            ReqWkshTemplate.Modify(true)
        else
            ReqWkshTemplate.Insert(true);
    end;

    procedure InsertBOMComponent(ParentItemNo: Code[20]; LineNo: Integer; BOMComponentType: Enum "BOM Component Type"; BomComponentNo: Code[20]; Description: Text[100]; UnitOfMeasureCode: Code[10]; Quantityper: Decimal)
    var
        BOMComponent: Record "BOM Component";
        Exists: Boolean;
    begin
        if BOMComponent.Get(ParentItemNo, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BOMComponent.Validate("Parent Item No.", ParentItemNo);
        BOMComponent.Validate("Line No.", LineNo);
        BOMComponent.Validate(Type, BOMComponentType);
        BOMComponent.Validate("No.", BomComponentNo);
        BOMComponent.Validate(Description, Description);
        BOMComponent.Validate("Unit of Measure Code", UnitOfMeasureCode);
        BOMComponent.Validate("Quantity per", Quantityper);

        if Exists then
            BOMComponent.Modify(true)
        else
            BOMComponent.Insert(true);
    end;

    procedure InsertLocation(Code: Code[10]; Name: Text[100]; Address: Text[100]; Address2: Text[50]; City: Text[30]; PhoneNo: Text[30]; FaxNo: Text[30]; Contact: Text[100]; PostCode: Code[20]; CountryRegionCode: Code[10]; UseAsInTransit: Boolean)
    var
        Location: Record Location;
        Exists: Boolean;
    begin
        if Location.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Location.Validate(Code, Code);
        Location.Validate(Name, Name);
        Location.Validate(Address, Address);
        Location.Validate("Address 2", Address2);
        Location.Validate(City, City);
        Location.Validate("Phone No.", PhoneNo);
        Location.Validate("Fax No.", FaxNo);
        Location.Validate(Contact, Contact);
        Location.Validate("Country/Region Code", CountryRegionCode);
        Location.Validate("Post Code", PostCode);
        Location.Validate("Use As In-Transit", UseAsInTransit);

        if Exists then
            Location.Modify(true)
        else
            Location.Insert(true);
    end;

    procedure InsertTransferHeader(TransferFromCode: Code[10]; TransferToCode: Code[10]; PostingDate: Date; InTransitCode: Code[10]; ExternalDocumentNo: Code[35]): Record "Transfer Header";
    var
        TransferHeader: Record "Transfer Header";
    begin
        TransferHeader.Validate("Transfer-from Code", TransferFromCode);
        TransferHeader.Validate("Transfer-to Code", TransferToCode);
        TransferHeader.Validate("Posting Date", PostingDate);
        TransferHeader.Validate("In-Transit Code", InTransitCode);
        TransferHeader.Validate("External Document No.", ExternalDocumentNo);
        TransferHeader.Insert(true);

        exit(TransferHeader);
    end;

    procedure InsertTransferLine(TransferHeader: Record "Transfer Header"; ItemNo: Code[20]; Quantity: Decimal; QtytoShip: Decimal)
    var
        Item: Record Item;
        TransferLine: Record "Transfer Line";
    begin
        Item.SetBaseLoadFields();
        Item.Get(ItemNo);

        TransferLine.Validate("Document No.", TransferHeader."No.");
        TransferLine.Validate("Line No.", GetNextTransferLineNo(TransferHeader));
        TransferLine.Validate("Item No.", Item."No.");
        TransferLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
        TransferLine.Validate("Quantity", Quantity);
        TransferLine.Validate("Qty. to Ship", QtytoShip);
        TransferLine.Insert(true);
    end;

    local procedure GetNextTransferLineNo(TransferHeader: Record "Transfer Header"): Integer
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetCurrentKey("Line No.");

        if TransferLine.FindLast() then
            exit(TransferLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InsertTransferRoute(TransferFromCode: Code[10]; TransferToCode: Code[10]; InTransitCode: Code[10]; ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[10])
    var
        TransferRoute: Record "Transfer Route";
        Exists: Boolean;
    begin
        if TransferRoute.Get(TransferFromCode, TransferToCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TransferRoute.Validate("Transfer-from Code", TransferFromCode);
        TransferRoute.Validate("Transfer-to Code", TransferToCode);
        TransferRoute.Validate("In-Transit Code", InTransitCode);
        TransferRoute.Validate("Shipping Agent Code", ShippingAgentCode);
        TransferRoute.Validate("Shipping Agent Service Code", ShippingAgentServiceCode);

        if Exists then
            TransferRoute.Modify(true)
        else
            TransferRoute.Insert(true);
    end;

    procedure InsertItemUOM(ItemNo: Code[20]; Code: Code[10]; QtyPerUnitofMeasure: Decimal; QtyRoundingPrecision: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Exists: Boolean;
    begin
        if ItemUnitOfMeasure.Get(ItemNo, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ItemUnitOfMeasure.Validate("Item No.", ItemNo);
        ItemUnitOfMeasure.Validate(Code, Code);
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPerUnitofMeasure);
        ItemUnitOfMeasure.Validate("Qty. Rounding Precision", QtyRoundingPrecision);

        if Exists then
            ItemUnitOfMeasure.Modify(true)
        else
            ItemUnitOfMeasure.Insert(true);
    end;

    procedure InsertItemTemplateData(TemplateCode: Code[20]; Description: Text[100]; BaseUnitofMeasure: Code[20]; ItemType: Enum "Item Type"; InventoryPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; Reserve: Enum "Reserve Method")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ItemTempl: Record "Item Templ.";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if not ItemTempl.Get(TemplateCode) then begin
            ItemTempl.Validate(Code, TemplateCode);
            ItemTempl.Validate(Description, Description);
            ItemTempl.Insert(true);
        end;

        ItemTempl.Validate("Base Unit of Measure", BaseUnitofMeasure);
        ItemTempl.Validate(Type, ItemType);
        ItemTempl.Validate("Inventory Posting Group", InventoryPostingGroup);
        ItemTempl.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ItemTempl.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        ItemTempl.Validate(Reserve, Reserve);
        ItemTempl.Modify(true);
    end;

    procedure InsertPurchasing(Code: Code[10]; Description: Text[100]; DropShipment: Boolean; SpecialOrder: Boolean)
    var
        Purchasing: Record "Purchasing";
        Exists: Boolean;
    begin
        if Purchasing.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Purchasing.Validate(Code, Code);
        Purchasing.Validate(Description, Description);
        Purchasing.Validate("Drop Shipment", DropShipment);
        Purchasing.Validate("Special Order", SpecialOrder);

        if Exists then
            Purchasing.Modify(true)
        else
            Purchasing.Insert(true);
    end;

    procedure InsertNonStockItem(VendorNo: Code[20]; VendorItemNo: Code[20]; Description: Text[100]; UnitofMeasure: Code[10]; PublishedCost: Decimal; NegotiatedCost: Decimal; UnitPrice: Decimal; GrossWeight: Decimal; NetWeight: Decimal; BarCode: Code[20]; ItemTemplCode: Code[20])
    var
        NonstockItem: Record "Nonstock Item";
    begin
        NonstockItem."Entry No." := '';
        NonstockItem.Insert(true);

        NonStockItem.Validate("Vendor No.", VendorNo);
        NonStockItem.Validate("Vendor Item No.", VendorItemNo);
        NonStockItem.Validate(Description, Description);
        NonStockItem.Validate("Unit of Measure", UnitofMeasure);
        NonStockItem.Validate("Published Cost", PublishedCost);
        NonStockItem.Validate("Negotiated Cost", NegotiatedCost);
        NonStockItem.Validate("Unit Price", UnitPrice);
        NonStockItem.Validate("Gross Weight", GrossWeight);
        NonStockItem.Validate("Net Weight", NetWeight);
        NonStockItem.Validate("Bar Code", BarCode);
        NonStockItem.Validate("Item Templ. Code", ItemTemplCode);
        NonstockItem.Modify(true);
    end;

    procedure InsertManufacturer(Code: Code[10]; Name: Text[50])
    var
        Manufacturer: Record "Manufacturer";
        Exists: Boolean;
    begin
        if Manufacturer.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Manufacturer.Validate(Code, Code);
        Manufacturer.Validate(Name, Name);

        if Exists then
            Manufacturer.Modify(true)
        else
            Manufacturer.Insert(true);
    end;
}