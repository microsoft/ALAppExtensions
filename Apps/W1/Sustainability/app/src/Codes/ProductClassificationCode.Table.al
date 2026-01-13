// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sustainability.Codes;

table 6320 "Product Classification Code"
{
    Caption = 'Product Classification';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;


    fields
    {
        field(1; Code; Code[50])
        {
            Caption = 'Code';
            ToolTip = 'Specifies the unique external classification code.';
            DataClassification = CustomerContent;
        }
        field(2; Type; Enum "Product Classification Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies the classification system, such as HS, CPV, or UNSPSC.';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[250])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the descriptive name of the classification code.';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[500])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a detailed description of the classification code.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code, Type)
        {
            Clustered = true;
        }
    }

}