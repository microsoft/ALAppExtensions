// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 149000 "BCPT Start Tests"
{
    TableNo = "BCPT Header";
    Access = Internal;

    trigger OnRun();
    begin
        StartBenchmarkTests(Rec);
    end;

    var
        NothingToRunErr: Label 'There is nothing to run.';
        CannotRunMultipleSuitesInParallelErr: Label 'There is already test run in progress. Start this operaiton after that finishes.';

    local procedure StartBenchmarkTests(BCPTHeader: Record "BCPT Header")
    var
        BCPTLine: Record "BCPT Line";
        NoOfInstances: Integer;
        i: integer;
        s: Integer;
    begin
        BCPTHeader.Validate("Started at", CurrentDateTime);
        BCPTHeader.Status := BCPTHeader.Status::Running;
        BCPTHeader."No. of tests running" := 0;
        BCPTHeader.Version += 1;
        BCPTHeader."No. of tests running" := 0;

        BCPTLine.SetRange("BCPT Code", BCPTHeader.Code);
        BCPTLine.SetFilter("Codeunit ID", '<>0');
        BCPTLine.SetRange("Version Filter", BCPTHeader.Version);
        BCPTLine.SetRange("Run in Foreground", false);
        BCPTLine.Locktable();
        if BCPTLine.FindSet() then
            repeat
                NoOfInstances := BCPTLine."No. of Sessions";
                if (NoOfInstances <= 0) or (BCPTHeader.CurrentRunType = BCPTHeader.CurrentRunType::PRT) then
                    NoOfInstances := 1;
                for i := 1 to NoOfInstances do begin
                    StartSession(s, Codeunit::"BCPT Role Wrapper", CompanyName, BCPTLine);
                    BCPTHeader."No. of tests running" += 1;
                end;
                BCPTLine.Status := BCPTLine.Status::Running;
                BCPTLine.Modify();
            until BCPTLine.Next() = 0;
        BCPTHeader.Modify();
        Commit();
        BCPTLine.SetRange("Run in Foreground", true);
        if BCPTLine.FindSet() then
            Codeunit.Run(Codeunit::"BCPT Role Wrapper", BCPTLine);
    end;

    internal procedure StartBCPTSuite(var BCPTHeader: Record "BCPT Header")
    var
        BCPTHeader2: Record "BCPT Header";
        Window: Dialog;
    begin
        // If there is already a suite running, then error
        BCPTHeader2.SetRange(Status, BCPTHeader2.Status::Running);
        if not BCPTHeader2.IsEmpty then
            Error(CannotRunMultipleSuitesInParallelErr);
        Commit();
        Window.Open('Starting background tasks and running any foreground tasks...');
        Codeunit.Run(Codeunit::"BCPT Start Tests", BCPTHeader);
        Window.Close();
        if BCPTHeader.Find() then;
    end;

    internal procedure StopBCPTSuite(var BCPTHeader: Record "BCPT Header")
    begin
        BCPTHeader.Status := BCPTHeader.Status::Cancelled;
        BCPTHeader.Modify();
        Commit();
    end;

    internal procedure StartNextBenchmarkTests(BCPTHeader: Record "BCPT Header")
    var
        BCPTHeader2: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";
    begin
        BCPTHeader2.SetRange(Status, BCPTHeader2.Status::Running);
        BCPTHeader2.SetFilter(Code, '<> %1', BCPTHeader.Code);
        if not BCPTHeader2.IsEmpty() then
            Error(CannotRunMultipleSuitesInParallelErr);

        BCPTHeader.LockTable();
        BCPTHeader.Find();
        if BCPTHeader.Status <> BCPTHeader.Status::Running then begin
            BCPTHeader.Validate("Started at", CurrentDateTime);
            BCPTHeader.Status := BCPTHeader.Status::Running;
            BCPTHeader."No. of tests running" := 0;
            BCPTHeader.Version += 1;
            BCPTHeader."No. of tests running" := 0;
            BCPTHeader.Modify();

            BCPTLine.SetRange("BCPT Code", BCPTHeader.Code);
            if BCPTLine.FindSet(true) then
                repeat
                    BCPTLine.Status := BCPTLine.Status::" ";
                    BCPTLine."Total Duration (ms)" := 0;
                    BCPTLine."No. of Iterations" := 0;
                    BCPTLine."No. of Running Sessions" := 0;
                    BCPTLine."No. of SQL Statements" := 0;
                    //BCPTLine.Version := BCPTHeader.Version;
                    BCPTLine.SetRange("Version Filter", BCPTHeader.Version);
                    BCPTLine.Modify(true);
                until BCPTLine.Next() = 0;
        end;

        BCPTLine.LockTable();
        BCPTLine.SetRange("BCPT Code", BCPTHeader.Code);
        BCPTLine.SetFilter("Codeunit ID", '<>0');
        BCPTLine.SetFilter(Status, '%1 | %2', BCPTLine.Status::" ", BCPTLine.Status::Starting);
        if BCPTLine.FindFirst() then begin
            if BCPTLine."No. of Running Sessions" < BCPTLine."No. of Sessions" then begin
                BCPTHeader."No. of tests running" += 1;
                BCPTLine."No. of Running Sessions" += 1;

                if BCPTLine."No. of Running Sessions" < BCPTLine."No. of Sessions" then
                    BCPTLine.Status := BCPTLine.Status::Starting
                else
                    BCPTLine.Status := BCPTLine.Status::Running;
                BCPTHeader.Modify();
                BCPTLine.Modify();
                Commit();
                BCPTLine.SetRange("Line No.", BCPTLine."Line No.");
                Codeunit.Run(Codeunit::"BCPT Role Wrapper", BCPTLine);

                BCPTLine.LockTable();
                if BCPTLine.Get(BCPTLine."BCPT Code", BCPTLine."Line No.") then;
                if BCPTLine."No. of Running Sessions" = BCPTLine."No. of Sessions" then begin
                    BCPTLine.Status := BCPTLine.Status::Completed;
                    BCPTLine.Modify();
                end;
            end;
            Commit();
        end else
            Error(NothingToRunErr);
    end;
}