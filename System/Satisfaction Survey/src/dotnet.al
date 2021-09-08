// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("Microsoft.Dynamics.Nav.Client.SatisfactionSurvey")
    {
        type("Microsoft.Dynamics.Nav.Client.SatisfactionSurvey.ISatisfactionSurvey"; "Microsoft.Dynamics.Nav.Client.SatisfactionSurvey")
        {
            IsControlAddIn = true;
        }
    }

}