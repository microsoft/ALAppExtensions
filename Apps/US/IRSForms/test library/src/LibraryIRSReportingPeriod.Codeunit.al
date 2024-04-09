// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 148000 "Library IRS Reporting Period"
{
    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateOneDayReportingPeriod(ReportingDate: Date): Code[20]
    begin
        exit(CreateReportingPeriod(ReportingDate, ReportingDate));
    end;

    procedure CreateReportingPeriod(StartingDate: Date; EndingDate: Date): Code[20]
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod."No." := LibraryUtility.GenerateGUID();
        IRSReportingPeriod.Validate("Starting Date", StartingDate);
        IRSReportingPeriod.Validate("Ending Date", EndingDate);
        IRSReportingPeriod.Insert(true);
        exit(IRSReportingPeriod."No.");
    end;

    procedure GetReportingPeriod(PostingDate: Date): Code[20]
    begin
        exit(GetReportingPeriod(PostingDate, PostingDate));
    end;

    procedure GetReportingPeriod(StartingDate: Date; EndingDate: Date): Code[20]
    var
        IRSReportingPeriod: Codeunit "IRS Reporting Period";
    begin
        exit(IRSReportingPeriod.GetReportingPeriod(StartingDate, EndingDate));
    end;

    procedure RemoveAllReportingPeriodsWithRelatedData()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod.DeleteAll(true);
    end;
}
