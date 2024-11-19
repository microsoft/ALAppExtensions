codeunit 5235 "Create Web Source"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertWebSource(Adatum(), AdatumDescriptionLbl, AdatumURLLbl);
        ContosoCRM.InsertWebSource(Contoso(), ContosoDescriptionLbl, ContosoURLLbl);
        ContosoCRM.InsertWebSource(Fabrikam(), FabrikamDescriptionLbl, FabrikamURLLbl);
        ContosoCRM.InsertWebSource(Lucerne(), LucerneDescriptionLbl, LucerneURLLbl);
        ContosoCRM.InsertWebSource(USStock(), USStockDescriptionLbl, USStockURLLbl);
    end;

    procedure Adatum(): Code[10]
    begin
        exit(AdatumTok);
    end;

    procedure Contoso(): Code[10]
    begin
        exit(ContosoTok);
    end;

    procedure Fabrikam(): Code[10]
    begin
        exit(FabrikamTok);
    end;

    procedure Lucerne(): Code[10]
    begin
        exit(LucerneTok);
    end;

    procedure USStock(): Code[10]
    begin
        exit(USStockTok);
    end;


    var
        AdatumTok: Label 'ADATUM', MaxLength = 10;
        ContosoTok: Label 'CONTOSO', MaxLength = 10;
        FabrikamTok: Label 'FABRIKAM', MaxLength = 10;
        LucerneTok: Label 'LUCERNE', MaxLength = 10;
        USStockTok: Label 'US-STOCK', MaxLength = 10;
        AdatumDescriptionLbl: Label 'Adatum', MaxLength = 100;
        ContosoDescriptionLbl: Label 'Contoso, Ltd.', MaxLength = 100;
        FabrikamDescriptionLbl: Label '​Fabrikam, Inc.', MaxLength = 100;
        LucerneDescriptionLbl: Label 'Lucerne Publishing', MaxLength = 100;
        USStockDescriptionLbl: Label 'Stock info by symbol', MaxLength = 100;
        AdatumURLLbl: Label 'http://www.adatum.com/', MaxLength = 250, Locked = true;
        ContosoURLLbl: Label 'http://www.contoso.com/', MaxLength = 250, Locked = true;
        FabrikamURLLbl: Label 'http://www.fabrikam.com/', MaxLength = 250, Locked = true;
        LucerneURLLbl: Label 'http://www.lucernepublishing.com/', MaxLength = 250, Locked = true;
        USStockURLLbl: Label '​http://firstupconsultants.com', MaxLength = 250, Locked = true;
}