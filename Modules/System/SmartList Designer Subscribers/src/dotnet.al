#if not CLEAN19
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("Microsoft.Dynamics.Nav.Ncl")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Runtime.QueryPage.AL.ALQueryNavigationValidator"; ALQueryNavigationValidator)
        {
        }

        type("Microsoft.Dynamics.Nav.Runtime.QueryPage.AL.ALQueryNavigationValidationResult"; ALQueryNavigationValidationResult)
        {
        }

        type("Microsoft.Dynamics.Nav.Runtime.QueryPage.AL.ALQueryNavigationValidationArgs"; ALQueryNavigationValidationArgs)
        {
        }
    }
}
#endif