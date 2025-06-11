// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 27031 "DIOT Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("DIOT Type of Operation"; Rec."DIOT Type of Operation")
            {
                ApplicationArea = BasicMX;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type to be used for all documents with this vendor.';
            }
            field("Tax Effects Applied"; Rec."Tax Effects Applied")
            {
                ApplicationArea = BasicMX;
                ToolTip = 'Specifies whether tax effects are applied to the invoices related to transactions with the vendor.';
                Description = 'Manifiesto que se dio efectos fiscales a los comprobantes que amparan las operaciones realizadas con el proveedor.';
            }
            field("Tax Jurisdiction Location"; Rec."Tax Jurisdiction Location")
            {
                ApplicationArea = BasicMX;
                Caption = 'Tax Jurisdiction Location';
                ToolTip = 'Specifies the tax jurisdiction location for the vendor.';
            }
        }
    }
}
