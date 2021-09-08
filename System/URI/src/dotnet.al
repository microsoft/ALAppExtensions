// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("System")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Uri"; "Uri")
        {
        }

        type("System.UriBuilder"; "UriBuilder")
        {
        }

        type("System.UriKind"; "UriKind")
        {
        }

        type("System.UriPartial"; "UriPartial")
        {
        }
    }
}
