// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

dotnet
{
    assembly("Microsoft.Dynamics.Nav.Types")
    {
        Culture = 'neutral';

        type("Microsoft.Dynamics.Nav.Types.Metadata.NavPageActionAL"; NavPageActionAL)
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.Ncl")
    {
        Culture = 'neutral';

        type("Microsoft.Dynamics.Nav.Runtime.NavPageActionALFunctions"; NavPageActionALFunctions)
        {
        }

        type("Microsoft.Dynamics.Nav.Runtime.NavPageActionALResponse"; NavPageActionALResponse)
        {
        }
    }
}
