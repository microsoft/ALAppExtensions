// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.TestLibraries.AI;

using System.AI;

codeunit 132933 "Azure OpenAI Test Library"
{

    procedure GetAOAIHistory(HistoryLength: Integer; var AOAIChatMessages: Codeunit "AOAI Chat Messages"): JsonArray
    begin
        AOAIChatMessages.SetHistoryLength(HistoryLength);
        exit(AOAIChatMessages.AssembleHistory());
    end;

}