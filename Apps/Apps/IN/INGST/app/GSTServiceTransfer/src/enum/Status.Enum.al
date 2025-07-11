// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

enum 18350 Status
{
    Extensible = true;
    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Shipped)
    {
        Caption = 'Shipped';
    }
}
