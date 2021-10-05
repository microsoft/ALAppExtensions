Codeunit 1917 "MigrationQB Helper Functions"
{
    var
        StartPositionTxt: Label ' STARTPOSITION %1', Locked = true;
        QueryCountTxt: Label ' MAXRESULTS %1', Locked = true;
        AnArrayExpectedErr: Label 'An array was expected.';
        MigrationTypeTxt: Label 'QuickBooks';
        QBORequestErr: Label 'Error from QBO request: %1', Locked = true;
        ReadingMessageErr: Label 'Error reading message response: %1', Locked = true;
        ImportedEntityTxt: Label 'Imported %1 data file.', Locked = true;
        PulledEntityTxt: Label 'Pulled %1 from source.', Locked = true;
        AuthHeaderErr: Label 'Unable to get Authorization header. ', Locked = true;

    procedure GetEntities(EntityName: Text; var JArray: JsonArray): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
        FileName: Text;
    begin
        FileName := GetFileNameByEntityName(EntityName);
        if FileName <> '' then begin
            GetFileContent(FileName, JObject);
            JObject.Get(EntityName, JToken);
            if not JToken.IsArray() then
                LogInternalError(AnArrayExpectedErr, DataClassification::SystemMetadata, Verbosity::Error);
            JArray := JToken.AsArray();
            Session.LogMessage('00007FJ', StrSubstNo(ImportedEntityTxt, EntityName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
            exit(true);
        end;
        exit(false);
    end;

    procedure GetEntities(QBQuery: Text; EntityName: Text; var JArray: JsonArray): Boolean
    var
        JToken: JsonToken;
        Request: Text;
        QueryEncoded: Text;
        NbChildren: Integer;
        StartPosition: Integer;
        PageSize: Integer;
        RealmId: Text;
    begin
        StartPosition := 1;
        PageSize := 100;

        if not IsolatedStorage.Get('Migration QB Realm Id', DataScope::Company, RealmId) then
            exit(false);

        JArray.ReadFrom('[]');

        repeat
            QueryEncoded := QBQuery + StrSubstNo(StartPositionTxt, StartPosition) + StrSubstNo(QueryCountTxt, PageSize);
            Request := StrSubstNo('/v3/company/%1/query?query=%2&minorversion=4', RealmId, QueryEncoded);
            if not InvokeQuickBooksRESTRequest(Request, EntityName, JToken) then
                exit(false);

            if not JToken.IsArray() then
                LogInternalError(AnArrayExpectedErr, DataClassification::SystemMetadata, Verbosity::Error);
            NbChildren := JToken.AsArray().Count();
            if NbChildren > 0 then
                AddToArray(JToken, JArray);
            if NbChildren = PageSize then
                StartPosition := StartPosition + PageSize;
        until NbChildren < PageSize;
        Session.LogMessage('00007FK', StrSubstNo(PulledEntityTxt, EntityName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
        exit(true);
    end;

    procedure GetObjectCount(EntityName: Text; var ObjectCount: Integer)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        FileName: Text;
    begin
        ObjectCount := 0;
        FileName := GetFileNameByEntityName(EntityName);
        if FileName <> '' then begin
            GetFileContent(FileName, JObject);
            JObject.Get('maxResults', JToken);
            if JToken.IsValue() then
                ObjectCount := JToken.AsValue().AsInteger();

            if EntityName = 'Customer' then
                RemoveChildCustomers(JObject, ObjectCount);
        end;
    end;

    local procedure RemoveChildCustomers(JObject: JsonObject; var ObjectCount: Integer);
    var
        JToken: JsonToken;
        ChildJToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
    begin
        JObject.Get('Customer', JToken);
        JArray := JToken.AsArray();
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            if (TrimStringQuotes(GetTextFromJToken(ChildJToken, 'ParentRef.ListId')) <> '') then
                ObjectCount := ObjectCount - 1;
            i := i + 1;
        end;
    end;

    procedure GetOnlineRecordCounts(): Boolean
    var
        MigrationQBConfig: Record "MigrationQB Config";
        MasterRecords: List of [Text];
        RecordType: Text;
        JToken: JsonToken;
        Request: Text;
        QueryEncoded: Text;
        RealmId: Text;
    begin
        MasterRecords.Add('Account');
        MasterRecords.Add('Customer');
        MasterRecords.Add('Item');
        MasterRecords.Add('Vendor');

        if not MigrationQBConfig.Get() then
            exit(false);

        if not IsolatedStorage.Get('Migration QB Realm Id', DataScope::Company, RealmId) then
            exit(false);

        foreach RecordType in MasterRecords do begin
            QueryEncoded := StrSubstNo('select count(*) from %1', RecordType) + StrSubstNo(StartPositionTxt, 1) + StrSubstNo(QueryCountTxt, 1);

            Request := StrSubstNo('/v3/company/%1/query?query=%2', RealmId, QueryEncoded);
            InvokeQuickBooksRESTRequest(Request, 'totalCount', JToken);

            if JToken.IsValue() then begin
                case RecordType of
                    'Account':
                        MigrationQBConfig.UpdateTotalAccounts(JToken.AsValue().AsInteger());
                    'Customer':
                        MigrationQBConfig.UpdateTotalCustomers(JToken.AsValue().AsInteger());
                    'Item':
                        MigrationQBConfig.UpdateTotalItems(JToken.AsValue().AsInteger());
                    'Vendor':
                        MigrationQBConfig.UpdateTotalVendors(JToken.AsValue().AsInteger());
                end;
                MigrationQBConfig.Modify();
            end
        end;
        exit(true);
    end;

    procedure GetTextFromJToken(JToken: JsonToken; Path: Text): Text
    var
        SelectedJToken: JsonToken;
    begin
        if (JToken.SelectToken(Path, SelectedJToken)) then
            exit(Format(SelectedJToken));
    end;

    procedure WriteTextToField(var DestinationFieldRef: FieldRef; TextToWrite: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        OutStream: OutStream;
        MyVariant: Variant;
        BooleanVar: Boolean;
        DateTimeVar: DateTime;
        IntegerVar: Integer;
        DecimalVar: Decimal;
        DummyDateVar: Date;
    begin
        TextToWrite := TrimStringQuotes(TextToWrite);
        case Format(DestinationFieldRef.Type()) of
            'Text', 'Code':
                DestinationFieldRef.Value := CopyStr(TextToWrite, 1, DestinationFieldRef.Length());
            'Boolean':
                begin
                    Evaluate(BooleanVar, TextToWrite);
                    DestinationFieldRef.Value := BooleanVar;
                end;
            'DateTime':
                begin
                    Evaluate(DateTimeVar, TextToWrite);
                    DestinationFieldRef.Value := DateTimeVar;
                end;
            'Integer':
                begin
                    Evaluate(IntegerVar, TextToWrite);
                    DestinationFieldRef.Value := IntegerVar;
                end;
            'Decimal':
                begin
                    Evaluate(DecimalVar, TextToWrite);
                    DestinationFieldRef.Value := DecimalVar;
                end;
            'Date':
                begin
                    if TextToWrite.Contains('T') then
                        TextToWrite := FixDateFormat(TextToWrite);
                    MyVariant := DummyDateVar;
                    TypeHelper.Evaluate(MyVariant, TextToWrite, 'yyyy-MM-dd', 'en-US');
                    DestinationFieldRef.Value := MyVariant;
                end;
            'Option':
                DestinationFieldRef.Value := TypeHelper.GetOptionNo(TextToWrite, DestinationFieldRef.OptionMembers());
            'BLOB':
                begin
                    TempBlob.CreateOutStream(OutSTream, TEXTENCODING::UTF8);
                    OutStream.Write(TextToWrite);
                    RecordRef := DestinationFieldRef.Record();
                    TempBlob.ToRecordRef(RecordRef, DestinationFieldRef.Number());
                end;
        end;
    end;

    procedure FixDateFormat(DateToFix: Text): Text
    var
        TextList: List of [Text];
        MyTemp: Text;
    begin
        TextList := DateToFix.Split('T');
        MyTemp := TextList.Get(1).TrimStart('"');
        exit(Mytemp);
    end;

    procedure GetFileNameByEntityName(EntityName: Text): Text
    var
        NameValueBuffer: Record "Name/Value Buffer";
    begin
        NameValueBuffer.SetFilter(Value, '= %1', EntityName);
        if NameValueBuffer.Find('-') then
            exit(NameValueBuffer.Name);

        exit('');
    end;

    procedure UpdateFieldValue(var RecordVariant: Variant; FieldNo: Integer; JObject: JsonObject; PropertyName: Text)
    var
        RRef: RecordRef;
        FRef: FieldRef;
        Value: Text;
        JToken: JsonToken;
    begin
        RRef.GetTable(RecordVariant);
        FRef := RRef.Field(FieldNo);

        if JObject.Get(PropertyName, JToken) then
            if JToken.WriteTo(Value) then
                WriteTextToField(FRef, Value);

        RRef.SetTable(RecordVariant);
    end;

    procedure UpdateFieldWithValue(var RecordVariant: Variant; FieldNo: Integer; Value: Text[30])
    var
        RRef: RecordRef;
        FRef: FieldRef;
    begin
        RRef.GetTable(RecordVariant);
        FRef := RRef.Field(FieldNo);
        WriteTextToField(FRef, Value);

        RRef.SetTable(RecordVariant);
    end;

    procedure UpdateFieldValueByPath(var RecordVariant: Variant; FieldNo: Integer; JObject: JsonObject; PropertyPath: Text)
    var
        RRef: RecordRef;
        FRef: FieldRef;
        JToken: JsonToken;
        Value: Text;
    begin
        RRef.GetTable(RecordVariant);
        FRef := RRef.Field(FieldNo);

        if JObject.SelectToken(PropertyPath, JToken) then
            if JToken.WriteTo(Value) then
                WriteTextToField(FRef, Value);

        RRef.SetTable(RecordVariant);
    end;

    procedure GetFieldValueByPath(FieldNo: Integer; JObject: JsonObject; PropertyPath: Text): Text
    var
        JToken: JsonToken;
        Value: Text;
    begin
        Value := '';
        if JObject.SelectToken(PropertyPath, JToken) then
            JToken.WriteTo(Value);

        exit(Value);
    end;

    local procedure GetFileContent(FileName: Text; var JObject: JsonObject)
    var
        FileInStream: InStream;
        TempFile: File;
    begin
        TempFile.TextMode(true);
        TempFile.WriteMode(false);
        TempFile.Open(FileName);
        TempFile.CreateInStream(FileInStream);
        JObject.ReadFrom(FileInStream);
    end;

    procedure TrimStringQuotes(Value: Text): Text
    begin
        exit(Value.TrimStart('"').TrimEnd('"'));
    end;

    procedure GetPostingAccountNumber(AccountToGet: Text): Code[20]
    var
        MigrationQBAccountSetup: Record "MigrationQB Account Setup";
    begin
        if not MigrationQBAccountSetup.FindFirst() then
            exit('');

        case AccountToGet of
            'SalesAccount':
                exit(MigrationQBAccountSetup.SalesAccount);
            'SalesCreditMemoAccount':
                exit(MigrationQBAccountSetup.SalesCreditMemoAccount);
            'SalesLineDiscAccount':
                exit(MigrationQBAccountSetup.SalesLineDiscAccount);
            'SalesInvDiscAccount':
                exit(MigrationQBAccountSetup.SalesInvDiscAccount);
            'PurchAccount':
                exit(MigrationQBAccountSetup.PurchAccount);
            'PurchCreditMemoAccount':
                exit(MigrationQBAccountSetup.PurchCreditMemoAccount);
            'PurchInvDiscAccount':
                exit(MigrationQBAccountSetup.PurchInvDiscAccount);
            'COGSAccount':
                exit(MigrationQBAccountSetup.COGSAccount);
            'InventoryAdjmtAccount':
                exit(MigrationQBAccountSetup.InventoryAdjmtAccount);
            'InventoryAccount':
                exit(MigrationQBAccountSetup.InventoryAccount);
            'ReceivablesAccount':
                exit(MigrationQBAccountSetup.ReceivablesAccount);
            'ServiceChargeAccount':
                exit(MigrationQBAccountSetup.ServiceChargeAccount);
            'PayablesAccount':
                exit(MigrationQBAccountSetup.PayablesAccount);
            'PurchServiceChargeAccount':
                exit(MigrationQBAccountSetup.PurchServiceChargeAccount);
        end;
    end;

    procedure ConvertAccountCategory(MigrationQBAccount: Record "MigrationQB Account"): Option
    var
        AccountCategoryType: Option ,Assets,Liabilities,Equity,Income,"Cost of Goods Sold",Expense;
    begin
        case MigrationQBAccount.AccountType.Replace(' ', '') of
            'Bank', 'AccountsReceivable', 'OtherAsset', 'OtherCurrentAsset', 'FixedAsset':
                exit(AccountCategoryType::Assets);

            'AccountsPayable', 'OtherCurrentLiability', 'CreditCard', 'LongTermLiability':
                exit(AccountCategoryType::Liabilities);

            'Equity':
                exit(AccountCategoryType::Equity);

            'Income', 'OtherIncome':
                exit(AccountCategoryType::Income);

            'CostOfGoodsSold', 'CostofGoodsSold':
                exit(AccountCategoryType::"Cost of Goods Sold");

            'Expense', 'OtherExpense':
                exit(AccountCategoryType::Expense);
        end;
    end;

    procedure ConvertDebitCreditType(MigrationQBAccount: Record "MigrationQB Account"): Option
    var
        DebitCreditType: Option Both,Debit,Credit;
    begin
        case MigrationQBAccount.AccountType.Replace(' ', '') of
            'Bank', 'AccountsReceivable', 'OtherAsset', 'OtherCurrentAsset', 'FixedAsset', 'CostOfGoodsSold', 'CostofGoodsSold', 'Expense', 'OtherExpense':
                exit(DebitCreditType::Debit);

            'AccountsPayable', 'OtherCurrentLiability', 'CreditCard', 'LongTermLiability', 'Equity', 'Income', 'OtherIncome':
                exit(DebitCreditType::Credit);
        end;
    end;

    procedure CreateCountyIfNeeded(CountryCode: Code[10]; CountryName: Text[50])
    var
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
    begin
        CustomerDataMigrationFacade.CreateCountryIfNeeded(CountryCode, CountryName, AddressFormatToSet::"City+County+Post Code", ContactAddressFormatToSet::"After Company Name");
    end;

    procedure GetArrayPropertyValueFromJObjectByName(JObject: JsonObject; PropertyName: Text; var JArray: JsonArray): Boolean
    var
        JToken: JsonToken;
    begin
        if JObject.Get(PropertyName, JToken) then begin
            if not JToken.IsArray() then
                LogInternalError(AnArrayExpectedErr, DataClassification::SystemMetadata, Verbosity::Error);
            JArray := JToken.AsArray();
            exit(true);
        end;
        exit(false);
    end;

    procedure CleanupGenJournalBatches()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetFilter("Bal. Account Type", '= 0');
        GenJournalBatch.SetFilter("Bal. Account No.", '> 0');
        if GenJournalBatch.Find('-') then begin
            repeat
                GenJournalBatch."Bal. Account No." := '';
                GenJournalBatch.Modify(true);
            until GenJournalBatch.Next() = 0;
            Commit();
        end;

        if ValidateCountry('GB') then begin
            GenJournalBatch.Reset();
            GenJournalBatch.SetFilter(Name, '= CASH');
            GenJournalBatch.SetFilter("No. Series", '= GJNL-PMT');
            if GenJournalBatch.FindFirst() then begin
                GenJournalBatch."No. Series" := '';
                GenJournalBatch.Modify(true);
                Commit();
            end;
        end;
    end;

    procedure CleanupVatPostingSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if ValidateCountry('GB') then
            if VATPostingSetup.FindSet(true, false) then begin
                repeat
                    VATPostingSetup."Sales VAT Account" := '';
                    VATPostingSetup."Purchase VAT Account" := '';
                    VATPostingSetup."Reverse Chrg. VAT Acc." := '';
                    VATPostingSetup.Modify(true);
                until VATPostingSetup.Next() = 0;
                Commit();
            end;
    end;

    procedure GetAcctCategoryEntryNo(Category: Option): Integer
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    begin
        GLAccountCategory.Init();
        GLAccountCategoryMgt.GetAccountCategory(GLAccountCategory, Category);
        exit(GLAccountCategory."Entry No.");
    end;

    procedure IsOnlineData(): Boolean
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        exit(MigrationQBConfig.IsOnlineData());
    end;

    procedure CleanupStagingTables()
    var
        MigrationQBAccount: Record "MigrationQB Account";
        MigrationQBAccountSetup: Record "MigrationQB Account Setup";
        MigrationQBConfig: Record "MigrationQB Config";
        MigrationQBCustomer: Record "MigrationQB Customer";
        MigrationQBCustomerTrans: Record "MigrationQB CustomerTrans";
        MigrationQBItem: Record "MigrationQB Item";
        MigrationQBVendor: Record "MigrationQB Vendor";
        MigrationQBVendorTrans: Record "MigrationQB VendorTrans";
    begin
        MigrationQBAccount.DeleteAll();
        MigrationQBAccountSetup.DeleteAll();
        MigrationQBConfig.DeleteAll();
        MigrationQBCustomer.DeleteAll();
        MigrationQBCustomerTrans.DeleteAll();
        MigrationQBItem.DeleteAll();
        MigrationQBVendor.DeleteAll();
        MigrationQBVendorTrans.DeleteAll();
    end;

    procedure CleanupIsolatedStorage()
    begin
        if IsolatedStorage.Delete('Migration QB Realm Id') then;
        if IsolatedStorage.Delete('Migration QB Access Token') then;
    end;

    procedure GetMigrationTypeTxt(): Text[10]
    begin
        exit(CopyStr(MigrationTypeTxt, 1, 10));
    end;

    procedure FormatGuid(myGuid: text): Text
    begin
        if StrPos(myGuid, '{') = 1 then
            exit(UpperCase(CopyStr(Format(myGuid), 2, 36)));
        exit(UpperCase(myGuid));
    end;

    procedure GetPropertyFromCode(CodeTxt: Text; Property: Text) ValueTxt: Text
    begin
        exit(LocalGetPropertyFromCode(CodeTxt, Property));
    end;

    [TryFunction]
    [Scope('OnPrem')]
    procedure GetAuthRequestUrl(ClientId: Text; ClientSecret: Text; Scope: Text; Url: Text; CallBackUrl: Text; State: Text; var AuthRequestUrl: Text)
    begin
        GetAuthRequestUrlImp(ClientId, ClientSecret, Scope, Url, CallBackUrl, State, AuthRequestUrl);
    end;

    [TryFunction]
    [Scope('OnPrem')]
    procedure GetAccessToken(Url: Text; Callback: Text; AuthCode: Text; ClientId: Text; ClientSecret: Text; var AccessKey: Text)
    begin
        GetAccessTokenImp(Url, Callback, AuthCode, ClientId, ClientSecret, AccessKey);
    end;

    [TryFunction]
    [Scope('OnPrem')]
    local procedure GetAuthorizationHeader(AccessTokenKey: Text; var AuthorizationHeader: Text)
    begin
        GetAuthorizationHeaderImp(AccessTokenKey, AuthorizationHeader)
    end;

    local procedure ValidateCountry(CountryCode: Code[10]): Boolean
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        if StrPos(ApplicationSystemConstants.ApplicationVersion(), CountryCode) = 1 then
            exit(true);

        exit(false);
    end;

    local procedure AddToArray(JToken: JsonToken; var JArray: JsonArray)
    var
        CurrentJToken: JsonToken;
    begin
        if not JToken.IsArray() then
            LogInternalError(AnArrayExpectedErr, DataClassification::SystemMetadata, Verbosity::Error);
        foreach CurrentJToken in JToken.AsArray() do
            JArray.Add(CurrentJToken);
    end;

    [NonDebuggable]
    local procedure InvokeQuickBooksRESTRequest(Request: Text; EntityName: Text; var JToken: JsonToken): Boolean
    var
        BaseUrlTxt: Label 'https://quickbooks.api.intuit.com', Locked = true;
        //BaseUrlTxt: Label 'https://sandbox-quickbooks.api.intuit.com', Locked = true;
        AuthorizationHeader: Text;
        AccessToken: Text;
    begin
        if not IsolatedStorage.Get('Migration QB Access Token', DataScope::Company, AccessToken) then
            exit(false);

        if not GetAuthorizationHeader(AccessToken, AuthorizationHeader) then begin
            Session.LogMessage('0000AL4', AuthHeaderErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
            exit(false);
        end;

        exit(InvokeRestRequest(BaseUrlTxt, AuthorizationHeader, Request, EntityName, JToken));
    end;

    local procedure InvokeRestRequest(Url: Text; AuthorizationHeader: Text; Request: Text; EntityName: Text; var JToken: JsonToken): Boolean
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        TokenName: Text;
        MessageResponse: Text;
    begin
        Client.DefaultRequestHeaders().Add('Accept', 'application/json');
        Client.DefaultRequestHeaders().Add('Authorization', AuthorizationHeader);

        Client.Get(Url + Request, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            Session.LogMessage('00007EM', StrSubstNo(QBORequestErr, ResponseMessage.ReasonPhrase()), Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
            exit(false);
        end;

        if not ResponseMessage.Content().ReadAs(MessageResponse) then begin
            Session.LogMessage('00007EN', StrSubstNo(ReadingMessageErr, ResponseMessage.ReasonPhrase()), Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
            exit(false);
        end;

        if not JObject.ReadFrom(MessageResponse.TrimStart('''').TrimEnd('''')) then begin
            Session.LogMessage('00007EO', StrSubstNo(ReadingMessageErr, ResponseMessage.ReasonPhrase()), Verbosity::Warning, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', GetMigrationTypeTxt());
            exit(false);
        end;

        // Check if response contains multiple entities
        if StrPos(LowerCase(Request), 'query') <> 0 then
            TokenName := 'QueryResponse.';

        exit(JObject.SelectToken(TokenName + EntityName, JToken));
    end;

    local procedure LocalGetPropertyFromCode(CodeTxt: Text; Property: Text) Value: Text
    var
        I: Integer;
        NumberOfProperties: Integer;
    begin
        CodeTxt := ConvertStr(CodeTxt, '&', ',');
        CodeTxt := ConvertStr(CodeTxt, '=', ',');
        NumberOfProperties := Round((StrLen(CodeTxt) - StrLen(DelChr(CodeTxt, '=', ','))) / 2, 1, '>');
        for I := 1 to NumberOfProperties do
            if SelectStr(2 * I - 1, CodeTxt) = Property then
                Value := SelectStr(2 * I, CodeTxt);
    end;

    [TryFunction]
    local procedure GetAuthRequestUrlImp(ClientId: Text; ClientSecret: Text; Scope: Text; Url: Text; CallBackUrl: Text; State: Text; var AuthRequestUrl: Text)
    var
        OAuthAuthorization: DotNet OAuthAuthorization;
        Consumer: DotNet Consumer;
        Token: DotNet Token;
    begin
        Token := Token.Token('', '');
        Consumer := Consumer.Consumer(ClientId, ClientSecret);
        OAuthAuthorization := OAuthAuthorization.OAuthAuthorization(Consumer, Token);
        AuthRequestUrl := OAuthAuthorization.CalculateAuthRequestUrl(Url, CallBackUrl, Scope, State);
    end;

    [TryFunction]
    local procedure GetAccessTokenImp(Url: Text; callback: Text; AuthCode: Text; ClientId: Text; ClientSecret: Text; var AccessKey: Text)
    var
        OAuthAuthorization: DotNet OAuthAuthorization;
        Consumer: DotNet Consumer;
        Token: DotNet Token;
        AccessToken: DotNet Token;
    begin
        Token := Token.Token(AuthCode, '');
        Consumer := Consumer.Consumer(ClientId, ClientSecret);
        OAuthAuthorization := OAuthAuthorization.OAuthAuthorization(Consumer, Token);

        AccessToken := OAuthAuthorization.GetAccessToken(Url, callback, Token);

        AccessKey := GetJSONTokenValueFromString('access_token', AccessToken.TokenKey());
    end;

    [TryFunction]
    local procedure GetAuthorizationHeaderImp(AccessTokenKey: Text; var AuthorizationHeader: Text)
    begin
        AuthorizationHeader := 'Bearer ' + AccessTokenKey;
    end;

    local procedure GetJSONTokenValueFromString(ObjectToGet: Text; JsonFormattedString: text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if (JObject.ReadFrom(JsonFormattedString)) then
            JObject.Get(ObjectToGet, JToken);
        if JToken.IsValue() then
            exit(JToken.AsValue().AsText());

        exit('');
    end;
}