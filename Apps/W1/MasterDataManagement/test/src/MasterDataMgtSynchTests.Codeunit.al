codeunit 139758 "Master Data Mgt. Synch. Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Master Data Management] [Synch]
    end;

    var
        Assert: Codeunit Assert;
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryMasterDataMgt: Codeunit "Library - Master Data Mgt.";
        InitializeHandled: Boolean;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure ErrorByDefaultWhenSynchTransferDataOverwritesLocalChange()
    var
        SourceCustomer: Record Customer;
        DestinationCustomer: Record Customer;
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        SourceRecordRef: RecordRef;
        DestinationRecordRef: RecordRef;
        SourceFieldRef: FieldRef;
        DestinationFieldRef: FieldRef;
        NeedsConversion: Boolean;
        IsValueFound: Boolean;
        NewValue: Variant;
    begin
        Initialize();

        // [GIVEN] two coupled customers
        LibrarySales.CreateCustomer(SourceCustomer);
        SourceCustomer.Name := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(SourceCustomer.Name));
        SourceCustomer.Modify();
        LibrarySales.CreateCustomer(DestinationCustomer);
        DestinationCustomer.Name := SourceCustomer.Name;
        DestinationCustomer.Modify();
        MasterDataMgtCoupling."Integration System ID" := SourceCustomer.SystemId;
        MasterDataMgtCoupling."Local System ID" := DestinationCustomer.SystemId;
        MasterDataMgtCoupling."Table ID" := Database::Customer;
        MasterDataMgtCoupling."Last Synch. Modified On" := DestinationCustomer.SystemModifiedAt;
        MasterDataMgtCoupling.Insert();

        // [WHEN] Destination customer is modified since last synch
        Sleep(100);
        DestinationCustomer.Name := CopyStr(LibraryRandom.RandText(10), 1, MaxStrlen(DestinationCustomer.Name));
        DestinationCustomer.Modify();
        Sleep(100);
        SourceRecordRef.Open(Database::Customer);
        SourceRecordRef.GetTable(SourceCustomer);
        SourceFieldRef := SourceRecordRef.Field(SourceCustomer.FieldNo(SourceCustomer.Name));
        DestinationRecordRef.Open(Database::Customer);
        DestinationRecordRef.GetTable(DestinationCustomer);
        DestinationFieldRef := DestinationRecordRef.Field(DestinationCustomer.FieldNo(DestinationCustomer.Name));

        // [THEN] Data synchronization throws an error if it tries to overwrite the change that was done since last synch
        asserterror LibraryMasterDataMgt.HandleOnTransferFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
        Assert.ExpectedError('overwrite local changes');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure SynchTransferDataOverwritesLocalChangeIfUserSetsItUp()
    var
        SourceCustomer: Record Customer;
        DestinationCustomer: Record Customer;
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        SourceRecordRef: RecordRef;
        DestinationRecordRef: RecordRef;
        SourceFieldRef: FieldRef;
        DestinationFieldRef: FieldRef;
        NeedsConversion: Boolean;
        IsValueFound: Boolean;
        NewValue: Variant;
    begin
        Initialize();

        // [GIVEN] The user set up the Customer.Name field mapping to overwrite local changes
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.FindFirst();
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", SourceCustomer.FieldNo(SourceCustomer.Name));
        IntegrationFieldMapping.FindFirst();
        IntegrationFieldMapping."Overwrite Local Change" := true;
        IntegrationFieldMapping.Modify();

        // [GIVEN] two coupled customers
        LibrarySales.CreateCustomer(SourceCustomer);
        SourceCustomer.Name := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(SourceCustomer.Name));
        SourceCustomer.Modify();
        LibrarySales.CreateCustomer(DestinationCustomer);
        DestinationCustomer.Name := SourceCustomer.Name;
        DestinationCustomer.Modify();
        MasterDataMgtCoupling."Integration System ID" := SourceCustomer.SystemId;
        MasterDataMgtCoupling."Local System ID" := DestinationCustomer.SystemId;
        MasterDataMgtCoupling."Table ID" := Database::Customer;
        MasterDataMgtCoupling."Last Synch. Modified On" := DestinationCustomer.SystemModifiedAt;
        MasterDataMgtCoupling.Insert();

        // [WHEN] Destination customer is modified since last synch
        Sleep(100);
        DestinationCustomer.Name := CopyStr(LibraryRandom.RandText(10), 1, MaxStrlen(DestinationCustomer.Name));
        DestinationCustomer.Modify();
        Sleep(100);
        SourceRecordRef.Open(Database::Customer);
        SourceRecordRef.GetTable(SourceCustomer);
        SourceFieldRef := SourceRecordRef.Field(SourceCustomer.FieldNo(SourceCustomer.Name));
        DestinationRecordRef.Open(Database::Customer);
        DestinationRecordRef.GetTable(DestinationCustomer);
        DestinationFieldRef := DestinationRecordRef.Field(DestinationCustomer.FieldNo(DestinationCustomer.Name));

        // [THEN] Data synchronization succeeds and overwrites the change that was done since last synch
        LibraryMasterDataMgt.HandleOnTransferFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure SynchronizingBlankPrimaryContactNoRetainsDestinationValue()
    var
        SourceCustomer: Record Customer;
        DestinationCustomer: Record Customer;
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        SourceFieldRef: FieldRef;
        DestinationFieldRef: FieldRef;
        SourceRecordRef: RecordRef;
        DestinationRecordRef: RecordRef;
        NeedsConversion: Boolean;
        IsValueFound: Boolean;
        NewValue: Variant;
        PrimaryContactNo: Code[20];
    begin
        Initialize();

        // [GIVEN] two coupled customers
        LibrarySales.CreateCustomer(SourceCustomer);
        SourceCustomer.Name := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(SourceCustomer.Name));
        SourceCustomer.Modify();
        LibrarySales.CreateCustomer(DestinationCustomer);
        DestinationCustomer.Name := SourceCustomer.Name;
        PrimaryContactNo := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(DestinationCustomer."Primary Contact No."));
        DestinationCustomer."Primary Contact No." := PrimaryContactNo;
        DestinationCustomer.Modify();
        MasterDataMgtCoupling."Integration System ID" := SourceCustomer.SystemId;
        MasterDataMgtCoupling."Local System ID" := DestinationCustomer.SystemId;
        MasterDataMgtCoupling."Table ID" := Database::Customer;
        MasterDataMgtCoupling."Last Synch. Modified On" := DestinationCustomer.SystemModifiedAt;
        MasterDataMgtCoupling.Insert();

        // [WHEN] Synch is trying to transfer a blank value into Primary Contact No.
        SourceRecordRef.Open(Database::Customer);
        SourceRecordRef.GetTable(SourceCustomer);
        SourceFieldRef := SourceRecordRef.Field(SourceCustomer.FieldNo(SourceCustomer."Primary Contact No."));
        DestinationRecordRef.Open(Database::Customer);
        DestinationRecordRef.GetTable(DestinationCustomer);
        DestinationFieldRef := DestinationRecordRef.Field(DestinationCustomer.FieldNo(DestinationCustomer."Primary Contact No."));
        LibraryMasterDataMgt.HandleOnTransferFieldData(SourceFieldRef, DestinationFieldRef, NewValue, IsValueFound, NeedsConversion);

        // [THEN] Data synchronization retains the original value of Primary Contact No.
        Assert.AreEqual(PrimaryContactNo, NewValue, '');
        Assert.AreEqual(true, IsValueFound, '');
        Assert.AreEqual(false, NeedsConversion, '');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure SynchronizingPrimaryKeyChange()
    var
        SourceCustomer: Record Customer;
        DestinationCustomer: Record Customer;
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtSynchTests: COdeunit "Master Data Mgt. Synch. Tests";
        SourceNoFieldRef: FieldRef;
        SourceNameFieldRef: FieldRef;
        DestinationNoFieldRef: FieldRef;
        DestinationNameFieldRef: FieldRef;
        SourceRecordRef: RecordRef;
        DestinationRecordRef: RecordRef;
        NewNo: Code[10];
        NewName: Text[100];
    begin
        Initialize();

        // [GIVEN] two coupled customers
        LibrarySales.CreateCustomer(SourceCustomer);
        SourceCustomer.Name := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(SourceCustomer.Name));
        SourceCustomer.Modify();
        LibrarySales.CreateCustomer(DestinationCustomer);
        DestinationCustomer.Name := SourceCustomer.Name;
        DestinationCustomer.Modify();
        MasterDataMgtCoupling."Integration System ID" := SourceCustomer.SystemId;
        MasterDataMgtCoupling."Local System ID" := DestinationCustomer.SystemId;
        MasterDataMgtCoupling."Table ID" := Database::Customer;
        MasterDataMgtCoupling."Last Synch. Modified On" := DestinationCustomer.SystemModifiedAt;
        MasterDataMgtCoupling.Insert();

        // [WHEN] Synch is trying to do a change of primary key and another field
        SourceRecordRef.Open(Database::Customer);
        SourceRecordRef.GetTable(SourceCustomer);
        SourceNoFieldRef := SourceRecordRef.Field(SourceCustomer.FieldNo(SourceCustomer."No."));
        SourceNameFieldRef := SourceRecordRef.Field(SourceCustomer.FieldNo(SourceCustomer.Name));
        NewNo := CopyStr(LibraryRandom.RandText(10), 1, MaxStrlen(NewNo));
        NewName := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(NewName));
        SourceNoFieldRef.Value(NewNo);
        SourceNameFieldRef.Value(NewName);
        DestinationRecordRef.Open(Database::Customer);
        DestinationRecordRef.GetTable(DestinationCustomer);
        DestinationNoFieldRef := DestinationRecordRef.Field(DestinationCustomer.FieldNo(DestinationCustomer."No."));
        DestinationNoFieldRef.Value(NewNo);
        DestinationNameFieldRef := DestinationRecordRef.Field(DestinationCustomer.FieldNo(DestinationCustomer.Name));
        DestinationNameFieldRef.Value(NewName);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.FindFirst();
        BindSubscription(MasterDataMgtSynchTests);
        LibraryMasterDataMgt.RenameIfNeededOnBeforeModifyRecord(IntegrationTableMapping, SourceRecordRef, DestinationRecordRef);
        UnbindSubscription(MasterDataMgtSynchTests);

        // [THEN] Data synchronization renamed DestinationRecordRef and kept the non-primary key field change in DestinationRecordRef so that Modify can finish the synch.
        DestinationCustomer.GetBySystemId(DestinationCustomer.SystemId);
        Assert.AreEqual(NewNo, DestinationCustomer."No.", '');
        Assert.AreNotEqual(NewName, DestinationCustomer.Name, '');
        Assert.AreEqual(NewNo, DestinationRecordRef.Field(DestinationCustomer.FieldNo("No.")).Value(), '');
        Assert.AreEqual(NewName, DestinationRecordRef.Field(DestinationCustomer.FieldNo(Name)).Value(), '');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure WasSourceModifiedAfterLastSynch()
    var
        SourceCustomer: Record Customer;
        DestinationCustomer: Record Customer;
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtSynchTests: Codeunit "Master Data Mgt. Synch. Tests";
        SourceRecordRef: RecordRef;
        SourceWasChanged: Boolean;
        IsHandled: Boolean;
    begin
        Initialize();

        // [GIVEN] two coupled customers
        LibrarySales.CreateCustomer(SourceCustomer);
        LibrarySales.CreateCustomer(DestinationCustomer);
        MasterDataMgtCoupling."Integration System ID" := SourceCustomer.SystemId;
        MasterDataMgtCoupling."Local System ID" := DestinationCustomer.SystemId;
        MasterDataMgtCoupling."Table ID" := Database::Customer;
        MasterDataMgtCoupling."Last Synch. Modified On" := DestinationCustomer.SystemModifiedAt;
        MasterDataMgtCoupling."Last Synch. Int. Modified On" := SourceCustomer.SystemModifiedAt;
        MasterDataMgtCoupling.Insert();

        // [WHEN] Source record changed since last synch
        Sleep(100);
        SourceCustomer.Name := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(SourceCustomer.Name));
        SourceCustomer.Modify();
        SourceCustomer.GetBySystemId(SourceCustomer.SystemId);

        // [THEN] Synch engine should detect that the source record modified
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.FindFirst();
        SourceRecordRef.Open(Database::Customer);
        SourceRecordRef.GetTable(SourceCustomer);
        BindSubscription(MasterDataMgtSynchTests);
        LibraryMasterDataMgt.HandleOnWasModifiedAfterLastSynch(TableConnectionType::ExternalSQL, IntegrationTableMapping, SourceRecordRef, SourceWasChanged, IsHandled);
        UnbindSubscription(MasterDataMgtSynchTests);
        Assert.AreEqual(true, SourceWasChanged, '');
        Assert.AreEqual(true, IsHandled, '');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure FindAndSynchRecordIDFromIntegrationSystemId()
    var
        SourceCustomer: Record Customer;
        DestinationCustomer: Record Customer;
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        MasterDataMgtSynchTests: Codeunit "Master Data Mgt. Synch. Tests";
        DestinationCustomerRecordId: RecordId;
        IsHandled: Boolean;
    begin
        Initialize();

        // [GIVEN] a customer
        LibrarySales.CreateCustomer(SourceCustomer);

        // [WHEN] No. field synch is disabled, because in the test we mock integration record as a local record and want to avoid primary key constraint violation
        // [WHEN] Synch. Only Coupled records is false because we want the synch to create a new customer based on SourceCustomer
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.FindFirst();
        IntegrationTableMapping."Synch. Only Coupled Records" := false;
        IntegrationTableMapping.Modify();
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", SourceCustomer.FieldNo("No."));
        IntegrationFieldMapping.FindFirst();
        IntegrationFieldMapping.Status := IntegrationFieldMapping.Status::Disabled;
        IntegrationFieldMapping.Modify();

        // [WHEN] Source record changed since last synch
        Sleep(100);
        SourceCustomer.Name := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(SourceCustomer.Name));
        SourceCustomer.Modify();
        SourceCustomer.GetBySystemId(SourceCustomer.SystemId);

        // [WHEN] The subscriber that synchronizes the record based on SystemId is called
        BindSubscription(MasterDataMgtSynchTests);
        LibraryMasterDataMgt.HandleOnFindAndSynchRecordIDFromIntegrationSystemId(SourceCustomer.SystemId, Database::Customer, DestinationCustomerRecordId, IsHandled);
        UnbindSubscription(MasterDataMgtSynchTests);

        // [THEN] Synch engine should modify the destination record accordingly
        Assert.AreEqual(true, IsHandled, '');
        DestinationCustomer.Get(DestinationCustomerRecordId);
        Assert.AreEqual(SourceCustomer.Name, DestinationCustomer.Name, '');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure SynchMediaField()
    var
        SourceCustomer: Record Customer;
        DestinationCustomer: Record Customer;
        IntegrationTableMapping: Record "Integration Table Mapping";
        IntegrationFieldMapping: Record "Integration Field Mapping";
        TenantMedia: Record "Tenant Media";
        MasterDataMgtSynchTests: Codeunit "Master Data Mgt. Synch. Tests";
        DestinationCustomerRecordId: RecordId;
        SourceCustomerRecRef, DestinationCustomerRecRef : RecordRef;
        MediaOutStream: OutStream;
        MediaInStream: InStream;
        IsHandled: Boolean;
        InStreamText: Text;
        DestinationImageMediaId: Guid;
    begin
        // [SCENARIO 572457] Synchronizing media fields
        Initialize();

        // [GIVEN] a customer
        LibrarySales.CreateCustomer(SourceCustomer);

        // [WHEN] No. field synch is disabled, because in the test we mock integration record as a local record and want to avoid primary key constraint violation
        // [WHEN] Synch. Only Coupled records is false because we want the synch to create a new customer based on SourceCustomer
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.FindFirst();
        IntegrationTableMapping."Synch. Only Coupled Records" := false;
        IntegrationTableMapping.Modify();
        IntegrationFieldMapping.SetRange("Integration Table Mapping Name", IntegrationTableMapping.Name);
        IntegrationFieldMapping.SetRange("Field No.", SourceCustomer.FieldNo("No."));
        IntegrationFieldMapping.FindFirst();
        IntegrationFieldMapping.Status := IntegrationFieldMapping.Status::Disabled;
        IntegrationFieldMapping.Modify();

        // [WHEN] Source record changed since last synch and gotten an image for the first time
        Sleep(100);
        TenantMedia."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TenantMedia."Company Name"));
        TenantMedia.Content.CreateOutStream(MediaOutStream);
        MediaOutStream.WriteText('1');
        TenantMedia.ID := CreateGuid();
        TenantMedia.Insert();
        SourceCustomer.Name := CopyStr(LibraryRandom.RandText(20), 1, MaxStrlen(SourceCustomer.Name));
        SourceCustomer.Modify();
        SourceCustomerRecRef.GetTable(SourceCustomer);
        SourceCustomerRecRef.Field(SourceCustomer.FieldNo(Image)).Value(TenantMedia.ID);
        SourceCustomerRecRef.Modify();
        SourceCustomer.GetBySystemId(SourceCustomer.SystemId);

        // [WHEN] The subscriber that synchronizes the record based on SystemId is called
        BindSubscription(MasterDataMgtSynchTests);
        LibraryMasterDataMgt.HandleOnFindAndSynchRecordIDFromIntegrationSystemId(SourceCustomer.SystemId, Database::Customer, DestinationCustomerRecordId, IsHandled);
        UnbindSubscription(MasterDataMgtSynchTests);

        // [THEN] Synch engine should modify the destination record accordingly, including the image field as well
        DestinationCustomer.Get(DestinationCustomerRecordId);
        DestinationCustomerRecRef.GetTable(DestinationCustomer);
        Assert.AreEqual(SourceCustomer.Name, DestinationCustomer.Name, '');
        DestinationImageMediaId := DestinationCustomerRecRef.Field(DestinationCustomer.FieldNo(Image)).Value();
        TenantMedia.Get(DestinationImageMediaId);
        TenantMedia.CalcFields(Content);
        TenantMedia.Content.CreateInStream(MediaInStream);
        MediaInStream.ReadText(InStreamText);
        Assert.AreEqual('1', InStreamText, '');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure FindingIfJobNeedsToBeRun()
    var
        SourceCustomer: Record Customer;
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataMgtSynchTests: Codeunit "Master Data Mgt. Synch. Tests";
        NeedsToRun: Boolean;
    begin
        Initialize();

        // [GIVEN] a customer
        LibrarySales.CreateCustomer(SourceCustomer);

        // [WHEN] Job Queue Entry for scheduled Customer synch job asks if it need to run
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.FindFirst();
        JobQueueEntry.SetRange("Recurring Job", true);
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.FindFirst();
        BindSubscription(MasterDataMgtSynchTests);
        LibraryMasterDataMgt.HandleOnFindingIfJobNeedsToBeRun(JobQueueEntry, NeedsToRun);
        UnbindSubscription(MasterDataMgtSynchTests);

        // [THEN] The answer is yes, because there are integration customers within the filter
        Assert.AreEqual(true, NeedsToRun, '');
    end;

    [Test]
    [HandlerFunctions('SynchronizationEnabledMessageHandler')]
    procedure AfterJobQueueEntryRun()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        MasterDataMgtSynchTests: Codeunit "Master Data Mgt. Synch. Tests";
    begin
        Initialize();

        // [GIVEN] Job Queue Entry for scheduled Customer synch job completes the run
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        IntegrationTableMapping.SetRange("Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Integration Table ID", Database::Customer);
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.FindFirst();
        JobQueueEntry.SetRange("Recurring Job", true);
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        JobQueueEntry.FindFirst();
        BindSubscription(MasterDataMgtSynchTests);
        LibraryMasterDataMgt.HandleOnAfterJobQueueEntryRun(JobQueueEntry);
        UnbindSubscription(MasterDataMgtSynchTests);

        // [THEN] The status is set to ready, because in this particular situation, jobs haven't been idle
        Assert.AreEqual(JobQueueEntry.Status::Ready, JobQueueEntry.Status, '');
    end;

    local procedure EnableSetup()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        MasterDataMgtSynchTests: Codeunit "Master Data Mgt. Synch. Tests";
    begin
        MasterDataManagementSetup.Init();
        MasterDataManagementSetup."Company Name" := CopyStr(LibraryRandom.RandText(30), 1, MaxStrLen(MasterDataManagementSetup."Company Name"));
        MasterDataManagementSetup.Validate("Is Enabled", true);
        BindSubscription(MasterDataMgtSynchTests);
        MasterDataManagementSetup.Insert(true);
        UnbindSubscription(MasterDataMgtSynchTests);
    end;

    local procedure Initialize()
    var
        MasterDataManagementSetup: Record "Master Data Management Setup";
        IntegrationTableMapping: Record "Integration Table Mapping";
        MasterDataMgtCoupling: Record "Master Data Mgt. Coupling";
        MasterDataMgtSubscriber: Record "Master Data Mgt. Subscriber";
        MasterDataMgtSynchTests: Codeunit "Master Data Mgt. Synch. Tests";
    begin
        OnBeforeInitialize(InitializeHandled);
        if InitializeHandled then
            exit;

        LibrarySetupStorage.Restore();

        BindSubscription(MasterDataMgtSynchTests);
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::"Master Data Management");
        if IntegrationTableMapping.FindSet() then
            repeat
                IntegrationTableMapping.Delete(true);
            until IntegrationTableMapping.Next() = 0;
        MasterDataMgtCoupling.DeleteAll();
        MasterDataManagementSetup.DeleteAll();
        MasterDataMgtSubscriber.DeleteAll();
        Commit();

        EnableSetup();
        UnbindSubscription(MasterDataMgtSynchTests);
        OnAfterInitialize(InitializeHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnHandleOnAfterDeleteIntegrationTableMapping', '', false, false)]
    local procedure OnHandleOnAfterDeleteIntegrationTableMapping(var IntegrationTableMapping: Record "Integration Table Mapping"; RunTrigger: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnHandleRecreateJobQueueEntryFromIntegrationTableMapping', '', false, false)]
    local procedure OnHandleRecreateJobQueueEntryFromIntegrationTableMapping(var JobQueueEntry: Record "Job Queue Entry"; var IntegrationTableMapping: Record "Integration Table Mapping"; var IsHandled: Boolean)
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Integration Synch. Job Runner");
        JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
        if not JobQueueEntry.IsEmpty() then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnSetIntegrationTableFilter', '', false, false)]
    local procedure HandleOnSetIntegrationTableFilter(IntegrationTableMapping: Record "Integration Table Mapping"; var RecRef: RecordRef; var IsHandled: Boolean)
    begin
        RecRef.Open(IntegrationTableMapping."Integration Table ID");
        IntegrationTableMapping.SetIntRecordRefFilter(RecRef);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnUpdateChildContactsParentCompany', '', false, false)]
    local procedure HandleOnUpdateChildContactsParentCompany(var SourceRecordRef: RecordRef; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnGetIntegrationRecordSystemId', '', false, false)]
    local procedure HandleOnGetIntegrationRecordSystemId(var SourceRecordRef: RecordRef; var IntegrationTableUid: Guid; var IsHandled: Boolean)
    var
        IntegrationTableUidFieldRef: FieldRef;
    begin
        IntegrationTableUidFieldRef := SourceRecordRef.Field(SourceRecordRef.SystemIdNo());
        IntegrationTableUid := IntegrationTableUidFieldRef.Value();
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnGetIntegrationSystemIdFromRecRef', '', false, false)]
    local procedure HandleOnGetIntegrationSystemIdFromRecRef(IntegrationRecordRef: RecordRef; var IntegrationRecordSystemId: Guid; var IsHandled: Boolean)
    var
        IntegrationSystemIDFieldRef: FieldRef;
    begin
        IntegrationSystemIDFieldRef := IntegrationRecordRef.Field(IntegrationRecordRef.SystemIdNo());
        IntegrationRecordSystemId := IntegrationSystemIDFieldRef.Value;
        IsHandled := true;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnGetIntegrationRecordRefBySystemId', '', false, false)]
    local procedure HandleOnGetIntegrationRecordRefBySystemId(IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; IntRecSystemId: Guid; var IsHandled: Boolean)
    begin
        if TryOpen(SourceRecordRef, IntegrationTableMapping."Table ID") then;
        SourceRecordRef.GetBySystemId(IntRecSystemId);
        IsHandled := true;
    end;

    [TryFunction]
    local procedure TryOpen(var RecRef: RecordRef; TableId: Integer)
    begin
        RecRef.open(TableId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Master Data Management", 'OnGetIntegrationRecordRef', '', false, false)]
    local procedure HandleOnGetIntegrationRecordRef(IntegrationTableMapping: Record "Integration Table Mapping"; var SourceRecordRef: RecordRef; var IsHandled: Boolean)
    begin
        IsHandled := true;
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
