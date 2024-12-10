codeunit 5572 "Create Industry Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertIndustryGroup(Advert(), AdvertisingLbl);
        ContosoCRM.InsertIndustryGroup(Lawyer(), LawyerOrAccountantLbl);
        ContosoCRM.InsertIndustryGroup(Man(), ManufacturerLbl);
        ContosoCRM.InsertIndustryGroup(Press(), TvStationRadioOrPressLbl);
        ContosoCRM.InsertIndustryGroup(Ret(), RetailLbl);
        ContosoCRM.InsertIndustryGroup(Whole(), WholesaleLbl);
    end;

    procedure Advert(): Code[10]
    begin
        exit(AdvertTok);
    end;

    procedure Lawyer(): Code[10]
    begin
        exit(LawyerTok);
    end;

    procedure Man(): Code[10]
    begin
        exit(ManTok);
    end;

    procedure Press(): Code[10]
    begin
        exit(PressTok);
    end;

    procedure Ret(): Code[10]
    begin
        exit(RetTok);
    end;

    procedure Whole(): Code[10]
    begin
        exit(WholeTok);
    end;

    var
        AdvertTok: Label 'ADVERT', MaxLength = 10;
        LawyerTok: Label 'LAWYER', MaxLength = 10;
        ManTok: Label 'MAN', MaxLength = 10;
        PressTok: Label 'PRESS', MaxLength = 10;
        RetTok: Label 'RET', MaxLength = 10;
        WholeTok: Label 'WHOLE', MaxLength = 10;
        AdvertisingLbl: Label 'Advertising', MaxLength = 100;
        LawyerOrAccountantLbl: Label 'Lawyer or Accountant', MaxLength = 100;
        ManufacturerLbl: Label 'Manufacturer', MaxLength = 100;
        TvStationRadioOrPressLbl: Label 'TV-station, Radio or Press', MaxLength = 100;
        RetailLbl: Label 'Retail', MaxLength = 100;
        WholesaleLbl: Label 'Wholesale', MaxLength = 100;
}