// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 138701 "Reten. Policy Setup Test"
{
    Subtype = Test;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        MinExpirationDateErr: Label 'The expiration date for this retention policy must be equal to or before %1.', Comment = '%1 = Date';
        RetentionPolicySetupLineLockedErr: Label 'The retention policy setup for table %1, %2 has mandatory filters that cannot be modified.', Comment = '%1 = table number, %2 = table caption';
        RetenPolSetupRenameErr: Label 'You cannot rename retention policy setup records. Table ID %1. Renamed to %2.', Comment = '%1, %2 = table number';
        RetenPolSetupLineRenameErr: Label 'You cannot rename retention policy setup line records. Table ID %1. Renamed to %2.', Comment = '%1, %2 = table number';

    trigger OnRun()
    begin

    end;

    [Test]
    procedure TestGetEmptyRetentionPolicyLineFilterView()
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicy: Codeunit "Retention Policy Setup";
        FilterView: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";

        // Exercise
        FilterView := RetentionPolicy.GetTableFilterView(RetentionPolicySetupLine);

        // Verify
        Assert.AreEqual('', FilterView, 'Filter should be empty');
    end;

    [Test]
    procedure TestGetEmptyRetentionPolicyLineFilterText()
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicy: Codeunit "Retention Policy Setup";
        FilterText: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";

        // Exercise
        FilterText := RetentionPolicy.GetTableFilterText(RetentionPolicySetupLine);

        // Verify
        Assert.AreEqual('', FilterText, 'Filter should be empty');
    end;

    [HandlerFunctions('EmptyFilterPageHandler')]
    [Test]
    procedure TestSetEmptyRetentionPolicyLineFilterView()
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicy: Codeunit "Retention Policy Setup";
        FilterView: Text;
        FilterText: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";

        // Exercise
        FilterText := RetentionPolicy.SetTableFilterView(RetentionPolicySetupLine);
        FilterView := RetentionPolicy.GetTableFilterView(RetentionPolicySetupLine);

        // Verify
        Assert.AreEqual('', FilterText, 'FilterText should be empty');
        Assert.AreEqual('', FilterView, 'FilterView should be empty');
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestSetRetentionPolicyLineFilterView()
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicy: Codeunit "Retention Policy Setup";
        WhereFilterTxt: Label 'WHERE(Field%1=1(..%2), Field%3=1(%4))', Locked = true;
        DescriptionTxt: Label 'some description', Locked = true;
        ExpectedFilterTxt: Label '%1: ..%2, %3: %4', Locked = true;
        ExpectedFilterViewTxt: Label 'VERSION(1) SORTING(Field1) WHERE(Field%1=1(..%2),Field%3=1(%4))', Locked = true;
        FilterView: Text;
        FilterText: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";
        LibraryVariableStorage.AssertEmpty();
        LibraryVariableStorage.Enqueue(StrSubstNo(WhereFilterTxt, RetentionPolicyTestData.FieldNo("Date Field"), Today(), RetentionPolicyTestData.FieldNo(Description), DescriptionTxt));

        // Exercise
        FilterText := RetentionPolicy.SetTableFilterView(RetentionPolicySetupLine);
        FilterView := RetentionPolicy.GetTableFilterView(RetentionPolicySetupLine);

        // Verify
        Assert.AreEqual(StrSubstNo(ExpectedFilterTxt, RetentionPolicyTestData.FieldCaption("Date Field"), Today(), RetentionPolicyTestData.FieldCaption(Description), DescriptionTxt), FilterText, 'FilterText doesn''t match'); // 'Date Field: ..14-04-20'
        Assert.AreEqual(StrSubstNo(ExpectedFilterViewTxt, RetentionPolicyTestData.FieldNo("Date Field"), Format(Today(), 0, 9), RetentionPolicyTestData.FieldNo(Description), DescriptionTxt), FilterView, 'FilterView doesn''t match'); // 'Date Field: ..2020-04-14'
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestSetRetentionPolicyLineFilterViewDateTimeField()
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicy: Codeunit "Retention Policy Setup";
        UseDateTime: DateTime;
        WhereFilterTxt: Label 'WHERE(Field%1=1(..%2), Field%3=1(%4))', Locked = true;
        DescriptionTxt: Label 'some description', Locked = true;
        ExpectedFilterTxt: Label '%1: ..%2, %3: %4', Locked = true;
        ExpectedFilterViewTxt: Label 'VERSION(1) SORTING(Field1) WHERE(Field%1=1(..%2),Field%3=1(%4))', Locked = true;
        FilterView: Text;
        FilterText: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        UseDateTime := CurrentDateTime();
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";
        LibraryVariableStorage.AssertEmpty();
        LibraryVariableStorage.Enqueue(StrSubstNo(WhereFilterTxt, RetentionPolicyTestData.FieldNo("DateTime Field"), Format(UseDateTime, 0, 1), RetentionPolicyTestData.FieldNo(Description), DescriptionTxt));

        // Exercise
        FilterText := RetentionPolicy.SetTableFilterView(RetentionPolicySetupLine);
        FilterView := RetentionPolicy.GetTableFilterView(RetentionPolicySetupLine);

        // Verify
        Assert.AreEqual(StrSubstNo(ExpectedFilterTxt, RetentionPolicyTestData.FieldCaption("DateTime Field"), Format(UseDateTime, 0, 1), RetentionPolicyTestData.FieldCaption(Description), DescriptionTxt), FilterText, 'FilterText doesn''t match'); // 'Date Field: ..14-04-20 12:34:56.789'
        Assert.AreEqual(StrSubstNo(ExpectedFilterViewTxt, RetentionPolicyTestData.FieldNo("DateTime Field"), Format(UseDateTime, 0, 9), RetentionPolicyTestData.FieldNo(Description), DescriptionTxt), FilterView, 'FilterView doesn''t match'); // 'Date Field: ..2020-04-14T10:34:56.789Z'
    end;

    [HandlerFunctions('RetentionPolicyFilterPageHandler')]
    [Test]
    procedure TestClearRetentionPolicyLineFilterView()
    var
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicy: Codeunit "Retention Policy Setup";
        WhereOlderFilterTxt: Label 'WHERE(Field%1=1(..%2))', Locked = true;
        EmptyFilterViewTxt: Label '', Locked = true;
        ExpectedFilterTxt: Label '%1: ..%2', Locked = true;
        FilterView: Text;
        FilterText: Text;
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";
        LibraryVariableStorage.AssertEmpty();
        LibraryVariableStorage.Enqueue(StrSubstNo(WhereOlderFilterTxt, RetentionPolicyTestData.FieldNo("Date Field"), Today()));
        FilterText := RetentionPolicy.SetTableFilterView(RetentionPolicySetupLine);
        Assert.AreEqual(StrSubstNo(ExpectedFilterTxt, RetentionPolicyTestData.FieldCaption("Date Field"), Today()), FilterText, 'FilterText doesn''t match'); // 'Date Field: ..14-04-20'

        // Exercise
        LibraryVariableStorage.AssertEmpty();
        LibraryVariableStorage.Enqueue(EmptyFilterViewTxt);
        FilterText := RetentionPolicy.SetTableFilterView(RetentionPolicySetupLine);
        FilterView := RetentionPolicy.GetTableFilterView(RetentionPolicySetupLine);

        // Verify
        Assert.AreEqual('', FilterText, 'FilterText should be empty');
        Assert.AreEqual('', FilterView, 'FilterView should be empty');
    end;

    [Test]
    procedure TestOnDeleteRetentionPolicySetup()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        RetentionPolicySetup.DeleteAll(true);
        RetentionPolicySetupLine.DeleteAll(true);
        // setup
        RetentionPolicySetup."Table ID" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";
        RetentionPolicySetupLine."Line No." := 10000;
        RetentionPolicySetupLine.Insert();
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";
        RetentionPolicySetupLine."Line No." := 20000;
        RetentionPolicySetupLine.Insert();
        RetentionPolicySetupLine."Table ID" := Database::"Retention Period";
        RetentionPolicySetupLine."Line No." := 10000;
        RetentionPolicySetupLine.Insert();

        // exercise
        RetentionPolicySetup.Delete(True);

        // verify
        Assert.IsFalse(RetentionPolicySetupLine.Get(Database::"Retention Policy Test Data", 10000), 'Record should not exist');
        Assert.IsFalse(RetentionPolicySetupLine.Get(Database::"Retention Policy Test Data", 20000), 'Record should not exist');
        Assert.IsTrue(RetentionPolicySetupLine.Get(Database::"Retention Period", 10000), 'Record should exist')
    end;

    [Test]
    procedure TestOnDeleteRetentionPolicySetupTemp()
    var
        TempRetentionPolicySetup: Record "Retention Policy Setup" temporary;
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        RetentionPolicySetup.DeleteAll(true);
        RetentionPolicySetupLine.DeleteAll(true);
        // setup
        TempRetentionPolicySetup."Table ID" := Database::"Retention Policy Test Data";
        TempRetentionPolicySetup.Insert();
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";
        RetentionPolicySetupLine."Line No." := 10000;
        RetentionPolicySetupLine.Insert();
        RetentionPolicySetupLine."Table ID" := Database::"Retention Policy Test Data";
        RetentionPolicySetupLine."Line No." := 20000;
        RetentionPolicySetupLine.Insert();
        RetentionPolicySetupLine."Table ID" := Database::"Retention Period";
        RetentionPolicySetupLine."Line No." := 10000;
        RetentionPolicySetupLine.Insert();

        // exercise
        TempRetentionPolicySetup.Delete(True);

        // verify
        Assert.IsTrue(RetentionPolicySetupLine.Get(Database::"Retention Policy Test Data", 10000), 'Record should exist');
        Assert.IsTrue(RetentionPolicySetupLine.Get(Database::"Retention Policy Test Data", 20000), 'Record should exist');
        Assert.IsTrue(RetentionPolicySetupLine.Get(Database::"Retention Period", 10000), 'Record should exist')
    end;

    [Test]
    procedure TestMandatoryMinimumRetentionDaysRetenPolPass()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        RetentionPeriod.Validate(Code, Format(RetentionPeriod."Retention Period"::"1 Week"));
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::"1 Week");
        RetentionPeriod.Insert();
        RetentionPolicySetup.Validate("Table Id", Database::"Retention Policy Test Data");

        // exercise
        ClearLastError();
        AssertError
        begin
            RetentionPolicySetup.Validate("Retention Period", RetentionPeriod.Code);
            Error('');
        end;

        // verify
        Assert.ExpectedError('');
    end;

    [Test]
    procedure TestMandatoryMinimumRetentionDaysRetenPolFail()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        RetentionPeriod.Validate(Code, UpperCase(Any.AlphabeticText(MaxStrLen(RetentionPeriod.Code))));
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::"Custom");
        Evaluate(RetentionPeriod."Ret. Period Calculation", '<-6D>');
        RetentionPeriod.Insert();
        RetentionPolicySetup.Validate("Table Id", Database::"Retention Policy Test Data");

        // exercise
        ClearLastError();
        AssertError
            RetentionPolicySetup.Validate("Retention Period", RetentionPeriod.Code);

        // verify
        Assert.ExpectedError(StrSubstNo(MinExpirationDateErr, CalcDate('<-7D>', Today())));
    end;

    [Test]
    procedure TestMandatoryMinimumRetentionDaysRetenPolLinePass()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        RetentionPeriod.Validate(Code, Format(RetentionPeriod."Retention Period"::"1 Week"));
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::"1 Week");
        RetentionPeriod.Insert();
        RetentionPolicySetupLine.Validate("Table Id", Database::"Retention Policy Test Data");

        // exercise
        ClearLastError();
        AssertError
        begin
            RetentionPolicySetupLine.Validate("Retention Period", RetentionPeriod.Code);
            Error('');
        end;

        // verify
        Assert.ExpectedError('');
    end;


    [Test]
    procedure TestMandatoryMinimumRetentionDaysRetenPolLineFail()
    var
        RetentionPeriod: Record "Retention Period";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        RetentionPeriod.Validate(Code, UpperCase(Any.AlphabeticText(MaxStrLen(RetentionPeriod.Code))));
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::"Custom");
        Evaluate(RetentionPeriod."Ret. Period Calculation", '<-6D>');
        RetentionPeriod.Insert();
        RetentionPolicySetupLine.Validate("Table Id", Database::"Retention Policy Test Data");

        // exercise
        ClearLastError();
        AssertError
            RetentionPolicySetupLine.Validate("Retention Period", RetentionPeriod.Code);

        // verify
        Assert.ExpectedError(StrSubstNo(MinExpirationDateErr, CalcDate('<-7D>', Today())));
    end;

    [Test]
    procedure TestDeleteLockedRetentionPolicySetupLine()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine."Table ID" := RetentionPolicySetup."Table Id";
        RetentionPolicySetupLine.Locked := true;
        RetentionPolicySetupLine.Insert();
        RetentionPolicySetupLine.CalcFields("Table Caption");

        // Exercise
        AssertError RetentionPolicySetupLine.Delete();

        // Verify
        Assert.ExpectedError(StrSubstNo(RetentionPolicySetupLineLockedErr, RetentionPolicySetupLine."Table ID", RetentionPolicySetupLine."Table Caption"));
    end;

    [Test]
    procedure TestDeleteLockedRetentionPolicySetupWithLockedLine()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine."Table ID" := RetentionPolicySetup."Table Id";
        RetentionPolicySetupLine.Locked := true;
        RetentionPolicySetupLine.Insert();
        RetentionPolicySetupLine.CalcFields("Table Caption");
        ClearLastError();

        // Exercise
        AssertError
        begin
            RetentionPolicySetup.Delete();
            error('');
        end;

        // Verify
        Assert.ExpectedError('');
    end;

    [Test]
    procedure TestModifyLockedRetentionPolicySetupLine()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine."Table ID" := RetentionPolicySetup."Table Id";
        RetentionPolicySetupLine.Locked := true;
        RetentionPolicySetupLine.Insert();
        RetentionPolicySetupLine.CalcFields("Table Caption");

        // Exercise
        RetentionPolicySetupLine.Locked := false;
        AssertError RetentionPolicySetupLine.Modify();

        // Verify
        Assert.ExpectedError(StrSubstNo(RetentionPolicySetupLineLockedErr, RetentionPolicySetupLine."Table ID", RetentionPolicySetupLine."Table Caption"));
    end;

    [Test]
    procedure TestRenameLockedRetentionPolicySetupLine()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine."Table ID" := RetentionPolicySetup."Table Id";
        RetentionPolicySetupLine.Locked := true;
        RetentionPolicySetupLine.Insert();

        // Exercise
        AssertError RetentionPolicySetupLine.Rename(Database::"Retention Policy Test Data 3", RetentionPolicySetupLine."Line No.");

        // Verify
        Assert.ExpectedError(StrSubstNo(RetenPolSetupLineRenameErr, Database::"Retention Policy Test Data", Database::"Retention Policy Test Data 3"));
    end;

    [Test]
    procedure TestRenameRetentionPolicySetup()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // Setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.Insert();

        // Exercise
        AssertError RetentionPolicySetup.Rename(Database::"Retention Policy Test Data 3");

        // Verify
        Assert.ExpectedError(StrSubstNo(RetenPolSetupRenameErr, Database::"Retention Policy Test Data", Database::"Retention Policy Test Data 3"));
    end;

    [Test]
    procedure TestRetentionPolicySetupLineWithMandatoryFilters()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPolicyTestData4: Record "Retention Policy Test Data 4";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        // setup is handled by installer:
        RetentionPolicySetup.SetRange("Table Id", Database::"Retention Policy Test Data 4");
        RetentionPolicySetup.DeleteAll(true);
        RetentionPolicySetup.Reset();
        // Retention Policy Test Data 4 is set up with 2 mandatory filters

        // exercise
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data 4";
        RetentionPolicySetup.Insert();

        // verify
        // line1
        RetentionPolicySetupLine.Get(RetentionPolicySetup."Table Id", 10000);
        Assert.IsTrue(RetentionPolicySetupLine.IsLocked(), 'The line should be locked');
        Assert.IsTrue(RetentionPolicySetupLine.Enabled, 'The line should be enabled');
        Assert.AreNotEqual(RetentionPolicySetupLine."Retention Period", '', 'The retention period field must not be blank');
        Assert.AreEqual(RetentionPolicySetupLine."Date Field No.", RetentionPolicySetupLine.FieldNo(SystemCreatedAt), 'The date field number must be 2000000001');
        RetentionPolicyTestData4.SetRange(Description, 'A', 'Z');
        Assert.AreEqual(RetentionPolicySetupLine.GetTableFilterView(), RetentionPolicyTestData4.GetView(false), 'The table filter is wrong');
        // line2
        RetentionPolicySetupLine.Get(RetentionPolicySetup."Table Id", 20000);
        Assert.IsFalse(RetentionPolicySetupLine.IsLocked(), 'The line should not be locked');
        Assert.IsFalse(RetentionPolicySetupLine.Enabled, 'The line should not be enabled');
        Assert.AreNotEqual(RetentionPolicySetupLine."Retention Period", '', 'The retention period field must not be blank');
        Assert.AreEqual(RetentionPolicySetupLine."Date Field No.", RetentionPolicyTestData4.FieldNo("DateTime Field"), 'The date field number must be 3');
        RetentionPolicyTestData4.SetRange(Description, 'E', 'Q');
        Assert.AreEqual(RetentionPolicySetupLine.GetTableFilterView(), RetentionPolicyTestData4.GetView(false), 'The table filter is wrong');
    end;

    [Test]
    procedure TestRetentionPolicySetupLineWithoutMandatoryFilters()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        // most setup is handled by installer:
        RetentionPolicySetup.SetRange("Table Id", Database::"Retention Policy Test Data");
        RetentionPolicySetup.DeleteAll(true);
        RetentionPolicySetup.Reset();
        RetentionPolicySetupLine.SetRange("Table Id", Database::"Retention Policy Test Data");
        RetentionPolicySetupLine.DeleteAll(true);
        RetentionPolicySetupLine.Reset();
        // Retention Policy Test Data is set up without mandatory filters

        // exercise
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data";
        RetentionPolicySetup.Insert();

        // verify
        RetentionPolicySetupLine.SetRange("Table ID", RetentionPolicySetup."Table Id");
        Assert.RecordIsEmpty(RetentionPolicySetupLine);
    end;

    [Test]
    procedure TestOnDeleteRetentionPolicySetupLineWithMandatoryFilters()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        RetentionPolicySetup.DeleteAll(true); // delete setup + lines + locked lines
        RetentionPolicySetupLine.DeleteAll(true); // delete orphaned lines
        // setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data 4";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine.SetRange("Table ID", Database::"Retention Policy Test Data 4");
