codeunit 11494 "Create GB Customer"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        UpdateDimensionOnCustomer(CreateCustomer.DomesticAdatumCorporation(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.SmallBusinessCustomerGroup());
        UpdateDimensionOnCustomer(CreateCustomer.DomesticTreyResearch(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.MediumBusinessCustomerGroup());
        UpdateDimensionOnCustomer(CreateCustomer.ExportSchoolofArt(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.LargeBusinessCustomerGroup());
        UpdateDimensionOnCustomer(CreateCustomer.EUAlpineSkiHouse(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.SmallBusinessCustomerGroup());
        UpdateDimensionOnCustomer(CreateCustomer.DomesticRelecloud(), CreateDimensionValue.SalesDepartment(), CreateDimensionValue.MediumBusinessCustomerGroup());
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record Customer; RunTrigger: Boolean)
    var
        CreateCustomer: Codeunit "Create Customer";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateRecordFields(Rec, DomesticAdatumCorporationVATLbl, false);
            CreateCustomer.DomesticTreyResearch():
                ValidateRecordFields(Rec, DomesticTreyResearchVATLbl, false);
            CreateCustomer.ExportSchoolofArt():
                ValidateRecordFields(Rec, '', true);
            CreateCustomer.EUAlpineSkiHouse():
                ValidateRecordFields(Rec, EUAlpineSkiHouseVATLbl, true);
            CreateCustomer.DomesticRelecloud():
                ValidateRecordFields(Rec, DomesticRelecloudVATLbl, true);
        end;
    end;

    local procedure ValidateRecordFields(var Customer: Record Customer; VATRegistrationNo: Code[20]; TaxLiable: Boolean)
    begin
        Customer.Validate("VAT Registration No.", VATRegistrationNo);
        Customer.Validate("Tax Liable", TaxLiable);
    end;

    local procedure UpdateDimensionOnCustomer(CustomerNo: Code[20]; GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);

        Customer.Validate("Global Dimension 1 Code", GlobalDimension1Code);
        Customer.Validate("Global Dimension 2 Code", GlobalDimension2Code);
        Customer.Modify(true);
    end;

    var
        DomesticAdatumCorporationVATLbl: Label 'GB111111111', MaxLength = 20;
        DomesticTreyResearchVATLbl: Label 'GB222222222', MaxLength = 20;
        EUAlpineSkiHouseVATLbl: Label 'DE444444444', MaxLength = 20;
        DomesticRelecloudVATLbl: Label 'GB333333333', MaxLength = 20;
}