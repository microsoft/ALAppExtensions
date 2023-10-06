// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

table 18811 "TCS Nature Of Collection"
{
    Caption = 'TCS Nature Of Collection';
    DataCaptionFields = Code, Description;
    LookupPageId = "TCS Nature of Collections";
    DrillDownPageId = "TCS Nature of Collections";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Description"; text[30])
        {
            DataClassification = CustomerContent;
        }
        field(3; "TCS On Recpt. Of Pmt."; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; code)
        {
            Clustered = true;
        }
    }
}
