codeunit 1921 "QB Migration Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;


    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        MigrationQBCustomer: Record "MigrationQB Customer";
        MigrationQBVendor: Record "MigrationQB Vendor";
        MigrationQBConfig: Record "MigrationQB Config";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB Account");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB Customer");
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(CompanyName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(GivenName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(FamilyName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(DisplayName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(BillAddrLine1));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(BillAddrLine2));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(BillAddrCity));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(BillAddrCountry));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(BillAddrState));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(BillAddrPostalCode));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(BillAddrCountrySubDivCode));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(PrimaryPhone));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(PrimaryEmailAddr));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(WebAddr));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Customer", MigrationQBCustomer.FieldNo(Fax));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB CustomerTrans");


        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB Config");
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Config", MigrationQBConfig.FieldNo("Zip File"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Config", MigrationQBConfig.FieldNo("Unziped Folder"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Config", MigrationQBConfig.FieldNo("Realm Id"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB Account Setup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB Item");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB Vendor");
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(CompanyName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(GivenName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(FamilyName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(DisplayName));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(BillAddrLine1));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(BillAddrLine2));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(BillAddrCity));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(BillAddrCountry));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(BillAddrState));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(BillAddrPostalCode));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(BillAddrCountrySubDivCode));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(PrimaryPhone));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(PrimaryEmailAddr));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(WebAddr));
        DataClassificationMgt.SetFieldToPersonal(Database::"MigrationQB Vendor", MigrationQBVendor.FieldNo(Fax));


        DataClassificationMgt.SetTableFieldsToNormal(Database::"MigrationQB VendorTrans");
    end;

}