codeunit 5386 "Create Item Charge"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
        CreateVatPostingGroups: Codeunit "Create VAT Posting Groups";
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        ContosoItem.InsertItemCharge(JBFreight(), FreightChargeJBSpeditionLbl, CreatePostingGroup.ServicesPostingGroup(), CreateVatPostingGroups.Standard(), FreightChargeJBSpeditionLbl);
        ContosoItem.InsertItemCharge(PurchAllowance(), PurchaseAllowanceLbl, CreatePostingGroup.ServicesPostingGroup(), CreateVatPostingGroups.Standard(), PurchaseAllowanceLbl);
        ContosoItem.InsertItemCharge(PurchFreight(), MiscFreightChargePurchLbl, CreatePostingGroup.ServicesPostingGroup(), CreateVatPostingGroups.Standard(), MiscFreightChargePurchLbl);
        ContosoItem.InsertItemCharge(PurchRestock(), PurchaseRestockChargeLbl, CreatePostingGroup.ServicesPostingGroup(), CreateVatPostingGroups.Standard(), PurchaseRestockChargeLbl);
        ContosoItem.InsertItemCharge(SaleAllowance(), SalesAllowanceLbl, CreatePostingGroup.ServicesPostingGroup(), CreateVatPostingGroups.Standard(), SalesAllowanceLbl);
        ContosoItem.InsertItemCharge(SaleFreight(), MiscFreightChargesSalesLbl, CreatePostingGroup.ServicesPostingGroup(), CreateVatPostingGroups.Standard(), MiscFreightChargesSalesLbl);
        ContosoItem.InsertItemCharge(SaleRestock(), SalesRestockChargeLbl, CreatePostingGroup.ServicesPostingGroup(), CreateVatPostingGroups.Standard(), SalesRestockChargeLbl);
    end;

    procedure JBFreight(): Code[20]
    begin
        exit(JBFreightTok);
    end;

    procedure PurchAllowance(): Code[20]
    begin
        exit(PurchAllowanceTok);
    end;

    procedure PurchFreight(): Code[20]
    begin
        exit(PurchFreightTok);
    end;

    procedure PurchRestock(): Code[20]
    begin
        exit(PurchRestockTok);
    end;

    procedure SaleAllowance(): Code[20]
    begin
        exit(SaleAllowanceTok);
    end;

    procedure SaleFreight(): Code[20]
    begin
        exit(SaleFreightTok);
    end;

    procedure SaleRestock(): Code[20]
    begin
        exit(SaleRestockTok);
    end;

    var
        JBFreightTok: Label 'JB-FREIGHT', MaxLength = 20;
        PurchAllowanceTok: Label 'P-ALLOWANCE', MaxLength = 20;
        PurchFreightTok: Label 'P-FREIGHT', MaxLength = 20;
        PurchRestockTok: Label 'P-RESTOCK', MaxLength = 20;
        SaleAllowanceTok: Label 'S-ALLOWANCE', MaxLength = 20;
        SaleFreightTok: Label 'S-FREIGHT', MaxLength = 20;
        SaleRestockTok: Label 'S-RESTOCK', MaxLength = 20;
        FreightChargeJBSpeditionLbl: Label 'Freight Charge (JB-Spedition)', Maxlength = 100;
        PurchaseAllowanceLbl: Label 'Purchase Allowance', Maxlength = 100;
        MiscFreightChargePurchLbl: Label 'Misc. Freight Charge (Purch.)', Maxlength = 100;
        PurchaseRestockChargeLbl: Label 'Purchase Restock Charge', Maxlength = 100;
        SalesAllowanceLbl: Label 'Sales Allowance', Maxlength = 100;
        MiscFreightChargesSalesLbl: Label 'Misc. Freight Charges (Sales)', Maxlength = 100;
        SalesRestockChargeLbl: Label 'Sales Restock Charge', Maxlength = 100;
}