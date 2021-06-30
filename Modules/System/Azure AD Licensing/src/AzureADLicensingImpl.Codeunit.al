// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 460 "Azure AD Licensing Impl."
{
    Access = Internal;

    var
        AzureADGraph: Codeunit "Azure AD Graph";
        SubscribedSkuEnumerator: DotNet IEnumerator;
        SubscribedSku: DotNet SkuInfo;
        ServicePlanEnumerator: DotNet IEnumerator;
        ServicePlan: DotNet ServicePlanInfo;
        DoIncludeUnknownPlans: Boolean;
        IsInitialized: Boolean;

    [NonDebuggable]
    procedure ResetSubscribedSKU(): Boolean
    var
        SubscribedSkus: DotNet GenericIEnumerable1;
    begin
        if IsNull(SubscribedSkuEnumerator) then begin
            AzureADGraph.GetDirectorySubscribedSkus(SubscribedSkus);

            if IsNull(SubscribedSkus) then
                exit(false);

            SubscribedSkuEnumerator := SubscribedSkus.GetEnumerator()
        end else
            SubscribedSkuEnumerator.Reset();

        exit(true);
    end;

    [NonDebuggable]
    procedure NextSubscribedSKU(): Boolean
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        TempSubscribedSku: DotNet SkuInfo;
        TempServicePlanEnumerator: DotNet IEnumerator;
        FoundKnownPlan: Boolean;
    begin
        if not IsInitialized then begin
            if not ResetSubscribedSKU() then
                exit(false);

            IsInitialized := true;
        end;

        if not SubscribedSkuEnumerator.MoveNext() then
            exit(false);
        SubscribedSku := SubscribedSkuEnumerator.Current();
        ServicePlanEnumerator := SubscribedSku.ServicePlans().GetEnumerator();

        if DoIncludeUnknownPlans then
            exit(true);

        TempSubscribedSku := SubscribedSku;
        TempServicePlanEnumerator := ServicePlanEnumerator;

        FoundKnownPlan := false;
        while NextServicePlan() do
            if AzureADPlan.IsBCServicePlan(ServicePlanId()) then begin
                FoundKnownPlan := true;
                break;
            end;

        if not FoundKnownPlan then begin
            SubscribedSku := TempSubscribedSku;
            ServicePlanEnumerator := TempServicePlanEnumerator;
            exit(NextSubscribedSKU());
        end;

        ServicePlanEnumerator.Reset();

        exit(true);
    end;

    [NonDebuggable]
    procedure SubscribedSKUCapabilityStatus(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.CapabilityStatus());
    end;

    [NonDebuggable]
    procedure SubscribedSKUConsumedUnits(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.ConsumedUnits());
    end;

    [NonDebuggable]
    procedure SubscribedSKUObjectId(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.ObjectId());
    end;

    [NonDebuggable]
    procedure SubscribedSKUPrepaidUnitsInEnabledState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Enabled());
    end;

    [NonDebuggable]
    procedure SubscribedSKUPrepaidUnitsInSuspendedState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Suspended());
    end;

    [NonDebuggable]
    procedure PrepaidUnitsInWarningState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Warning());
    end;

    [NonDebuggable]
    procedure SubscribedSKUId(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.SkuId());
    end;

    [NonDebuggable]
    procedure SubscribedSKUPartNumber(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.SkuPartNumber());
    end;

    [NonDebuggable]
    procedure ResetServicePlans()
    begin
        if not IsNull(ServicePlanEnumerator) then
            ServicePlanEnumerator.Reset();
    end;

    [NonDebuggable]
    procedure NextServicePlan(): Boolean
    begin
        if IsNull(ServicePlanEnumerator) then
            exit(false);

        if ServicePlanEnumerator.MoveNext() then begin
            ServicePlan := ServicePlanEnumerator.Current();
            exit(true);
        end;

        exit(false);
    end;

    [NonDebuggable]
    procedure ServicePlanCapabilityStatus(): Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        exit(ServicePlan.CapabilityStatus());
    end;

    [NonDebuggable]
    procedure ServicePlanId() FoundServicePlanId: Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        FoundServicePlanId := ServicePlan.ServicePlanId();
        if StrLen(FoundServicePlanId) > 2 then
            FoundServicePlanId := CopyStr(FoundServicePlanId, 2, StrLen(FoundServicePlanId) - 2);
    end;

    [NonDebuggable]
    procedure ServicePlanName(): Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        exit(ServicePlan.ServicePlanName());
    end;

    [NonDebuggable]
    procedure IncludeUnknownPlans(): Boolean
    begin
        exit(DoIncludeUnknownPlans);
    end;

    [NonDebuggable]
    procedure SetIncludeUnknownPlans(IncludeUnknownPlans: Boolean)
    begin
        DoIncludeUnknownPlans := IncludeUnknownPlans;
    end;

    [NonDebuggable]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADGraph.SetTestInProgress(TestInProgress);
    end;
}

