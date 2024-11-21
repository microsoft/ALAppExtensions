codeunit 5417 "Create Dimension Value"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateDimension: Codeunit "Create Dimension";
        ContosoDimension: Codeunit "Contoso Dimension";
        DimensionValueIndent: Codeunit "Dimension Value-Indent";
    begin
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), EuropeArea(), EuropeLbl, 3, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), EuropeNorthArea(), EuropeNorthLbl, 3, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), EuropeNorthEUArea(), EuropeNorthEULbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), EuropeNorthNonEUArea(), EuropeNorthNonEULbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), EuropeNorthTotalArea(), EuropeNorthTotalLbl, 4, EuropeNorthArea() + '..' + EuropeNorthTotalArea());
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), EuropeSouthArea(), EuropeSouthLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), EuropeTotalArea(), EuropeTotalLbl, 4, EuropeArea() + '..' + EuropeTotalArea());
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), AmericaArea(), AmericaLbl, 3, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), AmericaNorthArea(), AmericaNorthLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), AmericaSouthArea(), AmericaSouthLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.AreaDimension(), AmericaTotalArea(), AmericaTotalLbl, 4, AmericaArea() + '..' + AmericaTotalArea());

        ContosoDimension.InsertDimensionValue(CreateDimension.BusinessGroupDimension(), HomeBusinessGroup(), HomeLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.BusinessGroupDimension(), IndustrialBusinessGroup(), IndustrialLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.BusinessGroupDimension(), OfficeBusinessGroup(), OfficeLbl, 0, '');

        ContosoDimension.InsertDimensionValue(CreateDimension.CustomerGroupDimension(), LargeBusinessCustomerGroup(), LargeBusinessLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.CustomerGroupDimension(), MediumBusinessCustomerGroup(), MediumBusinessLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.CustomerGroupDimension(), SmallBusinessCustomerGroup(), SmallBusinessLbl, 0, '');

        ContosoDimension.InsertDimensionValue(CreateDimension.DepartmentDimension(), AdministrationDepartment(), AdministrationLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.DepartmentDimension(), ProductionDepartment(), ProductionLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.DepartmentDimension(), SalesDepartment(), SalesLbl, 0, '');

        ContosoDimension.InsertDimensionValue(CreateDimension.SalesCampaignDimension(), SummerSalesCampaign(), SummerLbl, 0, '');
        ContosoDimension.InsertDimensionValue(CreateDimension.SalesCampaignDimension(), WinterSalesCampaign(), WinterLbl, 0, '');

        DimensionValueIndent.Indent();
    end;

    procedure EuropeArea(): Code[20]
    begin
        exit('10');
    end;

    procedure EuropeNorthArea(): Code[20]
    begin
        exit('20');
    end;

    procedure EuropeNorthEUArea(): Code[20]
    begin
        exit('30');
    end;

    procedure EuropeNorthNonEUArea(): Code[20]
    begin
        exit('40');
    end;

    procedure EuropeNorthTotalArea(): Code[20]
    begin
        exit('45');
    end;

    procedure EuropeSouthArea(): Code[20]
    begin
        exit('50');
    end;

    procedure EuropeTotalArea(): Code[20]
    begin
        exit('55');
    end;

    procedure AmericaArea(): Code[20]
    begin
        exit('60');
    end;

    procedure AmericaNorthArea(): Code[20]
    begin
        exit('70');
    end;

    procedure AmericaSouthArea(): Code[20]
    begin
        exit('80');
    end;

    procedure AmericaTotalArea(): Code[20]
    begin
        exit('85');
    end;

    procedure HomeBusinessGroup(): Code[20]
    begin
        exit(HomeTok);
    end;

    procedure IndustrialBusinessGroup(): Code[20]
    begin
        exit(IndustrialTok);
    end;

    procedure OfficeBusinessGroup(): Code[20]
    begin
        exit(OfficeTok);
    end;

    procedure LargeBusinessCustomerGroup(): Code[20]
    begin
        exit(LargeBusinessTok);
    end;

    procedure MediumBusinessCustomerGroup(): Code[20]
    begin
        exit(MediumBusinessTok);
    end;

    procedure SmallBusinessCustomerGroup(): Code[20]
    begin
        exit(SmallBusinessTok);
    end;

    procedure AdministrationDepartment(): Code[20]
    begin
        exit(AdministrationTok);
    end;

    procedure ProductionDepartment(): Code[20]
    begin
        exit(ProductionTok);
    end;

    procedure SalesDepartment(): Code[20]
    begin
        exit(SalesTok);
    end;

    procedure SummerSalesCampaign(): Code[20]
    begin
        exit(SummerTok);
    end;

    procedure WinterSalesCampaign(): Code[20]
    begin
        exit(WinterTok);
    end;

    var
        EuropeLbl: Label 'Europe', MaxLength = 50;
        EuropeNorthLbl: Label 'Europe North', MaxLength = 50;
        EuropeNorthEULbl: Label 'Europe North (EU)', MaxLength = 50;
        EuropeNorthNonEULbl: Label 'Europe North (Non EU)', MaxLength = 50;
        EuropeNorthTotalLbl: Label 'Europe North, Total', MaxLength = 50;
        EuropeSouthLbl: Label 'Europe South', MaxLength = 50;
        EuropeTotalLbl: Label 'Europe, Total', MaxLength = 50;
        AmericaLbl: Label 'America', MaxLength = 50;
        AmericaNorthLbl: Label 'America North', MaxLength = 50;
        AmericaSouthLbl: Label 'America South', MaxLength = 50;
        AmericaTotalLbl: Label 'America, Total', MaxLength = 50;
        HomeLbl: Label 'Home', MaxLength = 50;
        IndustrialLbl: Label 'Industrial', MaxLength = 50;
        OfficeLbl: Label 'Office', MaxLength = 50;
        LargeBusinessLbl: Label 'Large Business', MaxLength = 50;
        MediumBusinessLbl: Label 'Medium Business', MaxLength = 50;
        SmallBusinessLbl: Label 'Small Business', MaxLength = 50;
        AdministrationLbl: Label 'Administration', MaxLength = 50;
        ProductionLbl: Label 'Production', MaxLength = 50;
        SalesLbl: Label 'Sales', MaxLength = 50;
        SummerLbl: Label 'Summer', MaxLength = 50;
        WinterLbl: Label 'Winter', MaxLength = 50;
        HomeTok: Label 'HOME', MaxLength = 20;
        IndustrialTok: Label 'INDUSTRIAL', MaxLength = 20;
        OfficeTok: Label 'OFFICE', MaxLength = 20;
        LargeBusinessTok: Label 'LARGE', MaxLength = 20;
        MediumBusinessTok: Label 'MEDIUM', MaxLength = 20;
        SmallBusinessTok: Label 'SMALL', MaxLength = 20;
        AdministrationTok: Label 'ADM', MaxLength = 20;
        ProductionTok: Label 'PROD', MaxLength = 20;
        SalesTok: Label 'SALES', MaxLength = 20;
        SummerTok: Label 'SUMMER', MaxLength = 20;
        WinterTok: Label 'WINTER', MaxLength = 20;
}