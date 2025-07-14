// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

/// <summary>
/// Enumeration for Avalara Send Mode.
/// Object name is kept for backward compatibility with previous app dependency. 
/// </summary>
enum 6373 "Avalara Send Mode"
{
    Extensible = false;

    value(0; Production)
    {
        Caption = 'Production';
    }
    value(1; Test)
    {
        Caption = 'Test';
    }
    value(2; Certification)
    {
        Caption = 'Certification';
    }
}