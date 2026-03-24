// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Manufacturing;

using Microsoft.DemoData.Common;
using Microsoft.DemoTool.Helpers;

codeunit 4764 "Create Mfg Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ManufacturingDemoDataSetup: Record "Manufacturing Module Setup";
        CommonLocation: Codeunit "Create Common Location";
        ContosoWarehouse: Codeunit "Contoso Warehouse";
    begin
        ManufacturingDemoDataSetup.Get();

        if ManufacturingDemoDataSetup."Manufacturing Location" = '' then
            ManufacturingDemoDataSetup.Validate("Manufacturing Location", CommonLocation.MainLocation());

        ContosoWarehouse.InsertLocation(SubcontractingLocation(), SubcontractingLocationNameLbl, '', false);

        if ManufacturingDemoDataSetup."Subcontracting Location" = '' then
            ManufacturingDemoDataSetup.Validate("Subcontracting Location", SubcontractingLocation());

        ManufacturingDemoDataSetup.Modify();
    end;

    var
        SubcontractingLocationNameLbl: Label 'Subcontracting', MaxLength = 100;

    procedure SubcontractingLocation(): Code[10]
    begin
        exit('82000');
    end;
}
