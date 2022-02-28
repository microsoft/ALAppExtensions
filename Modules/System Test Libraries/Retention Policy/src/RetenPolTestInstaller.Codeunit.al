// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AA0235
codeunit 138704 "Reten. Pol. Test Installer"
#pragma warning restore AA0235
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        RetentionPolicyTestData: Record "Retention Policy Test Data";
        RetentionPolicyTestData3: Record "Retention Policy Test Data 3";
        RetentionPolicyTestData4: Record "Retention Policy Test Data 4";
        RetentionPeriod: Record "Retention Period";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        RecordRef: RecordRef;
        RetPeriodCalc: DateFormula;
        TableFilters: JsonArray;
    begin
        // this installer will set up test data.

        // table with and without minimum retention
        RetenPolAllowedTables.AddAllowedTable(Database::"Retention Policy Test Data", RetentionPolicyTestData.FieldNo("DateTime Field"), 7); // 7 day min retention);
        RetenPolAllowedTables.AddAllowedTable(Database::"Retention Policy Test Data 3", RetentionPolicyTestData3.FieldNo("Date Field"), 0); // No min retention days

        // negative test
        RetenPolAllowedTables.AddAllowedTable(3900, 0); // Retention Period -> should fail, don't own table

        RetentionPolicyTestData4.SetRange(Description, 'A', 'Z');
        RecordRef.GetTable(RetentionPolicyTestData4);
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RetentionPeriod."Retention Period"::"1 Week", RetentionPolicyTestData4.FieldNo(SystemCreatedAt), false, true, RecordRef);

        RetentionPolicyTestData4.SetRange(Description, 'E', 'Q');
        RecordRef.GetTable(RetentionPolicyTestData4);
        Evaluate(RetPeriodCalc, '<-14D>');
        RetenPolAllowedTables.AddTableFilterToJsonArray(TableFilters, RetPeriodCalc, RetentionPolicyTestData4.FieldNo("DateTime Field"), false, false, RecordRef);
        RetenPolAllowedTables.AddAllowedTable(Database::"Retention Policy Test Data 4", TableFilters);
    end;
}