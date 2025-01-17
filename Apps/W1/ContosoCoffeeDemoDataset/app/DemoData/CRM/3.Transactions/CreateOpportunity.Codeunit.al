codeunit 5678 "Create Opportunity"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateSalesCycle: Codeunit "Create Sales Cycle";
        CreateSalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateCustomer: Codeunit "Create Customer";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateCloseOpportunityCode: Codeunit "Create Close Opportunity Code";
    begin
        ContosoCRM.InsertOpportunity(OP100015(), AssemblingFurnitureLbl, CreateSalespersonPurchaser.JimOlive(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19030104D), Enum::"Opportunity Status"::Won, Enum::"Opportunity Priority"::Low, true, ContosoUtilities.AdjustDate(19030126D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100016(), AssemblingFurnitureLbl, CreateSalespersonPurchaser.JimOlive(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19030104D), Enum::"Opportunity Status"::Won, Enum::"Opportunity Priority"::Normal, true, ContosoUtilities.AdjustDate(19030121D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100017(), AssemblingFurnitureLbl, CreateSalespersonPurchaser.OtisFalls(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19030106D), Enum::"Opportunity Status"::Won, Enum::"Opportunity Priority"::Normal, true, ContosoUtilities.AdjustDate(19030120D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100018(), FurnitureToSalesDepartmentLbl, CreateSalespersonPurchaser.JimOlive(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 0), CreateSalesCycle.NewSalesCycle(), ContosoUtilities.AdjustDate(19030106D), Enum::"Opportunity Status"::Won, Enum::"Opportunity Priority"::Low, true, ContosoUtilities.AdjustDate(19030120D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100019(), FurnitureForConferenceLbl, CreateSalespersonPurchaser.JimOlive(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19030101D), Enum::"Opportunity Status"::Won, Enum::"Opportunity Priority"::Normal, true, ContosoUtilities.AdjustDate(19030111D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100022(), StorageFacilitiesLbl, CreateSalespersonPurchaser.BenjaminChiu(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19030121D), Enum::"Opportunity Status"::"In Progress", Enum::"Opportunity Priority"::Normal, false, 0D, CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100023(), SwivelChairLbl, CreateSalespersonPurchaser.BenjaminChiu(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19021111D), Enum::"Opportunity Status"::"In Progress", Enum::"Opportunity Priority"::Normal, false, 0D, CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100024(), TableLightingLbl, CreateSalespersonPurchaser.HelenaRay(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19021214D), Enum::"Opportunity Status"::"In Progress", Enum::"Opportunity Priority"::Normal, false, 0D, CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100025(), GuestChairsForReceptionLbl, CreateSalespersonPurchaser.HelenaRay(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19030124D), Enum::"Opportunity Status"::"In Progress", Enum::"Opportunity Priority"::Low, false, 0D, CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100026(), StorageSystemLbl, CreateSalespersonPurchaser.HelenaRay(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19021126D), Enum::"Opportunity Status"::"In Progress", Enum::"Opportunity Priority"::High, false, 0D, CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100027(), DesksForServiceDepartmentLbl, CreateSalespersonPurchaser.JimOlive(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19021101D), Enum::"Opportunity Status"::"Not Started", Enum::"Opportunity Priority"::Normal, false, 0D, CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100037(), ConferenceTableLbl, CreateSalespersonPurchaser.OtisFalls(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 0), CreateSalesCycle.NewSalesCycle(), ContosoUtilities.AdjustDate(19020926D), Enum::"Opportunity Status"::Lost, Enum::"Opportunity Priority"::Normal, true, ContosoUtilities.AdjustDate(19021016D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100038(), NewOfficeSystemLbl, CreateSalespersonPurchaser.OtisFalls(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 0), CreateSalesCycle.NewSalesCycle(), ContosoUtilities.AdjustDate(19020922D), Enum::"Opportunity Status"::Lost, Enum::"Opportunity Priority"::High, true, ContosoUtilities.AdjustDate(19021003D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100039(), CompleteStorageSystemLbl, CreateSalespersonPurchaser.HelenaRay(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 0), CreateSalesCycle.NewSalesCycle(), ContosoUtilities.AdjustDate(19030105D), Enum::"Opportunity Status"::Lost, Enum::"Opportunity Priority"::Normal, true, ContosoUtilities.AdjustDate(19030116D), CreateNoSeries.Opportunity());
        ContosoCRM.InsertOpportunity(OP100040(), ChairsBlueLbl, CreateSalespersonPurchaser.BenjaminChiu(), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 1), ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 0), CreateSalesCycle.ExistingSalesCycle(), ContosoUtilities.AdjustDate(19030109D), Enum::"Opportunity Status"::Lost, Enum::"Opportunity Priority"::High, true, ContosoUtilities.AdjustDate(19030124D), CreateNoSeries.Opportunity());

        ContosoCRM.InsertOpportunityEntry(2, OP100015(), 1, ContosoUtilities.AdjustDate(19030119D), ContosoUtilities.AdjustDate(19030106D), false, ContosoUtilities.AdjustDate(0D), 0, 10000, 2, 10, '', 0);
        ContosoCRM.InsertOpportunityEntry(3, OP100015(), 2, ContosoUtilities.AdjustDate(19030119D), ContosoUtilities.AdjustDate(19030107D), false, ContosoUtilities.AdjustDate(0D), 1, 10000, 50, 30, '', 1);
        ContosoCRM.InsertOpportunityEntry(4, OP100015(), 3, ContosoUtilities.AdjustDate(19030119D), ContosoUtilities.AdjustDate(19030111D), false, ContosoUtilities.AdjustDate(0D), 1, 12000, 80, 55, '', 2);
        ContosoCRM.InsertOpportunityEntry(5, OP100015(), 4, ContosoUtilities.AdjustDate(19030119D), ContosoUtilities.AdjustDate(19030113D), false, ContosoUtilities.AdjustDate(0D), 1, 9000, 95, 95, '', 3);
        ContosoCRM.InsertOpportunityEntry(7, OP100015(), 0, ContosoUtilities.AdjustDate(19030126D), ContosoUtilities.AdjustDate(19030126D), true, ContosoUtilities.AdjustDate(19030126D), 5, 9000, 100, 100, CreateCloseOpportunityCode.BusinessW(), 4);
        ContosoCRM.InsertOpportunityEntry(8, OP100016(), 1, ContosoUtilities.AdjustDate(19030121D), ContosoUtilities.AdjustDate(19030106D), false, ContosoUtilities.AdjustDate(0D), 0, 5000, 2, 20, '', 0);
        ContosoCRM.InsertOpportunityEntry(9, OP100016(), 2, ContosoUtilities.AdjustDate(19030121D), ContosoUtilities.AdjustDate(19030108D), false, ContosoUtilities.AdjustDate(0D), 1, 5500, 50, 35, '', 1);
        ContosoCRM.InsertOpportunityEntry(10, OP100016(), 3, ContosoUtilities.AdjustDate(19030121D), ContosoUtilities.AdjustDate(19030112D), false, ContosoUtilities.AdjustDate(0D), 1, 5500, 80, 65, '', 2);
        ContosoCRM.InsertOpportunityEntry(11, OP100016(), 4, ContosoUtilities.AdjustDate(19030121D), ContosoUtilities.AdjustDate(19030117D), false, ContosoUtilities.AdjustDate(0D), 1, 5500, 95, 90, '', 3);
        ContosoCRM.InsertOpportunityEntry(12, OP100016(), 0, ContosoUtilities.AdjustDate(19030121D), ContosoUtilities.AdjustDate(19030121D), true, ContosoUtilities.AdjustDate(19030121D), 5, 5500, 100, 100, CreateCloseOpportunityCode.ConsultW(), 4);
        ContosoCRM.InsertOpportunityEntry(13, OP100017(), 1, ContosoUtilities.AdjustDate(19030117D), ContosoUtilities.AdjustDate(19030106D), false, ContosoUtilities.AdjustDate(0D), 0, 8000, 2, 25, '', 0);
        ContosoCRM.InsertOpportunityEntry(14, OP100017(), 2, ContosoUtilities.AdjustDate(19030117D), ContosoUtilities.AdjustDate(19030111D), false, ContosoUtilities.AdjustDate(0D), 1, 7000, 50, 50, '', 1);
        ContosoCRM.InsertOpportunityEntry(15, OP100017(), 3, ContosoUtilities.AdjustDate(19030117D), ContosoUtilities.AdjustDate(19030112D), false, ContosoUtilities.AdjustDate(0D), 1, 7000, 80, 65, '', 2);
        ContosoCRM.InsertOpportunityEntry(16, OP100017(), 4, ContosoUtilities.AdjustDate(19030117D), ContosoUtilities.AdjustDate(19030114D), false, ContosoUtilities.AdjustDate(0D), 1, 6000, 95, 70, '', 3);
        ContosoCRM.InsertOpportunityEntry(17, OP100017(), 0, ContosoUtilities.AdjustDate(19030120D), ContosoUtilities.AdjustDate(19030120D), true, ContosoUtilities.AdjustDate(19030120D), 5, 6000, 100, 100, CreateCloseOpportunityCode.RelationW(), 4);
        ContosoCRM.InsertOpportunityEntry(18, OP100018(), 1, ContosoUtilities.AdjustDate(19030120D), ContosoUtilities.AdjustDate(19030109D), false, ContosoUtilities.AdjustDate(0D), 0, 25000, 2, 30, '', 0);
        ContosoCRM.InsertOpportunityEntry(19, OP100018(), 2, ContosoUtilities.AdjustDate(19030120D), ContosoUtilities.AdjustDate(19030113D), false, ContosoUtilities.AdjustDate(0D), 1, 20000, 5, 50, '', 1);
        ContosoCRM.InsertOpportunityEntry(20, OP100018(), 3, ContosoUtilities.AdjustDate(19030120D), ContosoUtilities.AdjustDate(19030114D), false, ContosoUtilities.AdjustDate(0D), 1, 21000, 40, 70, '', 2);
        ContosoCRM.InsertOpportunityEntry(21, OP100018(), 4, ContosoUtilities.AdjustDate(19030120D), ContosoUtilities.AdjustDate(19030115D), false, ContosoUtilities.AdjustDate(0D), 1, 21000, 60, 95, '', 3);
        ContosoCRM.InsertOpportunityEntry(23, OP100018(), 0, ContosoUtilities.AdjustDate(19030120D), ContosoUtilities.AdjustDate(19030120D), true, ContosoUtilities.AdjustDate(19030120D), 5, 21000, 100, 100, CreateCloseOpportunityCode.PriceW(), 4);
        ContosoCRM.InsertOpportunityEntry(24, OP100019(), 1, ContosoUtilities.AdjustDate(19030111D), ContosoUtilities.AdjustDate(19030103D), false, ContosoUtilities.AdjustDate(0D), 0, 7500, 2, 25, '', 0);
        ContosoCRM.InsertOpportunityEntry(25, OP100019(), 2, ContosoUtilities.AdjustDate(19030111D), ContosoUtilities.AdjustDate(19030105D), false, ContosoUtilities.AdjustDate(0D), 1, 8000, 50, 55, '', 1);
        ContosoCRM.InsertOpportunityEntry(26, OP100019(), 3, ContosoUtilities.AdjustDate(19030111D), ContosoUtilities.AdjustDate(19030106D), false, ContosoUtilities.AdjustDate(0D), 1, 8000, 80, 80, '', 2);
        ContosoCRM.InsertOpportunityEntry(27, OP100019(), 4, ContosoUtilities.AdjustDate(19030111D), ContosoUtilities.AdjustDate(19030107D), false, ContosoUtilities.AdjustDate(0D), 1, 8000, 95, 80, '', 3);
        ContosoCRM.InsertOpportunityEntry(29, OP100019(), 0, ContosoUtilities.AdjustDate(19030111D), ContosoUtilities.AdjustDate(19030111D), true, ContosoUtilities.AdjustDate(19030111D), 5, 8000, 100, 100, CreateCloseOpportunityCode.ProductW(), 4);
        ContosoCRM.InsertOpportunityEntry(41, OP100022(), 1, ContosoUtilities.AdjustDate(19030203D), ContosoUtilities.AdjustDate(19030124D), true, ContosoUtilities.AdjustDate(0D), 0, 5000, 2, 25, '', 0);
        ContosoCRM.InsertOpportunityEntry(42, OP100023(), 1, ContosoUtilities.AdjustDate(19030216D), ContosoUtilities.AdjustDate(19021116D), true, ContosoUtilities.AdjustDate(0D), 0, 500, 2, 95, '', 0);
        ContosoCRM.InsertOpportunityEntry(43, OP100024(), 1, ContosoUtilities.AdjustDate(19030321D), ContosoUtilities.AdjustDate(19021215D), true, ContosoUtilities.AdjustDate(0D), 0, 2000, 2, 30, '', 0);
        ContosoCRM.InsertOpportunityEntry(44, OP100025(), 1, ContosoUtilities.AdjustDate(19030201D), ContosoUtilities.AdjustDate(19030126D), true, ContosoUtilities.AdjustDate(0D), 0, 10000, 2, 20, '', 0);
        ContosoCRM.InsertOpportunityEntry(45, OP100026(), 1, ContosoUtilities.AdjustDate(19030304D), ContosoUtilities.AdjustDate(19021129D), true, ContosoUtilities.AdjustDate(0D), 0, 3000, 2, 10, '', 0);
        ContosoCRM.InsertOpportunityEntry(62, OP100037(), 1, ContosoUtilities.AdjustDate(19021003D), ContosoUtilities.AdjustDate(19020928D), false, ContosoUtilities.AdjustDate(0D), 0, 450, 2, 10, '', 0);
        ContosoCRM.InsertOpportunityEntry(63, OP100037(), 0, ContosoUtilities.AdjustDate(19021016D), ContosoUtilities.AdjustDate(19021016D), true, ContosoUtilities.AdjustDate(19021016D), 6, 450, 100, 0, CreateCloseOpportunityCode.BusinessL(), 1);
        ContosoCRM.InsertOpportunityEntry(64, OP100038(), 0, ContosoUtilities.AdjustDate(19021003D), ContosoUtilities.AdjustDate(19021003D), true, ContosoUtilities.AdjustDate(19021003D), 6, 0, 100, 0, CreateCloseOpportunityCode.ConsultL(), 0);
        ContosoCRM.InsertOpportunityEntry(65, OP100039(), 0, ContosoUtilities.AdjustDate(19030116D), ContosoUtilities.AdjustDate(19030116D), true, ContosoUtilities.AdjustDate(19030116D), 6, 0, 100, 0, CreateCloseOpportunityCode.RelationL(), 0);
        ContosoCRM.InsertOpportunityEntry(66, OP100040(), 0, ContosoUtilities.AdjustDate(19030124D), ContosoUtilities.AdjustDate(19030124D), true, ContosoUtilities.AdjustDate(19030124D), 6, 0, 100, 0, CreateCloseOpportunityCode.PriceL(), 0);

    end;

    procedure OP100015(): Code[10]
    begin
        exit(OP100015Tok);
    end;

    procedure OP100016(): Code[10]
    begin
        exit(OP100016Tok);
    end;

    procedure OP100017(): Code[10]
    begin
        exit(OP100017Tok);
    end;

    procedure OP100018(): Code[10]
    begin
        exit(OP100018Tok);
    end;

    procedure OP100019(): Code[10]
    begin
        exit(OP100019Tok);
    end;

    procedure OP100022(): Code[10]
    begin
        exit(OP100022Tok);
    end;

    procedure OP100023(): Code[10]
    begin
        exit(OP100023Tok);
    end;

    procedure OP100024(): Code[10]
    begin
        exit(OP100024Tok);
    end;

    procedure OP100025(): Code[10]
    begin
        exit(OP100025Tok);
    end;

    procedure OP100026(): Code[10]
    begin
        exit(OP100026Tok);
    end;

    procedure OP100027(): Code[10]
    begin
        exit(OP100027Tok);
    end;

    procedure OP100037(): Code[10]
    begin
        exit(OP100037Tok);
    end;

    procedure OP100038(): Code[10]
    begin
        exit(OP100038Tok);
    end;

    procedure OP100039(): Code[10]
    begin
        exit(OP100039Tok);
    end;

    procedure OP100040(): Code[10]
    begin
        exit(OP100040Tok);
    end;


    var
        OP100015Tok: Label 'OP100015', Locked = true;
        OP100016Tok: Label 'OP100016', Locked = true;
        OP100017Tok: Label 'OP100017', Locked = true;
        OP100018Tok: Label 'OP100018', Locked = true;
        OP100019Tok: Label 'OP100019', Locked = true;
        OP100022Tok: Label 'OP100022', Locked = true;
        OP100023Tok: Label 'OP100023', Locked = true;
        OP100024Tok: Label 'OP100024', Locked = true;
        OP100025Tok: Label 'OP100025', Locked = true;
        OP100026Tok: Label 'OP100026', Locked = true;
        OP100027Tok: Label 'OP100027', Locked = true;
        OP100037Tok: Label 'OP100037', Locked = true;
        OP100038Tok: Label 'OP100038', Locked = true;
        OP100039Tok: Label 'OP100039', Locked = true;
        OP100040Tok: Label 'OP100040', Locked = true;
        AssemblingFurnitureLbl: Label 'Assembling furniture', MaxLength = 100;
        FurnitureToSalesDepartmentLbl: Label 'Furniture to sales department', MaxLength = 100;
        FurnitureForConferenceLbl: Label 'Furniture for the conference', MaxLength = 100;
        StorageFacilitiesLbl: Label 'Storage facilities', MaxLength = 100;
        SwivelChairLbl: Label 'Swivel chair', MaxLength = 100;
        TableLightingLbl: Label 'Table lighting', MaxLength = 100;
        StorageSystemLbl: Label 'Storage system', MaxLength = 100;
        DesksForServiceDepartmentLbl: Label 'Desks for the service dept.', MaxLength = 100;
        ConferenceTableLbl: Label 'Conference table', MaxLength = 100;
        NewOfficeSystemLbl: Label 'New office system', MaxLength = 100;
        CompleteStorageSystemLbl: Label 'Complete storage system', MaxLength = 100;
        ChairsBlueLbl: Label '30 chairs, blue', MaxLength = 100;
        GuestChairsForReceptionLbl: Label 'Guest chairs for the reception', MaxLength = 100;
}