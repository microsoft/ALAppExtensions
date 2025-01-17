namespace Microsoft.DataMigration.GP;

using System.Integration;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Email;
using Microsoft.Purchases.Remittance;
using Microsoft.Bank.Setup;

codeunit 4022 "GP Vendor Migrator"
{
    TableNo = "GP Vendor";

    var
        GlobalDocumentNo: Text[30];
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        VendorBatchNameTxt: Label 'GPVEND', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        VendorEmailTypeCodeLbl: Label 'VEN', Locked = true;
        MigrationLogAreaTxt: Label 'Vendor', Locked = true;
        TemporaryVendorMigratedTxt: Label 'Temporary vendor was migrated because %1', Comment = '%1 is the reason the temporary Vendor was migrated.';
        TemporaryVendorHasOpenPOsAndAPTrxTxt: Label 'it has open POs and open AP transactions.';
        TemporaryVendorHasOpenPOsTxt: Label 'it has open POs.';
        TemporaryVendorHasOpenAPTrxTxt: Label 'it has open AP transactions.';
        PhoneNumberContainsLettersMsg: Label 'Phone/Fax number skipped because it contains letters. Value=%1', Comment = '%1 is the phone/fax number.';

#pragma warning disable AA0207
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendor', '', true, true)]
    internal procedure OnMigrateVendor(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPVendor: Record "GP Vendor";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Vendor" then
            exit;
        GPVendor.Get(RecordIdToMigrate);
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));

        MigrateVendorDetails(GPVendor, Sender);
        MigrateVendorAddresses(GPVendor);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorPostingGroups', '', true, true)]
    internal procedure OnMigrateVendorPostingGroups(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GPVendor: Record "GP Vendor";
        Vendor: Record Vendor;
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PostingGroupNo: Code[20];
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Vendor" then
            exit;

        if GPVendor.Get(RecordIdToMigrate) then
            if not Sender.DoesVendorExist(CopyStr(GPVendor.VENDORID, 1, MaxStrLen(Vendor."No."))) then
                exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));

        Sender.CreatePostingSetupIfNeeded(
            CopyStr(PostingGroupCodeTxt, 1, 5),
            CopyStr(PostingGroupDescriptionTxt, 1, 20),
            HelperFunctions.GetPostingAccountNumber('PayablesAccount')
        );

        PostingGroupNo := CreateVendorPostingGroupIfNeeded(RecordIdToMigrate);
        Sender.SetVendorPostingGroup(PostingGroupNo);
        Sender.ModifyVendor(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorTransactions', '', true, true)]
    internal procedure OnMigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    begin
        MigrateVendorTransactions(Sender, RecordIdToMigrate, ChartOfAccountsMigrated);
    end;

    procedure MigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GPVendor: Record "GP Vendor";
        Vendor: Record Vendor;
        GPVendorTransactions: Record "GP Vendor Transactions";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        PaymentTermsFormula: DateFormula;
        PayablesAccountNo: Code[20];
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Vendor" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        if GPCompanyAdditionalSettings.GetMigrateOnlyPayablesMaster() then
            exit;

        if GPVendor.Get(RecordIdToMigrate) then
            if not Sender.DoesVendorExist(CopyStr(GPVendor.VENDORID, 1, MaxStrLen(Vendor."No."))) then
                exit;

        GetVendorPayablesAccount(GPVendor, GPCompanyAdditionalSettings, PayablesAccountNo);

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(VendorBatchNameTxt, 1, 7), '', '');
        GPVendorTransactions.SetRange(VENDORID, GPVendor.VENDORID);
        GPVendorTransactions.SetRange(TransType, GPVendorTransactions.TransType::Invoice);
        if GPVendorTransactions.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(GPVendorTransactions.GLDocNo, 1, 20),
                    CopyStr(GPVendor.VENDNAME, 1, 50),
                    GPVendorTransactions.DOCDATE,
                    0D,
                    -GPVendorTransactions.CURTRXAM,
                    -GPVendorTransactions.CURTRXAM,
                    '',
                    PayablesAccountNo
                );
                Sender.SetGeneralJournalLineDocumentType(GPVendorTransactions.TransType);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(GPVendorTransactions.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10), GPVendorTransactions.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(GPVendorTransactions.DOCNUMBR.Trim(), 1, 35));
            until GPVendorTransactions.Next() = 0;

        GPVendorTransactions.Reset();
        GPVendorTransactions.SetRange(VENDORID, GPVendor.VENDORID);
        GPVendorTransactions.SetRange(TransType, GPVendorTransactions.TransType::Payment);
        if GPVendorTransactions.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(GPVendorTransactions.GLDocNo, 1, 20),
                    CopyStr(GPVendor.VENDNAME, 1, 50),
                    GPVendorTransactions.DOCDATE,
                    0D,
                    GPVendorTransactions.CURTRXAM,
                    GPVendorTransactions.CURTRXAM,
                    '',
                    PayablesAccountNo
                );
                Sender.SetGeneralJournalLineDocumentType(GPVendorTransactions.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(GPVendorTransactions.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10), GPVendorTransactions.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(GPVendorTransactions.DOCNUMBR.Trim(), 1, 35));
            until GPVendorTransactions.Next() = 0;

        GPVendorTransactions.Reset();
        GPVendorTransactions.SetRange(VENDORID, GPVendor.VENDORID);
        GPVendorTransactions.SetRange(TransType, GPVendorTransactions.TransType::"Credit Memo");
        if GPVendorTransactions.FindSet() then
            repeat
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(RecordIdToMigrate));
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(GPVendorTransactions.GLDocNo, 1, 20),
                    CopyStr(GPVendor.VENDNAME, 1, 50),
                    GPVendorTransactions.DOCDATE,
                    0D,
                    GPVendorTransactions.CURTRXAM,
                    GPVendorTransactions.CURTRXAM,
                    '',
                    PayablesAccountNo
                );
                Sender.SetGeneralJournalLineDocumentType(GPVendorTransactions.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(GPVendorTransactions.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10), GPVendorTransactions.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(GPVendorTransactions.DOCNUMBR.Trim(), 1, 35));
            until GPVendorTransactions.Next() = 0;
    end;
