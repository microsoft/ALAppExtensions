// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using System.Utilities;

pagecustomization "PA E-Doc. Error Messages Part" customizes "Error Messages Part"
{
    ClearActions = true;
    ClearLayout = true;

    layout
    {
        modify("Message Type")
        {
            Visible = true;
        }
        modify(Description)
        {
            Visible = true;
        }
    }
}