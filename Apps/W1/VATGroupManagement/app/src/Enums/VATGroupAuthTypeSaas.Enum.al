// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

enum 4705 "VAT Group Auth Type Saas"
{
#if not CLEAN25
    value(0; WebServiceAccessKey)
    {
        Caption = 'Web Service Access Key';
        ObsoleteState = Pending;
        ObsoleteReason = 'OAuth2 is the only authentication option for making a Business Central API call.';
        ObsoleteTag = '25.0';
    }
#endif
    value(1; OAuth2)
    {
        Caption = 'OAuth2';
    }
}