// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

enum 6611 "FS Work Order Line Synch. Rule"
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