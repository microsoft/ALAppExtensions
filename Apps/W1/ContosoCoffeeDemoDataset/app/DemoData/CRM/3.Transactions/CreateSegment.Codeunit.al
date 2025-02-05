codeunit 5676 "Create Segment"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateSalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateInteractionTemplate: Codeunit "Create Interaction Template";
        CreateInteractionGroup: Codeunit "Create Interaction Group";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCRM.InsertSegmentHeader(IncreaseSaleSegment(), IncreaseSaleSegmentLbl, CreateSalespersonPurchaser.HelenaRay(), Enum::"Correspondence Type"::"Hard Copy", CreateInteractionTemplate.Bus(), 8, 30, CreateInteractionGroup.Letter(), 1, 1, true);
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 10000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 0));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 20000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 1));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 30000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 0));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 40000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 1));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 50000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 0));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 60000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 1));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 70000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 0));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 80000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 1));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 90000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 0));
        ContosoCRM.InsertSegmentLine(IncreaseSaleSegment(), 100000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 1));

        ContosoCRM.InsertSegmentHeader(EventSegment(), EventSegmentLbl, CreateSalespersonPurchaser.BenjaminChiu(), Enum::"Correspondence Type"::Email, CreateInteractionTemplate.Golf(), 8, 1, CreateInteractionGroup.Letter(), 1, 1, true);

        ContosoCRM.InsertSegmentHeader(WorkingPlaceSegment(), WorkingPlaceSegmentLbl, CreateSalespersonPurchaser.OtisFalls(), Enum::"Correspondence Type"::"Hard Copy", CreateInteractionTemplate.Abstract(), 8, 90, CreateInteractionGroup.Letter(), 1, 0, true);
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 10000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 0));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 20000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticAdatumCorporation(), 1));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 30000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 0));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 40000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.EUAlpineSkiHouse(), 1));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 50000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 0));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 60000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticRelecloud(), 1));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 70000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 0));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 80000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.ExportSchoolofArt(), 1));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 90000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 0));
        ContosoCRM.InsertSegmentLine(WorkingPlaceSegment(), 100000, ContosoCRM.FindContactNo(Enum::"Contact Business Relation Link To Table"::Customer, CreateCustomer.DomesticTreyResearch(), 1));

    end;

    procedure IncreaseSaleSegment(): Code[20]
    begin
        exit(IncreaseSaleSegmentTok);
    end;

    procedure EventSegment(): Code[20]
    begin
        exit(EventSegmentTok);
    end;

    procedure WorkingPlaceSegment(): Code[20]
    begin
        exit(WorkingPlaceSegmentTok);
    end;

    var
        IncreaseSaleSegmentTok: Label 'SM10001', MaxLength = 20;
        EventSegmentTok: Label 'SM10002', MaxLength = 20;
        WorkingPlaceSegmentTok: Label 'SM10004', MaxLength = 20;
        IncreaseSaleSegmentLbl: Label 'Increase sale', MaxLength = 100;
        EventSegmentLbl: Label 'Event', MaxLength = 100;
        WorkingPlaceSegmentLbl: Label 'Working place arrangement, Customer', MaxLength = 100;
}