// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoData.Finance;
using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.Dimension;
using Microsoft.FixedAssets.FixedAsset;

codeunit 5614 "Create FA Dimension Value"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDimension: Codeunit "Contoso Dimension";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
        CreateFixedAsset: Codeunit "Create Fixed Asset";
    begin
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000010(), CreateDimension.DepartmentDimension(), CreateDimensionValue.AdministrationDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000020(), CreateDimension.DepartmentDimension(), CreateDimensionValue.AdministrationDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000030(), CreateDimension.DepartmentDimension(), CreateDimensionValue.ProductionDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000040(), CreateDimension.DepartmentDimension(), CreateDimensionValue.ProductionDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000050(), CreateDimension.DepartmentDimension(), CreateDimensionValue.ProductionDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000060(), CreateDimension.DepartmentDimension(), CreateDimensionValue.ProductionDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000070(), CreateDimension.DepartmentDimension(), CreateDimensionValue.ProductionDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000080(), CreateDimension.DepartmentDimension(), CreateDimensionValue.ProductionDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::"Fixed Asset", CreateFixedAsset.FA000090(), CreateDimension.DepartmentDimension(), CreateDimensionValue.AdministrationDepartment(), Enum::"Default Dimension Value Posting Type"::" ");
    end;
}
