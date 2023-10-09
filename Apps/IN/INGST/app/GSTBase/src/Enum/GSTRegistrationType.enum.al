// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18053 "GST Registration Type"
{
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
