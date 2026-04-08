// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

profile "Payables Agent"
{
    Caption = 'Payables Agent (Copilot)', Locked = true;
    Description = 'Default role center for Payables Agent';
    ProfileDescription = 'Functionality for the Payables Agent to efficiently process purchase invoices and e-documents.';
    RoleCenter = "Payables Agent RC";
    Customizations = "PA E-Doc. Error Messages Part",
                     "PA E-Doc. Purchase Draft",
                     "PA EDoc Purchase Draft Subform",
                     "PA Inbound E-Documents",
                     "PA Purchase Invoice",
                     "PA Vendor Card",
                     "PA Vendors",
                     "PA Posted Purch. Doc.";
}