#pragma warning restore AA0207

    local procedure CreateVendorPostingGroupIfNeeded(RecordIdToMigrate: RecordId): Code[20]
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPPM00200: Record "GP PM00200";
        GPPM00100: Record "GP PM00100";
        GPVendor: Record "GP Vendor";
        VendorPostingGroup: Record "Vendor Posting Group";
        HelperFunctions: Codeunit "Helper Functions";
        ClassId: Text[20];
        AccountNumber: Code[20];
    begin
        if not GPCompanyAdditionalSettings.GetMigrateVendorClasses() then
            exit(PostingGroupCodeTxt);

        if not GPVendor.Get(RecordIdToMigrate) then
            exit(PostingGroupCodeTxt);

        if not GPPM00200.Get(GPVendor.VENDORID) then
            exit(PostingGroupCodeTxt);

#pragma warning disable AA0139
        ClassId := GPPM00200.VNDCLSID.Trim();
#pragma warning restore AA0139

        if ClassId = '' then
            exit(PostingGroupCodeTxt);

        if not GPPM00100.Get(ClassId) then
            exit(PostingGroupCodeTxt);

        if VendorPostingGroup.Get(ClassId) then
            exit(ClassId);

        VendorPostingGroup.Validate("Code", ClassId);
        VendorPostingGroup.Validate("Description", GPPM00100.VNDCLDSC);

        // Payables Account
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPPM00100.PMAPINDX);
        if AccountNumber = '' then
            AccountNumber := HelperFunctions.GetPostingAccountNumber('PayablesAccount');

        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            VendorPostingGroup.Validate("Payables Account", AccountNumber);
        end;

        // Service Charge Acc.
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPPM00100.PMFINIDX);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            VendorPostingGroup.Validate("Service Charge Acc.", AccountNumber);
        end;

        // Payment Disc. Debit Acc.
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPPM00100.PMDTKIDX);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            VendorPostingGroup.Validate("Payment Disc. Debit Acc.", AccountNumber);
        end;

        // Payment Disc. Credit Acc.
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPPM00100.PMDAVIDX);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            VendorPostingGroup.Validate("Payment Disc. Credit Acc.", AccountNumber);
        end;

        // Payment Tolerance Debit Acc.
        // Payment Tolerance Credit Acc.
        AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPPM00100.PMWRTIDX);
        if AccountNumber <> '' then begin
            HelperFunctions.EnsureAccountHasGenProdPostingAccount(AccountNumber);
            VendorPostingGroup.Validate("Payment Tolerance Debit Acc.", AccountNumber);
            VendorPostingGroup.Validate("Payment Tolerance Credit Acc.", AccountNumber);
        end;

        VendorPostingGroup.Insert();

        exit(ClassId);
    end;

    local procedure MigrateVendorDetails(GPVendor: Record "GP Vendor"; VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade")
    var
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        GPKnownCountries: Record "GP Known Countries";
        GPPM00200: Record "GP PM00200";
        GPSY01200: Record "GP SY01200";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPMigrationWarnings: Record "GP Migration Warnings";
        HelperFunctions: Codeunit "Helper Functions";
        PaymentTermsFormula: DateFormula;
        VendorNo: Code[20];
        Country: Code[10];
        ZipCode: Code[20];
        ShipMethod: Code[10];
        PaymentTerms: Code[10];
        VendorName: Text[50];
        VendorName2: Text[50];
        ContactName: Text[50];
        Address1: Text[50];
        Address2: Text[50];
        City: Text[30];
        State: Text[30];
        FoundKnownCountry: Boolean;
        CountryCodeISO2: Code[2];
        CountryName: Text[50];
        IsTemporaryVendor: Boolean;
        HasOpenPurchaseOrders: Boolean;
        HasOpenTransactions: Boolean;
    begin
        VendorNo := CopyStr(GPVendor.VENDORID, 1, MaxStrLen(Vendor."No."));

        if not ShouldMigrateVendor(VendorNo, IsTemporaryVendor, HasOpenPurchaseOrders, HasOpenTransactions) then
            exit;

        if IsTemporaryVendor then
            if HasOpenPurchaseOrders and HasOpenTransactions then
                GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, VendorNo, StrSubstNo(TemporaryVendorMigratedTxt, TemporaryVendorHasOpenPOsAndAPTrxTxt))
            else begin
                if HasOpenPurchaseOrders then
                    GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, VendorNo, StrSubstNo(TemporaryVendorMigratedTxt, TemporaryVendorHasOpenPOsTxt));

                if HasOpenTransactions then
                    GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, VendorNo, StrSubstNo(TemporaryVendorMigratedTxt, TemporaryVendorHasOpenAPTrxTxt));
            end;

        VendorName := CopyStr(GPVendor.VENDNAME.TrimEnd(), 1, MaxStrLen(VendorName));

        if not VendorDataMigrationFacade.CreateVendorIfNeeded(VendorNo, VendorName) then
            exit;

        VendorName2 := CopyStr(GPVendor.VNDCHKNM.TrimEnd(), 1, MaxStrLen(VendorName2));
        ContactName := CopyStr(GPVendor.VNDCNTCT, 1, MaxStrLen(ContactName));
        Address1 := CopyStr(GPVendor.ADDRESS1, 1, MaxStrLen(Address1));
        Address2 := CopyStr(GPVendor.ADDRESS2, 1, MaxStrLen(Address2));
        City := CopyStr(GPVendor.CITY, 1, MaxStrLen(City));
        State := CopyStr(GPVendor.STATE, 1, MaxStrLen(State));
        ZipCode := CopyStr(GPVendor.ZIPCODE, 1, MaxStrLen(ZipCode));
        Country := CopyStr(GPVendor.COUNTRY.Trim(), 1, MaxStrLen(Country));
        ShipMethod := CopyStr(GPVendor.SHIPMTHD, 1, MaxStrLen(ShipMethod));
        PaymentTerms := CopyStr(GPVendor.PYMTRMID, 1, MaxStrLen(PaymentTerms));

        if VendorName2 <> '' then
            if not HelperFunctions.StringEqualsCaseInsensitive(VendorName2, VendorName) then
                VendorDataMigrationFacade.SetName2(VendorName2);

        if Country <> '' then begin
            GPKnownCountries.SearchKnownCountry(Country, FoundKnownCountry, CountryCodeISO2, CountryName);
            if FoundKnownCountry then begin
                HelperFunctions.CreateCountryIfNeeded(CountryCodeISO2, CountryName);
                Country := CountryCodeISO2;
            end else
                HelperFunctions.CreateCountryIfNeeded(Country, Country)
        end;

        if Country = '' then begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (ZipCode <> '') and (City <> '') then
            VendorDataMigrationFacade.CreatePostCodeIfNeeded(ZipCode, City, State, Country);

        VendorDataMigrationFacade.SetAddress(Address1, Address2, Country, ZipCode, City);
        VendorDataMigrationFacade.SetContact(ContactName);
        SetPhoneAndFaxNumberIfValid(GPVendor, VendorDataMigrationFacade);

        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(VendorPostingGroup."Code")));
            VendorDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, MaxStrLen(GenBusinessPostingGroup."Code")));
        end;

