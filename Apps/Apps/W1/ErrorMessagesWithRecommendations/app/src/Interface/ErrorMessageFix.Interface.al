// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;

/// <summary>
/// An error message fix interface for setting additional properties and executing the fix from error message page.
/// </summary>
interface ErrorMessageFix
{
    /// <summary>
    /// Set error message properties like: title, caption, etc.
    /// It is primarily used to update fields in table extension 7900 "Error Message Ext."
    /// </summary>
    /// <param name="ErrorMessage">Update the extended fields of the error message record.</param>
    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary);

    /// <summary>
    /// Execute this procedure to fix the error. Return the execution status.
    /// If the error is fixed, the error message status will be set to Fixed and the OnSuccessMessage() will be shown.
    /// If the error is not fixed, the error message status will be set to Not Fixed.
    /// </summary>
    /// <param name="ErrorMessage">The error message record provides the necessary information about the error to be able to fix it. This contains the context, source and the sub-context of the error message.</param>
    /// <returns>True if the error is fixed. False if the error is not fixed.</returns>
    procedure OnFixError(ErrorMessage: Record "Error Message" temporary): Boolean;

    /// <summary>
    /// Show a acknowledgement message on successfully fixing the error.
    /// OnFixError and OnSuccessMessage are executed with the same instance of the interface.
    /// This means that the interface can store information from OnFixError() and use it in the OnSuccessMessage().
    /// </summary>
    /// <returns>The text message for showing it to the user.</returns>
    procedure OnSuccessMessage(): Text;
}