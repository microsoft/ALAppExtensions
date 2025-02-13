// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

table 6375 "Company"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Company Name"; Text[250])
        {
            Caption = 'Company Name';
        }
        field(3; "Company Id"; Text[250])
        {
            Caption = 'Company Id';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}