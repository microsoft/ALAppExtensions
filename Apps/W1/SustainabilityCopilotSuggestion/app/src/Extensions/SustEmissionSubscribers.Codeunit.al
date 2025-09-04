// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Account;

codeunit 6296 "Sust. Emission Subscribers"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Sustain. Account Subcategory", OnAfterValidateEvent, 'Emission Factor CO2', false, false)]
    local procedure OnAfterValidateEmissionFactorCO2(var Rec: Record "Sustain. Account Subcategory"; var xRec: Record "Sustain. Account Subcategory"; CurrFieldNo: Integer)
    begin
        if Rec."Emission Factor CO2" = xRec."Emission Factor CO2" then
            exit;

        if CurrFieldNo <> Rec.FieldNo("Emission Factor CO2") then
            exit;

        Rec."Calculated by Copilot" := false;
        Rec."Emission Factor Source" := '';
    end;
}