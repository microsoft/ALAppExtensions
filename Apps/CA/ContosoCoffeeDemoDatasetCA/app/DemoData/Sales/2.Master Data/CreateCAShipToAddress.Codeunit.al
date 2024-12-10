codeunit 27027 "Create CA Ship-to Address"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO: PostCode Later to be replaced from Labels

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticAdatumCorporation(), Calgary(), AdatumCorporationLbl, CalgaryAddressLbl, CalgaryCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'T2H 0K8');
        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticAdatumCorporation(), London(), AdatumCorporationLbl, EdmontonAddressLbl, CalgaryCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'T5T 4J2');
        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticTreyResearch(), Fleet(), TreyResearchLbl, TorontoAddressLbl, OttawaCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'M5B 2H1');
        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticTreyResearch(), TWYCross(), TreyResearchLbl, VancouverAddressLbl, VancouverCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'V7Y 1GS');

        UpdateCountyOnShipToAddress();
    end;

    procedure Calgary(): Code[10]
    begin
        exit(CalgaryTok);
    end;

    procedure London(): Code[10]
    begin
        exit(EdmontonTok);
    end;

    procedure Fleet(): Code[10]
    begin
        exit(TorontoTok);
    end;

    procedure TWYCross(): Code[10]
    begin
        exit(VancouverTok);
    end;

    local procedure UpdateCountyOnShipToAddress()
    var
        CreateCustomer: Codeunit "Create Customer";
    begin
        UpdateCounty(CreateCustomer.DomesticAdatumCorporation(), Calgary(), AbCountyLbl);
        UpdateCounty(CreateCustomer.DomesticAdatumCorporation(), London(), AbCountyLbl);
        UpdateCounty(CreateCustomer.DomesticTreyResearch(), Fleet(), OnCountyLbl);
        UpdateCounty(CreateCustomer.DomesticTreyResearch(), TWYCross(), BcCountyLbl);
    end;

    local procedure UpdateCounty(CustomerNo: Code[20]; Code: Code[20]; County: Text[30])
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        if ShiptoAddress.Get(CustomerNo, Code) then begin
            ShiptoAddress.Validate(County, County);
            ShiptoAddress.Modify(true);
        end;
    end;

    var
        CalgaryTok: Label 'CALGARY', MaxLength = 10;
        EdmontonTok: Label 'EDMONTON', MaxLength = 10;
        TorontoTok: Label 'TORONTO', MaxLength = 10;
        VancouverTok: Label 'VANCOUVER', MaxLength = 10;
        AdatumCorporationLbl: Label 'Adatum Corporation', MaxLength = 100;
        TreyResearchLbl: Label 'Trey Research', MaxLength = 100;
        CalgaryAddressLbl: Label '6455 Macleod Trail SW', MaxLength = 100;
        EdmontonAddressLbl: Label '1723,  8882 170 Street', MaxLength = 100;
        TorontoAddressLbl: Label '220 Yonge Street', MaxLength = 100;
        VancouverAddressLbl: Label '701 West Georgia Street', MaxLength = 100;
        CalgaryCityLbl: Label 'Calgary', MaxLength = 30;
        OttawaCityLbl: Label 'Ottawa', MaxLength = 30;
        VancouverCityLbl: Label 'Vancouver', MaxLength = 30;
        AbCountyLbl: Label 'AB', MaxLength = 30;
        OnCountyLbl: Label 'ON', MaxLength = 30;
        BcCountyLbl: Label 'BC', MaxLength = 30;
}