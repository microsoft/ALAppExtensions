// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;

/// <summary>
/// Default Integration Actions that framework provides.
/// </summary>
interface ISentDocumentActions
{

    /// <summary>
    /// Sends an outgoing E-Document approval request to the API to check if the sent document is approved.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document to be approved.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service used for the API interaction.</param>
    /// <param name="ActionContext">The action context interface used for managing HTTP requests and responses.</param>
    /// <returns>Returns true if the document approval request should update the E-Document status; otherwise, false.</returns>
    /// <remarks>
    /// Sends an HTTP request to the API to check if the document was approved by the service. The response is processed to determine whether the status should be updated.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the <c>GetApprovalStatus</c> method:
    /// <code>
    /// procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    /// var
    ///     Request: Codeunit Requests;
    ///     HttpExecutor: Codeunit "Http Executor";
    ///     ResponseContent: Text;
    /// begin
    ///     // Prepare the HTTP request
    ///     Request.Init();
    ///     Request.Authenticate().CreateApprovalRequest(EDocument."Document ID");
    ///     ActionContext.Http().SetHttpRequestMessage(Request.GetRequest());
    ///
    ///     // Execute the HTTP request
    ///     ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, ActionContext.Http().GetHttpResponseMessage());
    ///
    ///     // Process the response to determine the approval status
    ///     if ResponseContent.Contains('approved') then begin
    ///         ActionContext.SetStatus(ActionContext.GetStatus()."Approved");
    ///         exit(true);
    ///     end;
    /// end;
    /// </code>
    /// </example>
    procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean;

    /// <summary>
    /// Sends an outgoing E-Document cancellation request to the API to check if the sent document was canceled.
    /// </summary>
    /// <param name="EDocument">The record representing the E-Document to be canceled.</param>
    /// <param name="EDocumentService">The record representing the E-Document Service used for the API interaction.</param>
    /// <param name="ActionContext">The action context interface used for managing HTTP requests and responses.</param>
    /// <returns>Returns true if the document cancellation request should update the E-Document status; otherwise, false.</returns>
    /// <remarks>
    /// Sends an HTTP request to the API to check if the document was canceled by the service. The response is processed to determine whether the status should be updated.
    /// </remarks>
    /// <example>
    /// This example demonstrates how to implement the <c>GetCancellationStatus</c> method:
    /// <code>
    /// procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    /// var
    ///     Request: Codeunit Requests;
    ///     HttpExecutor: Codeunit "Http Executor";
    ///     ResponseContent: Text;
    /// begin
    ///     // Prepare the HTTP request
    ///     Request.Init();
    ///     Request.Authenticate().CreateCancellationRequest(EDocument."Document ID");
    ///     ActionContext.Http().SetHttpRequestMessage(Request.GetRequest());
    ///
    ///     // Execute the HTTP request
    ///     ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, ActionContext.Http().GetHttpResponseMessage());
    ///
    ///     // Process the response to determine the cancellation status
    ///     if ResponseContent.Contains('canceled') then begin
    ///         ActionContext.SetStatus(ActionContext.GetStatus()."Canceled");
    ///         exit(true);
    ///     end;
    /// end;
    /// </code>
    /// </example>s
    procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean;

}