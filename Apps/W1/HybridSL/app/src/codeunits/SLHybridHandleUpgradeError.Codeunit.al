// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

codeunit 47015 "SL Hybrid Handle Upgrade Error"
{
    Access = Internal;
    TableNo = "Hybrid Replication Summary";

    trigger OnRun()
    begin
        MarkUpgradeFailed(Rec);
    end;

    internal procedure MarkUpgradeFailed(var HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        FailureMessageOutStream: OutStream;
    begin
        HybridCompanyStatus.Get(CompanyName);
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Failed;
        HybridCompanyStatus."Upgrade Failure Message".CreateOutStream(FailureMessageOutStream);
        FailureMessageOutStream.Write(GetLastErrorText());
        HybridCompanyStatus.Modify();
        Commit();

        HybridReplicationSummary.Find();
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeFailed;
        HybridReplicationSummary.Modify();
    end;
}