// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.Finance.Deferral;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Attachment;
using Microsoft.Integration.Entity;
using System.Agents;
using System.Diagnostics;
using System.Security.AccessControl;
using System.Utilities;

/// <summary>
/// The permissionset that the agent will be assigned to when they are created in the system. This permissionset is used to give the agent access to the pages and actions that are needed to perform their tasks.
/// </summary>
permissionset 3303 "Payables Ag. - Run"
{
    Caption = 'Payables Agent - Run', Comment = 'Payables Agent is a term, and should not be translated.';
    Assignable = true;
    IncludedPermissionSets =
        // Basic permissions to access the system
        "D365 Basic - Read",
        "D365 READ",
        "LOCAL",
        // Permissions to be able to interact with e-documents and create purchase documents
        "D365 PURCH DOC, EDIT",
        "D365 VENDOR, EDIT",
        "E-Doc. Core - User";

    Permissions =
        // Missing permissions to create purchase documents
        tabledata "Error Message" = IMD,
        tabledata "Purch. Inv. Entity Aggregate" = IMD,
        tabledata "Document Attachment" = IMD,
        tabledata "Deferral Header" = IMD,
        tabledata "Deferral Line" = IMD,
        tabledata "Dimension Set Entry" = im,
        tabledata "Dimension Set Tree Node" = im,
    // Change Log
    tabledata "Change Log Entry" = i, // Needed when the customer has Change Log or Monitor Sensitive Fields enabled for tables the agent writes to (e.g. User Environment Login on login)
    // Other
    tabledata "Agent Task Message" = R, // Needed to add the filter of the e-documents that are available for the current session of the agent
    tabledata "Agent Task" = RM; // Needed to read the agent task from the inbound e-document page and update the agent task title when the agent picks up an e-document

    ExcludedPermissionSets =
        // Permissions that are not needed for the agent to perform their tasks
        "Payables Ag. - Excluded";
}