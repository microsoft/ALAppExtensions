// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Shared.Error;

using Microsoft.Shared.Error;

enumextension 139620 ErrMsgFixImplementationTestExt extends "Error Msg. Fix Implementation"
{
    value(139620; "Failing Fix")
    {
        Implementation = ErrorMessageFix = FailToFixErrorMessageTest;
    }
}