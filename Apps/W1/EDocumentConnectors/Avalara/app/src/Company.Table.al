#if not CLEAN26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

#pragma warning disable AS0130
#pragma warning disable AS0115
#pragma warning disable AS0072
#pragma warning disable PTE0025
table 6375 "Company"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    ObsoleteReason = 'This temporary table is replaced by 6373 "Avalara Company"';
    ObsoleteTag = '26.0';
    ObsoleteState = Removed;

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

#pragma warning restore AS0130
#pragma warning restore PTE0025
#pragma warning restore AS0072
#pragma warning restore AS0115
#endif