#pragma warning disable AA0210 // The table Retention Policy Setup Line does not contain a key with the field Locked.
        RetentionPolicySetupLine.SetRange(Locked, true);
        // #pragma warning enable AA0210
        RetentionPolicySetupLine.FindFirst();

        // exercise
        AssertError RetentionPolicySetupLine.Delete();

        // verify
        Assert.ExpectedError('The retention policy setup for table 138703, Retention Policy Test Data 4 has mandatory filters that cannot be modified.');

        // exercise
        RetentionPolicySetup.Delete(true);

        // verify
        RetentionPolicySetupLine.Reset();
        RetentionPolicySetupLine.Setrange("Table ID", Database::"Retention Policy Test Data 4");
        Assert.RecordIsEmpty(RetentionPolicySetupLine);
    end;

    [Test]
    procedure TestDeleteRetentionPeriodWithLockedLine()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPeriod: Record "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        RetentionPolicySetup.DeleteAll(true); // delete setup + lines + locked lines
        RetentionPolicySetupLine.DeleteAll(true); // delete orphaned lines
        // setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data 4";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine.SetRange("Table ID", Database::"Retention Policy Test Data 4");
#pragma warning disable AA0210 // The table Retention Policy Setup Line does not contain a key with the field Locked.
        RetentionPolicySetupLine.SetRange(Locked, true);
        // #pragma warning enable AA0210
        RetentionPolicySetupLine.FindFirst();

        // exercise
        RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period");
        AssertError RetentionPeriod.Delete();

        // verify
        Assert.ExpectedError('You cannot delete the retention period');
    end;

    [Test]
    procedure TestModifyRetentionPeriodWithLockedLine()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPeriod: Record "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        RetentionPolicySetup.DeleteAll(true); // delete setup + lines + locked lines
        RetentionPolicySetupLine.DeleteAll(true); // delete orphaned lines
        // setup
        RetentionPolicySetup."Table Id" := Database::"Retention Policy Test Data 4";
        RetentionPolicySetup.Insert();
        RetentionPolicySetupLine.SetRange("Table ID", Database::"Retention Policy Test Data 4");
