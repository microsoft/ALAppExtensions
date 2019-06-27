// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 460 "Azure AD Licensing Impl."
{
    Access = Internal;

    var
        GraphClient: DotNet GraphQuery;
        SubscribedSkuEnumerator: DotNet IEnumerator;
        SubscribedSku: DotNet SkuInfo;
        ServicePlanEnumerator: DotNet IEnumerator;
        ServicePlan: DotNet ServicePlanInfo;
        DoIncludeUnknownPlans: Boolean;

    [Scope('OnPrem')]
    procedure ResetSubscribedSKU()
    begin
        if IsNull(GraphClient) then
            Initialize();

        if IsNull(SubscribedSkuEnumerator) then
            SubscribedSkuEnumerator := GraphClient.GetDirectorySubscribedSkus().GetEnumerator()
        else
            SubscribedSkuEnumerator.Reset();
    end;

    [Scope('OnPrem')]
    procedure NextSubscribedSKU(): Boolean
    var
        MembershipEntitlement: Record "Membership Entitlement";
        TempSubscribedSku: DotNet SkuInfo;
        TempServicePlanEnumerator: DotNet IEnumerator;
        FoundKnownPlan: Boolean;
    begin
        if IsNull(GraphClient) then
            ResetSubscribedSKU();

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

    [Scope('OnPrem')]
    procedure SubscribedSKUCapabilityStatus(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.CapabilityStatus());
    end;

    [Scope('OnPrem')]
    procedure SubscribedSKUConsumedUnits(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.ConsumedUnits());
    end;

    [Scope('OnPrem')]
    procedure SubscribedSKUObjectId(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.ObjectId());
    end;

    [Scope('OnPrem')]
    procedure SubscribedSKUPrepaidUnitsInEnabledState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Enabled());
    end;

    [Scope('OnPrem')]
    procedure SubscribedSKUPrepaidUnitsInSuspendedState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Suspended());
    end;

    [Scope('OnPrem')]
    procedure PrepaidUnitsInWarningState(): Integer
    begin
        if IsNull(SubscribedSku) then
            exit(0);

        exit(SubscribedSku.PrepaidUnits().Warning());
    end;

    [Scope('OnPrem')]
    procedure SubscribedSKUId(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.SkuId());
    end;

    [Scope('OnPrem')]
    procedure SubscribedSKUPartNumber(): Text
    begin
        if IsNull(SubscribedSku) then
            exit('');

        exit(SubscribedSku.SkuPartNumber());
    end;

    [Scope('OnPrem')]
    procedure ResetServicePlans()
    begin
        if not IsNull(ServicePlanEnumerator) then
            ServicePlanEnumerator.Reset();
    end;

    [Scope('OnPrem')]
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

    [Scope('OnPrem')]
    procedure ServicePlanCapabilityStatus(): Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        exit(ServicePlan.CapabilityStatus());
    end;

    [Scope('OnPrem')]
    procedure ServicePlanId() FoundServicePlanId: Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        FoundServicePlanId := ServicePlan.ServicePlanId();
        if StrLen(FoundServicePlanId) > 2 then
            FoundServicePlanId := CopyStr(FoundServicePlanId, 2, StrLen(FoundServicePlanId) - 2);
    end;

    [Scope('OnPrem')]
    procedure ServicePlanName(): Text
    begin
        if IsNull(ServicePlan) then
            exit('');

        exit(ServicePlan.ServicePlanName());
    end;

    [Scope('OnPrem')]
    procedure IncludeUnknownPlans(): Boolean
    begin
        exit(DoIncludeUnknownPlans);
    end;

    [Scope('OnPrem')]
    procedure SetIncludeUnknownPlans(IncludeUnknownPlans: Boolean)
    begin
        DoIncludeUnknownPlans := IncludeUnknownPlans;
    end;

    local procedure Initialize()
    var
        AzureADLicensing: Codeunit "Azure AD Licensing";
    begin
        AzureADLicensing.OnInitialize(GraphClient);
        if IsNull(GraphClient) then
            GraphClient := GraphClient.GraphQuery();
    end;
}

