// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

enum 18084 "Registration Type"
{
    Extensible = true;
    value(0; GSTIN)
    {
        Caption = 'GSTIN';
    }
    value(1; UID)
    {
        Caption = 'UID';
    }
    value(2; GID)
    {
        Caption = 'GID';
    }
}
