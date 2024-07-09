namespace Microsoft.DataMigration.GP;

using System.Integration;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;

codeunit 4018 "GP Customer Migrator"
{
    TableNo = "GP Customer";

    var
        GlobalDocumentNo: Text[30];
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        CustomerBatchNameTxt: Label 'GPCUST', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        CustomerEmailTypeCodeLbl: Label 'CUS', Locked = true;
        MigrationLogAreaTxt: Label 'Customer', Locked = true;
        PhoneNumberContainsLettersMsg: Label 'Phone/Fax number skipped because it contains letters. Value=%1', Comment = '%1 is the phone/fax number.';

#pragma warning disable AA0207
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomer', '', true, true)]
    internal procedure OnMigrateCustomer(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPCustomer: Record "GP Customer";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Customer" then
            exit;
        GPCustomer.Get(RecordIdToMigrate);
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
        MigrateCustomerDetails(GPCustomer, Sender);
        MigrateCustomerAddresses(GPCustomer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerPostingGroups', '', true, true)]
    internal procedure OnMigrateCustomerPostingGroups(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PostingGroupNo: Code[20];
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Customer" then
            exit;
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        Sender.CreatePostingSetupIfNeeded(
            CopyStr(PostingGroupCodeTxt, 1, 5),
            CopyStr(PostingGroupDescriptionTxt, 1, 20),
            HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
        );

        PostingGroupNo := CreateCustomerPostingGroupIfNeeded(RecordIdToMigrate);
        Sender.SetCustomerPostingGroup(PostingGroupNo);
        Sender.ModifyCustomer(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerTransactions', '', true, true)]
    internal procedure OnMigrateCustomerTransactions(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        MigrationGPCustomer: Record "GP Customer";
        MigrationGPCustTrans: Record "GP Customer Transactions";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PaymentTermsFormula: DateFormula;
        ReceivablesAccountNo: Code[20];
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Customer" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        if GPCompanyAdditionalSettings.GetMigrateOnlyReceivablesMaster() then
            exit;

        MigrationGPCustomer.Get(RecordIdToMigrate);
        GetCustomerReceivablesAccount(MigrationGPCustomer, GPCompanyAdditionalSettings, ReceivablesAccountNo);

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(CustomerBatchNameTxt, 1, 7), '', '');
        MigrationGPCustTrans.SetRange(CUSTNMBR, MigrationGPCustomer.CUSTNMBR);
        MigrationGPCustTrans.SetRange(TransType, MigrationGPCustTrans.TransType::Invoice);
        if MigrationGPCustTrans.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(MigrationGPCustTrans.RecordId));

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPCustTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50),
                    MigrationGPCustTrans.DOCDATE,
                    0D,
                    MigrationGPCustTrans.CURTRXAM,
                    MigrationGPCustTrans.CURTRXAM,
                    '',
                    ReceivablesAccountNo
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationGPCustTrans.TransType);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20) <> '') then
                    Sender.CreateSalespersonPurchaserIfNeeded(CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20), '', '', '');
                Sender.SetGeneralJournalLineSalesPersonCode(CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20));
                if (CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(Copystr(MigrationGPCustTrans.PYMTRMID, 1, 10), MigrationGPCustTrans.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPCustTrans.DOCNUMBR.Trim(), 1, 35));
            until MigrationGPCustTrans.Next() = 0;

        MigrationGPCustTrans.Reset();
        MigrationGPCustTrans.SetRange(CUSTNMBR, MigrationGPCustomer.CUSTNMBR);
        MigrationGPCustTrans.SetRange(TransType, MigrationGPCustTrans.TransType::Payment);
        if MigrationGPCustTrans.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(MigrationGPCustTrans.RecordId));

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPCustTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50),
                    MigrationGPCustTrans.DOCDATE,
                    MigrationGPCustTrans.DOCDATE,
                    -MigrationGPCustTrans.CURTRXAM,
                    -MigrationGPCustTrans.CURTRXAM,
                    '',
                    ReceivablesAccountNo
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationGPCustTrans.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSalesPersonCode(CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20));
                if (CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(Copystr(MigrationGPCustTrans.PYMTRMID, 1, 10), MigrationGPCustTrans.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPCustTrans.DOCNUMBR.Trim(), 1, 35));
            until MigrationGPCustTrans.Next() = 0;

        MigrationGPCustTrans.Reset();
        MigrationGPCustTrans.SetRange(CUSTNMBR, MigrationGPCustomer.CUSTNMBR);
        MigrationGPCustTrans.SetRange(TransType, MigrationGPCustTrans.TransType::"Credit Memo");
        if MigrationGPCustTrans.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(MigrationGPCustTrans.RecordId));

                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPCustTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50),
                    MigrationGPCustTrans.DOCDATE,
                    0D,
                    -MigrationGPCustTrans.CURTRXAM,
                    -MigrationGPCustTrans.CURTRXAM,
                    '',
                    ReceivablesAccountNo
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationGPCustTrans.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20) <> '') then
                    Sender.CreateSalespersonPurchaserIfNeeded(CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20), '', '', '');
                Sender.SetGeneralJournalLineSalesPersonCode(CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20));
                if (CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(Copystr(MigrationGPCustTrans.PYMTRMID, 1, 10), MigrationGPCustTrans.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPCustTrans.DOCNUMBR.Trim(), 1, 35));
            until MigrationGPCustTrans.Next() = 0;
    end;
