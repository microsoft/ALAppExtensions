// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;
enum 7901 "Error Msg. Fix Implementation" implements ErrorMessageFix
{
    Extensible = true;
    DefaultImplementation = ErrorMessageFix = "Default Impl. Error Message";

    value(0; " ")
    {
        // Use the default implementation
    }
    value(1; DimensionCodeSameError)
    {
        Implementation = ErrorMessageFix = "Dimension Code Same Error";
    }
    value(2; DimensionCodeMustBeBlank)
    {
        Implementation = ErrorMessageFix = "Dimension Code Must Be Blank";
    }
    value(3; DimensionCodeSameMissingDimCodeError)
    {
        Implementation = ErrorMessageFix = "Dim. Code Same But Missing Err";
    }
}