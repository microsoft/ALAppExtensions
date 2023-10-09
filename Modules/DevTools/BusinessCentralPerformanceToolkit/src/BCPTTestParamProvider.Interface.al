// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

interface "BCPT Test Param. Provider"
{
    procedure GetDefaultParameters(): Text[1000];

    procedure ValidateParameters(Params: Text[1000]);
}