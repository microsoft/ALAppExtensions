// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;

/// <summary>
/// Exposes the functionality to handle recommended actions on the error messages page.
/// </summary>
codeunit 7900 ErrorMessagesActionHandler
{
    Access = Public;

    var
        ErrorMessagesActionHandlerImpl: Codeunit ErrorMessagesActionHandlerImpl;

    /// <summary>
    /// Drill down to the recommended action of an error message to execute it with a confirmation dialog box.
    /// </summary>
    /// <param name="ErrorMessage">Selected error message record is passed to get the action implementation properties and update the message status after executing the action.</param>
    procedure OnActionDrillDown(var ErrorMessage: Record "Error Message")
    begin
        ErrorMessagesActionHandlerImpl.OnRecommendedActionDrillDown(ErrorMessage);
    end;

    /// <summary>
    /// Execute recommended actions for all the selected error messages on the page.
    /// </summary>
    /// <param name="ErrorMessages">Selected error messages are passed from the page to get the action implementation properties and update the message status for each message after executing the actions.</param>
    procedure ExecuteActions(var ErrorMessages: Record "Error Message" temporary)
    begin
        ErrorMessagesActionHandlerImpl.ExecuteActions(ErrorMessages);
    end;
}