#pragma warning disable AL0432
        VendorDataMigrationFacade.SetHomePage(COPYSTR(GPVendor.INET2, 1, MaxStrLen(Vendor."Home Page")));
#pragma warning restore AL0432

        GPPM00200.SetLoadFields(VADDCDPR);
        if GPPM00200.Get(VendorNo) then
            if GPSY01200.Get(VendorEmailTypeCodeLbl, VendorNo, GPPM00200.VADDCDPR) then
                VendorDataMigrationFacade.SetEmail(CopyStr(GPSY01200.GetAllEmailAddressesText(MaxStrLen(Vendor."E-Mail")), 1, MaxStrLen(Vendor."E-Mail")));

        if (ShipMethod <> '') then begin
            VendorDataMigrationFacade.CreateShipmentMethodIfNeeded(ShipMethod, '');
            VendorDataMigrationFacade.SetShipmentMethodCode(ShipMethod);
        end;

        if (PaymentTerms <> '') then begin
            EVALUATE(PaymentTermsFormula, '');
            VendorDataMigrationFacade.CreatePaymentTermsIfNeeded(PaymentTerms, PaymentTerms, PaymentTermsFormula);
            VendorDataMigrationFacade.SetPaymentTermsCode(PaymentTerms);
        end;

        if (GPVendor.TAXSCHID <> '') then begin
            VendorDataMigrationFacade.CreateTaxAreaIfNeeded(GPVendor.TAXSCHID, '');
            VendorDataMigrationFacade.SetTaxAreaCode(GPVendor.TAXSCHID);
            VendorDataMigrationFacade.SetTaxLiable(true);
        end;

        VendorDataMigrationFacade.ModifyVendor(true);
    end;

    local procedure SetPhoneAndFaxNumberIfValid(var GPVendor: Record "GP Vendor"; var VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade")
    var
        GPMigrationWarnings: Record "GP Migration Warnings";
        HelperFunctions: Codeunit "Helper Functions";
        WarningContext: Text[50];
    begin
        WarningContext := CopyStr(GPVendor.VENDORID.Trim(), 1, MaxStrLen(GPMigrationWarnings.Context));
        GPVendor.PHNUMBR1 := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendor.PHNUMBR1);
        GPVendor.FAXNUMBR := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendor.FAXNUMBR);

        if GPVendor.PHNUMBR1 <> '' then
            if not HelperFunctions.ContainsAlphaChars(GPVendor.PHNUMBR1) then
                VendorDataMigrationFacade.SetPhoneNo(GPVendor.PHNUMBR1)
            else
                GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, WarningContext, StrSubstNo(PhoneNumberContainsLettersMsg, GPVendor.PHNUMBR1));

        if GPVendor.FAXNUMBR <> '' then
            if not HelperFunctions.ContainsAlphaChars(GPVendor.FAXNUMBR) then
                VendorDataMigrationFacade.SetFaxNo(GPVendor.FAXNUMBR)
            else
                GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, WarningContext, StrSubstNo(PhoneNumberContainsLettersMsg, GPVendor.FAXNUMBR));
    end;

    local procedure MigrateVendorAddresses(GPVendor: Record "GP Vendor")
    var
        Vendor: Record Vendor;
        GPPM00200: Record "GP PM00200";
        GPVendorAddress: Record "GP Vendor Address";
        AddressCode: Code[10];
        AssignedPrimaryAddressCode: Code[10];
        AssignedRemitToAddressCode: Code[10];
    begin
        if not Vendor.Get(GPVendor.VENDORID) then
            exit;

        if GPPM00200.Get(GPVendor.VENDORID) then begin
            AssignedPrimaryAddressCode := CopyStr(GPPM00200.VADDCDPR.Trim(), 1, MaxStrLen(AssignedPrimaryAddressCode));
            AssignedRemitToAddressCode := CopyStr(GPPM00200.VADCDTRO.Trim(), 1, MaxStrLen(AssignedRemitToAddressCode));
        end;

        GPVendorAddress.SetRange(VENDORID, Vendor."No.");
        if GPVendorAddress.FindSet() then
            repeat
                AddressCode := CopyStr(GPVendorAddress.ADRSCODE.Trim(), 1, MaxStrLen(AddressCode));

                if AddressCode = AssignedRemitToAddressCode then
                    CreateOrUpdateRemitAddress(Vendor, GPVendorAddress, AddressCode);

                if (AddressCode = AssignedPrimaryAddressCode) or (AddressCode <> AssignedRemitToAddressCode) then
                    CreateOrUpdateOrderAddress(Vendor, GPVendorAddress, AddressCode);

            until GPVendorAddress.Next() = 0;
    end;

    local procedure CreateOrUpdateOrderAddress(Vendor: Record Vendor; GPVendorAddress: Record "GP Vendor Address"; AddressCode: Code[10])
    var
        OrderAddress: Record "Order Address";
        GPSY01200: Record "GP SY01200";
        HelperFunctions: Codeunit "Helper Functions";
        MailManagement: Codeunit "Mail Management";
        EmailAddress: Text[80];
    begin
        if not OrderAddress.Get(Vendor."No.", AddressCode) then begin
            OrderAddress."Vendor No." := Vendor."No.";
            OrderAddress.Code := AddressCode;
            OrderAddress.Insert();
        end;

        OrderAddress.Name := Vendor.Name;
        OrderAddress.Address := GPVendorAddress.ADDRESS1;
        OrderAddress."Address 2" := CopyStr(GPVendorAddress.ADDRESS2, 1, MaxStrLen(OrderAddress."Address 2"));
        OrderAddress.City := CopyStr(GPVendorAddress.CITY, 1, MaxStrLen(OrderAddress.City));
        OrderAddress.Contact := GPVendorAddress.VNDCNTCT;
        OrderAddress."Phone No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.PHNUMBR1);
        OrderAddress."Fax No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.FAXNUMBR);
        OrderAddress."Post Code" := GPVendorAddress.ZIPCODE;
        OrderAddress.County := GPVendorAddress.STATE;

        if GPSY01200.Get(VendorEmailTypeCodeLbl, Vendor."No.", AddressCode) then
            EmailAddress := CopyStr(GPSY01200.GetSingleEmailAddress(MaxStrLen(OrderAddress."E-Mail")), 1, MaxStrLen(OrderAddress."E-Mail"));

