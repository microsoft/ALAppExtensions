codeunit 2050 "MS - Data Sharing Mgt."
{
    Permissions = TableData "MS - Data Sharing Setup" = RIMD;

    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        AllowTxt: Label 'Allow sharing';
        DataSharingNotificationDescriptionTxt: Label 'Show a notification to share data with Microsoft.';
        DataSharingNotificationTxt: Label 'Allow data sharing';
        DetailsTxt: Label 'Show details';
        NotificationMsg: Label 'Help us continue to improve our service by sharing your data. It''s completely anonymous.';
        ShareDataNotificationSentTxt: Label 'A notification has been sent to ask the user to share data anonymously (TenantID: %1, AadTenantId: %2).', Comment = '%1 is the value of the tenant ID, %2 is the value of the AAD tenant ID', Locked = true;
        SharingDataDisabledTxt: Label 'The user has stopped sharing anonymous data from their tenant (TenantID: %1, AadTenantId: %2, DemoCompany: %3).', Comment = '%1 is the value of the tenant ID, %2 is the value of the AAD tenant ID, %3 tells whether the company is a demo one', Locked = true;
        SharingDataEnabledTxt: Label 'The user has enabled data to be shared anonymously from their tenant (TenantID: %1, AadTenantId: %2, DemoCompany: %3).', Comment = '%1 is the value of the tenant ID, %2 is the value of the AAD tenant ID, %3 tells whether the company is a demo one', Locked = true;

    [EventSubscriber(ObjectType::Page, Page::"Customer List", 'OnOpenPageEvent', '', true, true)]
    local procedure OnCustomersList(var Rec: Record Customer)
    begin
        CreateAndSendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item List", 'OnOpenPageEvent', '', true, true)]
    local procedure OnItemsList(var Rec: Record Item)
    begin
        CreateAndSendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor List", 'OnOpenPageEvent', '', true, true)]
    local procedure OnVendorsList(var Rec: Record Vendor)
    begin
        CreateAndSendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order List", 'OnOpenPageEvent', '', true, true)]
    local procedure OnSalesOrdersList(var Rec: Record "Sales Header")
    begin
        CreateAndSendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice List", 'OnOpenPageEvent', '', true, true)]
    local procedure OnSalesInvoicesList(var Rec: Record "Sales Header")
    begin
        CreateAndSendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order List", 'OnOpenPageEvent', '', true, true)]
    local procedure OnPurchaseOrdersList(var Rec: Record "Purchase Header")
    begin
        CreateAndSendNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoices", 'OnOpenPageEvent', '', true, true)]
    local procedure OnPurchaseInvoicesList(var Rec: Record "Purchase Header")
    begin
        CreateAndSendNotification();
    end;

    local procedure CreateAndSendNotification();
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        MyNotifications: Record "My Notifications";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        DataSharingNotification: Notification;
        CheckForEnoughData: Boolean;
    begin
        if CompanyInformationMgt.IsDemoCompany() then
            exit;

        if MyNotifications.IsEnabled(GetDataSharingNotificationId()) then begin
            if MSDataSharingSetup.Get(GetCurrentCompanyId()) then
                exit;

            CheckForEnoughData := true;
            OnBeforeCheckForDataVolume(CheckForEnoughData);
            if CheckForEnoughData and (not IsEnoughDataAvailable()) then
                exit;

            DataSharingNotification.ID(GetDataSharingNotificationId());
            DataSharingNotification.Message(NotificationMsg);
            DataSharingNotification.Scope(NotificationScope::LocalScope);
            DataSharingNotification.AddAction(AllowTxt, Codeunit::"MS - Data Sharing Mgt.", 'ShareData');
            DataSharingNotification.AddAction(DetailsTxt, Codeunit::"MS - Data Sharing Mgt.", 'LearnMore');
            DataSharingNotification.Send();
            OnNotificationSent();
        end;
    end;

    local procedure IsEnoughDataAvailable(): Boolean;
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        GeneralLedgerEntry: Record "G/L Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        EnoughDataAccountRecommendation: Boolean;
        EnoughDataItemSales: Boolean;
        EnoughDataLatePayment: Boolean;
        DataThresholdAccountRecommendation: Integer;
        DataThresholdItemSales: Integer;
        DataThresholdLatePayment: Integer;
    begin
        // check that we have enough data to do ML
        DataThresholdLatePayment := 1000;
        DataThresholdItemSales := 1000;
        DataThresholdAccountRecommendation := 1000;

        if GeneralLedgerEntry.ReadPermission() then begin
            EnoughDataAccountRecommendation := GeneralLedgerEntry.CountApprox() > DataThresholdAccountRecommendation;
            if EnoughDataAccountRecommendation then // for performance
                exit(true);
        end;

        if CustomerLedgerEntry.ReadPermission() then begin
            EnoughDataLatePayment := CustomerLedgerEntry.CountApprox() > DataThresholdLatePayment;
            if EnoughDataLatePayment then // for performance
                exit(true);
        end;

        if ItemLedgerEntry.ReadPermission() then begin
            EnoughDataItemSales := ItemLedgerEntry.CountApprox() > DataThresholdItemSales;
            if EnoughDataItemSales then // for performance
                exit(true);
        end;

        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckForDataVolume(var CheckForEnoughData: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnNotificationSent()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Data Sharing Mgt.", 'OnNotificationSent', '', false, false)]
    local procedure OnNotificationSentSubscriber()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
    begin
        Session.LogMessage('00001FI', StrSubstNo(ShareDataNotificationSentTxt, TenantId(), AzureADTenant.GetAadTenantId()), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MSDataSharingSetup.TableName());
    end;

    procedure ShareData(var DataSharingNotification: Notification)
    begin
        EnableDataSharing();
    end;

    procedure LearnMore(var DataSharingNotification: Notification)
    begin
        Page.Run(Page::"MS - Data Sharing Learn More");
    end;

    local procedure GetDataSharingNotificationId(): Guid
    begin
        exit('E775D89D-7161-459A-A0D7-4CC67C96420C');
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetDataSharingNotificationId(),
        CopyStr(DataSharingNotificationTxt, 1, 128),
        DataSharingNotificationDescriptionTxt,
        true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure OnRegisterServiceConn(var ServiceConnection: Record "Service Connection")
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        MSDataSharingSetupPage: Page "MS - Data Sharing Setup";
        EmptyRecordId: RecordId;
        CompanyId: Guid;
    begin
        CompanyId := GetCurrentCompanyId();
        if not MSDataSharingSetup.Get(CompanyId) then begin
            MSDataSharingSetup.Init();
            MSDataSharingSetup."Company Id" := CompanyId;
            MSDataSharingSetup.Insert();
        end;
        if MSDataSharingSetup.Enabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection, EmptyRecordId, MSDataSharingSetupPage.Caption(),
            '', Page::"MS - Data Sharing Setup");
    end;

    procedure EnableDataSharing()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        CompanyId: Guid;
    begin
        CompanyId := GetCurrentCompanyId();

        with MSDataSharingSetup do
            if Get(CompanyId) then begin
                Enabled := true;
                Modify();
            end else begin
                Init();
                "Company Id" := CompanyId;
                Enabled := true;
                Insert();
            end;
        OnDataSharingEnabled();
    end;

    procedure DisableDataSharing()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
    begin
        with MSDataSharingSetup do
            if Get(GetCurrentCompanyId()) then
                if Enabled then begin
                    Enabled := false;
                    Modify();
                    OnDataSharingDisabled();
                end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDataSharingEnabled()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Data Sharing Mgt.", 'OnDataSharingEnabled', '', false, false)]
    local procedure OnDataSharingEnabledSubscriber()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        Session.LogMessage('00001FJ', StrSubstNo(SharingDataEnabledTxt, TenantId(), AzureADTenant.GetAadTenantId(), Format(CompanyInformationMgt.IsDemoCompany())), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MSDataSharingSetup.TableName());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDataSharingDisabled()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Data Sharing Mgt.", 'OnDataSharingDisabled', '', false, false)]
    local procedure OnDataSharingDisabledSubscriber()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        Session.LogMessage('00001FK', StrSubstNo(SharingDataDisabledTxt, TenantId(), AzureADTenant.GetAadTenantId(), Format(CompanyInformationMgt.IsDemoCompany())), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', MSDataSharingSetup.TableName());
    end;

    procedure ShowPrivacyStatement()
    begin
        Hyperlink('https://www.microsoft.com/en-us/trustcenter/CloudServices/Dynamics365#privacy');
    end;

    procedure GetCurrentCompanyId(): Guid;
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        exit(Company.Id);
    end;
}
