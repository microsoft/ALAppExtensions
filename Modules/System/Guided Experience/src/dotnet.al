// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

dotnet
{
    assembly("Microsoft.Dynamics.Nav.ClientExtensions")
    {
        type("Microsoft.Dynamics.Nav.Client.Capabilities.SpotlightTour"; "SpotlightTour")
        {
        }

        type("Microsoft.Dynamics.Nav.Client.Capabilities.SpotlightTourText"; "SpotlightTourText")
        {
        }

        type("Microsoft.Dynamics.Nav.Client.Capabilities.Tour"; "Tour")
        {
        }
    }
}