#pragma warning disable AA0139
        if MailManagement.ValidateEmailAddressField(EmailAddress) then
            OrderAddress."E-Mail" := EmailAddress;
#pragma warning restore AA0139

        OrderAddress.Modify();
    end;

    local procedure CreateOrUpdateRemitAddress(Vendor: Record Vendor; GPVendorAddress: Record "GP Vendor Address"; AddressCode: Code[10])
    var
        RemitAddress: Record "Remit Address";
        GPSY01200: Record "GP SY01200";
        HelperFunctions: Codeunit "Helper Functions";
        MailManagement: Codeunit "Mail Management";
        EmailAddress: Text[80];
    begin
        if not RemitAddress.Get(AddressCode, Vendor."No.") then begin
            RemitAddress."Vendor No." := Vendor."No.";
            RemitAddress.Code := AddressCode;
            RemitAddress.Insert();
        end;

        RemitAddress.Name := Vendor.Name;
        RemitAddress.Address := GPVendorAddress.ADDRESS1;
        RemitAddress."Address 2" := CopyStr(GPVendorAddress.ADDRESS2, 1, MaxStrLen(RemitAddress."Address 2"));
        RemitAddress.City := CopyStr(GPVendorAddress.CITY, 1, MaxStrLen(RemitAddress.City));
        RemitAddress.Contact := GPVendorAddress.VNDCNTCT;
        RemitAddress."Phone No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.PHNUMBR1);
        RemitAddress."Fax No." := HelperFunctions.CleanGPPhoneOrFaxNumber(GPVendorAddress.FAXNUMBR);
        RemitAddress."Post Code" := GPVendorAddress.ZIPCODE;
        RemitAddress.County := GPVendorAddress.STATE;

        if GPSY01200.Get(VendorEmailTypeCodeLbl, Vendor."No.", AddressCode) then
            EmailAddress := CopyStr(GPSY01200.GetSingleEmailAddress(MaxStrLen(RemitAddress."E-Mail")), 1, MaxStrLen(RemitAddress."E-Mail"));

