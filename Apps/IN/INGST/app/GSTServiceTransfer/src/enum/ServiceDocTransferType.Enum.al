// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

enum 18351 "Service Doc Transfer Type"
{
    Extensible = true;
    value(0; "Service Transfer Shipment")
    {
        Caption = 'Service Transfer Shipment';
    }
    value(1; "Service Transfer Receipt")
    {
        Caption = 'Service Transfer Receipt';
    }
}
