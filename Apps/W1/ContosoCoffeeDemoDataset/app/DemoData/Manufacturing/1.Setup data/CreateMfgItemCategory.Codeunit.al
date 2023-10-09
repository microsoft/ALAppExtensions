codeunit 4766 "Create Mfg Item Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemCategory(CoffeeMakerCode(), CoffeeMakersLbl, '');
        ContosoItem.InsertItemCategory(PartCode(), PartsLbl, '');
        ContosoItem.InsertItemCategory(ConsumerModelCode(), ConsumerModelsLbl, CoffeeMakerCode());
        ContosoItem.InsertItemCategory(CommercialModelCode(), CommercialModelsLbl, CoffeeMakerCode());
    end;

    var
        CoffeeMakerTok: Label 'CM', MaxLength = 20;
        CoffeeMakersLbl: Label 'Coffee Makers', MaxLength = 100;
        PartTok: Label 'PARTS', MaxLength = 20;
        PartsLbl: Label 'Parts', MaxLength = 100;
        ConsumerModelTok: Label 'CM_Consum', MaxLength = 20;
        ConsumerModelsLbl: Label 'Consumer Models', MaxLength = 100;
        CommercialModelTok: Label 'CM_Commer', MaxLength = 20;
        CommercialModelsLbl: Label 'Commercial Models', MaxLength = 100;

    procedure CoffeeMakerCode(): Code[20]
    begin
        exit(CoffeeMakerTok);
    end;

    procedure PartCode(): Code[20]
    begin
        exit(PartTok);
    end;

    procedure ConsumerModelCode(): Code[20]
    begin
        exit(ConsumerModelTok);
    end;

    procedure CommercialModelCode(): Code[20]
    begin
        exit(CommercialModelTok);
    end;
}