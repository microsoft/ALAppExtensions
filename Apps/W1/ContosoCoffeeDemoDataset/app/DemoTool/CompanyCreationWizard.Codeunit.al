#pragma warning disable AA0247
#if not CLEAN26
#pragma warning disable AS0049, AS0072
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

using Microsoft.Utilities;

codeunit 4786 "Company Creation Wizard"
{
    Permissions = tabledata "Assisted Company Setup Status" = rm;
    Access = Internal;
}
#pragma warning restore AS0049, AS0072
#endif
