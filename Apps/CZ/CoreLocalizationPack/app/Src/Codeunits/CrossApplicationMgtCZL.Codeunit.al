// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using System.Reflection;

codeunit 31419 "Cross Application Mgt. CZL"
{
    procedure CollectSuggestedApplication(CollectedFor: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        DummyVariant: Variant;
    begin
        exit(CollectSuggestedApplication(CollectedFor, DummyVariant, CrossApplicationBufferCZL));
    end;

    procedure CollectSuggestedApplication(CollectedFor: Variant; CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        DataTypeManagement: Codeunit "Data Type Management";
        CollectedForRecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(CollectedFor, CollectedForRecRef) then
            exit(false);

        Clear(CrossApplicationBufferCZL);
        OnCollectSuggestedApplication(CollectedForRecRef.Number, CollectedFor, CalledFrom, CrossApplicationBufferCZL);
        CrossApplicationBufferCZL.ExcludeDocument(CalledFrom);
        exit(not CrossApplicationBufferCZL.IsEmpty());
    end;

    procedure CalcSuggestedAmountToApply(CollectedFor: Variant): Decimal
    var
        CrossApplicationBufferCZL: Record "Cross Application Buffer CZL";
    begin
        CollectSuggestedApplication(CollectedFor, CrossApplicationBufferCZL);
        CrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(CrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownSuggestedAmountToApply(CollectedFor: Variant)
    var
        CrossApplicationBufferCZL: Record "Cross Application Buffer CZL";
    begin
        CollectSuggestedApplication(CollectedFor, CrossApplicationBufferCZL);
        Page.Run(Page::"Cross Application CZL", CrossApplicationBufferCZL);
    end;

    procedure SetAppliesToID(AppliesToID: Code[50])
    begin
        OnSetAppliesToID(AppliesToID);
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetAppliesToID(AppliesToID: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCollectSuggestedApplication(CollectedForTableID: Integer; CollectedFor: Variant; CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    begin
    end;
}