#pragma warning disable AA0139
        if MailManagement.ValidateEmailAddressField(EmailAddress) then
            RemitAddress."E-Mail" := EmailAddress;
#pragma warning restore AA0139

        RemitAddress.Modify();
    end;

    internal procedure ShouldMigrateVendor(VendorNo: Text[75]; var IsTemporaryVendor: Boolean; var HasOpenPurchaseOrders: Boolean; var HasOpenTransactions: Boolean): Boolean
    var
        GPPM00200: Record "GP PM00200";
        GPPOP10100: Record "GP POP10100";
        GPVendorTransactions: Record "GP Vendor Transactions";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        IsTemporaryVendor := false;
        HasOpenPurchaseOrders := false;
        HasOpenTransactions := false;

        if GPCompanyAdditionalSettings.GetMigrateTemporaryVendors() then
            exit(true);

        GPPM00200.SetLoadFields(VENDSTTS);
        if GPPM00200.Get(VendorNo) then
            IsTemporaryVendor := GPPM00200.VENDSTTS = 3;

        if not IsTemporaryVendor then
            exit(true);

        // Check for open POs
        GPPOP10100.SetRange(POTYPE, GPPOP10100.POTYPE::Standard);
        GPPOP10100.SetRange(POSTATUS, 1, 4);
        GPPOP10100.SetRange(VENDORID, VendorNo);
        HasOpenPurchaseOrders := GPPOP10100.Count() > 0;

        // Check for open AP transactions
        GPVendorTransactions.SetRange(VENDORID, VendorNo);
        HasOpenTransactions := GPVendorTransactions.Count() > 0;

        if not HasOpenPurchaseOrders then
            if not HasOpenTransactions then
                exit(false);

        exit(true);
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        GlobalDocumentNo := 'V00000';
        GetPMTrxFromJson(JArray);
    end;

    local procedure GetVendorsFromJson(JArray: JsonArray)
    var
        GPVendor: Record "GP Vendor";
        HelperFunctions: Codeunit "Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        i: Integer;
    begin
        i := 0;
        GPVendor.Reset();
        GPVendor.DeleteAll();

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'VENDORID'), 1, MAXSTRLEN(GPVendor.VENDORID));
            EntityId := CopyStr(HelperFunctions.TrimBackslash(EntityId), 1, 75);
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 75);

            if not GPVendor.Get(EntityId) then begin
                GPVendor.Init();
                GPVendor.Validate(GPVendor.VENDORID, EntityId);
                GPVendor.Insert(true);
            end;

            RecordVariant := GPVendor;
            UpdateVendorFromJson(RecordVariant, ChildJToken);
            GPVendor := RecordVariant;
            GPVendor.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateVendorFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        GPVendor: Record "GP Vendor";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(VENDORID), JToken.AsObject(), 'VENDORID');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(VENDNAME), JToken.AsObject(), 'VENDNAME');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(SEARCHNAME), JToken.AsObject(), 'SEARCHNAME');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(VNDCHKNM), JToken.AsObject(), 'VNDCHKNM');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(ADDRESS1), JToken.AsObject(), 'ADDRESS1');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(ADDRESS2), JToken.AsObject(), 'ADDRESS2');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(CITY), JToken.AsObject(), 'CITY');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(VNDCNTCT), JToken.AsObject(), 'VNDCNTCT');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(PHNUMBR1), JToken.AsObject(), 'PHNUMBR1');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(PYMTRMID), JToken.AsObject(), 'PYMTRMID');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(SHIPMTHD), JToken.AsObject(), 'SHIPMTHD');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(COUNTRY), JToken.AsObject(), 'COUNTRY');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(PYMNTPRI), JToken.AsObject(), 'PYMNTPRI');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(AMOUNT), JToken.AsObject(), 'AMOUNT');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(FAXNUMBR), JToken.AsObject(), 'FAXNUMBR');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(ZIPCODE), JToken.AsObject(), 'ZIPCODE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(STATE), JToken.AsObject(), 'STATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(INET1), JToken.AsObject(), 'INET1');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(INET2), JToken.AsObject(), 'INET2');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(TAXSCHID), JToken.AsObject(), 'TAXSCHID');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(UPSZONE), JToken.AsObject(), 'UPSZONE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendor.FieldNO(TXIDNMBR), JToken.AsObject(), 'TXIDNMBR');
    end;

    procedure PopulateVendorStagingTable(JArray: JsonArray)
    begin
        GetVendorsFromJson(JArray);
    end;

    local procedure GetPMTrxFromJson(JArray: JsonArray);
    var
        GPVendorTransactions: Record "GP Vendor Transactions";
        HelperFunctions: Codeunit "Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[40];
        i: Integer;
    begin
        i := 0;
        GPVendorTransactions.Reset();
        GPVendorTransactions.DeleteAll();

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id'), 1, MAXSTRLEN(GPVendorTransactions.Id));
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 40);

            if not GPVendorTransactions.Get(EntityId) then begin
                GPVendorTransactions.Init();
                GPVendorTransactions.Validate(GPVendorTransactions.Id, EntityId);
                GPVendorTransactions.Insert(true);
            end;

            RecordVariant := GPVendorTransactions;
            GlobalDocumentNo := CopyStr(IncStr(GlobalDocumentNo), 1, 30);
            UpdatePMTrxFromJson(RecordVariant, ChildJToken, GlobalDocumentNo);
            GPVendorTransactions := RecordVariant;
            HelperFunctions.SetVendorTransType(GPVendorTransactions);
            GPVendorTransactions.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdatePMTrxFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        GPVendorTransactions: Record "GP Vendor Transactions";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendorTransactions.FieldNo(VENDORID), JToken.AsObject(), 'VENDORID');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendorTransactions.FieldNo(DOCNUMBR), JToken.AsObject(), 'DOCNUMBR');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendorTransactions.FieldNo(DOCDATE), JToken.AsObject(), 'DOCDATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendorTransactions.FieldNo(DUEDATE), JToken.AsObject(), 'DUEDATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendorTransactions.FieldNo(CURTRXAM), JToken.AsObject(), 'CURTRXAM');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendorTransactions.FieldNo(DOCTYPE), JToken.AsObject(), 'DOCTYPE');
        HelperFunctions.UpdateFieldValue(RecordVariant, GPVendorTransactions.FieldNo(PYMTRMID), JToken.AsObject(), 'PYMTRMID');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, GPVendorTransactions.FieldNo(GLDocNo), DocumentNo);
    end;

    procedure MigrateVendorEFTBankAccounts()
    var
        GPSY06000: Record "GP SY06000";
        CounterGPSY06000: Record "GP SY06000";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        VendorBankAccountExists: Boolean;
        CurrencyCode: Code[10];
        IBANCode: Code[50];
        LastVendorNo: Code[20];
        VendorBankAccountCounter: Integer;
        TotalVendorBankAccounts: Integer;
        BankCode: Code[20];
    begin
        GPSY06000.SetCurrentKey(CustomerVendor_ID);
        GPSY06000.SetRange("INACTIVE", false);
        if not GPSY06000.FindSet() then
            exit;

        Clear(LastVendorNo);
        repeat
            Clear(VendorBankAccount);
            if Vendor.Get(GPSY06000.CustomerVendor_ID) then begin
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPSY06000.RecordId));

                if (Vendor."No." = LastVendorNo) then
                    VendorBankAccountCounter := VendorBankAccountCounter + 1
                else begin
                    VendorBankAccountCounter := 1;
                    CounterGPSY06000.SetRange(CustomerVendor_ID, Vendor."No.");
                    CounterGPSY06000.SetRange("INACTIVE", false);
                    TotalVendorBankAccounts := CounterGPSY06000.Count();
                end;

                LastVendorNo := Vendor."No.";
                CurrencyCode := CopyStr(GPSY06000.CURNCYID, 1, MaxStrLen(CurrencyCode));
                HelperFunctions.CreateCurrencyIfNeeded(CurrencyCode);
                CreateSwiftCodeIfNeeded(GPSY06000.SWIFTADDR);

                IBANCode := CopyStr(GPSY06000.IntlBankAcctNum.Trim(), 1, MaxStrLen(VendorBankAccount.IBAN));
                if not IsValidIBANCode(IBANCode) then
                    IBANCode := '';

                BankCode := GetBankAccountCode(Vendor."No.", VendorBankAccountCounter, TotalVendorBankAccounts);
                VendorBankAccountExists := VendorBankAccount.Get(Vendor."No.", BankCode);
                VendorBankAccount.Validate("Vendor No.", Vendor."No.");
                VendorBankAccount.Validate("Code", BankCode);
                VendorBankAccount.Validate("Name", GPSY06000.BANKNAME);
                VendorBankAccount.Validate("Bank Branch No.", GPSY06000.EFTBankBranchCode);
                VendorBankAccount.Validate("Bank Account No.", CopyStr(GPSY06000.EFTBankAcct, 1, MaxStrLen(VendorBankAccount."Bank Account No.")));
                VendorBankAccount.Validate("Transit No.", GPSY06000.EFTTransitRoutingNo);
                VendorBankAccount.Validate("IBAN", IBANCode);
                VendorBankAccount.Validate("SWIFT Code", GPSY06000.SWIFTADDR);

                if GeneralLedgerSetup.Get() then
                    if GeneralLedgerSetup."LCY Code" <> CurrencyCode then
                        VendorBankAccount.Validate("Currency Code", CurrencyCode);

                if not VendorBankAccountExists then
                    VendorBankAccount.Insert()
                else
                    VendorBankAccount.Modify();

                SetPreferredBankAccountIfNeeded(GPSY06000, Vendor, BankCode, TotalVendorBankAccounts);
            end;
        until GPSY06000.Next() = 0;
    end;

    local procedure GetBankAccountCode(VendorNo: Code[20]; var BankAccountCounter: Integer; TotalVendorBankAccounts: Integer): Code[20]
    var
        BankCode: Code[20];
        MaxSupportedVendorNoLength: Integer;
    begin
        if TotalVendorBankAccounts = 1 then
            exit(VendorNo);

        // Prevent over flow
        MaxSupportedVendorNoLength := MaxStrLen(BankCode) - StrLen(Format(TotalVendorBankAccounts)) - 1;
