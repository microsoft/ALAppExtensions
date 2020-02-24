codeunit 1933 "MigrationGP Vendor Migrator"
{
    TableNo = "MigrationGP Vendor";

    var
        DocumentNo: Text[30];
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        VendorBatchNameTxt: Label 'GPVEND', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendor', '', true, true)]
    procedure OnMigrateVendor(VAR Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationGPVendor: Record "MigrationGP Vendor";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Vendor" then
            exit;
        MigrationGPVendor.Get(RecordIdToMigrate);
        MigrateVendorDetails(MigrationGPVendor, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Data Migration Facade", 'OnMigrateVendorPostingGroups', '', true, true)]
    procedure OnMigrateVendorPostingGroups(var Sender: Codeunit "Vendor Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Vendor" then
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
        MigrationGPVendor: Record "MigrationGP Vendor";
        MigrationGPVendTrans: Record "MigrationGP VendorTrans";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        PaymentTermsFormula: DateFormula;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Vendor" then
            exit;

        MigrationGPVendor.Get(RecordIdToMigrate);
        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(VendorBatchNameTxt, 1, 7), '', '');
        MigrationGPVendTrans.SetRange(VENDORID, MigrationGPVendor.VENDORID);
        MigrationGPVendTrans.SetRange(TransType, MigrationGPVendTrans.TransType::Invoice);
        if MigrationGPVendTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPVendTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPVendor.VENDNAME, 1, 50),
                    MigrationGPVendTrans.DOCDATE,
                    0D,
                    -MigrationGPVendTrans.CURTRXAM,
                    -MigrationGPVendTrans.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationGPVendTrans.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10), MigrationGPVendTrans.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPVendTrans.DOCNUMBR, 1, 20) + '-' + CopyStr(MigrationGPVendTrans.GLDocNo, 1, 14));
            until MigrationGPVendTrans.Next() = 0;

        MigrationGPVendTrans.Reset();
        MigrationGPVendTrans.SetRange(VENDORID, MigrationGPVendor.VENDORID);
        MigrationGPVendTrans.SetRange(TransType, MigrationGPVendTrans.TransType::Payment);
        if MigrationGPVendTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPVendTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPVendor.VENDNAME, 1, 50),
                    MigrationGPVendTrans.DOCDATE,
                    0D,
                    MigrationGPVendTrans.CURTRXAM,
                    MigrationGPVendTrans.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationGPVendTrans.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10), MigrationGPVendTrans.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPVendTrans.DOCNUMBR, 1, 20) + '-' + CopyStr(MigrationGPVendTrans.GLDocNo, 1, 14));
            until MigrationGPVendTrans.Next() = 0;

        MigrationGPVendTrans.Reset();
        MigrationGPVendTrans.SetRange(VENDORID, MigrationGPVendor.VENDORID);
        MigrationGPVendTrans.SetRange(TransType, MigrationGPVendTrans.TransType::"Credit Memo");
        if MigrationGPVendTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(VendorBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPVendTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPVendor.VENDNAME, 1, 50),
                    MigrationGPVendTrans.DOCDATE,
                    0D,
                    MigrationGPVendTrans.CURTRXAM,
                    MigrationGPVendTrans.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('PayablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationGPVendTrans.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                if (CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10), MigrationGPVendTrans.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(MigrationGPVendTrans.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPVendTrans.DOCNUMBR, 1, 20) + '-' + CopyStr(MigrationGPVendTrans.GLDocNo, 1, 14));
            until MigrationGPVendTrans.Next() = 0;
    end;

    local procedure MigrateVendorDetails(MigrationGPVendor: Record "MigrationGP Vendor"; VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade")
    var
        CompanyInformation: Record "Company Information";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        PaymentTermsFormula: DateFormula;
        VendorName: Text[50];
        ContactName: Text[50];
        Country: Code[10];
    begin
        VendorName := CopyStr(MigrationGPVendor.VENDNAME, 1, 50);
        ContactName := CopyStr(MigrationGPVendor.VNDCNTCT, 1, 50);
        if not VendorDataMigrationFacade.CreateVendorIfNeeded(CopyStr(MigrationGPVendor.VENDORID, 1, 20), VendorName) then
            exit;

        if (CopyStr(MigrationGPVendor.COUNTRY, 1, 10) <> '') then begin
            HelperFunctions.CreateCountryIfNeeded(CopyStr(MigrationGPVendor.COUNTRY, 1, 10), CopyStr(MigrationGPVendor.COUNTRY, 1, 10));
            Country := CopyStr(MigrationGPVendor.COUNTRY, 1, 10);
        end else begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (CopyStr(MigrationGPVendor.ZIPCODE, 1, 20) <> '') and (CopyStr(MigrationGPVendor.CITY, 1, 30) <> '') then
            VendorDataMigrationFacade.CreatePostCodeIfNeeded(CopyStr(MigrationGPVendor.ZIPCODE, 1, 20),
                CopyStr(MigrationGPVendor.CITY, 1, 30), CopyStr(MigrationGPVendor.STATE, 1, 20), Country);

        VendorDataMigrationFacade.SetAddress(CopyStr(MigrationGPVendor.ADDRESS1, 1, 50),
            CopyStr(MigrationGPVendor.ADDRESS2, 1, 50), CopyStr(MigrationGPVendor.COUNTRY, 1, 10),
            CopyStr(MigrationGPVendor.ZIPCODE, 1, 20), CopyStr(MigrationGPVendor.CITY, 1, 30));
        VendorDataMigrationFacade.SetContact(ContactName);
        VendorDataMigrationFacade.SetPhoneNo(MigrationGPVendor.PHNUMBR1);
        VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        VendorDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        VendorDataMigrationFacade.SetFaxNo(MigrationGPVendor.FAXNUMBR);
        VendorDataMigrationFacade.SetEmail(COPYSTR(MigrationGPVendor.INET1, 1, 80));
        VendorDataMigrationFacade.SetHomePage(COPYSTR(MigrationGPVendor.INET2, 1, 80));
        VendorDataMigrationFacade.SetVendorPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));


        if (CopyStr(MigrationGPVendor.SHIPMTHD, 1, 10) <> '') then begin
            VendorDataMigrationFacade.CreateShipmentMethodIfNeeded(CopyStr(MigrationGPVendor.SHIPMTHD, 1, 10), '');
            VendorDataMigrationFacade.SetShipmentMethodCode(CopyStr(MigrationGPVendor.SHIPMTHD, 1, 10));
        end;

        if (CopyStr(MigrationGPVendor.PYMTRMID, 1, 10) <> '') then begin
            EVALUATE(PaymentTermsFormula, '');
            VendorDataMigrationFacade.CreatePaymentTermsIfNeeded(CopyStr(MigrationGPVendor.PYMTRMID, 1, 10), MigrationGPVendor.PYMTRMID, PaymentTermsFormula);
            VendorDataMigrationFacade.SetPaymentTermsCode(CopyStr(MigrationGPVendor.PYMTRMID, 1, 10));
        end;

        VendorDataMigrationFacade.SetName2(CopyStr(MigrationGPVendor.VNDCHKNM, 1, 50));

        if (MigrationGPVendor.TAXSCHID <> '') then begin
            VendorDataMigrationFacade.CreateTaxAreaIfNeeded(MigrationGPVendor.TAXSCHID, '');
            VendorDataMigrationFacade.SetTaxAreaCode(MigrationGPVendor.TAXSCHID);
            VendorDataMigrationFacade.SetTaxLiable(true);
        end;

        VendorDataMigrationFacade.ModifyVendor(true);
    end;

    procedure GetAll()
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
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
        MigrationGPVendor: Record "MigrationGP Vendor";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        i: Integer;
    begin
        i := 0;
        MigrationGPVendor.Reset();
        MigrationGPVendor.DeleteAll();

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'VENDORID'), 1, MAXSTRLEN(MigrationGPVendor.VENDORID));
            EntityId := CopyStr(HelperFunctions.TrimBackslash(EntityId), 1, 75);
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 75);

            if not MigrationGPVendor.Get(EntityId) then begin
                MigrationGPVendor.Init();
                MigrationGPVendor.Validate(MigrationGPVendor.VENDORID, EntityId);
                MigrationGPVendor.Insert(true);
            end;

            RecordVariant := MigrationGPVendor;
            UpdateVendorFromJson(RecordVariant, ChildJToken);
            MigrationGPVendor := RecordVariant;
            MigrationGPVendor.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateVendorFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationGPVendor: Record "MigrationGP Vendor";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(VENDORID), JToken.AsObject(), 'VENDORID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(VENDNAME), JToken.AsObject(), 'VENDNAME');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(SEARCHNAME), JToken.AsObject(), 'SEARCHNAME');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(VNDCHKNM), JToken.AsObject(), 'VNDCHKNM');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(ADDRESS1), JToken.AsObject(), 'ADDRESS1');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(ADDRESS2), JToken.AsObject(), 'ADDRESS2');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(CITY), JToken.AsObject(), 'CITY');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(VNDCNTCT), JToken.AsObject(), 'VNDCNTCT');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(PHNUMBR1), JToken.AsObject(), 'PHNUMBR1');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(PYMTRMID), JToken.AsObject(), 'PYMTRMID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(SHIPMTHD), JToken.AsObject(), 'SHIPMTHD');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(COUNTRY), JToken.AsObject(), 'COUNTRY');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(PYMNTPRI), JToken.AsObject(), 'PYMNTPRI');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(AMOUNT), JToken.AsObject(), 'AMOUNT');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(FAXNUMBR), JToken.AsObject(), 'FAXNUMBR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(ZIPCODE), JToken.AsObject(), 'ZIPCODE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(STATE), JToken.AsObject(), 'STATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(INET1), JToken.AsObject(), 'INET1');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(INET2), JToken.AsObject(), 'INET2');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(TAXSCHID), JToken.AsObject(), 'TAXSCHID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(UPSZONE), JToken.AsObject(), 'UPSZONE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendor.FieldNO(TXIDNMBR), JToken.AsObject(), 'TXIDNMBR');
    end;

    local procedure GetTransactions()
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
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
        MigrationGPVendTrans: Record "MigrationGP VendorTrans";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[40];
        i: Integer;
    begin
        i := 0;
        MigrationGPVendTrans.Reset();
        MigrationGPVendTrans.DeleteAll();

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id'), 1, MAXSTRLEN(MigrationGPVendTrans.Id));
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 40);

            if not MigrationGPVendTrans.Get(EntityId) then begin
                MigrationGPVendTrans.Init();
                MigrationGPVendTrans.Validate(MigrationGPVendTrans.Id, EntityId);
                MigrationGPVendTrans.Insert(true);
            end;

            RecordVariant := MigrationGPVendTrans;
            DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
            UpdatePMTrxFromJson(RecordVariant, ChildJToken, DocumentNo);
            MigrationGPVendTrans := RecordVariant;
            HelperFunctions.SetVendorTransType(MigrationGPVendTrans);
            MigrationGPVendTrans.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdatePMTrxFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationGPVendTrans: Record "MigrationGP VendorTrans";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendTrans.FieldNo(VENDORID), JToken.AsObject(), 'VENDORID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendTrans.FieldNo(DOCNUMBR), JToken.AsObject(), 'DOCNUMBR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendTrans.FieldNo(DOCDATE), JToken.AsObject(), 'DOCDATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendTrans.FieldNo(DUEDATE), JToken.AsObject(), 'DUEDATE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendTrans.FieldNo(CURTRXAM), JToken.AsObject(), 'CURTRXAM');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendTrans.FieldNo(DOCTYPE), JToken.AsObject(), 'DOCTYPE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPVendTrans.FieldNo(PYMTRMID), JToken.AsObject(), 'PYMTRMID');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationGPVendTrans.FieldNo(GLDocNo), DocumentNo);
    end;
}