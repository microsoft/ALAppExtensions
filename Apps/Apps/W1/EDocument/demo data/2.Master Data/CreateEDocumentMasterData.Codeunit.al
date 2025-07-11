#pragma warning disable AA0247
codeunit 5375 "Create E-Document Master Data"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateItems();
        SetVendorsToUseEDocOrder();
    end;

    local procedure SetVendorsToUseEDocOrder()
    var
        EDocumentModuleSetup: Record "E-Document Module Setup";
    begin
        EDocumentModuleSetup.Get();

        UpdateVendor(EDocumentModuleSetup."Vendor No. 1");
        UpdateVendor(EDocumentModuleSetup."Vendor No. 2");
        UpdateVendor(EDocumentModuleSetup."Vendor No. 3");
    end;

    local procedure UpdateVendor(VendorNo: Code[20])
    var
        Vendor: Record "Vendor";
    begin
        Vendor.Get(VendorNo);
        Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Order";
        Vendor.Modify();
    end;

    local procedure CreateItems()
    var
        ContosoItem: Codeunit "Contoso Item";
        CommonUoM: Codeunit "Create Common Unit Of Measure";
    begin
        ContosoItem.InsertItemCategory(BEANSTok, BeansLbl, '');

        CreateItem('WRB-1003', 'Whole Roasted Beans, Mexico', 180, CommonUoM.Piece());
        CreateItem('WRB-1004', 'Whole Roasted Beans, Kenya', 180, CommonUoM.Piece());
        CreateItem('WRB-1005', 'Whole Roasted Beans, COSTA RICA', 180, CommonUoM.Piece());
        CreateItem('WRB-1006', 'Whole Roasted Beans, ETHIOPIA', 180, CommonUoM.Piece());
        CreateItem('WRB-1007', 'Whole Roasted Beans, HAWAII', 180, CommonUoM.Piece());

        CreateItem(WholeDecafBeansColombia(), 'Whole Decaf Beans, Colombia', 180, CommonUoM.Piece());
        CreateItem('WDB-1001', 'Whole Decaf Beans, Brazil', 210, CommonUoM.Piece());
        CreateItem('WDB-1002', 'Whole Decaf Beans, Indonesia', 210, CommonUoM.Piece());
        CreateItem('WDB-1003', 'Whole Decaf Beans, Mexico', 210, CommonUoM.Piece());
        CreateItem('WDB-1004', 'Whole Decaf Beans, Kenya', 210, CommonUoM.Piece());
        CreateItem('WDB-1005', 'Whole Decaf Beans, Costa Rica', 210, CommonUoM.Piece());
        CreateItem('WDB-1006', 'Whole Decaf Beans, Ethiopia', 210, CommonUoM.Piece());
        CreateItem('WDB-1007', 'Whole Decaf Beans, Hawaii', 210, CommonUoM.Piece());

        CreateItem(PrecisionGrindHome(), 'Precision Grind Home', 199, CommonUoM.Piece());
        CreateItem(SmartGrindHome(), 'Smart Grind Home', 299, CommonUoM.Piece());
    end;

    local procedure CreateItem(ItemNo: Code[20]; Description: Text[100]; UnitPrice: Decimal; BaseUnitOfMeasure: Code[10])
    var
        CommonUoM: Codeunit "Create Common Unit Of Measure";
        ContosoItem: Codeunit "Contoso Item";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        ContosoUnitOfMeasure: Codeunit "Contoso Unit of Measure";
        GenProdPostingGroup, InventoryPostingGroup, TaxGroup : Code[20];
    begin
        GenProdPostingGroup := CommonPostingGroup.Retail();
        InventoryPostingGroup := CommonPostingGroup.Resale();
        TaxGroup := CommonPostingGroup.NonTaxable();

        ContosoItem.InsertInventoryItem(ItemNo, Description, UnitPrice, UnitPrice, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, Enum::"Costing Method"::FIFO, BaseUnitOfMeasure, BEANSTok, '', 1, '', ContosoUtilities.EmptyPicture(), Format(RandBarcodeInt()));
        case BaseUnitOfMeasure of
            CommonUoM.Box():
                ContosoUnitOfMeasure.InsertItemUnitOfMeasure(ItemNo, BaseUnitOfMeasure, 4, 0, 0, 0, 0);
            CommonUoM.Pack():
                ContosoUnitOfMeasure.InsertItemUnitOfMeasure(ItemNo, BaseUnitOfMeasure, 2, 0, 0, 0, 0);
            else
                ContosoUnitOfMeasure.InsertItemUnitOfMeasure(ItemNo, BaseUnitOfMeasure, 1, 0, 0, 0, 0);
        end;
    end;

    internal procedure RandBarcodeInt(): Integer
    begin
        exit(10000000 - 1 + Random(99999999 - 10000000 + 1));
    end;

    procedure PrecisionGrindHome(): Code[20]
    begin
        exit('GRH-1000');
    end;

    procedure SmartGrindHome(): Code[20]
    begin
        exit('GRH-1001');
    end;

    procedure WholeDecafBeansColombia(): Code[20]
    begin
        exit('WDB-1000');
    end;

    var
        ContosoUtilities: Codeunit "Contoso Utilities";
        BEANSTok: Label 'BEANS', MaxLength = 20;
        BeansLbl: Label 'Beans', MaxLength = 100;
}
