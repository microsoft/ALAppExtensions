codeunit 1912 "MigrationQB Customer Migrator"
{
    TableNo = "MigrationQB Customer";

    var
        DocumentNo: Text[30];
        PostingGroupCodeTxt: Label 'QB', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from QB', Locked = true;
        EmptyStringTxt: Label '', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomer', '', true, true)]
    procedure OnMigrateCustomer(VAR Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationQBCustomer: Record "MigrationQB Customer";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Customer" then
            exit;
        MigrationQBCustomer.Get(RecordIdToMigrate);
        MigrateCustomerDetails(MigrationQBCustomer, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerPostingGroups', '', true, true)]
    procedure OnMigrateCustomerPostingGroups(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Customer" then
            exit;

        Sender.CreatePostingSetupIfNeeded(
            CopyStr(PostingGroupCodeTxt, 1, 5),
            CopyStr(PostingGroupDescriptionTxt, 1, 20),
            HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
        );
        Sender.SetCustomerPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        Sender.ModifyCustomer(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Data Migration Facade", 'OnMigrateCustomerTransactions', '', true, true)]
    procedure OnMigrateCustomerTransactions(var Sender: Codeunit "Customer Data Migration Facade"; RecordIdToMigrate: RecordId; ChartOfAccountsMigrated: Boolean)
    var
        MigrationQBCustomer: Record "MigrationQB Customer";
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        if not ChartOfAccountsMigrated then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Customer" then
            exit;

        MigrationQBCustomer.Get(RecordIdToMigrate);
        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 5), '', '');

        MigrationQBCustTrans.SetRange(CustomerRef, MigrationQBCustomer.ListId);
        MigrationQBCustTrans.SetRange(TransType, MigrationQBCustTrans.TransType::Invoice);
        if MigrationQBCustTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(PostingGroupCodeTxt, 1, 5),
                    CopyStr(MigrationQBCustTrans.GLDocNo, 1, 20),
                    GetCustomerName(MigrationQBCustomer),
                    MigrationQBCustTrans.TxnDate,
                    0D,
                    MigrationQBCustTrans.Amount,
                    MigrationQBCustTrans.Amount,
                    '',
                    HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationQBCustTrans.TransType);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(MigrationQBCustTrans.DocNumber);
            until MigrationQBCustTrans.Next() = 0;

        MigrationQBCustTrans.Reset();
        MigrationQBCustTrans.SetRange(CustomerRef, MigrationQBCustomer.ListId);
        MigrationQBCustTrans.SetRange(TransType, MigrationQBCustTrans.TransType::Payment);
        if MigrationQBCustTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(PostingGroupCodeTxt, 1, 5),
                    CopyStr(MigrationQBCustTrans.GLDocNo, 1, 20),
                    GetCustomerName(MigrationQBCustomer),
                    MigrationQBCustTrans.TxnDate,
                    0D,
                    -MigrationQBCustTrans.Amount,
                    -MigrationQBCustTrans.Amount,
                    '',
                    HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationQBCustTrans.TransType::Payment);
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(MigrationQBCustTrans.TxnId);
            until MigrationQBCustTrans.Next() = 0;

        MigrationQBCustTrans.Reset();
        MigrationQBCustTrans.SetRange(CustomerRef, MigrationQBCustomer.ListId);
        MigrationQBCustTrans.SetRange(TransType, MigrationQBCustTrans.TransType::"Credit Memo");
        if MigrationQBCustTrans.FindSet() then
            repeat
                Sender.CreateGeneralJournalLine(
                    CopyStr(PostingGroupCodeTxt, 1, 5),
                    CopyStr(MigrationQBCustTrans.GLDocNo, 1, 20),
                    GetCustomerName(MigrationQBCustomer),
                    MigrationQBCustTrans.TxnDate,
                    0D,
                    -MigrationQBCustTrans.Amount,
                    -MigrationQBCustTrans.Amount,
                    '',
                    HelperFunctions.GetPostingAccountNumber('ReceivablesAccount')
                );
                Sender.SetGeneralJournalLineDocumentType(MigrationQBCustTrans.TransType::"Credit Memo");
                Sender.SetGeneralJournalLineSourceCode(CopyStr(SourceCodeTxt, 1, 10));
                Sender.SetGeneralJournalLineExternalDocumentNo(MigrationQBCustTrans.TxnId);
            until MigrationQBCustTrans.Next() = 0;
    end;

    local procedure MigrateCustomerDetails(MigrationQBCustomer: Record "MigrationQB Customer"; CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade")
    var
        CompanyInformation: Record "Company Information";
        CustomerName: Text[50];
        Country: Code[10];
        ContactName: Text[50];
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
    begin
        CustomerName := GetCustomerName(MigrationQBCustomer);
        ContactName := GetContactName(MigrationQBCustomer);
        if not CustomerDataMigrationFacade.CreateCustomerIfNeeded(CopyStr(MigrationQBCustomer.Id, 1, 20), CustomerName) then
            exit;

        if (CopyStr(MigrationQBCustomer.BillAddrCountry, 1, 10) <> '') then begin
            Country := CopyStr(MigrationQBCustomer.BillAddrCountry, 1, 10);
            CustomerDataMigrationFacade.CreateCountryIfNeeded(Country, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name");
        end else begin
            CompanyInformation.Get();
            Country := CompanyInformation."Country/Region Code";
        end;

        if (CopyStr(MigrationQBCustomer.BillAddrPostalCode, 1, 20) <> '') and (CopyStr(MigrationQBCustomer.BillAddrCity, 1, 30) <> '') then
            CustomerDataMigrationFacade.CreatePostCodeIfNeeded(CopyStr(MigrationQBCustomer.BillAddrPostalCode, 1, 20),
                CopyStr(MigrationQBCustomer.BillAddrCity, 1, 30), CopyStr(MigrationQBCustomer.BillAddrState, 1, 20), Country);

        CustomerDataMigrationFacade.SetAddress(CopyStr(MigrationQBCustomer.BillAddrLine1, 1, 50),
            CopyStr(MigrationQBCustomer.BillAddrLine2, 1, 50), Country, CopyStr(MigrationQBCustomer.BillAddrPostalCode, 1, 20),
            CopyStr(MigrationQBCustomer.BillAddrCity, 1, 30));
        CustomerDataMigrationFacade.SetContact(ContactName);
        CustomerDataMigrationFacade.SetPhoneNo(MigrationQBCustomer.PrimaryPhone);
        CustomerDataMigrationFacade.SetCustomerPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        CustomerDataMigrationFacade.SetGenBusPostingGroup(CopyStr(PostingGroupCodeTxt, 1, 5));
        CustomerDataMigrationFacade.SetFaxNo(MigrationQBCustomer.Fax);
        CustomerDataMigrationFacade.SetEmail(CopyStr(SelectStr(1, CopyStr(MigrationQBCustomer.PrimaryEmailAddr, 1, 80)), 1, 80));
        CustomerDataMigrationFacade.SetHomePage(CopyStr(MigrationQBCustomer.WebAddr, 1, 80));
        CustomerDataMigrationFacade.SetTaxLiable(MigrationQBCustomer.Taxable);
        CustomerDataMigrationFacade.ModifyCustomer(true);
    end;

    local procedure GetCustomerName(MigrationQBCustomer: Record "MigrationQB Customer"): Text[50]
    var
        name: Text[50];
    begin
        if (MigrationQBCustomer.CompanyName = '') AND (MigrationQBCustomer.GivenName = '') AND (MigrationQBCustomer.FamilyName = '') then begin
            name := CopyStr(MigrationQBCustomer.DisplayName, 1, 50);
            exit(name);
        end;

        if MigrationQBCustomer.CompanyName = '' then
            name := CopyStr(MigrationQBCustomer.GivenName + ' ' + MigrationQBCustomer.FamilyName, 1, 50)
        else
            name := CopyStr(MigrationQBCustomer.CompanyName, 1, 50);
        exit(name);
    end;

    local procedure GetContactName(MigrationQBCustomer: Record "MigrationQB Customer"): Text[50]
    var
        name: Text[50];
    begin
        name := CopyStr(MigrationQBCustomer.GivenName + ' ' + MigrationQBCustomer.FamilyName, 1, 50);
        exit(name);
    end;

    procedure GetAll(IsOnline: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        JArray: JsonArray;
        Success: Boolean;
    begin
        DeleteAll();

        if IsOnline then
            Success := HelperFunctions.GetEntities('Select * from Customer', 'Customer', JArray)
        else
            Success := HelperFunctions.GetEntities('Customer', JArray);

        if Success then begin
            GetCustomersFromJson(JArray);
            GetTransactions(IsOnline);
        end;
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        GetCustomersFromJson(JArray);
    end;

    procedure DeleteAll()
    var
        MigrationQBCustomer: Record "MigrationQB Customer";
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
    begin
        MigrationQBCustomer.DeleteAll();
        MigrationQBCustTrans.DeleteAll();
        Commit();
    end;

    local procedure GetCustomersFromJson(JArray: JsonArray)
    var
        MigrationQBCustomer: Record "MigrationQB Customer";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBCustomer.Get(EntityId) then begin
                MigrationQBCustomer.Init();
                MigrationQBCustomer.VALIDATE(MigrationQBCustomer.Id, EntityId);
                MigrationQBCustomer.Insert(true);
            end;

            RecordVariant := MigrationQBCustomer;
            UpdateCustomerFromJson(RecordVariant, ChildJToken);
            MigrationQBCustomer := RecordVariant;
            MigrationQBCustomer.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateCustomerFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationQBCustomer: Record "MigrationQB Customer";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustomer.FieldNO(GivenName), JToken.AsObject(), 'GivenName');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustomer.FieldNO(FamilyName), JToken.AsObject(), 'FamilyName');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustomer.FieldNO(CompanyName), JToken.AsObject(), 'CompanyName');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustomer.FieldNO(DisplayName), JToken.AsObject(), 'DisplayName');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrLine1), JToken.AsObject(), 'BillAddr.Line1');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrLine2), JToken.AsObject(), 'BillAddr.Line2');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrCity), JToken.AsObject(), 'BillAddr.City');

        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrCountry), JToken.AsObject(), 'BillAddr.Country');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrPostalCode), JToken.AsObject(), 'BillAddr.PostalCode');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrCountrySubDivCode),
            JToken.AsObject(), 'BillAddr.CountrySubDivisionCode');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(PrimaryPhone), JToken.AsObject(), 'PrimaryPhone.FreeFormNumber');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(PrimaryEmailAddr), JToken.AsObject(), 'PrimaryEmailAddr.Address');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(WebAddr), JToken.AsObject(), 'WebAddr.URI');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(Fax), JToken.AsObject(), 'Fax.FreeFormNumber');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustomer.FieldNO(Taxable), JToken.AsObject(), 'Taxable');
        HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(DefaultTaxCodeRef), JToken.AsObject(), 'DefaultTaxCodeRef.value');

        if HelperFunctions.IsOnlineData() then begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrState), JToken.AsObject(), 'BillAddr.CountrySubDivisionCode');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustomer.FieldNO(ListId), JToken.AsObject(), 'Id');
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(ParentRef), JToken.AsObject(), 'ParentRef.value');
        end else begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(BillAddrState), JToken.AsObject(), 'BillAddr.State');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustomer.FieldNO(ListId), JToken.AsObject(), 'ListId');
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustomer.FieldNO(ParentRef), JToken.AsObject(), 'ParentRef.ListId');
        end;
    end;

    local procedure GetTransactions(IsOnline: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        JArray: JsonArray;
    begin
        DocumentNo := 'C00000';
        if IsOnline then begin
            if (HelperFunctions.GetEntities('select * from Invoice where Balance != ''0'' ', 'Invoice', JArray)) then
                GetInvoicesFromJson(JArray);
            if (HelperFunctions.GetEntities('select * from CreditMemo where Balance != ''0'' ', 'CreditMemo', JArray)) then
                GetCreditMemosFromJson(JArray);
            if (HelperFunctions.GetEntities('select * from Payment', 'Payment', JArray)) then
                GetPaymentsFromJson(JArray);
        end else begin
            if (HelperFunctions.GetEntities('Invoice', JArray)) then
                GetInvoicesFromJson(JArray);
            if (HelperFunctions.GetEntities('Payment', JArray)) then
                GetPaymentsFromJson(JArray);
            if (HelperFunctions.GetEntities('CreditMemo', JArray)) then
                GetCreditMemosFromJson(JArray);
        end;

        if not HelperFunctions.IsOnlineData() then
            CleanupCustomerJobReferences();
    end;

    local procedure GetInvoicesFromJson(JArray: JsonArray);
    var
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;
        WHILE JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBCustTrans.Get(EntityId, MigrationQBCustTrans.TransType::Invoice) then begin
                MigrationQBCustTrans.Init();
                MigrationQBCustTrans.Validate(MigrationQBCustTrans.Id, EntityId);
                MigrationQBCustTrans.Validate(MigrationQBCustTrans.TransType, MigrationQBCustTrans.TransType::Invoice);
                MigrationQBCustTrans.Insert(true);
            end;

            RecordVariant := MigrationQBCustTrans;
            DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
            UpdateInvoiceFromJson(RecordVariant, ChildJToken, DocumentNo);
            MigrationQBCustTrans := RecordVariant;
            MigrationQBCustTrans.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure GetPaymentsFromJson(JArray: JsonArray);
    var
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBCustTrans.Get(EntityId, MigrationQBCustTrans.TransType::Payment) then begin
                MigrationQBCustTrans.Init();
                MigrationQBCustTrans.Validate(MigrationQBCustTrans.Id, EntityId);
                MigrationQBCustTrans.Validate(MigrationQBCustTrans.TransType, MigrationQBCustTrans.TransType::Payment);
                MigrationQBCustTrans.Insert(true);
            end;

            RecordVariant := MigrationQBCustTrans;
            DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
            UpdatePaymentFromJson(RecordVariant, ChildJToken, DocumentNo);
            MigrationQBCustTrans := RecordVariant;
            MigrationQBCustTrans.Modify(true);

            i := i + 1;
        end;
        CleanupPayments();
    end;

    local procedure GetCreditMemosFromJson(JArray: JsonArray);
    var
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        WHILE JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id')), 1, 15);

            if not MigrationQBCustTrans.Get(EntityId, MigrationQBCustTrans.TransType::"Credit Memo") then begin
                MigrationQBCustTrans.Init();
                MigrationQBCustTrans.Validate(MigrationQBCustTrans.Id, EntityId);
                MigrationQBCustTrans.Validate(MigrationQBCustTrans.TransType, MigrationQBCustTrans.TransType::"Credit Memo");
                MigrationQBCustTrans.Insert(true);
            end;

            RecordVariant := MigrationQBCustTrans;
            DocumentNo := CopyStr(IncStr(DocumentNo), 1, 30);
            UpdateCreditMemoFromJson(RecordVariant, ChildJToken, DocumentNo);
            MigrationQBCustTrans := RecordVariant;
            MigrationQBCustTrans.Modify(true);
            i := i + 1;
        end;
    end;

    local procedure UpdateInvoiceFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(DocNumber), JToken.AsObject(), 'DocNumber');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(ShipDate), JToken.AsObject(), 'ShipDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(DueDate), JToken.AsObject(), 'DueDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(TxnDate), JToken.AsObject(), 'TxnDate');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationQBCustTrans.FieldNo(GLDocNo), DocumentNo);

        if HelperFunctions.IsOnlineData() then begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustTrans.FieldNo(CustomerRef), JToken.AsObject(), 'CustomerRef.value');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(Amount), JToken.AsObject(), 'Balance');
        end else begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustTrans.FieldNo(CustomerRef), JToken.AsObject(), 'CustomerRef.ListId');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(Amount), JToken.AsObject(), 'BalanceRemaining');
        end;
    end;

    local procedure UpdatePaymentFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(DocNumber), JToken.AsObject(), 'TxnNumber');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(ShipDate), JToken.AsObject(), 'ShipDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(TxnDate), JToken.AsObject(), 'TxnDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(TxnId), JToken.AsObject(), 'TxnId');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationQBCustTrans.FieldNo(GLDocNo), DocumentNo);

        if HelperFunctions.IsOnlineData() then begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustTrans.FieldNo(CustomerRef), JToken.AsObject(), 'CustomerRef.value');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(Amount), JToken.AsObject(), 'UnappliedAmt');
        end else begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustTrans.FieldNo(CustomerRef), JToken.AsObject(), 'CustomerRef.ListId');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(Amount), JToken.AsObject(), 'UnusedPayment');
        end;
    end;

    local procedure UpdateCreditMemoFromJson(var RecordVariant: Variant; JToken: JsonToken; DocumentNo: Text[30])
    var
        MigrationQBCustTrans: Record "MigrationQB CustomerTrans";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(DocNumber), JToken.AsObject(), 'TxnNumber');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(ShipDate), JToken.AsObject(), 'ShipDate');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(TxnDate), JToken.AsObject(), 'TxnDate');
        HelperFunctions.UpdateFieldWithValue(RecordVariant, MigrationQBCustTrans.FieldNo(GLDocNo), DocumentNo);

        if HelperFunctions.IsOnlineData() then begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustTrans.FieldNo(CustomerRef), JToken.AsObject(), 'CustomerRef.value');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(Amount), JToken.AsObject(), 'Balance');
        end else begin
            HelperFunctions.UpdateFieldValueByPath(RecordVariant, MigrationQBCustTrans.FieldNo(CustomerRef), JToken.AsObject(), 'CustomerRef.ListId');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBCustTrans.FieldNo(Amount), JToken.AsObject(), 'CreditRemaining');
        end;
    end;

    local procedure CleanupCustomerJobReferences()
    var
        MigrationQBCustomer: Record "MigrationQB Customer";
        MigrationQBCustomerTrans: Record "MigrationQB CustomerTrans";
        MigrationQBConfig: Record "MigrationQB Config";
        i: Integer;
    begin
        MigrationQBCustomer.SetFilter(ParentRef, '<> %1', EmptyStringTxt);
        if MigrationQBCustomer.FindSet() then begin
            i := 0;
            repeat
                MigrationQBCustomerTrans.SetFilter(CustomerRef, MigrationQBCustomer.ListId);
                if (MigrationQBCustomerTrans.FindSet()) then
                    repeat
                        MigrationQBCustomerTrans.CustomerRef := MigrationQBCustomer.ParentRef;
                        MigrationQBCustomerTrans.Modify();
                    until MigrationQBCustomerTrans.Next() = 0;

                MigrationQBCustomer.Delete();
                i := i + 1;
            until MigrationQBCustomer.Next() = 0;

            MigrationQBConfig.Get();
            MigrationQBConfig."Total Customers" := MigrationQBConfig."Total Customers" - i;
        end;
    end;

    local procedure CleanupPayments()
    var
        MigrationQBCustomerTrans: Record "MigrationQB CustomerTrans";
    begin
        MigrationQBCustomerTrans.Reset();
        MigrationQBCustomerTrans.SetFilter(Amount, '= %1', 0);
        MigrationQBCustomerTrans.SetFilter(TransType, '%1', MigrationQBCustomerTrans.TransType::Payment);
        MigrationQBCustomerTrans.DeleteAll();
    end;
}