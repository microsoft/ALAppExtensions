// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

table 6122 "E-Doc. Service Supported Type"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "E-Document Service Code"; Code[20])
        {
            TableRelation = "E-Document Service";
            Caption = 'E-Document Service Code';
        }
        field(2; "Source Document Type"; Enum "E-Document Type")
        {
            Caption = 'Source Document Type';
        }
    }

    keys
    {
        key(Key1; "E-Document Service Code", "Source Document Type")
        {
            Clustered = true;
        }
    }
}