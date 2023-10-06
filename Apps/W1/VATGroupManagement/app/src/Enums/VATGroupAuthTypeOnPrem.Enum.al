// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

enum 4704 "VAT Group Auth Type OnPrem"
{
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