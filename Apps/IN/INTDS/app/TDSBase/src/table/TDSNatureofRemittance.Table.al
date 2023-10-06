// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

table 18690 "TDS Nature Of Remittance"
{
    Caption = 'TDS Nature of Remittance';
    DrillDownPageId = "TDS Nature of Remittances";
    LookupPageId = "TDS Nature of Remittances";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
