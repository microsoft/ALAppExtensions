// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

codeunit 4000 "Hybrid Cloud Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany();
    var
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        HybridCueSetupManagement.InsertDataForReplicationSuccessRateCue();
    end;
}