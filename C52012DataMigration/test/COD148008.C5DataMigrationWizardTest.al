// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148008 "C5 Data Migr. Wizard Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        C5DataMigratorDescTxt: Label 'Import from Microsoft Dynamics C5 2012';

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    [Test]
    procedure TestC5DataMigrationWizardFlow()
    var
        DataMigrationWizard: TestPage 1808;
    begin
        // [SCENARIO] Import from C5 is available when extension is installed and the wizard can complete

        // [WHEN] The data migration wizard is run
        DataMigrationWizard.Trap();
        Page.RUN(Page::"Data Migration Wizard");

        // [THEN] C5 data migrator is registered
        // TODO: The following section makes the compiler crash. Hence it's disabled for now. ETA: September
        // with DataMigrationWizard do
        // begin
        // ActionNext.INVOKE; // To: Choose Data Source page
        // Description.LOOKUP; // Lookup to different data migrations tools
        // Description.SETVALUE(C5DataMigratorDescTxt);
        // ActionNext.INVOKE; // To: Instructions & Settings
        // ActionNext.INVOKE; // To: Import your data
        // TODO: Handle File Dialog / Inject test file and avoid dialog
        // ActionApply.INVOKE; // To: That's it page
        // ActionFinish.INVOKE;
        // end;
    end;
}
