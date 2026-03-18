// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

codeunit 40018 "Fix Data OnRun Completed"
{
    TableNo = "Replication Run Completed Arg";

    trigger OnRun()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.RepairCompanionTableRecordConsistency();
        Commit();

        SelectLatestVersion();
    end;
}