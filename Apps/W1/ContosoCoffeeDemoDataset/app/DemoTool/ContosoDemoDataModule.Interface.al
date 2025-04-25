// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

interface "Contoso Demo Data Module"
{
    procedure RunConfigurationPage();
    procedure GetDependencies() Dependencies: List of [Enum "Contoso Demo Data Module"];
    procedure CreateSetupData();
    procedure CreateMasterData();
    procedure CreateTransactionalData();
    procedure CreateHistoricalData();
}
