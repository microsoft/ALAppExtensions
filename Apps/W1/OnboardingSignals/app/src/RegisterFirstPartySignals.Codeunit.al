// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20373 "Register First Party Signals"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        RegisterFirstPartySignals();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    begin
        RegisterFirstPartySignals();
    end;

    internal procedure RegisterFirstPartySignals()
    var
        Company: Record Company;
        OnboardingSignal: Codeunit "Onboarding Signal";
        EnvironmentInfo: Codeunit "Environment Information";
        OnboardingSignalType: Enum "Onboarding Signal Type";
    begin
        if not Company.Get(CompanyName()) then
            exit;

        if Company."Evaluation Company" then
            exit;

        if EnvironmentInfo.IsSandbox() then
            exit;

        OnboardingSignal.RegisterNewOnboardingSignal(Company.Name, OnboardingSignalType::"Purchase Invoice");
        OnboardingSignal.RegisterNewOnboardingSignal(Company.Name, OnboardingSignalType::"Sales Invoice");
        OnboardingSignal.RegisterNewOnboardingSignal(Company.Name, OnboardingSignalType::"Customer Payments");
        OnboardingSignal.RegisterNewOnboardingSignal(Company.Name, OnboardingSignalType::"Vendor Payments");
    end;
}
