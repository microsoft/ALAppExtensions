// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("Microsoft.Dynamics.Nav.AzureADGraphClient")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.AzureADGraphClient.GraphQuery"; "GraphQuery")
        {
        }
    }

    assembly("mscorlib")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Collections.IEnumerator"; "IEnumerator")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.LicensingService.Model")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.LicensingService.Model.SkuInfo"; "SkuInfo")
        {
        }

        type("Microsoft.Dynamics.Nav.LicensingService.Model.ServicePlanInfo"; "ServicePlanInfo")
        {
        }
    }

}
