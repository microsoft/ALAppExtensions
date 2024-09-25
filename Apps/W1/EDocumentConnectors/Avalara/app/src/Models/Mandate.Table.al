// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

/// <summary>
/// Model of Avalara Mandate
/// https://developer.avalara.com/api-reference/e-invoicing/einvoice/models/Mandate/
/// </summary>
table 6371 Mandate
{
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Country Mandate"; Code[50])
        {
            Caption = 'Country Mandate';
        }
        field(2; "Country Code"; Code[20])
        {
            Caption = 'Country Mandate';
        }
        field(3; "Description"; Text[2048])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Country Mandate")
        {
            Clustered = true;
        }
    }
}