#pragma warning restore AA0207

    local procedure CreateCustomerPostingGroupIfNeeded(RecordIdToMigrate: RecordId): Code[20]
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPCustomer: Record "GP Customer";
        GPRM00201: Record "GP RM00201";
        GPRM00101: Record "GP RM00101";
        CustomerPostingGroup: Record "Customer Posting Group";
        HelperFunctions: Codeunit "Helper Functions";
        ClassId: Code[20];
        AccountNumber: Code[20];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateCustomerClasses() then
            exit(PostingGroupCodeTxt);

        if not GPCustomer.Get(RecordIdToMigrate) then
            exit(PostingGroupCodeTxt);

        if not GPRM00101.Get(GPCustomer.CUSTNMBR) then
            exit(PostingGroupCodeTxt);

#pragma warning disable AA0139
        ClassId := GPRM00101.CUSTCLAS.Trim();
#pragma warning restore AA0139

        if ClassId = '' then
            exit(PostingGroupCodeTxt);

        if not GPRM00201.Get(ClassId) then
            exit(PostingGroupCodeTxt);

        if CustomerPostingGroup.Get(ClassId) then
            exit(ClassId);

        CustomerPostingGroup.Validate("Code", ClassId);
        CustomerPostingGroup.Validate("Description", GPRM00201.CLASDSCR);

        // Receivables Account
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPRM00201.RMARACC);
        if AccountNumber = '' then
            AccountNumber := HelperFunctions.GetPostingAccountNumber('ReceivablesAccount');

        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            CustomerPostingGroup.Validate("Receivables Account", AccountNumber);
        end;

        // Payment Disc. Debit Acc.
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPRM00201.RMTAKACC);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", AccountNumber);
        end;

        // Additional Fee Account
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPRM00201.RMFCGACC);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            CustomerPostingGroup.Validate("Additional Fee Account", AccountNumber);
        end;

        // Payment Disc. Credit Acc.
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPRM00201.RMAVACC);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", AccountNumber);
        end;

        // Payment Tolerance Debit Acc.
        // Payment Tolerance Credit Acc.
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPRM00201.RMWRACC);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", AccountNumber);
            CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", AccountNumber);
        end;

        CustomerPostingGroup.Insert();

        exit(ClassId);
    end;

    local procedure MigrateCustomerDetails(MigrationGPCustomer: Record "GP Customer"; CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade")
    var
        CompanyInformation: Record "Company Information";
        GPKnownCountries: Record "GP Known Countries";
        GPRM00101: Record "GP RM00101";
        GPSY01200: Record "GP SY01200";
        Customer: Record Customer;
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PaymentTermsFormula: DateFormula;
        Country: Code[10];
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
        FoundKnownCountry: Boolean;
        CountryCodeISO2: Code[2];
        CountryName: Text[50];
    begin
        if not CustomerDataMigrationFacade.CreateCustomerIfNeeded(CopyStr(MigrationGPCustomer.CUSTNMBR, 1, 20), CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50)) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(MigrationGPCustomer.RecordId));

        Country := CopyStr(MigrationGPCustomer.COUNTRY.Trim(), 1, 10);
        if Country <> '' then begin
            GPKnownCountries.SearchKnownCountry(Country, FoundKnownCountry, CountryCodeISO2, CountryName);
            if FoundKnownCountry then
                Country := CustomerDataMigrationFacade.CreateCountryIfNeeded(CountryCodeISO2, CountryName, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name")
            else
                Country := CustomerDataMigrationFacade.CreateCountryIfNeeded(Country, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name")
        end;

        if Country = '' then begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (CopyStr(MigrationGPCustomer.ZIPCODE, 1, 20) <> '') and (CopyStr(MigrationGPCustomer.CITY, 1, 30) <> '') then
            CustomerDataMigrationFacade.CreatePostCodeIfNeeded(CopyStr(MigrationGPCustomer.ZIPCODE, 1, 20),
                CopyStr(MigrationGPCustomer.CITY, 1, 30), CopyStr(MigrationGPCustomer.STATE, 1, 20), Country);

        CustomerDataMigrationFacade.SetAddress(CopyStr(MigrationGPCustomer.ADDRESS1, 1, 50),
            CopyStr(MigrationGPCustomer.ADDRESS2, 1, 50), Country, CopyStr(MigrationGPCustomer.ZIPCODE, 1, 20),
            CopyStr(MigrationGPCustomer.CITY, 1, 30));

        CustomerDataMigrationFacade.SetContact(CopyStr(MigrationGPCustomer.CNTCPRSN, 1, 50));
        SetPhoneAndFaxNumberIfValid(MigrationGPCustomer, CustomerDataMigrationFacade);

        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            CustomerDataMigrationFacade.SetCustomerPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
            CustomerDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        end;

        CustomerDataMigrationFacade.SetHomePage(COPYSTR(MigrationGPCustomer.INET2, 1, 80));

        GPRM00101.SetLoadFields(ADRSCODE);
        if GPRM00101.Get(MigrationGPCustomer.CUSTNMBR) then
            if GPSY01200.Get(CustomerEmailTypeCodeLbl, GPRM00101.CUSTNMBR, GPRM00101.ADRSCODE) then
                CustomerDataMigrationFacade.SetEmail(CopyStr(GPSY01200.GetAllEmailAddressesText(MaxStrLen(Customer."E-Mail")), 1, MaxStrLen(Customer."E-Mail")));

        if MigrationGPCustomer.STMTCYCL = true then
            CustomerDataMigrationFacade.SetPrintStatement(true);

        if (CopyStr(MigrationGPCustomer.SLPRSNID, 1, 20) <> '') then begin
            CustomerDataMigrationFacade.CreateSalespersonPurchaserIfNeeded(MigrationGPCustomer.SLPRSNID, '', '', '');
            CustomerDataMigrationFacade.SetSalesPersonCode(MigrationGPCustomer.SLPRSNID);
        end;

        if (CopyStr(MigrationGPCustomer.SHIPMTHD, 1, 10) <> '') then begin
            CustomerDataMigrationFacade.CreateShipmentMethodIfNeeded(CopyStr(MigrationGPCustomer.SHIPMTHD, 1, 10), '');
            CustomerDataMigrationFacade.SetShipmentMethodCode(CopyStr(MigrationGPCustomer.SHIPMTHD, 1, 10));
        end;

        if (CopyStr(MigrationGPCustomer.PYMTRMID, 1, 10) <> '') then begin
            EVALUATE(PaymentTermsFormula, '');
            CustomerDataMigrationFacade.CreatePaymentTermsIfNeeded(CopyStr(MigrationGPCustomer.PYMTRMID, 1, 10), MigrationGPCustomer.PYMTRMID, PaymentTermsFormula);
            CustomerDataMigrationFacade.SetPaymentTermsCode(CopyStr(MigrationGPCustomer.PYMTRMID, 1, 10));
        end;

        CustomerDataMigrationFacade.SetName2(CopyStr(MigrationGPCustomer.STMTNAME, 1, 50));

        if (CopyStr(MigrationGPCustomer.SALSTERR, 1, 10) <> '') then begin
            CustomerDataMigrationFacade.CreateTerritoryCodeIfNeeded(CopyStr(MigrationGPCustomer.SALSTERR, 1, 10), '');
            CustomerDataMigrationFacade.SetTerritoryCode(CopyStr(MigrationGPCustomer.SALSTERR, 1, 10));
        end;

        CustomerDataMigrationFacade.SetCreditLimitLCY(MigrationGPCustomer.CRLMTAMT);

        if (MigrationGPCustomer.TAXSCHID <> '') then begin
            CustomerDataMigrationFacade.CreateTaxAreaIfNeeded(MigrationGPCustomer.TAXSCHID, '');
            CustomerDataMigrationFacade.SetTaxAreaCode(MigrationGPCustomer.TAXSCHID);
            CustomerDataMigrationFacade.SetTaxLiable(true);
        end;

        CustomerDataMigrationFacade.ModifyCustomer(true);
    end;

    local procedure SetPhoneAndFaxNumberIfValid(var MigrationGPCustomer: Record "GP Customer"; var CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade")
    var
        GPMigrationWarnings: Record "GP Migration Warnings";
        HelperFunctions: Codeunit "Helper Functions";
        WarningContext: Text[50];
    begin
        WarningContext := CopyStr(MigrationGPCustomer.CUSTNMBR.Trim(), 1, MaxStrLen(GPMigrationWarnings.Context));
        MigrationGPCustomer.PHONE1 := HelperFunctions.CleanGPPhoneOrFaxNumber(MigrationGPCustomer.PHONE1);
        MigrationGPCustomer.FAX := HelperFunctions.CleanGPPhoneOrFaxNumber(MigrationGPCustomer.FAX);

        if MigrationGPCustomer.PHONE1 <> '' then
            if not HelperFunctions.ContainsAlphaChars(MigrationGPCustomer.PHONE1) then
                CustomerDataMigrationFacade.SetPhoneNo(MigrationGPCustomer.PHONE1)
            else
                GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, WarningContext, StrSubstNo(PhoneNumberContainsLettersMsg, MigrationGPCustomer.PHONE1));

        if MigrationGPCustomer.FAX <> '' then
            if not HelperFunctions.ContainsAlphaChars(MigrationGPCustomer.FAX) then
                CustomerDataMigrationFacade.SetFaxNo(MigrationGPCustomer.FAX)
            else
                GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, WarningContext, StrSubstNo(PhoneNumberContainsLettersMsg, MigrationGPCustomer.FAX));
    end;

    local procedure MigrateCustomerAddresses(MigrationGPCustomer: Record "GP Customer")
    var
        GPCustomerAddress: Record "GP Customer Address";
    begin
        GPCustomerAddress.SetRange(CUSTNMBR, MigrationGPCustomer.CUSTNMBR);
        if GPCustomerAddress.FindSet() then
            repeat
                GPCustomerAddress.MoveStagingData();
            until GPCustomerAddress.Next() = 0;
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        GetCustomersFromJson(JArray);
    end;

    procedure PopulateRMTRxStagingTable(JArray: JsonArray)
    begin
        GlobalDocumentNo := 'C00000';
        GetRMTrxFromJson(JArray);
    end;

    local procedure GetCustomersFromJson(JArray: JsonArray)
    var
        MigrationGPCustomer: Record "GP Customer";
        HelperFunctions: Codeunit "Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        i: Integer;
    begin
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'CUSTNMBR'), 1, MAXSTRLEN(MigrationGPCustomer.CUSTNMBR));
            EntityId := CopyStr(HelperFunctions.TrimBackslash(EntityId), 1, 75);
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 75);

            if not MigrationGPCustomer.Get(EntityId) then begin
                MigrationGPCustomer.Init();
                MigrationGPCustomer.Validate(MigrationGPCustomer.CUSTNMBR, EntityId);
                MigrationGPCustomer.Insert(true);
            end;

            RecordVariant := MigrationGPCustomer;
            UpdateCustomerFromJson(RecordVariant, ChildJToken);
            MigrationGPCustomer := RecordVariant;
            MigrationGPCustomer.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateCustomerFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationGPCustomer: Record "GP Customer";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(CUSTNMBR), JToken.AsObject(), 'CUSTNMBR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(CUSTNAME), JToken.AsObject(), 'CUSTNAME');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(STMTNAME), JToken.AsObject(), 'STMTNAME');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(ADDRESS1), JToken.AsObject(), 'ADDRESS1');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(ADDRESS2), JToken.AsObject(), 'ADDRESS2');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(CITY), JToken.AsObject(), 'CITY');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(CNTCPRSN), JToken.AsObject(), 'CNTCPRSN');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(PHONE1), JToken.AsObject(), 'PHONE1');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(SALSTERR), JToken.AsObject(), 'SALSTERR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(CRLMTAMT), JToken.AsObject(), 'CRLMTAMT');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(PYMTRMID), JToken.AsObject(), 'PYMTRMID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(SLPRSNID), JToken.AsObject(), 'SLPRSNID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(SHIPMTHD), JToken.AsObject(), 'SHIPMTHD');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(COUNTRY), JToken.AsObject(), 'COUNTRY');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(AMOUNT), JToken.AsObject(), 'AMOUNT');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(STMTCYCL), JToken.AsObject(), 'STMTCYCL');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(FAX), JToken.AsObject(), 'FAX');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(ZIPCODE), JToken.AsObject(), 'ZIPCODE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(STATE), JToken.AsObject(), 'STATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(INET1), JToken.AsObject(), 'INET1');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(INET2), JToken.AsObject(), 'INET2');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(TAXSCHID), JToken.AsObject(), 'TAXSCHID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(UPSZONE), JToken.AsObject(), 'UPSZONE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustomer.FieldNo(TAXEXMT1), JToken.AsObject(), 'TAXEXMT1');
    end;

    local procedure GetRMTrxFromJson(JArray: JsonArray);
    var
        MigrationGPCustTrans: Record "GP Customer Transactions";
        HelperFunctions: Codeunit "Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[40];
        i: Integer;
    begin
        i := 0;
        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id'), 1, MAXSTRLEN(MigrationGPCustTrans.Id));
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 40);

            if not MigrationGPCustTrans.Get(EntityId) then begin
                MigrationGPCustTrans.Init();
                MigrationGPCustTrans.Validate(MigrationGPCustTrans.Id, EntityId);
                MigrationGPCustTrans.Insert(true);
            end;

            RecordVariant := MigrationGPCustTrans;
            GlobalDocumentNo := CopyStr(IncStr(GlobalDocumentNo), 1, 30);
            UpdateRMTraxFromJson(RecordVariant, ChildJToken, GlobalDocumentNo);
            MigrationGPCustTrans := RecordVariant;
            HelperFunctions.SetCustomerTransType(MigrationGPCustTrans);
            MigrationGPCustTrans.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateRMTraxFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationGPCustTrans: Record "GP Customer Transactions";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(CUSTNMBR), JToken.AsObject(), 'CUSTNMBR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(DOCNUMBR), JToken.AsObject(), 'DOCNUMBR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(DOCDATE), JToken.AsObject(), 'DOCDATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(DUEDATE), JToken.AsObject(), 'DUEDATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(CURTRXAM), JToken.AsObject(), 'CURTRXAM');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(RMDTYPAL), JToken.AsObject(), 'RMDTYPAL');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(SLPRSNID), JToken.AsObject(), 'SLPRSNID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPCustTrans.FieldNo(PYMTRMID), JToken.AsObject(), 'PYMTRMID');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationGPCustTrans.FieldNo(GLDocNo), DocumentNo);
    end;

    local procedure GetCustomerReceivablesAccount(var GPCustomer: Record "GP Customer"; var GPCompanyAdditionalSettings: Record "GP Company Additional Settings"; var ReceivablesAccountNo: Code[20])
    var
        GPRM00101: Record "GP RM00101";
        GPRM00201: Record "GP RM00201";
        HelperFunctions: Codeunit "Helper Functions";
        CustomerClassId: Text[20];
        DefaultReceivablesAccountNo: Code[20];
    begin
        DefaultReceivablesAccountNo := HelperFunctions.GetPostingAccountNumber('ReceivablesAccount');
        ReceivablesAccountNo := DefaultReceivablesAccountNo;

        if not GPCompanyAdditionalSettings.GetMigrateCustomerClasses() then
            exit;

        if not GPRM00101.Get(GPCustomer.CUSTNMBR) then
            exit;

#pragma warning disable AA0139
        CustomerClassId := GPRM00101.CUSTCLAS.Trim();
#pragma warning restore AA0139

        if CustomerClassId = '' then
            exit;

        if not GPRM00201.Get(CustomerClassId) then
            exit;

        ReceivablesAccountNo := HelperFunctions.GetGPAccountNumberByIndex(GPRM00201.RMARACC);

        if ReceivablesAccountNo = '' then
            ReceivablesAccountNo := DefaultReceivablesAccountNo;
    end;

#if not CLEAN23
    [Obsolete('Updated to use the OnMigrateCustomerPostingGroups event subscriber.', '23.0')]
    procedure MigrateCustomerClasses()
    begin
    end;
#endif
}