#pragma warning disable AA0210 // The table Retention Policy Setup Line does not contain a key with the field Locked.
        RetentionPolicySetupLine.SetRange(Locked, true);
        // #pragma warning enable AA0210
        RetentionPolicySetupLine.FindFirst();

        // exercise
        RetentionPeriod.Get(RetentionPolicySetupLine."Retention Period");
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::Custom);
        Evaluate(RetentionPeriod."Ret. Period Calculation", '<-2D>');
        AssertError RetentionPeriod.Modify();

        // verify
        Assert.ExpectedError('You cannot modify the retention period');
    end;

    [Test]
    procedure TestValidateRetentionPeriodNeverDeleteWithMinRetentionDays()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
        RetentionPolicySetupLine: Record "Retention Policy Setup Line";
        RetentionPeriod: Record "Retention Period";
    begin
        PermissionsMock.Set('Retention Pol. Admin');
        // setup
        RetentionPolicySetup.DeleteAll(true); // delete setup + lines + locked lines
        RetentionPolicySetupLine.DeleteAll(true); // delete orphaned lines
        RetentionPeriod.DeleteAll(true);

        RetentionPeriod.Code := CopyStr(UpperCase(Format(RetentionPeriod."Retention period"::"Never Delete")), 1, MaxStrLen(RetentionPeriod.Code));
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention period"::"Never Delete");
        RetentionPeriod.Insert();

        RetentionPolicySetup.Validate("Table Id", Database::"Retention Policy Test Data");
        RetentionPolicySetup.Insert(true);

        // exercise
        ClearLastError();
        RetentionPolicySetup.validate("Retention Period", RetentionPeriod.Code);

        // verify
        // no error
        Assert.AreEqual('', GetLastErrorText(), 'No error was expected');
    end;

    [FilterPageHandler]
    procedure EmptyFilterPageHandler(var RecordRef: RecordRef): Boolean
    begin
        exit(true);
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
}