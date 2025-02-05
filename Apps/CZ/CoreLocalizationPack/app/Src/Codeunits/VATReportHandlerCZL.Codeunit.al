// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment.Configuration;

codeunit 31174 "VAT Report Handler CZL"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"VAT Report Header", 'OnAfterInitRecord', '', false, false)]
    local procedure ValidateVATReportVersionOnAfterInitRecord(var VATReportHeader: Record "VAT Report Header")
    begin
        VATReportHeader.Validate("VAT Report Version");
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Report Header", 'OnBeforeTestOriginalReportNo', '', false, false)]
    local procedure SkipTestForVATReturnOnBeforeTestOriginalReportNo(VATReportHeader: Record "VAT Report Header"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        IsHandled := VATReportHeader."VAT Report Config. Code" = "VAT Report Configuration"::"VAT Return";
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure EnableOnInitializingNotificationWithDefaultState()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReturnPeriod: Record "VAT Return Period";
    begin
        VATReturnPeriod.SetDueDateForVATReportNotificationDefaultState();
        VATReportHeader.SetOnlyStandardVATReportInPeriodNotificationDefaultStateCZL();
    end;
}