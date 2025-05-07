// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Dimension;

codeunit 5663 "Create Purchase Dim. Value"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDimension: Codeunit "Contoso Dimension";
        CreateVendor: Codeunit "Create Vendor";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.ExportFabrikam(), CreateDimension.AreaDimension(), CreateDimensionValue.AmericaNorthArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.ExportFabrikam(), CreateDimension.BusinessGroupDimension(), CreateDimensionValue.IndustrialBusinessGroup(), Enum::"Default Dimension Value Posting Type"::" ");
        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.ExportFabrikam(), CreateDimension.SalesCampaignDimension(), CreateDimensionValue.SummerSalesCampaign(), Enum::"Default Dimension Value Posting Type"::" ");

        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.DomesticFirstUp(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthNonEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");

        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.EUGraphicDesign(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");

        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.DomesticWorldImporter(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthNonEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.DomesticWorldImporter(), CreateDimension.BusinessGroupDimension(), CreateDimensionValue.HomeBusinessGroup(), Enum::"Default Dimension Value Posting Type"::"Same Code");

        ContosoDimension.InsertDefaultDimensionValue(Database::Vendor, CreateVendor.DomesticNodPublisher(), CreateDimension.AreaDimension(), CreateDimensionValue.EuropeNorthNonEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory");
    end;
}