#pragma warning disable AA0139
        if StrLen(VendorNo) > MaxSupportedVendorNoLength then
            VendorNo := CopyStr(VendorNo, 1, MaxSupportedVendorNoLength);
#pragma warning restore AA0139

        // The Vendor has more than one account, append a number to the code
        BankCode := CopyStr(VendorNo + '-' + Format(BankAccountCounter), 1, MaxStrLen(BankCode));
        while BankAccountAlreadyExists(VendorNo, BankCode) do begin
            BankAccountCounter := BankAccountCounter + 1;
            BankCode := CopyStr(VendorNo + '-' + Format(BankAccountCounter), 1, MaxStrLen(BankCode));
        end;

        exit(BankCode);
    end;

    local procedure BankAccountAlreadyExists(VendorNo: Code[20]; BankCode: Code[20]): Boolean
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        VendorBankAccount.SetRange("Vendor No.", VendorNo);
        VendorBankAccount.SetRange(Code, BankCode);
        exit(not VendorBankAccount.IsEmpty());
    end;

    local procedure IsValidIBANCode(IBANCode: Code[100]): Boolean
    var
        I: Integer;
    begin
        if IBANCode = '' then
            exit(false);

        if (StrLen(IBANCode) < 16) or (StrLen(IBANCode) > 35) then
            exit(false);

        for I := 1 to StrLen(UpperCase(IBANCode)) do
            if not ValidateIsValidIBANCharacter(IBANCode[I]) then
                exit(false);

        exit(true);
    end;

    local procedure ValidateIsValidIBANCharacter(C: Char): Boolean
    begin
        exit(
            (C = ' ') or
            ((C >= '0') and (C <= '9')) or
            ((C >= 'A') and (C <= 'Z'))
        )
    end;

    local procedure CreateSwiftCodeIfNeeded(SWIFTADDR: Text[11])
    var
        SwiftCode: Record "SWIFT Code";
    begin
        if (SWIFTADDR <> '') and not SwiftCode.Get(SWIFTADDR) then begin
            SwiftCode.Validate("Code", SWIFTADDR);
            SwiftCode.Insert();
        end;
    end;

    local procedure SetPreferredBankAccountIfNeeded(GPSY06000: Record "GP SY06000"; var Vendor: Record Vendor; NewBankCode: Code[20]; TotalVendorBankAccounts: Integer)
    var
        SearchGPSY06000: Record "GP SY06000";
        GPPM00200: Record "GP PM00200";
        ShouldSetAsPrimaryAccount: Boolean;
        AddressCode: Code[10];
        PrimaryAddressCode: Code[10];
        RemitToAddressCode: Code[10];
    begin
        if GPPM00200.Get(Vendor."No.") then begin
            AddressCode := CopyStr(GPSY06000.ADRSCODE.Trim(), 1, MaxStrLen(AddressCode));
            PrimaryAddressCode := CopyStr(GPPM00200.VADDCDPR.Trim(), 1, MaxStrLen(PrimaryAddressCode));
            RemitToAddressCode := CopyStr(GPPM00200.VADCDTRO.Trim(), 1, MaxStrLen(RemitToAddressCode));

            // The Remit To is the preferred account
            if AddressCode = RemitToAddressCode then
                ShouldSetAsPrimaryAccount := true
            else
                if AddressCode = PrimaryAddressCode then begin
                    // If the Vendor does not have a Remit To account, then use the Primary account instead
                    SearchGPSY06000.SetRange("CustomerVendor_ID", Vendor."No.");
                    SearchGPSY06000.SetRange("ADRSCODE", RemitToAddressCode);
                    SearchGPSY06000.SetRange("INACTIVE", false);
                    if SearchGPSY06000.IsEmpty() then
                        ShouldSetAsPrimaryAccount := true;
                end;
        end;

        if ShouldSetAsPrimaryAccount or (TotalVendorBankAccounts = 1) then begin
            Vendor.Validate(Vendor."Preferred Bank Account Code", NewBankCode);
            Vendor.Modify(true);
        end;
    end;

    local procedure GetVendorPayablesAccount(var GPVendor: Record "GP Vendor"; var GPCompanyAdditionalSettings: Record "GP Company Additional Settings"; var PayablesAccountNo: Code[20])
    var
        GPPM00200: Record "GP PM00200";
        GPPM00100: Record "GP PM00100";
        HelperFunctions: Codeunit "Helper Functions";
        VendorClassId: Text[20];
        DefaultPayablesAccountNo: Code[20];
    begin
        DefaultPayablesAccountNo := HelperFunctions.GetPostingAccountNumber('PayablesAccount');
        PayablesAccountNo := DefaultPayablesAccountNo;

        if not GPCompanyAdditionalSettings.GetMigrateVendorClasses() then
            exit;

        if not GPPM00200.Get(GPVendor.VENDORID) then
            exit;

#pragma warning disable AA0139
        VendorClassId := GPPM00200.VNDCLSID.Trim();
#pragma warning restore AA0139

        if VendorClassId = '' then
            exit;

        if not GPPM00100.Get(VendorClassId) then
            exit;

        PayablesAccountNo := HelperFunctions.GetGPAccountNumberByIndex(GPPM00100.PMAPINDX);

        if PayablesAccountNo = '' then
            PayablesAccountNo := DefaultPayablesAccountNo;
    end;
}