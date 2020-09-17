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

    procedure NextSubscribedSKU(): Boolean
    var
        MembershipEntitlement: Record "Membership Entitlement";
        TempSubscribedSku: DotNet SkuInfo;
        TempServicePlanEnumerator: DotNet IEnumerator;
        FoundKnownPlan: Boolean;
    begin
        if not IsInitialized then begin
            if not ResetSubscribedSKU() then
                exit(false);

            IsInitialized := true;
        end;

        MembershipEntitlement.SetRange(Type, MembershipEntitlement.Type::"Azure AD Plan");

        TempSubscribedSku := SubscribedSku;
        TempServicePlanEnumerator := ServicePlanEnumerator;

        if SubscribedSkuEnumerator.MoveNext() then begin
            SubscribedSku := SubscribedSkuEnumerator.Current();
            ServicePlanEnumerator := SubscribedSku.ServicePlans().GetEnumerator();

            if not DoIncludeUnknownPlans then begin
                FoundKnownPlan := false;
                while NextServicePlan() do begin
                    MembershipEntitlement.SetFilter(ID, LowerCase(ServicePlanId()));
                    if MembershipEntitlement.Count() > 0 then
                        FoundKnownPlan := true
                    else begin
                        MembershipEntitlement.SetFilter(ID, UpperCase(ServicePlanId()));
                        if MembershipEntitlement.Count() > 0 then
                            FoundKnownPlan := true;
                    end;
                end;

                if not FoundKnownPlan then begin
                    SubscribedSku := TempSubscribedSku;
                    ServicePlanEnumerator := TempServicePlanEnumerator;
                    exit(NextSubscribedSKU());
                end;

                ServicePlanEnumerator.Reset();
            end;

            exit(true);
        end;

        exit(false)
    end;

    procedure SubscribedSKUCapabilityStatus(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.CapabilityStatus());
    end;

    procedure SubscribedSKUConsumedUnits(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.ConsumedUnits());
    end;

    procedure SubscribedSKUObjectId(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.ObjectId());
    end;

    procedure SubscribedSKUPrepaidUnitsInEnabledState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Enabled());
    end;

    procedure SubscribedSKUPrepaidUnitsInSuspendedState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Suspended());
    end;

    procedure PrepaidUnitsInWarningState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Warning());
    end;

    procedure SubscribedSKUId(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.SkuId());
    end;

    procedure SubscribedSKUPartNumber(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.SkuPartNumber());
    end;

    procedure ResetServicePlans()
    begin
        if not IsNull(ServicePlanEnumerator) then
            ServicePlanEnumerator.Reset();
    end;

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

    procedure ServicePlanCapabilityStatus(): Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        exit(ServicePlan.CapabilityStatus());
    end;

    procedure ServicePlanId() FoundServicePlanId: Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        FoundServicePlanId := ServicePlan.ServicePlanId();
        if StrLen(FoundServicePlanId) > 2 then
            FoundServicePlanId := CopyStr(FoundServicePlanId, 2, StrLen(FoundServicePlanId) - 2);
    end;

    procedure ServicePlanName(): Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        exit(ServicePlan.ServicePlanName());
    end;

    procedure IncludeUnknownPlans(): Boolean
    begin
        exit(DoIncludeUnknownPlans);
    end;

    procedure SetIncludeUnknownPlans(IncludeUnknownPlans: Boolean)
    begin
        DoIncludeUnknownPlans := IncludeUnknownPlans;
    end;

    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADGraph.SetTestInProgress(TestInProgress);
    end;
}

