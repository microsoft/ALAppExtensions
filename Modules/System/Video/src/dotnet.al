// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("Microsoft.Dynamics.Nav.Client.WebPageViewer")
    {
        Culture = 'neutral';

        type("Microsoft.Dynamics.Nav.Client.WebPageViewer.IWebPageViewer"; WebPageViewer)
        {
            IsControlAddIn = true;
        }
    }
}
