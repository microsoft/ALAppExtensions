// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Setup;

tableextension 27030 "DIOT Purch. & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(27030; "Default Vendor DIOT Type"; Enum "DIOT Type of Operation")
        {
            Caption = 'Default Vendor DIOT Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Default Vendor DIOT Type" = Enum::"DIOT Type of Operation"::"Lease and Rent" then
                    Message(LeaseAndRentMsg);
            end;
        }
    }

    var
        LeaseAndRentMsg: Label 'Non-Mexican vendors cannot have Lease and Rent as their DIOT operation type. This default will only work for MX vendors. The rest will have their type changed to Others.';
}
