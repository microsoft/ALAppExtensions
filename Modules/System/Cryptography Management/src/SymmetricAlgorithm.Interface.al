// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

interface SymmetricAlgorithm
{
    internal procedure GetInstance(var DotNetSymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm");
    internal procedure XmlEncrypmentMethodUrl(): Text;
}