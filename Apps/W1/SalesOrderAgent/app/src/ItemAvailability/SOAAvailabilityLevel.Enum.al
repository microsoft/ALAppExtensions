// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

enum 4592 "SOA Availability Level"
{
    Access = Internal;
    Extensible = false;

    value(0; "Out of stock")
    {
        Caption = 'Out of stock';
    }
    value(1; Limited)
    {
        Caption = 'Limited';
    }
    value(2; Available)
    {
        Caption = 'Available';
    }
}