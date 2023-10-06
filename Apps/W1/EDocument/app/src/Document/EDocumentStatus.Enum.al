// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

enum 6108 "E-Document Status"
{
    Extensible = true;
    AssignmentCompatibility = true;
    value(0; "In Progress") { Caption = 'In Progress'; }
    value(1; "Processed") { Caption = 'Processed'; }
    value(2; "Error") { Caption = 'Error'; }
}
