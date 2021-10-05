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

        type("Microsoft.Dynamics.Nav.Runtime.Apps.NavAppALInstaller"; "NavAppALInstaller")
        {
        }

        type("Microsoft.Dynamics.Nav.Runtime.ExtensionLicenseInformationProvider"; "ExtensionLicenseInformationProvider")
        {
        }

        type("Microsoft.Dynamics.Nav.Runtime.Apps.ALNavAppOperationInvoker"; "ALNavAppOperationInvoker")
        {
        }

        type("Microsoft.Dynamics.Nav.Runtime.Apps.ALPackageDeploymentSchedule"; "ALPackageDeploymentSchedule")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.ClientExtensions")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Client.Capabilities.AppSource"; "AppSource")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.Types")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Types.NavAppSyncMode"; "ALNavAppSyncMode")
        {
        }
    }
}
