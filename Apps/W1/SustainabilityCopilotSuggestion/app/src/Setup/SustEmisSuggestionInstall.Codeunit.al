// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

codeunit 6292 "Sust. Emis. Suggestion Install"
{
    Access = Internal;
    Subtype = Install;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnInstallAppPerCompany()
    var
        SustainabilityImp: Codeunit "Sust. Emis. Suggestion Impl.";
    begin
        SustainabilityImp.RegisterCapability();
    end;
}