// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

using System.Threading;

codeunit 4707 "VAT Group Sub. Status JobQueue"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"VAT Group Submission Status");
    end;
}