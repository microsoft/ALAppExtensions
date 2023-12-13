// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GeneralLedger.Reports;

codeunit 31329 "Gen. Jnl. Template Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnBeforeValidateEvent', 'Force Doc. Balance', false, false)]
    local procedure TestNotCheckDocTypeCZLOnBeforeValidateForceDocBalance(var Rec: Record "Gen. Journal Template")
    begin
        if not Rec."Force Doc. Balance" then
            Rec.TestField("Not Check Doc. Type CZL", false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure UpdateTestReportIdOnAfterValidateType(var Rec: Record "Gen. Journal Template")
    begin
        Rec."Test Report ID" := Report::"General Journal - Test CZL";
    end;
}
