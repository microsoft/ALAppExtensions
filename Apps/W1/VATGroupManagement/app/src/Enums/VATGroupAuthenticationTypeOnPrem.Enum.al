#if not CLEANSCHEMA25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

#pragma warning disable AL0659
enum 4700 "VAT Group Authentication Type OnPrem"
#pragma warning restore
{
    ObsoleteReason = 'Replaced by "VAT Group Auth Type OnPrem" as the name exceeds 30 characters.';
#pragma warning disable AS0074
    ObsoleteTag = '25.0';
#pragma warning restore AS0074
    ObsoleteState = Pending;

    value(0; WebServiceAccessKey)
    {
        Caption = 'Web Service Access Key';
    }
    value(1; OAuth2)
    {
        Caption = 'OAuth2';
    }
    value(2; WindowsAuthentication)
    {
        Caption = 'Windows Authentication';
    }
}
#endif