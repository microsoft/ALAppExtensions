codeunit 134706 "Email Retention Policy Tests"
{
    Subtype = test;
    TestPermissions = Restrictive;
    Permissions = tabledata "Sent Email" = rimd,
                  tabledata "Email Outbox" = rimd;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        IsInitialized: Boolean;


    [HandlerFunctions('ConfirmApplyRetentionPolicy')]
    [Test]
    procedure SentEmailRetentionPolicyWithoutFiltersTest()
    var
        SentEmail: Record "Sent Email";
        RetentionPolicySetup: Record "Retention Policy Setup";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        // Init
        Initialize();

        // Setup
        CreateSentEmailRecord(CreateDateTime(CalcDate('<-1Y>', Today), Time()));
        CreateRetentionPolicySetup(RetentionPolicySetup, Database::"Sent Email", SentEmail.FieldNo("Date Time Sent"), CreateOrFindRetentionPeriod(enum::"Retention Period Enum"::"1 Month"));
        LibraryAssert.TableIsNotEmpty(Database::"Sent Email");

        // Exercise
        PermissionsMock.Set('Email - Edit');
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, true);
        PermissionsMock.ClearAssignments();

        // Verify
        LibraryAssert.TableIsEmpty(Database::"Sent Email");
    end;

    [HandlerFunctions('ConfirmApplyRetentionPolicy')]
    [Test]
    procedure SentEmailRetentionPolicyWithFiltersTest()
    var
        SentEmail: Record "Sent Email";
        RetentionPolicySetup: Record "Retention Policy Setup";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        // Init
        Initialize();

        // Setup
        CreateSentEmailRecord(CreateDateTime(CalcDate('<-1Y>', Today), Time()));
        CreateRetentionPolicySetupWithLine(RetentionPolicySetup, Database::"Sent Email", SentEmail.FieldNo("Date Time Sent"), CreateOrFindRetentionPeriod(enum::"Retention Period Enum"::"1 Month"));
        LibraryAssert.TableIsNotEmpty(Database::"Sent Email");

        // Exercise
        PermissionsMock.Set('Email - Edit');
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, true);
        PermissionsMock.ClearAssignments();

        // Verify
        LibraryAssert.TableIsEmpty(Database::"Sent Email");
    end;

    local procedure CreateSentEmailRecord(DatetimeSent: datetime)
    var
        SentEmail: Record "Sent Email";
    begin
        SentEmail."Date Time Sent" := DatetimeSent;
        SentEmail.Insert();
    end;

    local procedure CreateOrFindRetentionPeriod(RetentionPeriodEnum: enum "Retention Period Enum"): Code[20]
    var
        RetentionPolicySetup: Codeunit "Retention Policy Setup";
    begin
        exit(RetentionPolicySetup.FindOrCreateRetentionPeriod(RetentionPeriodEnum))
    end;

    local procedure CreateRetentionPolicySetup(var RetentionPolicySetup: Record "Retention Policy Setup"; TableId: Integer; DateFieldNo: integer; RetentionPeriod: Code[20])
    begin
        RetentionPolicySetup.SetRange("Table Id", TableId);
        RetentionPolicySetup.DeleteAll(true);

        RetentionPolicySetup.Validate("Table Id", TableId);
        RetentionPolicySetup.Validate("Date Field No.", DateFieldNo);
        RetentionPolicySetup.Validate("Retention Period", RetentionPeriod);
        RetentionPolicySetup.Validate("Apply to all records", true);
        RetentionPolicySetup.Validate(Manual, true);
        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Insert(true);
    end;

    local procedure CreateRetentionPolicySetupWithLine(var RetentionPolicySetup: Record "Retention Policy Setup"; TableId: Integer; DateFieldNo: integer; RetentionPeriod: Code[20])
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        RetentionPolicySetup.SetRange("Table Id", TableId);
        RetentionPolicySetup.DeleteAll(true);

        RetentionPolicySetup.Validate("Table Id", TableId);
        RetentionPolicySetup.Validate("Date Field No.", DateFieldNo);
        RetentionPolicySetup.Validate("Retention Period", RetentionPeriod);
        RetentionPolicySetup.Validate("Apply to all records", false);
        RetentionPolicySetup.Validate(Manual, true);
        RetentionPolicySetup.Insert(true);

        RetentionPolicySetupLine.Validate("Table Id", TableId);
        RetentionPolicySetupLine.Validate("Line No.", RetentionPolicySetupLine."Line No." + 10000);
        RetentionPolicySetupLine.Validate("Date Field No.", DateFieldNo);
        RetentionPolicySetupLine.Validate("Retention Period", RetentionPeriod);
        RetentionPolicySetupLine.Validate(Enabled, true);
        RetentionPolicySetupLine.Insert(true);

        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Modify(true);
    end;


    [ConfirmHandler]
    procedure ConfirmApplyRetentionPolicy(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.ExpectedMessage('Do you want to delete expired data, as defined in the selected retention policy?', Question);
        Reply := true;
    end;

    local procedure Initialize()
    var
        SentEmail: Record "Sent Email";
    begin
        SentEmail.DeleteAll();

        if IsInitialized then
            exit;

        Commit();
    end;
}