// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Common;

using Microsoft.Purchases.Vendor;

tableextension 6362 "E-Doc. Ext. Vendor" extends Vendor
{
    fields
    {
        field(6360; "Service Participant Id"; Text[100])
        {
            Caption = 'Service Participant Id';
            DataClassification = CustomerContent;
        }
    }
}