codeunit 1911 "MigrationQB Account Migrator"
{
    TableNo = "MigrationQB Account";

    var
        PostingGroupCodeTxt: Label 'QB', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from QB', Locked = true;
        DescriptionTxt: Label 'Opening Balance', Locked = true;
        GlDocNoTxt: Label 'G00001', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccount', '', true, true)]
    procedure OnMigrateGlAccount(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationQBAccount: Record "MigrationQB Account";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Account" then
            exit;
        MigrationQBAccount.Get(RecordIdToMigrate);
        MigrateAccountDetails(MigrationQBAccount, Sender);
    end;

    procedure MigrateAccountDetails(MigrationQBAccount: Record "MigrationQB Account"; GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        AccountType: Option Posting;
    begin
        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(MigrationQBAccount.AcctNum, CopyStr(MigrationQBAccount.Name, 1, 50), AccountType::Posting) then
            exit;

        GLAccDataMigrationFacade.SetDirectPosting(true);
        GLAccDataMigrationFacade.SetBlocked(not MigrationQBAccount.Active);
        GLAccDataMigrationFacade.SetAccountCategory(HelperFunctions.ConvertAccountCategory(MigrationQBAccount));
        GLAccDataMigrationFacade.SetDebitCreditType(HelperFunctions.ConvertDebitCreditType(MigrationQBAccount));
        GLAccDataMigrationFacade.SetAccountSubCategory(
            HelperFunctions.GetAcctCategoryEntryNo(HelperFunctions.ConvertAccountCategory(MigrationQBAccount)));
        GLAccDataMigrationFacade.ModifyGLAccount(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnCreateOpeningBalanceTrx', '', true, true)]
    procedure OnCreateOpeningBalanceTrx(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationQBAccount: Record "MigrationQB Account";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Account" then
            exit;

        MigrationQBAccount.Get(RecordIdToMigrate);
        if MigrationQBAccount.CurrentBalance = 0 then
            exit;

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 5), '', '');
        Sender.CreateGeneralJournalLine(
            CopyStr(PostingGroupCodeTxt, 1, 5),
            CopyStr(GlDocNoTxt, 1, 10),
            CopyStr(DescriptionTxt, 1, 20),
            Today(),
            0D,
            MigrationQBAccount.CurrentBalance,
            MigrationQBAccount.CurrentBalance,
            '',
            ''
        );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigratePostingGroups', '', true, true)]
    procedure OnMigratePostingGroups(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationQBAccount: Record "MigrationQB Account";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationQB Account" then
            exit;
        MigrationQBAccount.Get(RecordIdToMigrate);

        Sender.CreateGenBusinessPostingGroupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 5), CopyStr(PostingGroupDescriptionTxt, 1, 20));
        Sender.CreateGenProductPostingGroupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 5), CopyStr(PostingGroupDescriptionTxt, 1, 20));
        Sender.CreateGeneralPostingSetupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 5));

        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesAccount') then
            Sender.SetGeneralPostingSetupSalesAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('SalesAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount') then
            Sender.SetGeneralPostingSetupSalesCreditMemoAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount') then
            Sender.SetGeneralPostingSetupSalesLineDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount') then
            Sender.SetGeneralPostingSetupSalesInvDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchAccount') then
            Sender.SetGeneralPostingSetupPurchAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('PurchAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchCreditMemoAccount') then
            Sender.SetGeneralPostingSetupPurchCreditMemoAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('PurchCreditMemoAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchLineDiscAccount') then
            Sender.SetGeneralPostingSetupPurchLineDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('PurchLineDiscAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('COGSAccount') then
            Sender.SetGeneralPostingSetupCOGSAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('COGSAccount'));
        if MigrationQBAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount') then
            Sender.SetGeneralPostingSetupInventoryAdjmtAccount(CopyStr(PostingGroupCodeTxt, 1, 5), HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount'));
    end;

    procedure GetAll(IsOnline: Boolean)
    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        JArray: JsonArray;
        Success: Boolean;
    begin
        DeleteAll();

        if IsOnline then
            Success := HelperFunctions.GetEntities('Select * from Account', 'Account', JArray)
        else
            Success := HelperFunctions.GetEntities('Account', JArray);

        if Success then
            GetAccountsFromJson(JArray);
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        GetAccountsFromJson(JArray);
    end;

    procedure DeleteAll()
    var
        MigrationQBAccount: Record "MigrationQB Account";
    begin
        MigrationQBAccount.DeleteAll();
    end;

    procedure PreDataIsValid(): Boolean
    var
        MigrationQBAccount: Record "MigrationQB Account";
    begin
        if MigrationQBAccount.Find('-') then
            repeat
                if MigrationQBAccount.AcctNum = '' then
                    exit(false);

            until MigrationQBAccount.Next() = 0;

        exit(true);
    end;

    local procedure GetAccountsFromJson(JArray: JsonArray)
    var
        MigrationQBAccount: Record "MigrationQB Account";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[15];
        i: Integer;
    begin
        i := 0;

        while JArray.Get(i, ChildJToken) do begin
            EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'AcctNum')), 1, 15);

            if not MigrationQBAccount.Get(EntityId) then begin
                MigrationQBAccount.Init();
                MigrationQBAccount.VALIDATE(MigrationQBAccount.AcctNum, EntityId);
                MigrationQBAccount.Insert(true);
            end;

            RecordVariant := MigrationQBAccount;
            UpdateAccountFromJson(RecordVariant, ChildJToken);
            MigrationQBAccount := RecordVariant;
            MigrationQBAccount.Modify(true);

            i := i + 1;
        end;
    end;

    local procedure UpdateAccountFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationQBAccount: Record "MigrationQB Account";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(Name), JToken.AsObject(), 'Name');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(SubAccount), JToken.AsObject(), 'SubAccount');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(FullyQualifiedName), JToken.AsObject(), 'FullyQualifiedName');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(Active), JToken.AsObject(), 'Active');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(Classification), JToken.AsObject(), 'Classification');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(AccountType), JToken.AsObject(), 'AccountType');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(AccountSubType), JToken.AsObject(), 'AccountSubType');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(CurrentBalance), JToken.AsObject(), 'CurrentBalance');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(CurrentBalanceWithSubAccounts), JToken.AsObject(), 'CurrentBalanceWithSubAccounts');

        if HelperFunctions.IsOnlineData() then
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(Id), JToken.AsObject(), 'Id')
        else
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationQBAccount.FieldNO(Id), JToken.AsObject(), 'ListID');
    end;
}