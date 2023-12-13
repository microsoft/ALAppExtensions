codeunit 139770 "Master Data Mgt. Setup Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Master Data Management] [Setup]
    end;

    var
        Assert: Codeunit Assert;
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        InitializeHandled: Boolean;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure EnableSetup()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataMgtSetupTests: Codeunit "Master Data Mgt. Setup Tests";
    begin
        Initialize();
        MasterDataManagementSetup.Init();
        MasterDataManagementSetup."Company Name" := CopyStr(LibraryRandom.RandText(30), 1, MaxStrLen(MasterDataManagementSetup."Company Name"));
        MasterDataManagementSetup.Validate("Is Enabled", true);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Insert(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        VerifyDefaultSetup();
    end;

    local procedure VerifyDefaultSetup()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        SynchronizationTableNos: List of [Integer];
        TableNo: Integer;
    begin
        SynchronizationTableNos.Add(Database::Customer);
        SynchronizationTableNos.Add(Database::Vendor);
        SynchronizationTableNos.Add(Database::Contact);
        SynchronizationTableNos.Add(Database::Currency);
        SynchronizationTableNos.Add(Database::"Currency Exchange Rate");
        SynchronizationTableNos.Add(Database::"No. Series");
        SynchronizationTableNos.Add(Database::"No. Series Line");
        SynchronizationTableNos.Add(Database::"Country/Region");
        SynchronizationTableNos.Add(Database::"Post Code");
        SynchronizationTableNos.Add(Database::"Sales & Receivables Setup");
        SynchronizationTableNos.Add(Database::"Marketing Setup");
        SynchronizationTableNos.Add(Database::"Purchases & Payables Setup");
        SynchronizationTableNos.Add(Database::"Payment Terms");
        SynchronizationTableNos.Add(Database::"Shipment Method");
        SynchronizationTableNos.Add(Database::"Shipping Agent");
        SynchronizationTableNos.Add(Database::"Salesperson/Purchaser");

        foreach TableNo in SynchronizationTableNos do begin
            IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
            IntegrationTableMapping.SetRange("Table ID", TableNo);
            IntegrationTableMapping.SetRange("Integration Table ID", TableNo);
            IntegrationTableMapping.SetRange("Delete After Synchronization", false);
            Assert.AreEqual(IntegrationTableMapping.Count(), 1, '');
            IntegrationTableMapping.FindFirst();
            Assert.AreEqual(IntegrationTableMapping.Direction, IntegrationTableMapping.Direction::FromIntegrationTable, '');
            IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
            IntegrationFieldMapping.SetRange(Status, IntegrationFieldMapping.Status::Enabled);
            Assert.IsTrue(IntegrationFieldMapping.Count() > 0, '');
            IntegrationFieldMapping.SetRange(Status);
            if IntegrationFieldMapping.FindSet() then
                repeat
                    Assert.AreEqual(IntegrationFieldMapping.Direction, IntegrationFieldMapping.Direction::FromIntegrationTable, '');
                until IntegrationFieldMapping.Next() = 0;
            JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
            JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
            JobQueueEntry.SetRange("Recurring Job", true);
            Assert.AreEqual(JobQueueEntry.Count(), 1, '');
        end;

        MasterDataMgtSubscriber.SetRange("Company Name", CompanyName());
        Assert.AreEqual(MasterDataMgtSubscriber.Count(), 1, '');
    end;

    [Test]
    procedure EnableSetupFailsIfCurrentCompanyChosen()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
    begin
        Initialize();
        MasterDataManagementSetup.Init();
        asserterror MasterDataManagementSetup.Validate("Company Name", CopyStr(CompanyName(), 1, MaxStrLen(MasterDataManagementSetup."Company Name")));
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler,ConfirmHandlerYes')]
    procedure DisableSetupKeepCouplingTable()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataMgtSetupTests: Codeunit "Master Data Mgt. Setup Tests";
        EmptyGuid: Guid;
    begin
        Initialize();
        MasterDataManagementSetup.Init();
        MasterDataManagementSetup."Company Name" := CopyStr(LibraryRandom.RandText(30), 1, MaxStrLen(MasterDataManagementSetup."Company Name"));
        MasterDataManagementSetup.Validate("Is Enabled", true);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Insert(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        // insert a dummy coupling
        MasterDataMgtCoupling."Integration System ID" := EmptyGuid;
        MasterDataMgtCoupling."Local System ID" := EmptyGuid;
        MasterDataMgtCoupling.Insert();

        MasterDataManagementSetup.Validate("Is Enabled", false);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Modify(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        // mappings are deleted, job queue entries are on hold, the coupling was kept
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Recurring Job", true);
        JobQueueEntry.SetFilter(Status, '<>' + Format(JobQueueEntry.Status::"On Hold"));
        Assert.AreEqual(0, JobQueueEntry.Count(), '');
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        Assert.IsTrue(IntegrationTableMapping.Count() > 0, '');
        Assert.IsTrue(IntegrationFieldMapping.Count() > 0, '');
        Assert.AreEqual(1, MasterDataMgtCoupling.Count(), '');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler,ConfirmHandlerYes')]
    procedure ResetConfigurationResetsDefaults()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataMgtSetupTests: Codeunit "Master Data Mgt. Setup Tests";
        MasterDataManagementSetupPage: TestPage "Master Data Management Setup";
    begin
        Initialize();
        MasterDataManagementSetup.Init();
        MasterDataManagementSetup."Company Name" := CopyStr(LibraryRandom.RandText(30), 1, MaxStrLen(MasterDataManagementSetup."Company Name"));
        MasterDataManagementSetup.Validate("Is Enabled", true);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Insert(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        // mappings and job queue entries are deleted
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Recurring Job", true);
        JobQueueEntry.DeleteAll();
        IntegrationFieldMapping.DeleteAll();
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.DeleteAll();

        // reset configuration
        MasterDataManagementSetupPage.OpenEdit();
        MasterDataManagementSetupPage.ResetConfiguration.Invoke();
        VerifyDefaultSetup();
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure ExportImportSetup()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtSetupTests: Codeunit "Master Data Mgt. Setup Tests";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin
        Initialize();
        MasterDataManagementSetup.Init();
        MasterDataManagementSetup."Company Name" := CopyStr(LibraryRandom.RandText(30), 1, MaxStrLen(MasterDataManagementSetup."Company Name"));
        MasterDataManagementSetup.Validate("Is Enabled", true);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Insert(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        // export setup
        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(XMLPORT::ExportMDMSetup, OutStr);
        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF16);

        // mappings and job queue entries are deleted
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        if IntegrationTableMapping.FindSet() then
            repeat
                IntegrationTableMapping.Delete(true);
            until IntegrationTableMapping.Next() = 0;

        // reimport setup
        XMLPORT.Import(XMLPORT::ImportMDMSetup, InStr);
        VerifyDefaultSetup();
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler,TableObjectsHandler')]
    procedure SynchronizeAdditionalTable()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataMgtSetupTests: Codeunit "Master Data Mgt. Setup Tests";
        TempBlob: Codeunit "Temp Blob";
        MasterDataSynchTables: TestPage "Master Data Synch. Tables";
        MasterDataSynchFields: TestPage "Master Data Synch. Fields";
        InStr: InStream;
        OutStr: OutStream;
    begin
        Initialize();
        MasterDataManagementSetup.Init();
        MasterDataManagementSetup."Company Name" := CopyStr(LibraryRandom.RandText(30), 1, MaxStrLen(MasterDataManagementSetup."Company Name"));
        MasterDataManagementSetup.Validate("Is Enabled", true);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Insert(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        // Add one more table to synch
        MasterDataSynchTables.OpenEdit();
        LibraryVariableStorage.Enqueue(Database::"Activity Log");
        MasterDataSynchFields.Trap();
        MasterDataSynchTables.New();
        MasterDataSynchTables.TableCaptionValue.AssistEdit();
        MasterDataSynchFields.Close();

        // export setup
        TempBlob.CreateOutStream(OutStr);
        XMLPORT.Export(XMLPORT::ExportMDMSetup, OutStr);
        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF16);

        // mappings and job queue entries are deleted
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Recurring Job", true);
        JobQueueEntry.DeleteAll();
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        if IntegrationTableMapping.FindSet() then
            repeat
                IntegrationTableMapping.Delete(true);
            until IntegrationTableMapping.Next() = 0;

        // reimport setup and verify that the additional table and field mappings are also there
        XMLPORT.Import(XMLPORT::ImportMDMSetup, InStr);
        VerifyDefaultSetup();
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::"Activity Log");
        IntegrationTableMapping.SetRange("Integration Table ID", Database::"Activity Log");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        Assert.AreEqual(1, IntegrationTableMapping.Count(), 'Expected a synchronization table for Activity Log table');
        IntegrationTableMapping.FindFirst();
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        Assert.IsTrue(IntegrationFieldMapping.Count() > 0, 'Expected synchronization fields for the added table (Activity Log).');
        IntegrationFieldMapping.SetRange(Status, IntegrationFieldMapping.Status::Enabled);
        Assert.IsTrue(IntegrationFieldMapping.Count() = 0, 'All synchronization fields for the added table should be disabled by default.');
        IntegrationFieldMapping.SetRange(Status);
        IntegrationFieldMapping.SetRange("Field Caption", '');
        Assert.IsTrue(IntegrationFieldMapping.Count() = 0, 'All synchronization fields for the added table should have a caption.');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler,ConfirmHandlerNo')]
    procedure DisableSetupDeleteCouplingTable()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataMgtSetupTests: Codeunit "Master Data Mgt. Setup Tests";
        EmptyGuid: Guid;
    begin
        Initialize();
        MasterDataManagementSetup.Init();
        MasterDataManagementSetup."Company Name" := CopyStr(LibraryRandom.RandText(30), 1, MaxStrLen(MasterDataManagementSetup."Company Name"));
        MasterDataManagementSetup.Validate("Is Enabled", true);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Insert(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        // insert a dummy coupling
        MasterDataMgtCoupling."Integration System ID" := EmptyGuid;
        MasterDataMgtCoupling."Local System ID" := EmptyGuid;
        MasterDataMgtCoupling.Insert();

        MasterDataManagementSetup.Validate("Is Enabled", false);
        BindSubscription(MasterDataMgtSetupTests);
        MasterDataManagementSetup.Modify(true);
        UnbindSubscription(MasterDataMgtSetupTests);

        // mappings are deleted, job queue entries are on hold, the coupling was deleted
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Recurring Job", true);
        JobQueueEntry.SetFilter(Status, '<>' + Format(JobQueueEntry.Status::"On Hold"));
        Assert.AreEqual(0, JobQueueEntry.Count(), '');
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        Assert.AreEqual(0, IntegrationTableMapping.Count(), '');
        Assert.AreEqual(0, IntegrationFieldMapping.Count(), '');
        Assert.AreEqual(0, MasterDataMgtCoupling.Count(), '');
    end;

    local procedure Initialize()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        JObQueueEntry: Record "Job Queue Entry";
    begin
        OnBeforeInitialize(InitializeHandled);
        if InitializeHandled then
            exit;

        LibrarySetupStorage.Restore();

        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        if IntegrationTableMapping.FindSet() then
            repeat
                IntegrationTableMapping.Delete(true);
            until IntegrationTableMapping.Next() = 0;
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.DeleteAll();
        MasterDataMgtCoupling.DeleteAll();
        MasterDataManagementSetup.DeleteAll();
        MasterDataMgtSubscriber.DeleteAll();
        Commit();
        OnAfterInitialize(InitializeHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnAddSubsidiarySubscriptionToMasterCompany', '', false, false)]
    local procedure HandleOnAddSubsidiarySubscriptionToMasterCompany(MasterCompanyName: Text[30]; SubsidiaryCompanyName: Text[30]; var IsHandled: Boolean)
    var
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
    begin
        MasterDataMgtSubscriber.Init();
        MasterDataMgtSubscriber."Company Name" := SubsidiaryCompanyName;
        if MasterDataMgtSubscriber.Insert() then;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnRemoveSubsidiarySubscriptionFromMasterCompany', '', false, false)]
    local procedure HandleOnRemoveSubsidiarySubscriptionFromMasterCompany(MasterCompanyName: Text[30]; SubsidiaryCompanyName: Text[30]; var IsHandled: Boolean)
    var
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
    begin
        MasterDataMgtSubscriber.SetRange("Company Name", SubsidiaryCompanyName);
        MasterDataMgtSubscriber.DeleteAll();
        IsHandled := true;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    internal procedure TableObjectsHandler(var TableObjects: TestPage "Table Objects")
    var
        TableNo: Variant;
        TableID: Text;
    begin
        LibraryVariableStorage.Dequeue(TableNo);
        TableID := Format(TableNo);
        TableObjects.FILTER.SetFilter("Object ID", TableID);
        TableObjects.Last();
        TableObjects.OK().Invoke();
    end;

    [ConfirmHandler]
    internal procedure ConfirmHandlerYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    internal procedure ConfirmHandlerNo(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [MessageHandler]
    procedure SynchronizationEnabledMessageHandler(Message: Text)
    begin
        if StrPos(Message, 'is enabled') <> 0 then
            exit;
        if StrPos(Message, 'default setup') <> 0 then
            exit;
        Assert.Fail(StrSubstNo('Unexpected message: %1', Message));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitialize(var InitializeHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitialize(var InitializeHandled: Boolean)
    begin
    end;
}