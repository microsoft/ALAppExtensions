// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Jobs;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.NoSeries;

codeunit 5195 "Create Job No Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(Job(), JobNosDescTok, 'PR00010', 'PR99999', '', '', 10, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(JobJournal(), ProjectJournalLbl, 'J00001', 'J01000', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(RecurringJobJournal(), RecurringProjectJournalLbl, 'J01001', 'J02000', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
        ContosoNoSeries.InsertNoSeries(JobWIP(), ProjectWIPLbl, 'WIP00001', 'WIP99999', '', '', 1, Enum::"No. Series Implementation"::Sequence, true);
    end;

    var
        JobsNosTok: Label 'PROJECTS', MaxLength = 20;
        JobNosDescTok: Label 'Projects', MaxLength = 100;
        ProjectJournalTok: Label 'PJNL-GEN', MaxLength = 20, Comment = 'short for Project Journal General';
        ProjectJournalLbl: Label 'Project Journal', MaxLength = 100;
        RecurringProjectJournalTok: Label 'PJNL-REC', MaxLength = 20, Comment = 'short for Recurring Project Journal';
        RecurringProjectJournalLbl: Label 'Recurring Project Journal', MaxLength = 100;
        ProjectWIPTok: Label 'PROJECT-WIP', MaxLength = 20, Comment = 'short for Project Work In Progress';
        ProjectWIPLbl: Label 'Project-WIP', MaxLength = 100, Comment = 'short for Project Work In Progress';

    procedure Job(): Code[20]
    begin
        exit(JobsNosTok);
    end;

    procedure JobJournal(): Code[20]
    begin
        exit(ProjectJournalTok);
    end;

    procedure RecurringJobJournal(): Code[20]
    begin
        exit(RecurringProjectJournalTok);
    end;

    procedure JobWIP(): Code[20]
    begin
        exit(ProjectWIPTok);
    end;
}
