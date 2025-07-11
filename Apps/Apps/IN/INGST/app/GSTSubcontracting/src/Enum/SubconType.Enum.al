// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

enum 18467 "Subcon Type"
{
    Extensible = true;

    value(0; Consume)
    { }
    value(1; RejectVE)
    { }
    value(2; RejectCE)
    { }
    value(3; Receive)
    { }
    value(4; Rework)
    { }
}
