// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1864 "C5 VendTable Migrator"
{
    TableNo = "C5 VendTable";

    var
        UninitializedVendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade";
        ReferencedVendorDoesNotExistErr: Label 'Vendor %1 is related to %2, but we couldn’t find %2. Try migrating again.', Comment = '%1 is the current vendor number, %2 is the referenced vendor''s number';
        DeliveryNotFoundErr: Label 'The Delivery ''%1'' was not found.', Comment = '%1 = customer discount group';
        EmployeeNotFoundErr: Label 'The Employee ''%1'' was not found.', Comment = '%1 = employee';
        VendDiscGroupNotFoundErr: Label 'The VendDiscGroup ''%1'' was not found.', Comment = '%1 = vendor discount group';
        PaymentNotFoundErr: Label 'The Payment ''%1'' was not found.', Comment = '%1 = payment';
        GeneralJournalBatchNameTxt: Label 'VENDMIGR', Locked = true;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendor', '', true, true)]
    procedure OnMigrateVendor(VAR Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        C5VendTable: Record "C5 VendTable";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"C5 VendTable" then
            exit;
        C5VendTable.Get(RecordIdToMigrate);
        MigrateVendorDetails(C5VendTable, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorDimensions', '', true, true)]
    procedure OnMigrateVendorDimensions(VAR Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        C5VendTable: Record "C5 VendTable";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"C5 VendTable" then
            exit;

        C5VendTable.Get(RecordIdToMigrate);
        if C5VendTable.Department <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(
                C5HelperFunctions.GetDepartmentDimensionCodeTxt(),
                C5HelperFunctions.GetDepartmentDimensionDescTxt(),
                C5VendTable.Department,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Department", C5VendTable.Department));
        if C5VendTable.Centre <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(
                C5HelperFunctions.GetCostCenterDimensionCodeTxt(),
                C5HelperFunctions.GetCostCenterDimensionDescTxt(),
                C5VendTable.Centre,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Centre", C5VendTable.Centre));
        if C5VendTable.Purpose <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(
                C5HelperFunctions.GetPurposeDimensionCodeTxt(),
                C5HelperFunctions.GetPurposeDimensionDescTxt(),
                C5VendTable.Purpose,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Purpose", C5VendTable.Purpose));
    end;

    local procedure MigrateVendorDetails(C5VendTable: Record "C5 VendTable"; VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade")
    var
        C5VendContact: Record "C5 VendContact";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        PostCode: Code[20];
        City: Text[30];
        CountryRegionCode: Code[10];
    begin
        if not VendorDataMigrationFacade.CreateVendorIfNeeded(C5VendTable.Account, C5VendTable.Name) then
            exit;

        VendorDataMigrationFacade.SetSearchName(C5VendTable.SearchName);
        C5HelperFunctions.ExtractPostCodeAndCity(C5VendTable.ZipCity, C5vENDTable.Country, PostCode, City, CountryRegionCode);
        VendorDataMigrationFacade.SetAddress(C5VendTable.Address1, C5VendTable.Address2, CountryRegionCode, PostCode, City);
        VendorDataMigrationFacade.SetPhoneNo(C5VendTable.Phone);
        VendorDataMigrationFacade.SetTelexNo(C5VendTable.Telex);
        VendorDataMigrationFacade.SetEmail(C5VendTable.Email);
        VendorDataMigrationFacade.SetOurAccountNo(C5VendTable.OurAccount);
        VendorDataMigrationFacade.SetCurrencyCode(C5HelperFunctions.FixLCYCode(C5VendTable.Currency)); // assume the currency is already present
        VendorDataMigrationFacade.SetLanguageCode(C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_));
        VendorDataMigrationFacade.SetPaymentTermsCode(CreatePaymentTermsIfNeeded(C5VendTable.Payment));
        VendorDataMigrationFacade.SetPurchaserCode(CreateSalespersonPurchaserIfNeeded(C5VendTable.Purchaser));
        VendorDataMigrationFacade.SetShipmentMethodCode(CreateShipmentMethodIfNeeded(C5VendTable.Delivery));
        VendorDataMigrationFacade.SetInvoiceDiscCode(CreateVendorInvoiceDiscountIfNeeded(C5VendTable.DiscGroup));

        VendorDataMigrationFacade.SetBlockedType(ConvertBlocked(C5VendTable));
        VendorDataMigrationFacade.SetFaxNo(C5VendTable.Fax);
        VendorDataMigrationFacade.SetVATRegistrationNo(C5VendTable.VatNumber);
        VendorDataMigrationFacade.SetHomePage(C5VendTable.URL);

        // reference to another vendor
        // to make sure the pay to vendor exists
        if (C5VendTable.InvoiceAccount <> '') and not VendorDataMigrationFacade.DoesVendorExist(C5VendTable.InvoiceAccount) then
            Error(StrSubstNo(ReferencedVendorDoesNotExistErr, C5VendTable.Account, C5VendTable.InvoiceAccount));

        VendorDataMigrationFacade.SetPayToVendorNo(C5VendTable.InvoiceAccount); // foreign key

        VendorDataMigrationFacade.SetContact(C5VendTable.Attention);

        C5VendContact.SetRange(Account, C5VendTable.Account);
        C5VendContact.SetRange(PrimaryContact, C5VendContact.PrimaryContact::No);
        if C5VendContact.FindSet() then
            repeat
                C5HelperFunctions.ExtractPostCodeAndCity(C5VendContact.ZipCity, C5VendContact.Country, PostCode, City, CountryRegionCode);
                VendorDataMigrationFacade.SetVendorAlternativeContact(
                    C5VendContact.Name, C5VendContact.Address1, C5VendContact.Address2,
                    PostCode, City, CountryRegionCode, C5VendContact.Email, C5VendContact.Phone,
                    C5VendContact.Fax, C5VendContact.CellPhone);
            until C5VendContact.Next() = 0;
        VendorDataMigrationFacade.ModifyVendor(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorPostingGroups', '', true, true)]
    procedure OnMigrateVendorPostingGroups(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        C5VendTable: Record "C5 VendTable";
        C5VendGroup: Record "C5 VendGroup";
        C5LedTableMigrator: Codeunit "C5 LedTable Migrator";
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if RecordIdToMigrate.TableNo() <> Database::"C5 VendTable" then
            exit;

        C5VendTable.Get(RecordIdToMigrate);
        C5VendGroup.SetRange(Group, C5VendTable.Group);
        C5VendGroup.FindFirst();

        if ChartOfAccountsMigrated and (C5VendGroup.GroupAccount <> '') then
            Sender.CreatePostingSetupIfNeeded(C5VendGroup.Group, C5VendGroup.GroupName, C5LedTableMigrator.FillWithLeadingZeros(C5VendGroup.GroupAccount))
        else
            Sender.CreatePostingSetupIfNeeded(C5VendGroup.Group, C5VendGroup.GroupName, '');

        Sender.SetVendorPostingGroup(C5VendGroup.Group);
        Sender.ModifyVendor(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorTransactions', '', true, true)]
    procedure OnMigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        C5VendTable: Record "C5 VendTable";
        C5VendTrans: Record "C5 VendTrans";
        C5VendGroup: Record "C5 VendGroup";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        C5LedTableMigrator: Codeunit "C5 LedTable Migrator";
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if RecordIdToMigrate.TableNo() <> Database::"C5 VendTable" then
            exit;

        C5VendTable.Get(RecordIdToMigrate);

        Sender.CreateGeneralJournalBatchIfNeeded(GetHardCodedBatchName(), '', '');

        C5VendTrans.SetRange(Account, C5VendTable.Account);
        C5VendTrans.SetRange(Open, C5VendTrans.Open::Yes);
        C5VendTrans.SetRange(BudgetCode, C5VendTrans.BudgetCode::Actual);

        C5VendGroup.SetRange(Group, C5VendTable.Group);
        C5VendGroup.FindFirst();
        if C5VendTrans.FindSet() then
            repeat
                C5HelperFunctions.MigrateExchangeRatesForCurrency(C5VendTrans.Currency);

                Sender.CreateGeneralJournalLine(
                    GetHardCodedBatchName(),
                    'C5MIGRATE',
                    CopyStr(STRSUBSTNO('%1 %2', C5VendTrans.InvoiceNumber, C5VendTrans.Txt), 1, 50),
                    C5VendTrans.Date_,
                    C5VendTrans.DueDate,
                    C5VendTrans.AmountCur,
                    C5VendTrans.AmountMST,
                    C5VendTrans.Currency,
                    C5LedTableMigrator.FillWithLeadingZeros(C5VendGroup.GroupAccount));
                Sender.SetGeneralJournalLineDimension(
                    C5HelperFunctions.GetDepartmentDimensionCodeTxt(),
                    C5HelperFunctions.GetDepartmentDimensionDescTxt(),
                    C5VendTrans.Department,
                    C5HelperFunctions.GetDimensionValueName(Database::"C5 Department", C5VendTrans.Department));
                Sender.SetGeneralJournalLineDimension(
                    C5HelperFunctions.GetCostCenterDimensionCodeTxt(),
                    C5HelperFunctions.GetCostCenterDimensionDescTxt(),
                    C5VendTrans.Centre,
                    C5HelperFunctions.GetDimensionValueName(Database::"C5 Centre", C5VendTrans.Centre));
                Sender.SetGeneralJournalLineDimension(
                    C5HelperFunctions.GetPurposeDimensionCodeTxt(),
                    C5HelperFunctions.GetPurposeDimensionDescTxt(),
                    C5VendTrans.Purpose,
                    C5HelperFunctions.GetDimensionValueName(Database::"C5 Purpose", C5VendTrans.Purpose));
            until C5VendTrans.Next() = 0;
    end;

    local procedure CreatePaymentTermsIfNeeded(C5PaymentTxt: Text[10]): Code[10]
    var
        C5Payment: Record "C5 Payment";
        DueDateAsDateFormula: DateFormula;
        DueDateCalculation: Text;
    begin
        if C5PaymentTxt = '' then
            exit(C5PaymentTxt);

        C5Payment.SetRange(Payment, C5PaymentTxt);
        if not C5Payment.FindFirst() then
            Error(PaymentNotFoundErr, C5PaymentTxt);

        case C5Payment.Method of
            C5Payment.Method::Net:
                DueDateCalculation := '';
            C5Payment.Method::"Cur. month":
                DueDateCalculation := 'CM';
            C5Payment.Method::"Cur. quarter":
                DueDateCalculation := 'CQ';
            C5Payment.Method::"Cur. year":
                DueDateCalculation := 'CY';
            C5Payment.Method::"Cur. week":
                DueDateCalculation := 'CW';
        end;

        case C5Payment.UnitCode of
            C5Payment.UnitCode::Day:
                DueDateCalculation += StrSubstNo('+%1D', C5Payment.Qty);
            C5Payment.UnitCode::Week:
                DueDateCalculation += StrSubstNo('+%1W', C5Payment.Qty);
            C5Payment.UnitCode::Month:
                DueDateCalculation += StrSubstNo('+%1M', C5Payment.Qty);
        end;
        DueDateCalculation := StrSubstNo('<%1>', DueDateCalculation);
        Evaluate(DueDateAsDateFormula, DueDateCalculation);

        exit(UninitializedVendorDataMigrationFacade.CreatePaymentTermsIfNeeded(C5Payment.Payment,
                                                                               C5Payment.Txt,
                                                                               DueDateAsDateFormula));
    end;

    local procedure CreateVendorInvoiceDiscountIfNeeded(C5DiscGroup: Code[10]): Code[20]
    var
        C5VendDiscGroup: Record "C5 VendDiscGroup";
    begin
        if C5DiscGroup = '' then
            exit(C5DiscGroup);

        C5VendDiscGroup.SetRange(DiscGroup, C5DiscGroup);
        if not C5VendDiscGroup.FindFirst() then
            Error(VendDiscGroupNotFoundErr, C5DiscGroup);

        UninitializedVendorDataMigrationFacade.CreateVendorInvoiceDiscountIfNeeded(C5VendDiscGroup.DiscGroup, '', 0, 0);
        exit(C5VendDiscGroup.DiscGroup);
    end;

    local procedure CreateSalespersonPurchaserIfNeeded(C5EmployeeTxt: Code[10]): Code[20]
    var
        C5Employee: Record "C5 Employee";
    begin
        if C5EmployeeTxt = '' then
            exit(C5EmployeeTxt);

        C5Employee.SetRange(Employee, C5EmployeeTxt);
        if not C5Employee.FindFirst() then
            Error(EmployeeNotFoundErr, C5EmployeeTxt);

        exit(UninitializedVendorDataMigrationFacade.CreateSalespersonPurchaserIfNeeded(C5Employee.Employee,
                                                                                       C5Employee.Name,
                                                                                       C5Employee.Phone,
                                                                                       C5Employee.Email));
    end;

    local procedure CreateShipmentMethodIfNeeded(C5DeliveryTxt: Code[10]): Code[10]
    var
        C5Delivery: Record "C5 Delivery";
    begin
        if C5DeliveryTxt = '' then
            exit(C5DeliveryTxt);

        C5Delivery.SetRange(Delivery, C5DeliveryTxt);
        if not C5Delivery.FindFirst() then
            Error(DeliveryNotFoundErr, C5DeliveryTxt);

        exit(UninitializedVendorDataMigrationFacade.CreateShipmentMethodIfNeeded(C5Delivery.Delivery, C5Delivery.Name));
    end;

    local procedure ConvertBLocked(C5VendTable: Record "C5 VendTable"): Option
    var
        BlockedType: Option " ",Payment,All;
    begin
        case C5VendTable.Blocked of
            C5VendTable.Blocked::No:
                exit(BlockedType::" ");
            C5VendTable.Blocked::Invoicing,
            C5VendTable.Blocked::Delivery,
            C5VendTable.Blocked::Yes:
                exit(BlockedType::All);
        end;
    end;

    procedure GetHardCodedBatchName(): Code[10]
    begin
        exit(CopyStr(GeneralJournalBatchNameTxt, 1, 10));
    end;
}