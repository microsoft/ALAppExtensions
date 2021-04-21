codeunit 4022 "GP Vendor Migrator"
{
    TableNo = "GP Vendor";

    var
        DocumentNo: Text[30];
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        VendorBatchNameTxt: Label 'GPVEND', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendor', '', true, true)]
    procedure OnMigrateVendor(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPVendor: Record "GP Vendor";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Vendor" then
            exit;
        GPVendor.Get(RecordIdToMigrate);
        MigrateVendorDetails(GPVendor, Sender);
        MigrateVendorAddresses(GPVendor);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorPostingGroups', '', true, true)]
    procedure OnMigrateVendorPostingGroups(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Vendor" then
            exit;

        Sender.CreatePostingSetupIfNeeded(
            CopyStr(PostingGroupCodeTxt, 1, 5),
            CopyStr(PostingGroupDescriptionTxt, 1, 20),
            HelperFunctions.GetPostingAccountNumber('PayablesAccount')
        );

        Sender.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        Sender.ModifyVendor(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorTransactions', '', true, true)]
    procedure OnMigrateVendorTransactions(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        GPVendor: Record "GP Vendor";
        GPVendorTransactions: Record "GP Vendor Transactions";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        HelperFunctions: Codeunit "Helper Functions";
        PaymentTermsFormula: DateFormula;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Vendor" then
            exit;

        GPVendor.Get(RecordIdToMigrate);
        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(VendorBatchNameTxt, 1, 7), '', '');
        GPVendorTransactions.SetRange(VENDORID, GPVendor.VENDORID);
        GPVendorTransactions.SetRange(TransType, GPVendorTransactions.TransType::Invoice);
        if GPVendorTransactions.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(GPVendorTransactions.GLDocNo, 1, 20),
                    CopyStr(GPVendor.VENDNAME, 1, 50),
                    GPVendorTransactions.DOCDATE,
                    0D,
                    -GPVendorTransactions.CURTRXAM,
                    -GPVendorTransactions.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(GPVendorTransactions.TransType);
                DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(GPVendorTransactions.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10), GPVendorTransactions.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(GPVendorTransactions.DOCNUMBR, 1, 20) + '-' + CopyStr(GPVendorTransactions.GLDocNo, 1, 14));
            until GPVendorTransactions.Next() = 0;

        GPVendorTransactions.Reset();
        GPVendorTransactions.SetRange(VENDORID, GPVendor.VENDORID);
        GPVendorTransactions.SetRange(TransType, GPVendorTransactions.TransType::Payment);
        if GPVendorTransactions.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(GPVendorTransactions.GLDocNo, 1, 20),
                    CopyStr(GPVendor.VENDNAME, 1, 50),
                    GPVendorTransactions.DOCDATE,
                    0D,
                    GPVendorTransactions.CURTRXAM,
                    GPVendorTransactions.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(GPVendorTransactions.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(GPVendorTransactions.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10), GPVendorTransactions.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(GPVendorTransactions.DOCNUMBR, 1, 20) + '-' + CopyStr(GPVendorTransactions.GLDocNo, 1, 14));
            until GPVendorTransactions.Next() = 0;

        GPVendorTransactions.Reset();
        GPVendorTransactions.SetRange(VENDORID, GPVendor.VENDORID);
        GPVendorTransactions.SetRange(TransType, GPVendorTransactions.TransType::"Credit Memo");
        if GPVendorTransactions.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(GPVendorTransactions.GLDocNo, 1, 20),
                    CopyStr(GPVendor.VENDNAME, 1, 50),
                    GPVendorTransactions.DOCDATE,
                    0D,
                    GPVendorTransactions.CURTRXAM,
                    GPVendorTransactions.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(GPVendorTransactions.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(GPVendorTransactions.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10), GPVendorTransactions.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(GPVendorTransactions.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(GPVendorTransactions.DOCNUMBR, 1, 20) + '-' + CopyStr(GPVendorTransactions.GLDocNo, 1, 14));
            until GPVendorTransactions.Next() = 0;
    end;

    local procedure MigrateVendorDetails(GPVendor: Record "GP Vendor"; VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade")
    var
        CompanyInformation: Record "Company Information";
        HelperFunctions: Codeunit "Helper Functions";
        PaymentTermsFormula: DateFormula;
        VendorName: Text[50];
        ContactName: Text[50];
        Country: Code[10];
    begin
        VendorName := CopyStr(GPVendor.VENDNAME, 1, 50);
        ContactName := CopyStr(GPVendor.VNDCNTCT, 1, 50);
        if not VendorDataMigrationFacade.CreateVendorIfNeeded(CopyStr(GPVendor.VENDORID, 1, 20), VendorName) then
            exit;

        if (CopyStr(GPVendor.COUNTRY, 1, 10) <> '') then begin
            HelperFunctions.CreateCountryIfNeeded(CopyStr(GPVendor.COUNTRY, 1, 10), CopyStr(GPVendor.COUNTRY, 1, 10));
            Country := CopyStr(GPVendor.COUNTRY, 1, 10);
        end else begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (CopyStr(GPVendor.ZIPCODE, 1, 20) <> '') and (CopyStr(GPVendor.CITY, 1, 30) <> '') then
            VendorDataMigrationFacade.CreatePostCodeIfNeeded(CopyStr(GPVendor.ZIPCODE, 1, 20),
                CopyStr(GPVendor.CITY, 1, 30), CopyStr(GPVendor.STATE, 1, 20), Country);

        VendorDataMigrationFacade.SetAddress(CopyStr(GPVendor.ADDRESS1, 1, 50),
            CopyStr(GPVendor.ADDRESS2, 1, 50), Country,
            CopyStr(GPVendor.ZIPCODE, 1, 20), CopyStr(GPVendor.CITY, 1, 30));
        VendorDataMigrationFacade.SetContact(ContactName);
        VendorDataMigrationFacade.SetPhoneNo(GPVendor.PHNUMBR1);
        VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        VendorDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        VendorDataMigrationFacade.SetFaxNo(GPVendor.FAXNUMBR);
        VendorDataMigrationFacade.SetEmail(COPYSTR(GPVendor.INET1, 1, 80));
        VendorDataMigrationFacade.SetHomePage(COPYSTR(GPVendor.INET2, 1, 80));
        VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));


        if (CopyStr(GPVendor.SHIPMTHD, 1, 10) <> '') then begin
            VendorDataMigrationFacade.CreateShipmentMethodIfNeeded(CopyStr(GPVendor.SHIPMTHD, 1, 10), '');
            VendorDataMigrationFacade.SetShipmentMethodCode(CopyStr(GPVendor.SHIPMTHD, 1, 10));
        end;

        if (CopyStr(GPVendor.PYMTRMID, 1, 10) <> '') then begin
            EVALUATE(PaymentTermsFormula, '');
            VendorDataMigrationFacade.CreatePaymentTermsIfNeeded(CopyStr(GPVendor.PYMTRMID, 1, 10), GPVendor.PYMTRMID, PaymentTermsFormula);
            VendorDataMigrationFacade.SetPaymentTermsCode(CopyStr(GPVendor.PYMTRMID, 1, 10));
        end;

        VendorDataMigrationFacade.SetName2(CopyStr(GPVendor.VNDCHKNM, 1, 50));

        if (GPVendor.TAXSCHID <> '') then begin
            VendorDataMigrationFacade.CreateTaxAreaIfNeeded(GPVendor.TAXSCHID, '');
            VendorDataMigrationFacade.SetTaxAreaCode(GPVendor.TAXSCHID);
            VendorDataMigrationFacade.SetTaxLiable(true);
        end;

        VendorDataMigrationFacade.ModifyVendor(true);
    end;

    local procedure MigrateVendorAddresses(GPVendor: Record "GP Vendor")
    var
        GPVendorAddress: Record "GP Vendor Address";
    begin
        GPVendorAddress.SetRange(VENDORID, GPVendor.VENDORID);
        if GPVendorAddress.FindSet() then
            repeat
                GPVendorAddress.MoveStagingData();
            until GPVendorAddress.Next() = 0;
    end;

    procedure GetAll()
    var
        HelperFunctions: Codeunit "Helper Functions";
        JArray: JsonArray;
    begin
        HelperFunctions.GetEntities('Vendor', JArray);
        GetVendorsFromJson(JArray);
        GetTransactions();
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        DocumentNo := 'V00000';
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

    local procedure GetTransactions()
    var
        HelperFunctions: Codeunit "Helper Functions";
        JArray: JsonArray;
    begin
        DocumentNo := 'V00000';
        if (HelperFunctions.GetEntities('PMTrx', JArray)) then
            GetPMTrxFromJson(JArray);
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
            DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
            UpdatePMTrxFromJson(RecordVariant, ChildJToken, DocumentNo);
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
}