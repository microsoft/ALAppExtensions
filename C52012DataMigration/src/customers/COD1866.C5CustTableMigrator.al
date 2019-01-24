// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1866 "C5 CustTable Migrator"
{
    TableNo = "C5 CustTable";

    var
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        ReferencedCustomerDoesNotExistErr: Label 'Customer %1 is related to %2, but we couldn’t find %2. Try migrating again.', Comment = '%1 is the current customer number, %2 is the referenced customer''s number';
        CustDiscGroupGroupNotFoundErr: Label 'The CustDiscGroup ''%1'' was not found.', Comment = '%1 = customer discount group';
        DeliveryNotFoundErr: Label 'The Delivery ''%1'' was not found.', Comment = '%1 = customer discount group';
        EmployeeNotFoundErr: Label 'The Employee ''%1'' was not found.', Comment = '%1 = employee';
        InventPriceGroupNotFoundErr: Label 'The InventPriceGroup ''%1'' was not found.', Comment = '%1 = invent price group group';
        ProcCodeNotFoundErr: Label 'The ProcCode ''%1'' was not found.', Comment = '%1 = proc Code ';
        PaymentNotFoundErr: Label 'The Payment ''%1'' was not found.', Comment = '%1 = payment';
        GeneralJournalBatchNameTxt: Label 'CUSTMIGR', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomer', '', true, true)]
    procedure OnMigrateCustomer(VAR Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        C5CustTable: Record "C5 CustTable";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"C5 CustTable" then
            exit;
        C5CustTable.Get(RecordIdToMigrate);
        MigrateCustomerDetails(C5CustTable, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerDimensions', '', true, true)]
    procedure OnMigrateCustomerDimensions(VAR Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        C5CustTable: Record "C5 CustTable";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"C5 CustTable" then
            exit;

        C5CustTable.Get(RecordIdToMigrate);
        if C5CustTable.Department <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(C5HelperFunctions.GetDepartmentDimensionCodeTxt(),
                C5HelperFunctions.GetDepartmentDimensionDescTxt(),
                C5CustTable.Department,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Department", C5CustTable.Department));
        if C5CustTable.Centre <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(C5HelperFunctions.GetCostCenterDimensionCodeTxt(),
                C5HelperFunctions.GetCostCenterDimensionDescTxt(),
                C5CustTable.Centre,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Centre", C5CustTable.Centre));
        if C5CustTable.Purpose <> '' then
            Sender.CreateDefaultDimensionAndRequirementsIfNeeded(C5HelperFunctions.GetPurposeDimensionCodeTxt(),
                C5HelperFunctions.GetPurposeDimensionDescTxt(),
                C5CustTable.Purpose,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Purpose", C5CustTable.Purpose));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerPostingGroups', '', true, true)]
    procedure OnMigrateCustomerPostingGroups(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        C5CustTable: Record "C5 CustTable";
        C5CustGroup: Record "C5 CustGroup";
        C5LedTableMigrator: Codeunit "C5 LedTable Migrator";
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if RecordIdToMigrate.TableNo() <> Database::"C5 CustTable" then
            exit;

        C5CustTable.Get(RecordIdToMigrate);
        C5CustGroup.SetRange(Group, C5CustTable.Group);
        C5CustGroup.FindFirst();

        if ChartOfAccountsMigrated and (C5CustGroup.GroupAccount <> '') then
            Sender.CreatePostingSetupIfNeeded(C5CustGroup.Group,
                                              C5CustGroup.GroupName,
                                              C5LedTableMigrator.FillWithLeadingZeros(C5CustGroup.GroupAccount))
        else
            Sender.CreatePostingSetupIfNeeded(C5CustGroup.Group, C5CustGroup.GroupName, '');
        Sender.SetCustomerPostingGroup(C5CustGroup.Group);
        Sender.ModifyCustomer(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerTransactions', '', true, true)]
    procedure OnMigrateCustomerTransactions(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        C5CustTable: Record "C5 CustTable";
        C5CustGroup: Record "C5 CustGroup";
        C5CustTrans: Record "C5 CustTrans";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        C5LedTableMigrator: Codeunit "C5 LedTable Migrator";
    begin
        if not ChartOfAccountsMigrated then
            exit;
        if RecordIdToMigrate.TableNo() <> Database::"C5 CustTable" then
            exit;

        C5CustTable.Get(RecordIdToMigrate);

        Sender.CreateGeneralJournalBatchIfNeeded(GetHardCodedBatchName(), '', '');

        C5CustGroup.SetRange(Group, C5CustTable.Group);
        C5CustGroup.FindFirst();

        C5CustTrans.SetRange(Account, C5CustTable.Account);
        C5CustTrans.SetRange(Open, C5CustTrans.Open::Yes);
        C5CustTrans.SetRange(BudgetCode, C5CustTrans.BudgetCode::Actual);
        if C5CustTrans.FindSet() then
            repeat
                C5HelperFunctions.MigrateExchangeRatesForCurrency(C5CustTrans.Currency);

                Sender.CreateGeneralJournalLine(
                    GetHardCodedBatchName(),
                    'C5MIGRATE',
                    CopyStr(STRSUBSTNO('%1 %2', C5CustTrans.InvoiceNumber, C5CustTrans.Txt), 1, 50),
                    C5CustTrans.Date_,
                    C5CustTrans.DueDate,
                    C5CustTrans.AmountCur,
                    C5CustTrans.AmountMST,
                    C5CustTrans.Currency,
                    C5LedTableMigrator.FillWithLeadingZeros(C5CustGroup.GroupAccount));
                Sender.SetGeneralJournalLineDimension(C5HelperFunctions.GetDepartmentDimensionCodeTxt(),
                    C5HelperFunctions.GetDepartmentDimensionDescTxt(),
                    C5CustTrans.Department,
                    C5HelperFunctions.GetDimensionValueName(Database::"C5 Department", C5CustTrans.Department));
                Sender.SetGeneralJournalLineDimension(C5HelperFunctions.GetCostCenterDimensionCodeTxt(),
                C5HelperFunctions.GetCostCenterDimensionDescTxt(),
                C5CustTrans.Centre,
                C5HelperFunctions.GetDimensionValueName(Database::"C5 Centre", C5CustTrans.Centre));
                Sender.SetGeneralJournalLineDimension(C5HelperFunctions.GetPurposeDimensionCodeTxt(),
                    C5HelperFunctions.GetPurposeDimensionDescTxt(),
                    C5CustTrans.Purpose,
                    C5HelperFunctions.GetDimensionValueName(Database::"C5 Purpose", C5CustTrans.Purpose));
            until C5CustTrans.Next() = 0;
    end;

    local procedure MigrateCustomerDetails(C5CustTable: Record "C5 CustTable"; CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade")
    var
        C5CustContact: Record "C5 CustContact";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        PostCode: Code[20];
        City: Text[30];
        CountryRegionCode: Code[10];
    begin
        if not CustomerDataMigrationFacade.CreateCustomerIfNeeded(C5CustTable.Account, C5CustTable.Name) then
            exit;

        CustomerDataMigrationFacade.SetSearchName(C5CustTable.SearchName);

        C5HelperFunctions.ExtractPostCodeAndCity(C5CustTable.ZipCity, C5CustTable.Country, PostCode, City, CountryRegionCode);
        CustomerDataMigrationFacade.SetAddress(C5CustTable.Address1, C5CustTable.Address2, CountryRegionCode, PostCode, City);

        CustomerDataMigrationFacade.SetPhoneNo(C5CustTable.Phone);
        CustomerDataMigrationFacade.SetEmail(C5CustTable.Email);
        CustomerDataMigrationFacade.SetTelexNo(C5CustTable.CellPhone);
        CustomerDataMigrationFacade.SetCreditLimitLCY(C5CustTable.BalanceMax);
        CustomerDataMigrationFacade.SetCurrencyCode(C5HelperFunctions.FixLCYCode(C5CustTable.Currency)); // assume the currency is already present
        CustomerDataMigrationFacade.SetCustomerPriceGroup(CreateCustomerPriceGroupIfNeeded(C5CustTable.PriceGroup));
        CustomerDataMigrationFacade.SetLanguageCode(C5HelperFunctions.GetLanguageCodeForC5Language(C5CustTable.Language_));
        CustomerDataMigrationFacade.SetPaymentTermsCode(CreatePaymentTermsIfNeeded(C5CustTable.Payment));
        CustomerDataMigrationFacade.SetSalespersonCode(CreateSalespersonPurchaserIfNeeded(C5CustTable.SalesRep));
        CustomerDataMigrationFacade.SetShipmentMethodCode(CreateShipmentMethodIfNeeded(C5CustTable.Delivery));
        CustomerDataMigrationFacade.SetInvoiceDiscCode(CreateCustomerDiscountGroupIfNeeded(C5CustTable.DiscGroup));

        CustomerDataMigrationFacade.SetBlockedType(ConvertBlocked(C5CustTable));

        // reference to another customer
        // to make sure the bill to customer exists
        if (C5CustTable.InvoiceAccount <> '') and not CustomerDataMigrationFacade.DoesCustomerExist(C5CustTable.InvoiceAccount) then
            Error(StrSubstNo(ReferencedCustomerDoesNotExistErr, C5CustTable.Account, C5CustTable.InvoiceAccount));

        CustomerDataMigrationFacade.SetBillToCustomerNo(C5CustTable.InvoiceAccount);

        CustomerDataMigrationFacade.SetPaymentMethodCode(CreatePaymentMethodIfNeeded(C5CustTable.PaymentMode));
        CustomerDataMigrationFacade.SetFaxNo(C5CustTable.Fax);
        CustomerDataMigrationFacade.SetVATRegistrationNo(C5CustTable.VatNumber);
        CustomerDataMigrationFacade.SetHomePage(C5CustTable.URL);
        CustomerDataMigrationFacade.SetContact(C5CustTable.Attention);

        C5CustContact.SetRange(Account, C5CustTable.Account);
        C5CustContact.SetRange(PrimaryContact, C5CustContact.PrimaryContact::No);
        if C5CustContact.FindSet() then
            repeat
                C5HelperFunctions.ExtractPostCodeAndCity(C5CustContact.ZipCity, C5CustContact.Country, PostCode, City, CountryRegionCode);
                CustomerDataMigrationFacade.SetCustomerAlternativeContact(
                    C5CustContact.Name, C5CustContact.Address1, C5CustContact.Address2,
                    PostCode, City, CountryRegionCode, C5CustContact.Email, C5CustContact.Phone,
                    C5CustContact.Fax, C5CustContact.CellPhone);
            until C5CustContact.Next() = 0;

        CustomerDataMigrationFacade.ModifyCustomer(true);
    end;

    local procedure CreatePaymentTermsIfNeeded(C5PaymentTxt: Code[10]): Code[10]
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

        exit(CustomerDataMigrationFacade.CreatePaymentTermsIfNeeded(
            C5Payment.Payment,
            C5Payment.Txt,
            DueDateAsDateFormula));
    end;

    local procedure CreatePaymentMethodIfNeeded(C5ProcCodeTxt: Text[10]): Code[10]
    var
        C5ProcCode: Record "C5 ProcCode";
    begin
        if C5ProcCodeTxt = '' then
            exit(C5ProcCodeTxt);

        C5ProcCode.SetRange(Code, C5ProcCodeTxt);
        // only migrates the payment methods for customers
        C5ProcCode.SetRange(Type, C5ProcCode.Type::Customer);
        if not C5ProcCode.FindFirst() then
            Error(ProcCodeNotFoundErr, C5ProcCode);

        exit(CustomerDataMigrationFacade.CreatePaymentMethodIfNeeded(C5ProcCode.Code, C5ProcCode.Name));
        // specifications from C5 table 102 are not migrated
    end;

    local procedure CreateCustomerPriceGroupIfNeeded(C5InvenPriceGroupTxt: Code[10]): Code[10]
    var
        C5InvenPriceGroup: Record "C5 InvenPriceGroup";
    begin
        if C5InvenPriceGroupTxt = '' then
            exit(C5InvenPriceGroupTxt);

        C5InvenPriceGroup.SetRange(Group, C5InvenPriceGroupTxt);
        if not C5InvenPriceGroup.FindFirst() then
            Error(InventPriceGroupNotFoundErr, C5InvenPriceGroup);

        exit(CustomerDataMigrationFacade.CreateCustomerPriceGroupIfNeeded(
            C5InvenPriceGroup.Group,
            C5InvenPriceGroup.GroupName,
            C5InvenPriceGroup.InclVat = C5InvenPriceGroup.InclVat::Yes));
    end;

    local procedure CreateSalespersonPurchaserIfNeeded(C5EmployeeTxt: Code[10]): Code[20]
    var
        C5Employee: Record "C5 Employee";
    begin
        if C5EmployeeTxt = '' then
            exit(C5EmployeeTxt);

        C5Employee.SetRange(Employee, C5EmployeeTxt);
        if not C5Employee.FindFirst() then
            Error(EmployeeNotFoundErr, C5Employee);

        exit(CustomerDataMigrationFacade.CreateSalespersonPurchaserIfNeeded(
            C5Employee.Employee,
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
            Error(DeliveryNotFoundErr, C5Delivery);

        exit(CustomerDataMigrationFacade.CreateShipmentMethodIfNeeded(C5Delivery.Delivery, C5Delivery.Name));
    end;

    local procedure CreateCustomerDiscountGroupIfNeeded(C5DiscGroup: Code[10]): Code[20]
    var
        C5CustDiscGroup: Record "C5 CustDiscGroup";
    begin
        if C5DiscGroup = '' then
            exit(C5DiscGroup);

        C5CustDiscGroup.SetRange(DiscGroup, C5DiscGroup);
        if not C5CustDiscGroup.FindFirst() then
            Error(CustDiscGroupGroupNotFoundErr, C5DiscGroup);

        exit(CustomerDataMigrationFacade.CreateCustomerDiscountGroupIfNeeded(C5CustDiscGroup.DiscGroup, C5CustDiscGroup.Comment));
    end;

    local procedure ConvertBLocked(C5CustTable: Record "C5 CustTable"): Option
    var
        Blocked: Option " ",Ship,Invoice,All;
    begin
        case C5CustTable.Blocked of
            C5CustTable.Blocked::No:
                exit(Blocked::" ");
            C5CustTable.Blocked::Invoicing:
                exit(Blocked::Invoice);
            C5CustTable.Blocked::Delivery:
                exit(Blocked::Ship);
            C5CustTable.Blocked::Yes:
                exit(Blocked::All);
        end;
    end;

    procedure GetHardCodedBatchName(): Code[10]
    begin
        exit(CopyStr(GeneralJournalBatchNameTxt, 1, 10));
    end;
}