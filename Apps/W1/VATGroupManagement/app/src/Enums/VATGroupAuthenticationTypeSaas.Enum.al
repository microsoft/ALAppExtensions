// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

#if not CLEAN22
#pragma warning disable AL0659 
enum 4702 "VAT Group Authentication Type Saas"
#pragma warning restore
{
    ObsoleteReason = 'Replaced by "VAT Group Auth Type Saas" as the name exceeds 30 characters.';
    ObsoleteTag = '22.0';
    ObsoleteState = Pending;

    value(0; WebServiceAccessKey)
    {
        Caption = 'Web Service Access Key';
    }
    value(1; OAuth2)
    {
        Caption = 'OAuth2';
    }
}
#endif