// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 149113 "BCPT Open RoleCenter SOP"
{
    // Test codeunits can only run in foreground (UI)
    Subtype = Test;

    trigger OnRun();
    var
        SOPRC: testpage "SO Processor Activities";
    begin
        SOPRC.OpenView();
        SOPRC.Close();
    end;
}