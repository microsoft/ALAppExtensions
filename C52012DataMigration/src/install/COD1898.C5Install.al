// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1898 "C5 Install"
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
        C5LedTrans: Record "C5 LedTrans";
        C5CustTrans: Record "C5 CustTrans";
        C5CustTable: Record "C5 CustTable";
        C5CustContact: Record "C5 CustContact";
        C5VendContact: Record "C5 VendContact";
        C5Employee: Record "C5 Employee";
        C5SchemaParameters: Record "C5 Schema Parameters";
        C5VendTrans: Record "C5 VendTrans";
        C5VendTable: Record "C5 VendTable";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 LedTrans");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 LedTrans", C5LedTrans.FieldNo(CreatedBy));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 LedTable");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 CustDiscGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 ProcCode");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 CustTrans");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTrans", C5CustTrans.FieldNo(ApprovedBy));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 CustGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 CustContact");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(Address1));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(Address2));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(ZipCity));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(Country));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(Phone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(Fax));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(Email));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(CellPhone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustContact", C5CustContact.FieldNo(LocalNumber));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 CustTable");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Address1));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Address2));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(ZipCity));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Country));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Phone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Fax));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(ImageFile));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Language_));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(Email));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(URL));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(CellPhone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(KrakNumber));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 CustTable", C5CustTable.FieldNo(EanNumber));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Schema Parameters");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Schema Parameters", C5SchemaParameters.FieldNo("Zip File"));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Schema Parameters", C5SchemaParameters.FieldNo("Unziped Folder"));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Department");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Centre");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Purpose");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Payment");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Employee");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(Address1));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(Address2));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(ZipCity));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(Phone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(User));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(LocalNumber));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(ImageFile));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(Email));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(Country));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(KrakNumber));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(Language_));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 Employee", C5Employee.FieldNo(CellPhone));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Delivery");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 Country");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 ExchRate");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 CN8Code");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenBOM");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenCustDisc");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenDiscGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenItemGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenLocation");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenPrice");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenPriceGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenTable");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 InvenTrans");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 UnitCode");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 ItemTrackGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 VatGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 VendContact");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(Address1));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(Address2));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(ZipCity));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(Country));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(Phone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(Fax));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(Email));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(CellPhone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendContact", C5VendContact.FieldNo(LocalNumber));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 VendDiscGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 VendGroup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 VendTrans");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTrans", C5VendTrans.FieldNo(ApprovedBy));

        DataClassificationMgt.SetTableFieldsToNormal(Database::"C5 VendTable");
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Name));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Address1));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Address2));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(ZipCity));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Country));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Phone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Fax));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(ImageFile));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Language_));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(Email));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(URL));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(CellPhone));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(KrakNumber));
        DataClassificationMgt.SetFieldToPersonal(Database::"C5 VendTable", C5VendTable.FieldNo(EanNumber));
    end;
}