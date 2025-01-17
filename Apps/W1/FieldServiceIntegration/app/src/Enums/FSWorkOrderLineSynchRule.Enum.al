// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

#pragma warning disable AS0130
#pragma warning disable PTE0025
enum 6611 "FS Work Order Line Synch. Rule"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    AssignmentCompatibility = true;
    Extensible = true;

    value(0; LineUsed)
    {
        Caption = 'when work order product/service is used';
    }
    value(1; WorkOrderCompleted)
    {
        Caption = 'when work order is completed';
    }
}