codeunit 4018 "GP Customer Migrator"
{
    TableNo = "GP Customer";

    var
        GlobalDocumentNo: Text[30];
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        CustomerBatchNameTxt: Label 'GPCUST', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;

#pragma warning disable AA0207
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomer', '', true, true)]
    procedure OnMigrateCustomer(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPCustomer: Record "GP Customer";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Customer" then
            exit;
        GPCustomer.Get(RecordIdToMigrate);
        MigrateCustomerDetails(GPCustomer, Sender);
        MigrateCustomerAddresses(GPCustomer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerPostingGroups', '', true, true)]
    procedure OnMigrateCustomerPostingGroups(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Customer" then
            exit;

        Sender.CreatePostingSetupIfNeeded(
            CopyStr(PostingGroupCodeTxt, 1, 5),
            CopyStr(PostingGroupDescriptionTxt, 1, 20),
            HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
        );
        // Set the other two accounts here?
        Sender.SetCustomerPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        Sender.ModifyCustomer(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerTransactions', '', true, true)]
    procedure OnMigrateCustomerTransactions(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        MigrationGPCustomer: Record "GP Customer";
        MigrationGPCustTrans: Record "GP Customer Transactions";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        HelperFunctions: Codeunit "Helper Functions";
        PaymentTermsFormula: DateFormula;
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"GP Customer" then
            exit;

        MigrationGPCustomer.Get(RecordIdToMigrate);
        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(CustomerBatchNameTxt, 1, 7), '', '');
        MigrationGPCustTrans.SetRange(CUSTNMBR, MigrationGPCustomer.CUSTNMBR);
        MigrationGPCustTrans.SetRange(TransType, MigrationGPCustTrans.TransType::Invoice);
        if MigrationGPCustTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPCustTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50),
                    MigrationGPCustTrans.DOCDATE,
                    0D,
                    MigrationGPCustTrans.CURTRXAM,
                    MigrationGPCustTrans.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
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
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPCustTrans.DOCNUMBR, 1, 20) + '-' + CopyStr(MigrationGPCustTrans.GLDocNo, 1, 14));
            until MigrationGPCustTrans.Next() = 0;

        MigrationGPCustTrans.Reset();
        MigrationGPCustTrans.SetRange(CUSTNMBR, MigrationGPCustomer.CUSTNMBR);
        MigrationGPCustTrans.SetRange(TransType, MigrationGPCustTrans.TransType::Payment);
        if MigrationGPCustTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPCustTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50),
                    MigrationGPCustTrans.DOCDATE,
                    MigrationGPCustTrans.DOCDATE,
                    -MigrationGPCustTrans.CURTRXAM,
                    -MigrationGPCustTrans.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationGPCustTrans.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineSalesPersonCode(CopyStr(MigrationGPCustTrans.SLPRSNID, 1, 20));
                if (CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10) <> '') then begin
                    Evaluate(PaymentTermsFormula, '');
                    Sender.CreatePaymentTermsIfNeeded(Copystr(MigrationGPCustTrans.PYMTRMID, 1, 10), MigrationGPCustTrans.PYMTRMID, PaymentTermsFormula);
                end;
                Sender.SetGeneralJournalLinePaymentTerms(CopyStr(MigrationGPCustTrans.PYMTRMID, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPCustTrans.DOCNUMBR, 1, 20) + '-' + CopyStr(MigrationGPCustTrans.GLDocNo, 1, 14));
            until MigrationGPCustTrans.Next() = 0;

        MigrationGPCustTrans.Reset();
        MigrationGPCustTrans.SetRange(CUSTNMBR, MigrationGPCustomer.CUSTNMBR);
        MigrationGPCustTrans.SetRange(TransType, MigrationGPCustTrans.TransType::"Credit Memo");
        if MigrationGPCustTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(CustomerBatchNameTxt, 1, 7),
                    CopyStr(MigrationGPCustTrans.GLDocNo, 1, 20),
                    CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50),
                    MigrationGPCustTrans.DOCDATE,
                    0D,
                    -MigrationGPCustTrans.CURTRXAM,
                    -MigrationGPCustTrans.CURTRXAM,
                    '',
                    HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
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
                Sender.SetGeneralJournalLineExternalDocumentNo(CopyStr(MigrationGPCustTrans.DOCNUMBR, 1, 20) + '-' + CopyStr(MigrationGPCustTrans.GLDocNo, 1, 14));
            until MigrationGPCustTrans.Next() = 0;
    end;
