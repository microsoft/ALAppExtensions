// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Library;

dotnet
{
    assembly("MockTest")
    {
        type("MockTest.MockAzureKeyVaultSecret.MockAzureKeyVaultSecretProvider"; "MockAzureKeyVaultSecretProvider")
        {
        }
    }
}