// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

enum 6612 "FS Integration Type"
{
    Extensible = true;

    value(0; Project)
    {
        Caption = 'Projects (default)';
    }
    value(1; Service)
    {
        Caption = 'Service';
    }
    value(2; Both)
    {
        Caption = 'Both';
    }
}
