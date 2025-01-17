// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.D365Sales;

tableextension 6617 "FS CRM Product" extends "CRM Product"
{
    fields
    {
        field(12000; FieldServiceProductType; Option)
        {
            Caption = 'Field Service Product Type';
            Description = 'Field Service Type of product.';
            ExternalName = 'msdyn_fieldserviceproducttype';
            ExternalType = 'Picklist';
            OptionCaption = 'Inventory,Service,Non-Inventory';
            OptionOrdinalValues = 690970000, 690970002, 690970001;
            OptionMembers = Inventory,Service,"Non-Inventory";
            DataClassification = SystemMetadata;
        }
    }
}