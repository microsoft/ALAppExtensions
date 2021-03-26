codeunit 2429 "XS Populate Sync Field Table"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        if AppInfo.DataVersion().Major() = 0 then
            SetAllUpgradeTags();

        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        SynchronizationField: Record "XS Synchronization Field";
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.Name() <> '_Exclude_XeroSync_' then
            exit;

        if (Session.GetExecutionContext() <> Session.GetExecutionContext() ::Install) and (Session.GetCurrentModuleExecutionContext() <> Session.GetExecutionContext() ::Upgrade) then
            exit;

        if not SynchronizationField.IsEmpty() then
            exit;

        ApplyEvaluationClassificationsForPrivacy();
        PopulateSyncFieldTableForCustomer();
        PopulateSyncFieldTableForItem();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        SyncChange: Record "Sync Change";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Sync Change");
        DataClassificationMgt.SetFieldToPersonal(Database::"Sync Change", SyncChange.FieldNo("XS Xero Json Response"));
    end;

    procedure PopulateSyncFieldTableForItem()
    var
        Item: Record Item;
    begin
        CreateEntry(Database::Item, Item.FieldNo(Description));
        CreateEntry(Database::Item, Item.FieldNo("Description 2"));
        CreateEntry(Database::Item, Item.FieldNo(Type));
        CreateEntry(Database::Item, Item.FieldNo("Unit Price"));
        CreateEntry(Database::Item, Item.FieldNo("Unit Cost"));
    end;

    procedure PopulateSyncFieldTableForCustomer()
    var
        Customer: Record Customer;
    begin
        CreateEntry(Database::Customer, Customer.FieldNo(Name));
        CreateEntry(Database::Customer, Customer.FieldNo(Address));
        CreateEntry(Database::Customer, Customer.FieldNo(City));
        CreateEntry(Database::Customer, Customer.FieldNo(Contact));
        CreateEntry(Database::Customer, Customer.FieldNo("Phone No."));
        CreateEntry(Database::Customer, Customer.FieldNo("Currency Code"));
        CreateEntry(Database::Customer, Customer.FieldNo("Country/Region Code"));
        CreateEntry(Database::Customer, Customer.FieldNo("Fax No."));
        CreateEntry(Database::Customer, Customer.FieldNo("VAT Registration No."));
        CreateEntry(Database::Customer, Customer.FieldNo("Post Code"));
        CreateEntry(Database::Customer, Customer.FieldNo(County));
        CreateEntry(Database::Customer, Customer.FieldNo("E-Mail"));
    end;

    local procedure CreateEntry(TableNo: Integer; FieldNo: Integer)
    var
        SynchronizationField: Record "XS Synchronization Field";
    begin
        SynchronizationField.Validate("Table No.", TableNo);
        SynchronizationField.Validate("Field No.", FieldNo);

        SynchronizationField.Insert(true);
    end;

    local procedure SetAllUpgradeTags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        XsUpgrade: Codeunit "Xs Upgrade";
    begin
        if not UpgradeTag.HasUpgradeTag(XsUpgrade.GetXSSecretsToISUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(XsUpgrade.GetXSSecretsToISUpgradeTag());

        if not UpgradeTag.HasUpgradeTag(XsUpgrade.GetXSSecretsToISValidationTag()) then
            UpgradeTag.SetUpgradeTag(XsUpgrade.GetXSSecretsToISValidationTag());
    end;
}