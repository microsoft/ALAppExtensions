// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;

codeunit 5122 "Create FA Maintenance"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertMaintenance(Service(), ServiceNameLbl);
        ContosoFixedAsset.InsertMaintenance(SpareParts(), SparePartsNameLbl);
    end;

    procedure Service(): Code[10]
    begin
        exit(ServiceLbl);
    end;

    procedure SpareParts(): Code[10]
    begin
        exit(SparePartsLbl);
    end;

    var
        ServiceLbl: Label 'SERVICE', MaxLength = 10;
        ServiceNameLbl: Label 'Service', MaxLength = 100;
        SparePartsLbl: Label 'SPAREPARTS', MaxLength = 10;
        SparePartsNameLbl: Label 'Spare Parts', MaxLength = 100;
}
