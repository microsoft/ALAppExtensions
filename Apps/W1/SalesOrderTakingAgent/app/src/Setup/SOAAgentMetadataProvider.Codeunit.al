// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Agents;

codeunit 4401 "SOA Agent Metadata Provider" implements IAgentMetadata, IAgentFactory
{
    Access = Internal;

    procedure GetInitials(): Text[4]
    begin
        exit(SOASetup.GetInitials());
    end;

    procedure GetFirstTimeSetupPageId(): Integer
    begin
        // The first time setup page ID is the same as the setup page ID.
        exit(Page::"SOA Setup");
    end;

    procedure GetSetupPageId(): Integer
    begin
        // The first time setup page ID is the same as the setup page ID.
        exit(Page::"SOA Setup");
    end;

    procedure GetSummaryPageId(): Integer
    begin
        // TODO(agents) return the summary page when we have one.
        exit(Page::"SOA Setup");
    end;

    procedure ShowCanCreateAgent(): Boolean
    begin
        exit(SOASetup.AllowCreateNewSOAgent());
    end;

    var
        SOASetup: Codeunit "SOA Setup";

}