#pragma warning restore AA0207

    local procedure MigrateCustomerDetails(MigrationGPCustomer: Record "GP Customer"; CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade")
    var
        CompanyInformation: Record "Company Information";
        HelperFunctions: Codeunit "Helper Functions";
        PaymentTermsFormula: DateFormula;
        Country: Code[10];
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
    begin
        if not CustomerDataMigrationFacade.CreateCustomerIfNeeded(CopyStr(MigrationGPCustomer.CUSTNMBR, 1, 20), CopyStr(MigrationGPCustomer.CUSTNAME, 1, 50)) then
            exit;

        if (CopyStr(MigrationGPCustomer.COUNTRY, 1, 10) <> '') then begin
            Country := CopyStr(MigrationGPCustomer.COUNTRY, 1, 10);
            CustomerDataMigrationFacade.CreateCountryIfNeeded(Country, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name");
        end else begin
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
        MigrationGPCustomer.PHONE1 := HelperFunctions.CleanGPPhoneOrFaxNumber(MigrationGPCustomer.PHONE1);
        MigrationGPCustomer.FAX := HelperFunctions.CleanGPPhoneOrFaxNumber(MigrationGPCustomer.FAX);
        CustomerDataMigrationFacade.SetPhoneNo(MigrationGPCustomer.PHONE1);
        CustomerDataMigrationFacade.SetFaxNo(MigrationGPCustomer.FAX);
        CustomerDataMigrationFacade.SetCustomerPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        CustomerDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        CustomerDataMigrationFacade.SetEmail(COPYSTR(MigrationGPCustomer.INET1, 1, 80));
        CustomerDataMigrationFacade.SetHomePage(COPYSTR(MigrationGPCustomer.INET2, 1, 80));

        If MigrationGPCustomer.STMTCYCL = true then
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

#if not CLEAN22
    [Obsolete('Method is not supported, it was using files', '22.0')]
    procedure GetAll()
#if not CLEAN21
    var
        MigrationGPCustomer: Record "GP Customer";
        HelperFunctions: Codeunit "Helper Functions";
        JArray: JsonArray;
    begin
#pragma warning disable AL0432        
        HelperFunctions.GetEntities('Customer', JArray);
        MigrationGPCustomer.DeleteAll();
        GetCustomersFromJson(JArray);
        GetTransactions();
#pragma warning restore AL0432               
    end;
#else
    begin
    end;
#endif
#endif

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

        WHILE JArray.Get(i, ChildJToken) do begin
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

#if not CLEAN22
    [Obsolete('Method is not supported, it was using files', '22.0')]
    local procedure GetTransactions()
#if not CLEAN21    
    var
        MigrationGPCustTrans: Record "GP Customer Transactions";
        HelperFunctions: Codeunit "Helper Functions";
        JArray: JsonArray;
#endif
    begin
#if not CLEAN21
        MigrationGPCustTrans.DeleteAll();
        GlobalDocumentNo := 'C00000';
#pragma warning disable AL0432
        if (HelperFunctions.GetEntities('RMTrx', JArray)) then
            GetRMTrxFromJson(JArray);
#pragma warning restore AL0432            
#endif
    end;
#endif

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
        WHILE JArray.Get(i, ChildJToken) do begin
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

    procedure MigrateCustomerClasses()
    var
        GPRM00101: Record "GP RM00101";
        GPRM00201: Record "GP RM00201";
        CustomerPostingGroup: Record "Customer Posting Group";
        Customer: Record Customer;
        HelperFunctions: Codeunit "Helper Functions";
        ClassId: Text[20];
        AccountNumber: Code[20];
    begin
        if not GPRM00101.FindSet() then
            exit;

        if not GPRM00201.FindSet() then
            exit;

        // Create the Customer Posting Groups
        repeat
            Clear(CustomerPostingGroup);
#pragma warning disable AA0139
            ClassId := GPRM00201.CLASSID.Trim();
#pragma warning restore AA0139

            if ClassId <> '' then
                if not CustomerPostingGroup.Get(ClassId) then begin
                    CustomerPostingGroup.Validate("Code", ClassId);
                    CustomerPostingGroup.Validate("Description", GPRM00201.CLASDSCR);

                    // Receivables Account
                    AccountNumber := HelperFunctions.GetGPAccountNumberByIndex(GPRM00201.RMARACC);
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
                end;
        until GPRM00201.Next() = 0;

        // Assign the Customer Posting Groups to the Customers
        repeat
#pragma warning disable AA0139
            ClassId := GPRM00101.CUSTCLAS.Trim();
#pragma warning restore AA0139
            if ClassId <> '' then
                if Customer.Get(GPRM00101.CUSTNMBR) then begin
                    Customer.Validate("Customer Posting Group", ClassId);
                    Customer.Modify(true);
                end;
        until GPRM00101.Next() = 0;
    end;
}