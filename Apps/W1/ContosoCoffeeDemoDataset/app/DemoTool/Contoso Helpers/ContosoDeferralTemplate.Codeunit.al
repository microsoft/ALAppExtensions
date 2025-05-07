// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.Deferral;

codeunit 5390 "Contoso Deferral Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Deferral Template" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;


    procedure InsertDeferralTemplate("Deferral Code": Code[10]; Description: Text[100]; "Deferral Account": Code[20]; "Deferral %": Decimal; "Calc. Method": Enum "Deferral Calculation Method"; "Start Date": Enum "Deferral Calculation Start Date"; "No. of Periods": Integer; "Period Description": Text[100])
    var
        DeferralTemplate: Record "Deferral Template";
        Exists: Boolean;
    begin
        if DeferralTemplate.Get("Deferral Code") then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DeferralTemplate.Validate("Deferral Code", "Deferral Code");
        DeferralTemplate.Validate(Description, Description);
        DeferralTemplate.Validate("Deferral Account", "Deferral Account");
        DeferralTemplate.Validate("Deferral %", "Deferral %");
        DeferralTemplate.Validate("Calc. Method", "Calc. Method");
        DeferralTemplate.Validate("Start Date", "Start Date");
        DeferralTemplate.Validate("No. of Periods", "No. of Periods");
        DeferralTemplate.Validate("Period Description", "Period Description");

        if Exists then
            DeferralTemplate.Modify(true)
        else
            DeferralTemplate.Insert(true);
    end;
}
