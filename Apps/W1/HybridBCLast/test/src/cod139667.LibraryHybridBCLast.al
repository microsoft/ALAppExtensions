codeunit 139667 "Library - Hybrid BC Last"
{
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit Assert;
        LibraryHybridManagement: Codeunit "Library - Hybrid Management";
        DataLoadFailure: Text;
        UpgradeEvents: Dictionary of [Decimal, Text];
        SubscriptionIdTxt: Label 'DynamicsBCLast_IntelligentCloud';
        SubscriptionFormatTxt: Label '%1_IntelligentCloud', Comment = '%1 - The source product id', Locked = true;
        DateTimeStringFormatTok: Label '%1-%2-%3', Locked = true;

    procedure InitializeMapping(SourceVersion: Decimal)
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        W1Management: Codeunit "W1 Management";
    begin
        if not IntelligentCloudSetup.Get() then begin
            IntelligentCloudSetup.Init();
            IntelligentCloudSetup.Insert();
        end;

        IntelligentCloudSetup."Source BC Version" := SourceVersion;
        IntelligentCloudSetup.Modify();
        W1Management.PopulateTableMapping();
    end;

    procedure InsertNotification(var RunId: Text; var StartTime: DateTime; var TriggerType: Text; MessageCode: Code[10]; SyncedVersion: Integer)
    var
        WebhookNotification: Record "Webhook Notification";
        NotificationStream: OutStream;
        NotificationText: Text;
    begin
        NotificationText := LibraryHybridManagement.GetNotificationPayload(SubscriptionIdTxt, RunId, StartTime, TriggerType, AdditionalNotificationText(MessageCode, SyncedVersion));
        WebhookNotification.Init();
        WebhookNotification.ID := CreateGuid();
        WebhookNotification."Subscription ID" := CopyStr(SubscriptionIdTxt, 1, 150);
        WebhookNotification.Notification.CreateOutStream(NotificationStream, TextEncoding::UTF8);
        NotificationStream.WriteText(NotificationText);
        WebhookNotification.Insert(true);
    end;

    procedure InitializeWebhookSubscription()
    var
        WebhookSubscription: Record "Webhook Subscription";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
    begin
        WebhookSubscription.DeleteAll();
        WebhookSubscription.Init();
        WebhookSubscription."Subscription ID" := COPYSTR(SubscriptionIdTxt, 1, 150);
        WebhookSubscription.Endpoint := 'Hybrid';
        WebhookSubscription.Insert();

        if not IntelligentCloudSetup.Get() then begin
            IntelligentCloudSetup.Init();
            IntelligentCloudSetup.Insert();
        end;

        IntelligentCloudSetup."Product ID" := HybridBCLastWizard.ProductId();
        IntelligentCloudSetup.Modify();
    end;

    local procedure AdditionalNotificationText(MessageCode: Code[10]; SyncedVersion: Integer) Json: Text
    begin
        if MessageCode <> '' then
            Json := ', "Code": "' + MessageCode + '"';

        Json += ', "SyncedVersion": "' + Format(SyncedVersion) + '"';
        Json += ', "IncrementalTables": [' +
                            '{' +
                            '"TableName": "Good Table",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 742,' +
                            '"Errors": ""' +
                            '},' +
                            '{' +
                            '"TableName": "Bad Table",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 742,' +
                            '"ErrorCode": "50001"' +
                            '},' +
                            '{' +
                            '"TableName": "Warning Table",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 742,' +
                            '"ErrorCode": "50004"' +
                            '}' +
                        ']';
        Json += ', "FullTables": [' +
                            '{' +
                            '"TableName": "Big Good Table",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 742,' +
                            '"Errors": ""' +
                            '},' +
                            '{' +
                            '"TableName": "Big Bad Table",' +
                            '"CompanyName": "' + CompanyName() + '",' +
                            '"$companyid": 0,' +
                            '"NewVersion": 742,' +
                            '"ErrorCode": "50004",' +
                            '"Errors": "Failure processing data for Table = ''Bad Table''\\\\r\\\\n' +
                                        'Error message: Explicit value must be specified for identity column in table ''' +
                                        'CRONUS International Ltd_$Bad Table''."' +
                            '}' +
                        ']';
    end;

    procedure InsertHybridCompany(Company: Record Company)
    var
        HybridCompany: Record "Hybrid Company";
    begin
        HybridCompany.DeleteAll();
        repeat
            HybridCompany.Init();
            HybridCompany."Name" := Company.Name;
            HybridCompany."Display Name" := Company."Display Name";
            HybridCompany.Replicate := true;
            if HybridCompany.Insert() then;
        until Company.Next() = 0;
    end;

    procedure InvokeLoadData(CountryCode: Text)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1DataLoad: Codeunit "W1 Data Load";
    begin
        HybridReplicationSummary.Init();
        HybridReplicationSummary."Run ID" := CreateGuid();
        HybridReplicationSummary.Insert();

        W1DataLoad.LoadTableData(HybridReplicationSummary, CountryCode);
    end;

    procedure InvokePostProcessEvent();
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        W1Management: Codeunit "W1 Management";
        ApiEvents: Codeunit "Api Events";
    begin
        HybridReplicationSummary.Init();
        HybridReplicationSummary."Run ID" := CreateGuid();
        HybridReplicationSummary.Insert();

        BindSubscription(ApiEvents);
        W1Management.OnAfterCompanyUpgradeCompleted(HybridReplicationSummary);
        UnbindSubscription(ApiEvents)
    end;

    procedure SetDataLoadFailure(NewDataLoadFailure: Text)
    begin
        DataLoadFailure := NewDataLoadFailure;
    end;

    procedure ClearGlobalVariables()
    begin
        Clear(DataLoadFailure);
        Clear(UpgradeEvents);
    end;

    procedure VerifyEventOrder(TargetVersion: Decimal; LastUpgrade: Boolean)
    var
        EventString: Text;
        UpgradedVersion: Decimal;
    begin
        // The specified TargetVersion should be first in the list
        UpgradeEvents.Keys().Get(1, UpgradedVersion);
        Assert.AreEqual(TargetVersion, UpgradedVersion, 'Incorrect upgrade version order.');

        UpgradeEvents.Get(TargetVersion, EventString);
        UpgradeEvents.Remove(TargetVersion);
        Assert.AreEqual('UTL', EventString, 'Events not called in the correct order.');

        if LastUpgrade and (UpgradeEvents.Count() > 0) then begin
            UpgradeEvents.Keys.Get(1, UpgradedVersion);
            Assert.Fail('Additional upgrade version found: ' + Format(UpgradedVersion));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnInvokePerCompanyUpgrade', '', false, false)]
    local procedure MigrateCompanyOnInvokeCompanyMigration(HybridReplicationSummary: Record "Hybrid Replication Summary"; CompanyName: Text[30])
    var
        HybridBCLastSetup: Record "Hybrid BC Last Setup";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        if HybridBCLastSetup.CanHandleCodeunit(Codeunit::"Library - Hybrid BC Last") then begin
            HybridReplicationDetail.SetRange("Run ID", HybridReplicationSummary."Run ID");
            HybridReplicationDetail.DeleteAll();
            Commit();
            Codeunit.Run(Codeunit::"W1 Management", HybridReplicationSummary);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterW1DataLoadForVersion', '', false, false)]
    local procedure FailOnAfterW1DataLoad(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if DataLoadFailure <> '' then
            Error(DataLoadFailure);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Data Load", 'OnAfterW1DataLoadNonCompanyForVersion', '', false, false)]
    local procedure FailOnAfterW1NonPerCompanyDataLoad(CountryCode: Text; TargetVersion: Decimal)
    begin
        if DataLoadFailure <> '' then
            Error(DataLoadFailure);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure DummyOnUpgradePerCompany(CountryCode: Text; TargetVersion: Decimal)
    var
        EventString: Text;
    begin
        if not UpgradeEvents.Get(TargetVersion, EventString) then
            UpgradeEvents.Add(TargetVersion, 'U')
        else
            UpgradeEvents.Set(TargetVersion, EventString + 'U');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnTransformPerCompanyTableDataForVersion', '', false, false)]
    local procedure DummyOnTransformPerCompany(CountryCode: Text; TargetVersion: Decimal)
    var
        EventString: Text;
    begin
        if not UpgradeEvents.Get(TargetVersion, EventString) then
            UpgradeEvents.Add(TargetVersion, 'T')
        else
            UpgradeEvents.Set(TargetVersion, EventString + 'T');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnLoadTableDataForVersion', '', false, false)]
    local procedure DummyOnDataLoadPerCompany(CountryCode: Text; TargetVersion: Decimal)
    var
        EventString: Text;
    begin
        if not UpgradeEvents.Get(TargetVersion, EventString) then
            UpgradeEvents.Add(TargetVersion, 'L')
        else
            UpgradeEvents.Set(TargetVersion, EventString + 'L');
    end;

    procedure InsertWebhookCompletedReplication(RunID: Text; CompanyName: Text)
    var
        WebhookNotification: Record "Webhook Notification";
        HybridBCLastWizard: Codeunit "Hybrid BC Last Wizard";
        NotificationOutStream: OutStream;
        TodayDate: Date;
        DateTimeString: Text;
    begin
        WebhookNotification.ID := CreateGuid();
        WebhookNotification."Sequence Number" := 1;
        WebhookNotification."Subscription ID" := COPYSTR(STRSUBSTNO(SubscriptionFormatTxt, HybridBCLastWizard.ProductId()), 1, 150);
        WebhookNotification.Notification.CreateOutStream(NotificationOutStream);
        TodayDate := DT2Date(CurrentDateTime);
        DateTimeString := StrSubstNo(DateTimeStringFormatTok, Date2DMY(TodayDate, 3), Date2DMY(TodayDate, 2), Date2DMY(TodayDate, 1));
        NotificationOutStream.WriteText(GetBCPreviousCloudSuccessfullNotification(RunID, CompanyName, DateTimeString));
        WebhookNotification.Insert();
    end;

    local procedure GetBCPreviousCloudSuccessfullNotification(RunId: Text; NameOfCompany: Text; StartDate: Text): Text
    begin
        exit('{"@odata.type":"#Microsoft.Dynamics.NAV.Hybrid.Notification","SubscriptionId":"DynamicsBCLast_IntelligentCloud","ChangeType":"Changed","RunId":"' + RunId + '", "StartTime": "' + StartDate + 'T23:59:59.3759312Z","TriggerType":"PipelineActivity","Status":"Completed","ServiceType":"ReplicationCompleted","SyncedVersion":"145","IncrementalTables":[{"TableName":"Bank Account$16319982-4995-4fb1-8fb2-2b1e13773e3b","CompanyName":"' + NameOfCompany + '","ErrorCode":"50004","ErrorMessage":"The table does not exist in the local instance."},{"TableName":"AMC Bank Banks$16319982-4995-4fb1-8fb2-2b1e13773e3b","CompanyName":"' + NameOfCompany + '","ErrorCode":"50004","ErrorMessage":"The table does not exist in the local instance."},{"TableName":"Standard Item Journal$437dbf0e-84ff-417a-965d-ed2bb9650972","CompanyName":"' + NameOfCompany + '","ErrorCode":"","ErrorMessage":""},{"TableName":"Standard Purchase Code$437dbf0e-84ff-417a-965d-ed2bb9650972","CompanyName":"' + NameOfCompany + '","ErrorCode":"","ErrorMessage":""}]}');
    end;
}