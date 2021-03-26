codeunit 18471 "Update Subcontract Details"
{
    procedure InsertSubComponentsDetails(PurchLine: Record "Purchase Line")
    var
        SubOrderComponents: Record "Sub Order Component List";
        ProdOrderComponent: Record "Prod. Order Component";
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        InventorySetup: Record "Inventory Setup";
        Item: Record Item;
        Vendor: Record Vendor;
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        ProdOrderComponent.SetRange(Status, ProdOrderComponent.Status::Released);
        ProdOrderComponent.SetRange("Prod. Order No.", PurchLine."Prod. Order No.");
        ProdOrderComponent.SetRange("Prod. Order Line No.", PurchLine."Prod. Order Line No.");
        if ProdOrderComponent.FindSet() then
            repeat
                SubOrderComponents.Init();
                SubOrderComponents."Document No." := PurchLine."Document No.";
                SubOrderComponents."Document Line No." := PurchLine."Line No.";
                SubOrderComponents."Production Order No." := PurchLine."Prod. Order No.";
                SubOrderComponents."Production Order Line No." := PurchLine."Prod. Order Line No.";
                SubOrderComponents."Line No." := ProdOrderComponent."Line No.";
                SubOrderComponents."Parent Item No." := PurchLine."No.";
                SubOrderComponents.Insert();

                SubOrderComponents."Item No." := ProdOrderComponent."Item No.";
                SubOrderComponents."Unit of Measure Code" := ProdOrderComponent."Unit of Measure Code";
                SubOrderComponents.Description := COPYSTR(ProdOrderComponent.Description, 1, 30);
                SubOrderComponents."Quantity per" := ProdOrderComponent."Quantity per";
                SubOrderComponents."Quantity To Send" := ProdOrderComponent."Expected Quantity";

                Item.Get(SubOrderComponents."Item No.");
                SubOrderComponents."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, SubOrderComponents."Unit of Measure Code");
                SubOrderComponents."Quantity (Base)" := Round(
                    SubOrderComponents."Quantity To Send" *
                    SubOrderComponents."Qty. per Unit of Measure", 0.00001);
                SubOrderComponents."Quantity To Send (Base)" := SubOrderComponents."Quantity (Base)";
                SubOrderComponents.Description := CopyStr(ProdOrderComponent.Description, 1, 30);
                SubOrderComponents.Validate("Scrap %", ProdOrderComponent."Scrap %");
                SubOrderComponents."Variant Code" := ProdOrderComponent."Variant Code";

                Item.Get(SubOrderComponents."Parent Item No.");
                SubOrderComponents."Company Location" := Item."Sub. Comp. Location";
                SubOrderComponents."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";

                Vendor.Get(PurchLine."Buy-from Vendor No.");
                Vendor.TestField("Vendor Location");

                SubOrderComponents."Vendor Location" := Vendor."Vendor Location";

                InventorySetup.Get();
                InventorySetup.TestField("Job Work Return Period");

                SubOrderComponents."Job Work Return Period" := InventorySetup."Job Work Return Period";
                SubOrderComponents.Modify();
            until ProdOrderComponent.Next() = 0;

        ProdOrderComponent.Reset();
        ProdOrderComponent.SetRange(Status, ProdOrderComponent.Status::Released);
        ProdOrderComponent.SetRange("Prod. Order No.", PurchLine."Prod. Order No.");
        ProdOrderComponent.SetRange("Prod. Order Line No.", PurchLine."Prod. Order Line No.");
        if ProdOrderComponent.FindSet() then
            repeat
                SubOrderCompListVend.Init();
                SubOrderCompListVend."Document No." := PurchLine."Document No.";
                SubOrderCompListVend."Document Line No." := PurchLine."Line No.";
                SubOrderCompListVend."Production Order No." := PurchLine."Prod. Order No.";
                SubOrderCompListVend."Production Order Line No." := PurchLine."Prod. Order Line No.";
                SubOrderCompListVend."Line No." := ProdOrderComponent."Line No.";
                SubOrderCompListVend."Parent Item No." := PurchLine."No.";
                SubOrderCompListVend.Insert();

                SubOrderCompListVend."Item No." := ProdOrderComponent."Item No.";
                SubOrderCompListVend."Unit of Measure" := ProdOrderComponent."Unit of Measure Code";
                SubOrderCompListVend.Description := COPYSTR(ProdOrderComponent.Description, 1, 30);
                SubOrderCompListVend."Quantity per" := ProdOrderComponent."Quantity per";

                Item.Get(SubOrderCompListVend."Item No.");

                SubOrderCompListVend."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, SubOrderCompListVend."Unit of Measure");
                SubOrderCompListVend.Description := CopyStr(ProdOrderComponent.Description, 1, 30);
                SubOrderCompListVend.Validate("Scrap %", ProdOrderComponent."Scrap %");
                SubOrderCompListVend."Variant Code" := ProdOrderComponent."Variant Code";
                Item.Get(SubOrderCompListVend."Parent Item No.");
                SubOrderCompListVend."Company Location" := Item."Sub. Comp. Location";
                SubOrderCompListVend."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";

                Vendor.Get(PurchLine."Buy-from Vendor No.");
                Vendor.TestField("Vendor Location");

                SubOrderCompListVend."Vendor Location" := Vendor."Vendor Location";
                SubOrderCompListVend.Modify();
            until ProdOrderComponent.Next() = 0;
        PurchLine.Modify();
    end;

    procedure UpdateProdOrderline(ReqLine: Record "Requisition Line"; PurchOrderHeader: Record "Purchase Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrdComp: Record "Prod. Order Component";
    begin
        ProdOrderLine.Reset();
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ReqLine."Prod. Order No.");
        ProdOrderLine.SetRange("Line No.", ReqLine."Prod. Order Line No.");
        if ProdOrderLine.FindFirst() then begin
            ProdOrderLine."Subcontracting Order No." := PurchOrderHeader."Document No.";
            ProdOrderLine."Subcontractor Code" := PurchOrderHeader."Buy-from Vendor No.";
            ProdOrderLine.Modify();

            //Update Prod. Order Component
            ProdOrdComp.Reset();
            ProdOrdComp.SetRange(Status, ProdOrderLine.Status);
            ProdOrdComp.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrdComp.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            if ProdOrdComp.FindSet() then
                repeat
                    ProdOrdComp."Subcontracting Order No." := ProdOrderLine."Subcontracting Order No.";
                    ProdOrdComp."Subcontractor Code" := ProdOrderLine."Subcontractor Code";
                    ProdOrdComp.Modify();
                until ProdOrdComp.Next() = 0;
        end;
    end;
}