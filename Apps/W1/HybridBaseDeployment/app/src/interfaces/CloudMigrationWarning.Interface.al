// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration;

interface "Cloud Migration Warning"
{
    procedure CheckWarning(): Boolean;
    procedure FixWarning();
    procedure ShowWarning(var CloudMigrationWarning: Record "Cloud Migration Warning"): Text;
    procedure GetWarningMessage(): Text[1024];
    procedure GetWarningCount(): Integer;
}