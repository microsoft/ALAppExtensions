// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

table 10500 "Postcode Notif. Memory"
{
    Caption = 'Postcode Notification Memory';
    DataClassification = CustomerContent;

    fields
    {
        field(1; UserId; Code[50])
        {
            Caption = 'UserId';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; UserId)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
