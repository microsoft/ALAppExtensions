// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

dotnet
{
    assembly("Microsoft.Dynamics.Nav.AzureKeyVaultClient")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.AzureKeyVaultClient.AzureKeyVaultClientHelper"; "AzureKeyVaultClientHelper")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.Ncl")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Runtime.Encryption.IAzureKeyVaultSecretProvider"; "IAzureKeyVaultSecretProvider")
        {
        }
    }
}