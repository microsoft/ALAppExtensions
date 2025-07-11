// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

tableextension 13406 "Intrastat Report Setup FI" extends "Intrastat Report Setup"
{
    fields
    {
        field(13406; "Custom Code"; Text[2])
        {
            Caption = 'Custom Code';
            DataClassification = CustomerContent;
        }
        field(13407; "Company Serial No."; Text[3])
        {
            Caption = 'Company Serial No.';
            DataClassification = CustomerContent;
        }
        field(13408; "Last Transfer Date"; Date)
        {
            Caption = 'Last Transfer Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13409; "File No."; Code[3])
        {
            Caption = 'File No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}