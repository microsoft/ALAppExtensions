// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 136641 "C5 Bulk-Fix Errors Test"
{
    // [FEATURE] [C5 Data Migration]
    Subtype=Test;
    TestPermissions = Disabled;

    var
        Assert : Codeunit Assert;
        C5MigrationTypeTxt: Label 'C5 2012', Locked = true;
        Error1: Label 'Error 1', Locked = true;
        Error2: Label 'Error 2', Locked = true;
        MigrateEntitiesAgainQst: Label	'Do you want to migrate the updated entities?\\If you do, remember to refresh the %1 page so you can follow the progress.', Comment = '%1 = caption of page Data Migration overview';
        C5CustTableError1: Record "C5 CustTable";
        C5CustTableError2: Record "C5 CustTable";

    [Test]
    [HandlerFunctions('HandleCustListAsModalPage,HandleQuestion')]
    procedure TestBulkFixErrors()
    var
        C5CustTable: Record "C5 CustTable";
        DataMigrationError: Record "Data Migration Error";
        DataMigrationErrorPage : TestPage "Data Migration Error";
        I: Integer;
    begin
        // [SCENARIO] The bulk edit button leads to opening of list page and closing it issues a confirmation to migrate
        // [GIVEN] Create 10 customer entities, 2 of which have an error
        C5CustTable.DeleteAll();
        for I := 1 to 10 do begin
            CreateCustTable(C5CustTable,I);
        end;

        DataMigrationError.DeleteAll();
        C5CustTableError1.Get(3);
        CreateDataMigrationError(C5CustTableError1, Error1);
        C5CustTableError2.Get(7);
        CreateDataMigrationError(C5CustTableError2, Error2);

        // [GIVEN] Open the Data Migration Error page
        DataMigrationErrorPage.Trap();
        Commit();
        Page.Run(Page::"Data Migration Error");

        // [WHEN] Click on the bulk edit
        DataMigrationErrorPage.BulkFixErrors.Invoke();

        // [THEN] Check that only two records are shown - in the modal page handler

        // [THEN] A confirmation message to migrate is issued- tested by handler function
    end;

    local procedure CreateCustTable(var C5CustTable: Record "C5 CustTable"; NewRecId : Integer)
    begin
        C5CustTable.Init();
        C5CustTable.RecId := NewRecId;
        C5CustTable.Account := FORMAT(NewRecId);
        C5CustTable.Insert();
    end;

    local procedure CreateDataMigrationError(C5CustTable : Record "C5 CustTable"; ErrorMessage : Text[250])
    var 
        DataMigrationError: Record "Data Migration Error";
    begin
        DataMigrationError.Init();
        DataMigrationError."Migration Type" := C5MigrationTypeTxt;
        DataMigrationError."Destination Table ID" := Database::Customer;
        DataMigrationError."Source Staging Table Record ID" := C5CustTable.RecordId();
        DataMigrationError."Error Message" := ErrorMessage;
        DataMigrationError.Insert();
    end;

    [ModalPageHandler]
    procedure HandleCustListAsModalPage(var C5CustTableList: TestPage "C5 CustTable List")
    begin
        C5CustTableList.First();
        Assert.AreEqual(Error1,C5CustTableList."Error Message".Value(),'Wrong error message in first record or wrong number of records shown');
        Assert.AreEqual(C5CustTableError1.Account,C5CustTableList.Account.Value(),'Wrong account in first record');
        Assert.IsFalse(C5CustTableList."Error Message".Enabled(), 'Error message should not be editable');
        Assert.IsTrue(C5CustTableList.Account.Enabled(), 'Fields on the record should be editable');
        C5CustTableList.Next();
        Assert.AreEqual(Error2,C5CustTableList."Error Message".Value(),'Wrong error message in second record or wrong number of records shown');
        Assert.AreEqual(C5CustTableError2.Account,C5CustTableList.Account.Value(),'Wrong account in second record');
        Assert.IsFalse(C5CustTableList."Error Message".Enabled(), 'Error message should not be editable');
        Assert.IsTrue(C5CustTableList.Account.Enabled(), 'Fields on the record should be editable');
        Assert.IsFalse(C5CustTableList.Next(),'Only two records should be shown as they have errors');
    end;

    [ConfirmHandler]
    procedure HandleQuestion(Question : Text[1024];VAR Reply : Boolean);
    var
        DataMigrationOverview: Page "Data Migration Overview";
    begin
        Assert.AreEqual(StrSubstNo(MigrateEntitiesAgainQst,DataMigrationOverview.Caption()), Question, 'Wrong confirmation handler');
        Reply := false;
    end;
}