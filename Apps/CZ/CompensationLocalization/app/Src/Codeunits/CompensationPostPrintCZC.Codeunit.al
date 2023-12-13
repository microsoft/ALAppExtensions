// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

codeunit 31265 "Compensation - Post Print CZC"
{
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    begin
        CompensationHeaderCZC.Copy(Rec);
        Code();
        Rec := CompensationHeaderCZC;
    end;

    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        WithoutConfirmation: Boolean;

    procedure PostWithoutConfirmation(var PostedCompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        WithoutConfirmation := true;
        CompensationHeaderCZC.Copy(PostedCompensationHeaderCZC);
        Code();
        PostedCompensationHeaderCZC := CompensationHeaderCZC;
    end;

    local procedure Code()
    begin
        if WithoutConfirmation then
            Codeunit.Run(Codeunit::"Compensation - Post CZC", CompensationHeaderCZC)
        else
            Codeunit.Run(Codeunit::"Compensation - Post Yes/No CZC", CompensationHeaderCZC);

        GetReport(CompensationHeaderCZC);
        Commit();
    end;

    procedure GetReport(var PrintedCompensationHeaderCZC: Record "Compensation Header CZC")
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        PostedCompensationHeaderCZC.Get(PrintedCompensationHeaderCZC."No.");
        PostedCompensationHeaderCZC.SetRecFilter();
        PostedCompensationHeaderCZC.PrintRecords(false);
    end;
}
