// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 136630 "C5 Run All Tests"
{
  trigger OnRun();
  var
    C5CustTableMigratorTest: Codeunit "C5 CustTable Migrator Tst";
    C5DataLoaderTests: Codeunit "C5 Data Loader Tests";
    C5DataMigrationWizardTest: Codeunit "C5 Data Migr. Wizard Test";
    C5HelperFunctionTest: Codeunit "C5 Helper Functions Test";
    C5ItemMigratorTest: Codeunit "C5 Item Migrator Test";
    C5LedTableMigratorTest: Codeunit "C5 LedTable Migrator Test";
    C5SchemaReaderTests: Codeunit "C5 Schema Reader Tests";
    C5VendTableMigratorTest: Codeunit "C5 VendTable Migrator Tst";
    C5CustomSchemaTest: Codeunit "C5 Custom Schema Test";
    C5LedTransMigratorTest: Codeunit "C5 LedTrans Migrator Test";
    C5BulkFixErrorsTest: Codeunit "C5 Bulk-Fix Errors Test";
  begin
    C5CustTableMigratorTest.Run();
    C5DataLoaderTests.Run();
    C5DataMigrationWizardTest.Run();
    C5HelperFunctionTest.Run();
    C5ItemMigratorTest.Run();
    C5LedTableMigratorTest.Run();
    C5SchemaReaderTests.Run();
    C5VendTableMigratorTest.Run();
    C5CustomSchemaTest.Run();
    C5LedTransMigratorTest.Run();
    C5BulkFixErrorsTest.Run();
  end;
}