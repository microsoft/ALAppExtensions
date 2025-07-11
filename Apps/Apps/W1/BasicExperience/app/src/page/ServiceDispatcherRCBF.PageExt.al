// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using Microsoft.Service.RoleCenters;

pageextension 20655 "Service Dispatcher RC BF" extends "Service Dispatcher Role Center"
{
    actions
    {
        modify("Sales Or&der")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}