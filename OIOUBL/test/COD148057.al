// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148057 "OIOUBL Export Document"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun();
    begin
        // [FEATURE] [OIOUBL]
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OIOUBL-Management", 'OnBeforeExportFile', '', false, false)]
    local procedure ManagementOnBeforeExportFile(var OutputBlob: Record TempBlob; var IsExported: Boolean)
    begin
        // Doing something else with the blob
        IsExported := true;
    end;
}