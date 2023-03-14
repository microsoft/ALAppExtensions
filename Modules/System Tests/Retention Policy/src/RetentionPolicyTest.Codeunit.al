// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 138702 "Retention Policy Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PermissionsMock: Codeunit "Permissions Mock";
        DateFieldNoMustHaveAValueErr: Label 'The field Date Field No. must have a value in the retention policy for table %1, %2', Comment = '%1 = table number, %2 = table caption';

    trigger OnRun()
    begin
    end;

    [Test]
    procedure TestExpirationDateWhereOlderFilterViewS1()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // base scenario
        // ExpirationDate < NullDateReplacement
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo(SystemCreatedAt);
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&..%2))', DateFieldNo, Format(FixViewsTimeZoneIssueMaxRange(ExpirationDate - 1), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereOlderFilterViewS2()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // NullDateReplacement < ExpirationDate
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo(SystemCreatedAt);
        ExpirationDate := CalcDate('<-6M>', Today());
        NullDateReplacementDate := CalcDate('<-1Y>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>=''''&..%2))', DateFieldNo, Format(FixViewsTimeZoneIssueMaxRange(ExpirationDate - 1), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereOlderFilterViewS3()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // CustomDateField
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("Date Field");
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&..%2))', DateFieldNo, Format(ExpirationDate - 1, 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereOlderFilterViewS4()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // custom datetime field
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("DateTime Field");
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&..%2))', DateFieldNo, Format(FixViewsTimeZoneIssueMaxRange(ExpirationDate - 1), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereOlderFilterViewS5()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView : Text;
    begin
        // [SCENARIO]
        // DateFieldNo error
        // Setup
        DateFieldNo := 0;
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&..%2))', DateFieldNo, Format(FixViewsTimeZoneIssueMaxRange(ExpirationDate - 1), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        AssertError ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        Assert.ExpectedError(StrSubstNo(DateFieldNoMustHaveAValueErr, RecordRef.Number, RecordRef.Caption));
    end;

    [Test]
    procedure TestExpirationDateWhereOlderFilterViewS6()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // NullDateReplacement < ExpirationDate and custom datetimefield
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("DateTime Field");
        ExpirationDate := CalcDate('<-6M>', Today());
        NullDateReplacementDate := CalcDate('<-1Y>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&..%2))', DateFieldNo, Format(FixViewsTimeZoneIssueMaxRange(ExpirationDate - 1), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereOlderExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereNewerFilterViewS1()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // base scenario
        // ExpirationDate < NullDateReplacement
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo(SystemCreatedAt);
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>=''''&%2..))', DateFieldNo, Format(FixViewsTimeZoneIssueMinRange(ExpirationDate), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereNewerFilterViewS2()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // NullDateReplacement < ExpirationDate
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo(SystemCreatedAt);
        ExpirationDate := CalcDate('<-6M>', Today());
        NullDateReplacementDate := CalcDate('<-1Y>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&%2..))', DateFieldNo, Format(FixViewsTimeZoneIssueMinRange(ExpirationDate), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereNewerFilterViewS3()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // CustomDateField
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("Date Field");
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&%2..))', DateFieldNo, Format(ExpirationDate, 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereNewerFilterViewS4()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // custom datetime field
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("DateTime Field");
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&%2..))', DateFieldNo, Format(FixViewsTimeZoneIssueMinRange(ExpirationDate), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateWhereNewerFilterViewS5()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView : Text;
    begin
        // [SCENARIO]
        // DateFieldNo error
        // Setup
        DateFieldNo := 0;
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&%2..))', DateFieldNo, Format(FixViewsTimeZoneIssueMinRange(ExpirationDate), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        AssertError ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        Assert.ExpectedError(StrSubstNo(DateFieldNoMustHaveAValueErr, RecordRef.Number, RecordRef.Caption));
    end;

    [Test]
    procedure TestExpirationDateWhereNewerFilterViewS6()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // NullDateReplacement < ExpirationDate and custom datetimefield
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("DateTime Field");
        ExpirationDate := CalcDate('<-6M>', Today());
        NullDateReplacementDate := CalcDate('<-1Y>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(>''''&%2..))', DateFieldNo, Format(FixViewsTimeZoneIssueMinRange(ExpirationDate), 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetWhereNewerExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        // parse out time component
        ActualView := ActualView.Remove(ActualView.LastIndexOf('T'), 10);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateSingleDateFilterViewS1()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // base scenario
        // ExpirationDate < NullDateReplacement
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo(SystemCreatedAt);
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(%2))', DateFieldNo, SingleDateViewTimeRange(ExpirationDate - 1));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetSingleDateExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateSingleDateFilterViewS2()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // NullDateReplacement < ExpirationDate
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo(SystemCreatedAt);
        ExpirationDate := CalcDate('<-6M>', Today());
        NullDateReplacementDate := CalcDate('<-1Y>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(''''..''''|%2))', DateFieldNo, SingleDateViewTimeRange(ExpirationDate - 1));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetSingleDateExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateSingleDateFilterViewS3()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // CustomDateField
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("Date Field");
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(%2))', DateFieldNo, Format(ExpirationDate - 1, 0, 9));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetSingleDateExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateSingleDateFilterViewS4()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // custom datetime field
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("DateTime Field");
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(%2))', DateFieldNo, SingleDateViewTimeRange(ExpirationDate - 1));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetSingleDateExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestExpirationDateSingleDateFilterViewS5()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView : Text;
    begin
        // [SCENARIO]
        // DateFieldNo error
        // Setup
        DateFieldNo := 0;
        ExpirationDate := CalcDate('<-1Y>', Today());
        NullDateReplacementDate := CalcDate('<-6M>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(%2))', DateFieldNo, SingleDateViewTimeRange(ExpirationDate - 1));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        AssertError ApplyRetentionPolicy.SetSingleDateExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        Assert.ExpectedError(StrSubstNo(DateFieldNoMustHaveAValueErr, RecordRef.Number, RecordRef.Caption));
    end;

    [Test]
    procedure TestExpirationDateSingleDateFilterViewS6()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RecordRef: RecordRef;
        ExpirationDate: Date;
        NullDateReplacementDate: Date;
        DateFieldNo: Integer;
        Filtergroup: Integer;
        EmptyView, ExpectedView, ActualView : Text;
    begin
        // [SCENARIO]
        // NullDateReplacement < ExpirationDate and custom datetimefield
        // Setup
        DateFieldNo := RetentionPolicyTestData.FieldNo("DateTime Field");
        ExpirationDate := CalcDate('<-6M>', Today());
        NullDateReplacementDate := CalcDate('<-1Y>', Today());
        Filtergroup := 10;
        EmptyView := 'VERSION(1) SORTING(Field1)';
#pragma warning disable AA0217
        ExpectedView := StrSubstNo('VERSION(1) SORTING(Field1) WHERE(Field%1=1(%2))', DateFieldNo, SingleDateViewTimeRange(ExpirationDate - 1));
#pragma warning restore
        RecordRef.GetTable(RetentionPolicyTestData);

        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty to start with.');

        // Execute
        ApplyRetentionPolicy.SetSingleDateExpirationDateFilter(DateFieldNo, ExpirationDate, RecordRef, Filtergroup, NullDateReplacementDate);

        // Verify
        ActualView := RecordRef.GetView(false);
        Assert.AreEqual(ExpectedView, ActualView, 'The view is not correct');
        RecordRef.Filtergroup := 0;
        Assert.AreEqual(EmptyView, RecordRef.GetView(false), 'View should be empty in filtergroup 0');
    end;

    [Test]
    procedure TestApplyRetentionPolicyTableNotAllowed()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestDataTwo: Record "Retention Policy Test Data Two";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        RetentionPolicySetup."Table ID" := Database::"Retention Policy Test Data Two";
        RetentionPolicySetup."Retention Period" := RetentionPeriod.Code;
        RetentionPolicySetup."Date Field No." := RetentionPolicyTestDataTwo.FieldNo("Date Field");
        RetentionPolicySetup."Apply to all records" := true;
        RetentionPolicySetup.Enabled := true;

        RetentionPolicyTestDataTwo."Date Field" := CalcDate('<-2W>', Today());
        RetentionPolicyTestDataTwo."Description" := CopyStr(Any.AlphabeticText(Any.IntegerInRange(1, MaxStrLen(RetentionPolicyTestDataTwo.Description))), 1, MaxStrLen(RetentionPolicyTestDataTwo.Description));
        RetentionPolicyTestDataTwo.Insert();
        Assert.AreEqual(1, RetentionPolicyTestDataTwo.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        AssertError
            ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.ExpectedError('Table 138701, Retention Policy Test Data Two, is not in the list of allowed tables.');
    end;

    [Test]
    procedure TestApplyRetentionPolicyDeleteOneLineDisabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertDisabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicyTestData('<-2W>');

        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    //[HandlerFunctions('ConfirmYes')]
    procedure TestApplyRetentionPolicyDeleteOneLineEnabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicyTestData('<-2W>');

        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsEmpty(RetentionPolicyTestData);
        Assert.AreEqual(0, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyKeepOneLineDisabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertDisabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicyTestData('<-4D>');

        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyKeepOneLineEnabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicyTestData('<-4D>');

        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyKeepOneDeleteOneLine()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicyTestData('<-7D>'); // keep
        InsertRetentionPolicyTestData('<-8D>'); // delete

        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyKeepTwoLines()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicyTestData('<-4D>');
        InsertRetentionPolicyTestData('<-2W>');

        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyDeleteTwoLines()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicyTestData('<-4M>');
        InsertRetentionPolicyTestData('<-2M>');

        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsEmpty(RetentionPolicyTestData);
        Assert.AreEqual(0, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]

    [Test]
    procedure TestApplyRetentionPolicySubsetsDeleteOneLineDisabledDisabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        FilterView: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertDisabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertDisabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", FilterView, RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-2W>');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestApplyRetentionPolicySubsetsDeleteOneLineEnabledDisabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        FilterView: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertDisabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", FilterView, RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-2W>');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestApplyRetentionPolicySubsetsDeleteOneLineDisabledEnabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        FilterView: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertDisabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", FilterView, RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-2W>');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestApplyRetentionPolicySubsetsDeleteOneLineEnabledEnabled()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        FilterView: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", FilterView, RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-2W>');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsEmpty(RetentionPolicyTestData);
        Assert.AreEqual(0, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    //[HandlerFunctions('ConfirmYes')]
    procedure TestApplyRetentionPolicySubsetsDiffViews()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset B', RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-3D>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-2W>', 'Subset A'); // delete
        InsertRetentionPolicyTestData('<-5W>', 'Subset A'); // delete
        InsertRetentionPolicyTestData('<-5D>', 'Subset B'); // keep
        InsertRetentionPolicyTestData('<-3W>', 'Subset B'); // keep
        InsertRetentionPolicyTestData('<-6W>', 'Subset B'); // delete

        Assert.AreEqual(6, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
        RetentionPolicyTestData.SetRange(Description, 'Subset B');
        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    //[HandlerFunctions('ConfirmYes')]
    procedure TestRetentionPolicySubsetsSameViews()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-3D>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-5D>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-2W>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-3W>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-5W>', 'Subset A'); // delete
        InsertRetentionPolicyTestData('<-6W>', 'Subset A'); // delete

        Assert.AreEqual(6, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        Assert.AreEqual(4, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestRetentionPolicySubsetsWithConflictsNeverDelete()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));
        InsertOneYearRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));
        InsertNeverDeleteRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-3D>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-5D>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-2W>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-3W>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-5W>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-6W>', 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-2Y>', 'Subset A'); // keep

        Assert.AreEqual(7, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        Assert.AreEqual(7, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestApplyRetentionPolicy1KLines()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        DateFormulaLbl: Label '<-%1D>', Locked = true;
        i: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", '', RetentionPolicyTestData.FieldNo(Description));
        InsertNeverDeleteRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-3D>', ''); // keep
        for i := 1 to 499 do
            InsertRetentionPolicyTestData(StrSubsTNo(DateFormulaLbl, Any.IntegerInRange(10, 365)), ''); // delete
        InsertRetentionPolicyTestData('<-5D>', 'Subset A'); // keep
        for i := 1 to 498 do
            InsertRetentionPolicyTestData(StrSubsTNo(DateFormulaLbl, Any.IntegerInRange(10, 365)), 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-2Y>', 'Subset A'); // keep

        Assert.AreEqual(1000, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        Assert.AreEqual(500, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
        RetentionPolicyTestData.SetRange(Description, '');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestApplyRetentionPolicy20KLines()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        DateFormulaLbl: Label '<-%1D>', Locked = true;
        i: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", '', RetentionPolicyTestData.FieldNo(Description));
        InsertNeverDeleteRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));

        InsertRetentionPolicyTestData('<-3D>', ''); // keep
        for i := 1 to 9999 do
            InsertRetentionPolicyTestData(StrSubsTNo(DateFormulaLbl, Any.IntegerInRange(10, 365)), ''); // delete
        InsertRetentionPolicyTestData('<-5D>', 'Subset A');
        for i := 1 to 9998 do
            InsertRetentionPolicyTestData(StrSubsTNo(DateFormulaLbl, Any.IntegerInRange(10, 365)), 'Subset A'); // keep
        InsertRetentionPolicyTestData('<-2Y>', 'Subset A'); // keep

        Assert.AreEqual(20000, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        Assert.AreEqual(10000, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
        RetentionPolicyTestData.SetRange(Description, '');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyDeleteMaxLinesOneTable()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        i: Integer;
        MaxRecordsToDelete: Integer;
        Buffer: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        MaxRecordsToDelete := 250000;
        Buffer := 1000;
        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));

        For i := 1 to (MaxRecordsToDelete + Buffer) do // must exceed the hardcoded limit by >1k
            InsertRetentionPolicyTestData('<-2M>');

        Assert.AreEqual((MaxRecordsToDelete + Buffer), RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(Buffer, RetentionPolicyTestData.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyDeleteMaxLinesBufferOneTable()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        i: Integer;
        MaxRecordsToDelete: Integer;
        Buffer: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        MaxRecordsToDelete := 250000;
        Buffer := 999;
        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));

        For i := 1 to (MaxRecordsToDelete + Buffer) do // must exceed the hardcoded limit by <1k
            InsertRetentionPolicyTestData('<-2M>');

        Assert.AreEqual(MaxRecordsToDelete + Buffer, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsEmpty(RetentionPolicyTestData);
    end;

    [Test]
    procedure TestApplyRetentionPolicyDeleteMaxLinesTwoTables()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicyTestData3: Record "Retention Policy Test Data 3";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        i: Integer;
        MaxRecordsToDelete: Integer;
        RecordsTableOne: Integer;
        Buffer: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        MaxRecordsToDelete := 250000;
        RecordsTableOne := 150000;
        Buffer := 1000;
        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicySetupTable3(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData3.FieldNo("Datetime Field"));

        For i := 1 to (RecordsTableOne) do
            InsertRetentionPolicyTestData('<-2M>');
        For i := (RecordsTableOne + 1) to (MaxRecordsToDelete + Buffer) do
            InsertRetentionPolicyTestData3('<-2M>');

        Assert.AreEqual(RecordsTableOne, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');
        Assert.AreEqual(MaxRecordsToDelete + Buffer - RecordsTableOne, RetentionPolicyTestData3.Count(), 'Incorrect number of records before applying retention policy');
        Assert.AreEqual(150000, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');
        Assert.AreEqual(101000, RetentionPolicyTestData3.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(false);

        // Verify
        Assert.RecordIsEmpty(RetentionPolicyTestData);
        Assert.RecordIsNotEmpty(RetentionPolicyTestData3);
        Assert.AreEqual(Buffer, RetentionPolicyTestData3.Count(), 'Incorrect number of records after applying retention policy');
    end;

    [Test]
    procedure TestApplyRetentionPolicyDeleteMaxLinesBufferTwoTables()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicyTestData3: Record "Retention Policy Test Data 3";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        i: Integer;
        MaxRecordsToDelete: Integer;
        RecordsTableOne: Integer;
        Buffer: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        MaxRecordsToDelete := 250000;
        RecordsTableOne := 150000;
        Buffer := 999;

        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertRetentionPolicySetupTable3(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData3.FieldNo("Datetime Field"));

        For i := 1 to (RecordsTableOne) do
            InsertRetentionPolicyTestData('<-2M>');
        For i := (RecordsTableOne + 1) to (MaxRecordsToDelete + Buffer) do
            InsertRetentionPolicyTestData3('<-2M>');

        Assert.AreEqual(RecordsTableOne, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');
        Assert.AreEqual(MaxRecordsToDelete + Buffer - RecordsTableOne, RetentionPolicyTestData3.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(false);

        // Verify
        Assert.RecordIsEmpty(RetentionPolicyTestData);
        Assert.RecordIsEmpty(RetentionPolicyTestData3);
    end;

    [Test]
    procedure TestApplyRetentionPolicyTooManyLinesToDeleteOneTableAndReschedule()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        RetentionPolicyTest: Codeunit "Retention Policy Test";
        i: Integer;
        MaxRecordsToDelete: Integer;
        Buffer: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        MaxRecordsToDelete := 250000;
        Buffer := 1500;
        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));

        For i := 1 to (MaxRecordsToDelete + Buffer) do // must exceed the hardcoded limit by >1k
            InsertRetentionPolicyTestData('<-2M>');

        Assert.AreEqual((MaxRecordsToDelete + Buffer), RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        BindSubscription(RetentionPolicyTest);
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsEmpty(RetentionPolicyTestData);
    end;

    [Test]
    procedure TestApplyRetentionPolicyTooManyLinesToDeleteOneTableDontReschedule()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
        i: Integer;
        MaxRecordsToDelete: Integer;
        Buffer: Integer;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        MaxRecordsToDelete := 250000;
        Buffer := 1500;
        ClearTestData();
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupForAllRecords(RetentionPolicySetup, RetentionPeriod, RetentionPolicyTestData.FieldNo("Date Field"));

        For i := 1 to (MaxRecordsToDelete + Buffer) do // must exceed the hardcoded limit by >1k
            InsertRetentionPolicyTestData('<-2M>');

        Assert.AreEqual((MaxRecordsToDelete + Buffer), RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestApplyRetentionPolicyConflictWithBlankFilter()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset D', RetentionPolicyTestData.FieldNo("Description 2"));
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.");

        InsertRetentionPolicyTestData('<-3D>', 'Subset A', 'Subset D'); // keep because of A, D and ''
        InsertRetentionPolicyTestData('<-5D>', 'Subset B', 'Subset D'); // keep because of D and ''
        InsertRetentionPolicyTestData('<-2W>', 'Subset B', 'Subset E'); // keep because of ''
        InsertRetentionPolicyTestData('<-3W>', 'Subset A', 'Subset E'); // keep because of ''
        InsertRetentionPolicyTestData('<-5W>', 'Subset B', 'Subset D'); // delete because of D
        InsertRetentionPolicyTestData('<-6W>', 'Subset A', 'Subset E'); // delete because of A 
        InsertRetentionPolicyTestData('<-2Y>', 'Subset B', 'Subset E'); // delete because of ''

        Assert.AreEqual(7, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(4, RetentionPolicyTestData.Count(), 'Incorrect total number of records after applying retention policy');
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records for Subset A after applying retention policy for Subset A');
        RetentionPolicyTestData.SetRange(Description);
        RetentionPolicyTestData.SetRange("Description 2", 'Subset D');
        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records for Subset D after applying retention policy');
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        RetentionPolicyTestData.SetRange("Description 2", 'Subset E');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records for Subset A, E after applying retention policy');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestApplyRetentionPolicyConflictWithoutBlankFilter()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        ClearTestData();
        InsertEnabledRetentionPolicySetupForSubsets(RetentionPolicySetup, RetentionPolicyTestData.FieldNo("Date Field"));
        InsertOneWeekRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset A', RetentionPolicyTestData.FieldNo(Description));
        InsertOneMonthRetentionPeriod(RetentionPeriod);
        InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, RetentionPolicySetup."Date Field No.", 'Subset D', RetentionPolicyTestData.FieldNo("Description 2"));

        InsertRetentionPolicyTestData('<-3D>', 'Subset A', 'Subset D'); // keep because of A and D
        InsertRetentionPolicyTestData('<-5D>', 'Subset B', 'Subset D'); // keep because of D
        InsertRetentionPolicyTestData('<-2W>', 'Subset B', 'Subset E'); // keep (no policy)
        InsertRetentionPolicyTestData('<-3W>', 'Subset A', 'Subset E'); // delete because of A
        InsertRetentionPolicyTestData('<-5W>', 'Subset B', 'Subset D'); // delete because of D
        InsertRetentionPolicyTestData('<-6W>', 'Subset A', 'Subset E'); // delete because of A
        InsertRetentionPolicyTestData('<-2Y>', 'Subset B', 'Subset E'); // keep (no policy)

        Assert.AreEqual(7, RetentionPolicyTestData.Count(), 'Incorrect number of records before applying retention policy');

        // Exercise
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);

        // Verify
        Assert.RecordIsNotEmpty(RetentionPolicyTestData);
        Assert.AreEqual(4, RetentionPolicyTestData.Count(), 'Incorrect total number of records after applying retention policy');
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        Assert.AreEqual(1, RetentionPolicyTestData.Count(), 'Incorrect number of records for Subset A after applying retention policy for');
        RetentionPolicyTestData.SetRange(Description);
        RetentionPolicyTestData.SetRange("Description 2", 'Subset D');
        Assert.AreEqual(2, RetentionPolicyTestData.Count(), 'Incorrect number of records for Subset D after applying retention policy');
        RetentionPolicyTestData.SetRange(Description, 'Subset A');
        RetentionPolicyTestData.SetRange("Description 2", 'Subset E');
        Assert.RecordIsEmpty(RetentionPolicyTestData);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Apply Retention Policy", 'OnApplyRetentionPolicyRecordLimitExceeded', '', false, false)]
    local procedure ReRerun(CurrTableId: Integer; NumberOfRecordsRemainingToBeDeleted: Integer)
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        ApplyRetentionPolicy: Codeunit "Apply Retention Policy";
    begin
        Commit();
        if NumberOfRecordsRemainingToBeDeleted <= 0 then
            exit;
        RetentionPolicySetup.Get(CurrTableId);
        ApplyRetentionPolicy.ApplyRetentionPolicy(RetentionPolicySetup, false);
    end;

    [ConfirmHandler]
    procedure ConfirmYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    procedure ClearTestData()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicyTestDataTwo: Record "Retention Policy Test Data Two";
        RetentionPolicyTestData3: Record "Retention Policy Test Data 3";
    begin
        RetentionPolicyTestData.DeleteAll(true);
        RetentionPolicyTestDataTwo.DeleteAll(true);
        RetentionPolicyTestData3.DeleteAll(true);
        RetentionPolicySetup.DeleteAll(true);
        RetentionPolicySetupLine.DeleteAll(true);
        RetentionPeriod.DeleteAll(true);
    end;

    local procedure InsertOneWeekRetentionPeriod(var RetentionPeriod: Record "Retention Period")
    begin
        InsertRetentionPeriod(RetentionPeriod, RetentionPeriod."Retention Period"::"1 Week");
    end;

    local procedure InsertOneMonthRetentionPeriod(var RetentionPeriod: Record "Retention Period")
    begin
        InsertRetentionPeriod(RetentionPeriod, RetentionPeriod."Retention Period"::"1 Month");
    end;

    local procedure InsertOneYearRetentionPeriod(var RetentionPeriod: Record "Retention Period")
    begin
        InsertRetentionPeriod(RetentionPeriod, RetentionPeriod."Retention Period"::"1 Year");
    end;

    local procedure InsertNeverDeleteRetentionPeriod(var RetentionPeriod: Record "Retention Period")
    begin
        InsertRetentionPeriod(RetentionPeriod, RetentionPeriod."Retention Period"::"Never Delete");
    end;

    local procedure InsertRetentionPeriod(var RetentionPeriod: Record "Retention Period"; RetentionPeriodEnum: Enum "Retention Period Enum")
    begin
        RetentionPeriod.Code := RetentionPolicyCode(RetentionPeriodEnum);
        RetentionPeriod.Description := Format(RetentionPeriodEnum);
        RetentionPeriod."Retention Period" := RetentionPeriodEnum;
        RetentionPeriod.Insert();
    end;

    local procedure InsertRetentionPolicyTestData(RecordAgeDateFormula: Text)
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
    begin
        RetentionPolicyTestData."Date Field" := CalcDate(RecordAgeDateFormula, Today());
        RetentionPolicyTestData."Description" := CopyStr(Any.AlphabeticText(Any.IntegerInRange(1, MaxStrLen(RetentionPolicyTestData.Description))), 1, MaxStrLen(RetentionPolicyTestData.Description));
        RetentionPolicyTestData.Insert();
    end;

    local procedure InsertRetentionPolicyTestData3(RecordAgeDateFormula: Text)
    var
        RetentionPolicyTestData3: Record "Retention Policy Test Data 3";
    begin
        RetentionPolicyTestData3."Datetime Field" := CreateDateTime(CalcDate(RecordAgeDateFormula, Today()), 120000T);
        RetentionPolicyTestData3."Description" := CopyStr(Any.AlphabeticText(Any.IntegerInRange(1, MaxStrLen(RetentionPolicyTestData3.Description))), 1, MaxStrLen(RetentionPolicyTestData3.Description));
        RetentionPolicyTestData3.Insert();
    end;

    local procedure InsertRetentionPolicyTestData(RecordAgeDateFormula: Text; Description: Text[100])
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
    begin
        RetentionPolicyTestData."Date Field" := CalcDate(RecordAgeDateFormula, Today());
        RetentionPolicyTestData."Description" := Description;
        RetentionPolicyTestData.Insert();
    end;

    local procedure InsertRetentionPolicyTestData(RecordAgeDateFormula: Text; Description: Text[100]; Description2: Text[100])
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
    begin
        RetentionPolicyTestData."Date Field" := CalcDate(RecordAgeDateFormula, Today());
        RetentionPolicyTestData."Description" := Description;
        RetentionPolicyTestData."Description 2" := Description2;
        RetentionPolicyTestData.Insert();
    end;

    local procedure InsertEnabledRetentionPolicySetupForAllRecords(var RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer)
    begin
        InsertRetentionPolicySetup(RetentionPolicySetup, RetentionPeriod, DateFieldNo, true, true);
    end;

    local procedure InsertDisabledRetentionPolicySetupForAllRecords(var RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer)
    begin
        InsertRetentionPolicySetup(RetentionPolicySetup, RetentionPeriod, DateFieldNo, true, false);
    end;

    local procedure InsertEnabledRetentionPolicySetupForSubsets(var RetentionPolicySetup: Record "Retention Policy Setup"; DateFieldNo: Integer)
    var
        RetentionPeriod: Record "Retention Period";
    begin
        InsertRetentionPolicySetup(RetentionPolicySetup, RetentionPeriod, DateFieldNo, false, true);
    end;

    local procedure InsertDisabledRetentionPolicySetupForSubsets(var RetentionPolicySetup: Record "Retention Policy Setup"; DateFieldNo: Integer)
    var
        RetentionPeriod: Record "Retention Period";
    begin
        InsertRetentionPolicySetup(RetentionPolicySetup, RetentionPeriod, DateFieldNo, false, false);
    end;

    local procedure InsertRetentionPolicySetup(var RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer; ApplyToAllRecords: Boolean; Enabled: Boolean)
    begin
        RetentionPolicySetup."Table ID" := Database::"Retention Policy Test Data";
        RetentionPolicySetup."Retention Period" := RetentionPeriod.Code;
        RetentionPolicySetup."Date Field No." := DateFieldNo;
        RetentionPolicySetup."Apply to all records" := ApplyToAllRecords;
        RetentionPolicySetup.Enabled := Enabled;
        RetentionPolicySetup.Insert();
    end;

    local procedure InsertRetentionPolicySetupTable3(var RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer)
    begin
        RetentionPolicySetup."Table ID" := Database::"Retention Policy Test Data 3";
        RetentionPolicySetup."Retention Period" := RetentionPeriod.Code;
        RetentionPolicySetup."Date Field No." := DateFieldNo;
        RetentionPolicySetup."Apply to all records" := true;
        RetentionPolicySetup.Enabled := true;
        RetentionPolicySetup.Insert();
    end;

    local procedure InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer)
    begin
        InsertRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, DateFieldNo, '', 0, true);
    end;

    local procedure InsertEnabledRetentionPolicySetupLine(RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer; DescriptionFilter: Text; DescriptionFieldNo: Integer)
    begin
        InsertRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, DateFieldNo, DescriptionFilter, DescriptionFieldNo, true);
    end;

    local procedure InsertDisabledRetentionPolicySetupLine(RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer; DescriptionFilter: Text; DescriptionFieldNo: Integer)
    begin
        InsertRetentionPolicySetupLine(RetentionPolicySetup, RetentionPeriod, DateFieldNo, DescriptionFilter, DescriptionFieldNo, false);
    end;

    local procedure InsertRetentionPolicySetupLine(var RetentionPolicySetup: Record "Retention Policy Setup"; RetentionPeriod: Record "Retention Period"; DateFieldNo: Integer; DescriptionFilter: Text; DescriptionFieldNo: Integer; Enabled: Boolean)
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        FilterView: Text;
        FilterViewLbl: Label 'WHERE(Field%1=1(%2))', Locked = true;
    begin
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table ID");
        if RetentionPolicySetupLine.FindLast() then;

        RetentionPolicySetupLine."Table ID" := RetentionPolicySetup."Table ID";
        RetentionPolicySetupLine."Line No." += 10000;
        RetentionPolicySetupLine."Retention Period" := RetentionPeriod.Code;
        RetentionPolicySetupLine."Date Field No." := DateFieldNo;
        RetentionPolicySetupLine.Enabled := Enabled;

        FilterView := StrSubstNo(FilterViewLbl, DescriptionFieldNo, DescriptionFilter);
        LibraryVariableStorage.AssertEmpty();
        LibraryVariableStorage.Enqueue(FilterView);
        RetentionPolicySetupLine.SetTableFilter();

        RetentionPolicySetupLine.Insert();
    end;

    [FilterPageHandler]
    procedure RetentionPolicyFilterPageHandler(var RecordRef: RecordRef): Boolean
    var
        FilterView: Text;
    begin
        FilterView := LibraryVariableStorage.DequeueText();

        RecordRef.SetView(FilterView);
        exit(true);
    end;

    local procedure RetentionPolicyCode(RetentionPeriod: Variant) RetentionPolicyCode: Code[20]
    begin
        RetentionPolicyCode := CopyStr(UpperCase(Format(RetentionPeriod)), 1, MaxStrLen(RetentionPolicyCode))
    end;

    local procedure FixViewsTimeZoneIssueMaxRange(InDate: Date): Date
    begin
#pragma warning disable AA0217
        exit(ParseDateOutOfViewRange(StrSubstNo('WHERE(Field2000000001=1(..%1))', InDate)))
#pragma warning restore
    end;

    local procedure FixViewsTimeZoneIssueMinRange(InDate: Date): Date
    begin
#pragma warning disable AA0217
        exit(ParseDateOutOfViewRange(StrSubstNo('WHERE(Field2000000001=1(%1..))', InDate)))
#pragma warning restore
    end;

    local procedure ParseDateOutOfViewRange(ViewText: Text) OutDate: Date
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
    begin
        RetentionPolicyTestData.SetView(ViewText);
        ViewText := RetentionPolicyTestData.GetView(false);
        Evaluate(OutDate, ViewText.Substring(ViewText.LastIndexOf('T') - 10, 10));
    end;

    local procedure SingleDateViewTimeRange(InDate: Date): Text
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        ViewText: Text;
    begin
#pragma warning disable AA0217
        RetentionPolicyTestData.SetView(StrSubstNo('WHERE(Field2000000001=1(%1))', InDate));
#pragma warning restore
        ViewText := RetentionPolicyTestData.GetView(false);
        exit(ViewText.Substring(ViewText.LastIndexOf('(') + 1, 42))
    end;
}