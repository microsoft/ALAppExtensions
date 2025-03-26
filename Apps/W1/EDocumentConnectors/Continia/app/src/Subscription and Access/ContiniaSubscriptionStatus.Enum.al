// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

enum 6395 "Continia Subscription Status"
{
    Access = Internal;
    Extensible = false;

    value(0; NotSubscribed)
    {
        Caption = 'Not Subscribed';
    }
    value(1; Subscription)
    {
        Caption = 'Subscription';
    }
    value(2; Unsubscribed)
    {
        Caption = 'Unsubscribed';
    }
}