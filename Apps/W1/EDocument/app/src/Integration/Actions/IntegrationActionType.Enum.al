// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument.Integration.Interfaces;

/// <summary>
/// Type of actions that can be performed on an E-Document
/// Actions are invoked using the InvokeAction method in Integration Management
/// </summary>
enum 6170 "Integration Action Type" implements IDocumentAction
{
    Access = Public;
    Extensible = true;

    value(0; "No Action")
    {
        Implementation = IDocumentAction = "Empty Integration Action";
    }
    value(1; "Sent Document Approval")
    {
        Implementation = IDocumentAction = "Sent Document Approval";
    }
    value(2; "Sent Document Cancellation")
    {
        Implementation = IDocumentAction = "Sent Document Cancellation";
    }

}