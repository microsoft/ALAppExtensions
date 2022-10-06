// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------


/// <summary>
/// Interface defines methods which all implementations of symmetric algorithms must inherit.
/// </summary>
interface SymmetricAlgorithm
{
    /// <summary>
    /// Initializes a new instance of the SymmetricAlgorithm. 
    /// </summary>    
    internal procedure GetInstance(var DotNetSymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm");

    /// <summary>
    /// Returns Url of the encrypment method used
    /// </summary>
    /// <returns>An string containing the encrypment method Url.</returns>
    internal procedure XmlEncrypmentMethodUrl(): Text;
}